import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/features/exams/data/models/exam_model.dart';
import 'package:al_mobdea_admin/features/exams/data/models/exam_question_model.dart';
import 'package:al_mobdea_admin/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_draft_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_question_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_result_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/exam_question_image_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockExamsRemoteDataSource remoteDataSource;
  late ExamsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(tExamModel);
    registerFallbackValue(tExamQuestionModel);
    registerFallbackValue(tExamQuestionImageFile);
    registerFallbackValue(<ExamQuestionModel>[]);
    registerFallbackValue(<String, ExamQuestionImageFile>{});
  });

  setUp(() {
    remoteDataSource = MockExamsRemoteDataSource();
    repository = ExamsRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  const tAppError = AppErrorModel(
    code: 'internal',
    message: 'server error',
    type: AppErrorType.server,
    isRetryable: true,
  );

  final tRemoteException = FirebaseRemoteException(errorModel: tAppError);

  final tUnexpectedError = Exception('boom');

  group('getExams', () {
    test('returns Right with unmodifiable exam entities', () async {
      when(
        () => remoteDataSource.getExams(
          gradeId: any(named: 'gradeId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => [tExamModel]);

      final result = await repository.getExams(gradeId: tGradeId);

      expect(result.isRight(), isTrue);

      final exams = result.fold(
        (AppErrorModel failure) => throw StateError('left'),
        (list) => list,
      );

      expect(exams.single.examId, tExamId);
      expect(exams.single, isA<ExamEntity>());
      expect(
        () => exams.add(tExamEntity),
        throwsUnsupportedError,
      );
    });

    test('returns Left when the data source throws', () async {
      when(
        () => remoteDataSource.getExams(
          gradeId: any(named: 'gradeId'),
          status: any(named: 'status'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.getExams();

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (_) => null), tAppError);
    });

    test('maps unexpected errors to a server/unknown failure', () async {
      when(
        () => remoteDataSource.getExams(
          gradeId: any(named: 'gradeId'),
          status: any(named: 'status'),
        ),
      ).thenThrow(tUnexpectedError);

      final result = await repository.getExams();

      expect(result.isLeft(), isTrue);
    });
  });

  group('streamExams', () {
    test('emits Right for each snapshot', () async {
      when(
        () => remoteDataSource.streamExams(
          gradeId: any(named: 'gradeId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) => Stream.value([tExamModel]));

      final stream = repository.streamExams();

      await expectLater(
        stream,
        emits(
          predicate<Either<AppErrorModel, List<ExamEntity>>>((either) {
            return either.fold(
              (_) => false,
              (exams) => exams.single.examId == tExamId,
            );
          }),
        ),
      );
    });

    test('emits Left when the stream errors', () async {
      when(
        () => remoteDataSource.streamExams(
          gradeId: any(named: 'gradeId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) => Stream.error(tRemoteException));

      final stream = repository.streamExams();

      await expectLater(
        stream,
        emits(isA<Left<AppErrorModel, List<ExamEntity>>>()),
      );
    });
  });

  group('getExamById', () {
    test('returns Right with the exam entity including questions', () async {
      when(
        () => remoteDataSource.getExamById(examId: any(named: 'examId')),
      ).thenAnswer((_) async => tExamModel);

      final result = await repository.getExamById(examId: tExamId);

      final exam = result.fold(
        (AppErrorModel failure) => throw StateError('left'),
        (e) => e,
      );

      expect(exam.examId, tExamId);
      expect(exam.questions.single.questionId, tExamQuestionId);
    });

    test('returns Left when the data source throws', () async {
      when(
        () => remoteDataSource.getExamById(examId: any(named: 'examId')),
      ).thenThrow(tRemoteException);

      final result = await repository.getExamById(examId: tExamId);

      expect(result.isLeft(), isTrue);
    });
  });

  group('createExam', () {
    final tExamDraft = ExamDraftEntity(
      examName: tExamName,
      gradeId: tGradeId,
      durationMinutes: tExamDurationMinutes,
      status: ExamStatus.unpublished,
    );

    test(
        'builds the exam model from the draft, computes totalScore, and returns the id',
        () async {
      when(
        () => remoteDataSource.createExam(
          exam: any(named: 'exam'),
          questions: any(named: 'questions'),
          questionImages: any(named: 'questionImages'),
        ),
      ).thenAnswer((_) async => tExamId);

      final result = await repository.createExam(
        examDraft: tExamDraft,
        questions: [tExamQuestionEntity],
        questionImages: {tExamQuestionId: tExamQuestionImageFile},
      );

      expect(result, equals(const Right<AppErrorModel, String>(tExamId)));

      final capturedExam = verify(
        () => remoteDataSource.createExam(
          exam: captureAny(named: 'exam'),
          questions: captureAny(named: 'questions'),
          questionImages: any(named: 'questionImages'),
        ),
      ).captured[0] as ExamModel;

      expect(capturedExam.gradeId, tGradeId);
      expect(capturedExam.examName, tExamName);
      expect(capturedExam.durationMinutes, tExamDurationMinutes);
      expect(capturedExam.questionCount, 1);
      expect(capturedExam.totalScore, tExamTotalScore);
      expect(capturedExam.status, ExamStatus.unpublished);
      expect(capturedExam.participantsCount, 0);
    });

    test('returns Left when the data source throws', () async {
      when(
        () => remoteDataSource.createExam(
          exam: any(named: 'exam'),
          questions: any(named: 'questions'),
          questionImages: any(named: 'questionImages'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.createExam(
        examDraft: tExamDraft,
        questions: [tExamQuestionEntity],
        questionImages: {},
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('createQuestion', () {
    test('returns Right with the created question entity', () async {
      when(
        () => remoteDataSource.createQuestion(
          examId: any(named: 'examId'),
          question: any(named: 'question'),
          image: any(named: 'image'),
        ),
      ).thenAnswer((_) async => tExamQuestionModel);

      final result = await repository.createQuestion(
        examId: tExamId,
        question: tExamQuestionEntity,
        image: tExamQuestionImageFile,
      );

      final question = result.fold(
        (AppErrorModel failure) => throw StateError('left'),
        (q) => q,
      );

      expect(question.questionId, tExamQuestionId);
      expect(question, isA<ExamQuestionEntity>());
    });

    test('returns Left when the data source throws', () async {
      when(
        () => remoteDataSource.createQuestion(
          examId: any(named: 'examId'),
          question: any(named: 'question'),
          image: any(named: 'image'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.createQuestion(
        examId: tExamId,
        question: tExamQuestionEntity,
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('updateExam', () {
    test('returns Right(unit) and forwards the exam model', () async {
      when(
        () => remoteDataSource.updateExam(exam: any(named: 'exam')),
      ).thenAnswer((_) async {});

      final result = await repository.updateExam(exam: tExamEntity);

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));

      final captured = verify(
        () => remoteDataSource.updateExam(exam: captureAny(named: 'exam')),
      ).captured.single as ExamModel;

      expect(captured.examId, tExamId);
      expect(captured.examName, tExamName);
    });

    test('returns Left when the data source throws', () async {
      when(
        () => remoteDataSource.updateExam(exam: any(named: 'exam')),
      ).thenThrow(tRemoteException);

      final result = await repository.updateExam(exam: tExamEntity);

      expect(result.isLeft(), isTrue);
    });
  });

  group('deleteExam', () {
    test('returns Right(unit) on success', () async {
      when(
        () => remoteDataSource.deleteExam(examId: any(named: 'examId')),
      ).thenAnswer((_) async {});

      final result = await repository.deleteExam(examId: tExamId);

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
    });

    test('returns Left when the data source throws', () async {
      when(
        () => remoteDataSource.deleteExam(examId: any(named: 'examId')),
      ).thenThrow(tRemoteException);

      final result = await repository.deleteExam(examId: tExamId);

      expect(result.isLeft(), isTrue);
    });
  });

  group('updateQuestion', () {
    test('returns Right(unit) and forwards image flags', () async {
      when(
        () => remoteDataSource.updateQuestion(
          question: any(named: 'question'),
          newImage: any(named: 'newImage'),
          removeCurrentImage: any(named: 'removeCurrentImage'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.updateQuestion(
        question: tExamQuestionEntity,
        newImage: tExamQuestionImageFile,
        removeCurrentImage: false,
      );

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));

      final capturedQuestion = verify(
        () => remoteDataSource.updateQuestion(
          question: captureAny(named: 'question'),
          newImage: tExamQuestionImageFile,
          removeCurrentImage: false,
        ),
      ).captured.single as ExamQuestionModel;

      expect(capturedQuestion.questionId, tExamQuestionId);
    });

    test('returns Left when the data source throws', () async {
      when(
        () => remoteDataSource.updateQuestion(
          question: any(named: 'question'),
          newImage: any(named: 'newImage'),
          removeCurrentImage: any(named: 'removeCurrentImage'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.updateQuestion(
        question: tExamQuestionEntity,
        removeCurrentImage: true,
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('deleteQuestion', () {
    test('returns Right(unit) on success', () async {
      when(
        () => remoteDataSource.deleteQuestion(
          examId: any(named: 'examId'),
          questionId: any(named: 'questionId'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.deleteQuestion(
        examId: tExamId,
        questionId: tExamQuestionId,
      );

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
    });

    test('returns Left when the data source throws', () async {
      when(
        () => remoteDataSource.deleteQuestion(
          examId: any(named: 'examId'),
          questionId: any(named: 'questionId'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.deleteQuestion(
        examId: tExamId,
        questionId: tExamQuestionId,
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('getExamResults', () {
    test('returns Right with result entities', () async {
      when(
        () => remoteDataSource.getExamResults(
          examId: any(named: 'examId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => [tExamResultModel]);

      final result = await repository.getExamResults(examId: tExamId);

      final results = result.fold(
        (AppErrorModel failure) => throw StateError('left'),
        (r) => r,
      );

      expect(results.single.resultId, tExamResultId);
      expect(results.single, isA<ExamResultEntity>());
      expect(
        () => results.add(tExamResultEntity),
        throwsUnsupportedError,
      );
    });

    test('returns Left when the data source throws', () async {
      when(
        () => remoteDataSource.getExamResults(
          examId: any(named: 'examId'),
          status: any(named: 'status'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.getExamResults(examId: tExamId);

      expect(result.isLeft(), isTrue);
    });
  });

  group('streamExamResults', () {
    test('emits Right for each snapshot', () async {
      when(
        () => remoteDataSource.streamExamResults(
          examId: any(named: 'examId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) => Stream.value([tExamResultModel]));

      final stream = repository.streamExamResults(examId: tExamId);

      await expectLater(
        stream,
        emits(
          predicate<Either<AppErrorModel, List<ExamResultEntity>>>((either) {
            return either.fold(
              (_) => false,
              (results) => results.single.resultId == tExamResultId,
            );
          }),
        ),
      );
    });

    test('emits Left when the stream errors', () async {
      when(
        () => remoteDataSource.streamExamResults(
          examId: any(named: 'examId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) => Stream.error(tRemoteException));

      final stream = repository.streamExamResults(examId: tExamId);

      await expectLater(
        stream,
        emits(isA<Left<AppErrorModel, List<ExamResultEntity>>>()),
      );
    });
  });

  group('FirebaseErrorHandler mapping', () {
    test('maps a raw FirebaseException into a Left failure', () async {
      when(
        () => remoteDataSource.getExamById(examId: any(named: 'examId')),
      ).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        ),
      );

      final result = await repository.getExamById(examId: tExamId);

      final failure = result.fold((l) => l, (_) => null);

      expect(failure, isNotNull);
      expect(failure!.type, AppErrorType.authorization);
    });
  });
}

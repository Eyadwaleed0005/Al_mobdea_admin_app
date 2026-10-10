import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/features/lesson_exams/data/models/lesson_exam_question_model.dart';
import 'package:al_mobdea_admin/features/lesson_exams/data/repositories/lesson_exam_repository_impl.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/entities/lesson_exam_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockLessonExamsRemoteDataSource remoteDataSource;
  late LessonExamRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(tLessonExamQuestionModel);
    registerFallbackValue(tLessonExamQuestionImageFile);
  });

  setUp(() {
    remoteDataSource = MockLessonExamsRemoteDataSource();
    repository = LessonExamRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );
  });

  const tAppError = AppErrorModel(
    code: 'internal',
    message: 'server error',
    type: AppErrorType.server,
    isRetryable: true,
  );

  final tRemoteException = FirebaseRemoteException(
    errorModel: tAppError,
  );

  group('streamLessonExam', () {
    test('emits Right(LessonExamEntity) with unmodifiable questions',
        () async {
      when(
        () => remoteDataSource.streamQuestions(
          lessonId: any(named: 'lessonId'),
        ),
      ).thenAnswer((_) => Stream.value([tLessonExamQuestionModel]));

      final stream = repository.streamLessonExam(lessonId: tLessonId);

      await expectLater(
        stream,
        emits(
          predicate<Either<AppErrorModel, LessonExamEntity>>(
            (either) {
              return either.fold(
                (_) => false,
                (exam) =>
                    exam.questions.single.questionId ==
                    tLessonExamQuestionId,
              );
            },
          ),
        ),
      );
    });

    test('emits Left(AppErrorModel) when datasource stream throws', () async {
      when(
        () => remoteDataSource.streamQuestions(
          lessonId: any(named: 'lessonId'),
        ),
      ).thenAnswer((_) => Stream.error(tRemoteException));

      final stream = repository.streamLessonExam(lessonId: tLessonId);

      await expectLater(
        stream,
        emits(isA<Left<AppErrorModel, LessonExamEntity>>()),
      );
    });
  });

  group('createQuestion', () {
    test('returns Right(unit) and forwards the question data', () async {
      when(
        () => remoteDataSource.createQuestion(
          question: any(named: 'question'),
          image: any(named: 'image'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.createQuestion(
        lessonId: tLessonId,
        questionText: tLessonExamQuestionText,
        degree: tLessonExamQuestionDegree,
        choices: tLessonExamChoices,
        image: tLessonExamQuestionImageFile,
      );

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
      final capturedQuestion = verify(
        () => remoteDataSource.createQuestion(
          question: captureAny(named: 'question'),
          image: tLessonExamQuestionImageFile,
        ),
      ).captured.single as LessonExamQuestionModel;

      expect(capturedQuestion.questionId, isEmpty);
      expect(capturedQuestion.lessonId, tLessonId);
      expect(capturedQuestion.choices, tLessonExamChoices);
    });

    test('returns Left when datasource throws', () async {
      when(
        () => remoteDataSource.createQuestion(
          question: any(named: 'question'),
          image: any(named: 'image'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.createQuestion(
        lessonId: tLessonId,
        questionText: tLessonExamQuestionText,
        degree: tLessonExamQuestionDegree,
        choices: tLessonExamChoices,
      );

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
        lessonId: tLessonId,
        questionId: tLessonExamQuestionId,
        questionText: tLessonExamQuestionText,
        degree: tLessonExamQuestionDegree,
        choices: tLessonExamChoices,
        newImage: tLessonExamQuestionImageFile,
        removeCurrentImage: true,
      );

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));

      final capturedQuestion = verify(
        () => remoteDataSource.updateQuestion(
          question: captureAny(named: 'question'),
          newImage: tLessonExamQuestionImageFile,
          removeCurrentImage: true,
        ),
      ).captured.single as LessonExamQuestionModel;

      expect(capturedQuestion.questionId, tLessonExamQuestionId);
    });

    test('returns Left when datasource throws', () async {
      when(
        () => remoteDataSource.updateQuestion(
          question: any(named: 'question'),
          newImage: any(named: 'newImage'),
          removeCurrentImage: any(named: 'removeCurrentImage'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.updateQuestion(
        lessonId: tLessonId,
        questionId: tLessonExamQuestionId,
        questionText: tLessonExamQuestionText,
        degree: tLessonExamQuestionDegree,
        choices: tLessonExamChoices,
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('deleteQuestion', () {
    test('returns Right(unit) on success', () async {
      when(
        () => remoteDataSource.deleteQuestion(
          lessonId: any(named: 'lessonId'),
          questionId: any(named: 'questionId'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.deleteQuestion(
        lessonId: tLessonId,
        questionId: tLessonExamQuestionId,
      );

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
    });

    test('returns Left when datasource throws', () async {
      when(
        () => remoteDataSource.deleteQuestion(
          lessonId: any(named: 'lessonId'),
          questionId: any(named: 'questionId'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.deleteQuestion(
        lessonId: tLessonId,
        questionId: tLessonExamQuestionId,
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('saveCorrectAnswers', () {
    test('returns Right(unit) and forwards an unmodifiable answers map',
        () async {
      when(
        () => remoteDataSource.saveCorrectAnswers(
          lessonId: any(named: 'lessonId'),
          correctChoiceIndexes: any(named: 'correctChoiceIndexes'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.saveCorrectAnswers(
        lessonId: tLessonId,
        correctChoiceIndexes: {tLessonExamQuestionId: 1},
      );

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));

      final answers = verify(
        () => remoteDataSource.saveCorrectAnswers(
          lessonId: tLessonId,
          correctChoiceIndexes: captureAny(
            named: 'correctChoiceIndexes',
          ),
        ),
      ).captured.single as Map<String, int>;

      expect(answers[tLessonExamQuestionId], 1);
      expect(
        () => answers[tSecondLessonExamQuestionId] = 2,
        throwsUnsupportedError,
      );
    });

    test('returns Left when datasource throws', () async {
      when(
        () => remoteDataSource.saveCorrectAnswers(
          lessonId: any(named: 'lessonId'),
          correctChoiceIndexes: any(named: 'correctChoiceIndexes'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.saveCorrectAnswers(
        lessonId: tLessonId,
        correctChoiceIndexes: {tLessonExamQuestionId: 1},
      );

      expect(result.isLeft(), isTrue);
    });
  });
}

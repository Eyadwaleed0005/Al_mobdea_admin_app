import 'package:al_mobdea_admin/features/exams/data/data_sources/exams_remote_data_source.dart';
import 'package:al_mobdea_admin/features/exams/data/data_sources/firebase_exams_remote_data_source.dart';
import 'package:al_mobdea_admin/features/exams/data/models/exam_question_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_attempt_status.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/exam_question_image_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockExamQueryService examQueryService;
  late MockExamResultsQueryService examResultsQueryService;
  late MockExamCreationService examCreationService;
  late MockExamUpdateService examUpdateService;
  late MockExamDeletionService examDeletionService;
  late FirebaseExamsRemoteDataSource dataSource;

  setUpAll(() {
    registerFallbackValue(tExamModel);
    registerFallbackValue(tExamQuestionModel);
    registerFallbackValue(tExamQuestionImageFile);
    registerFallbackValue(<ExamQuestionModel>[]);
    registerFallbackValue(<String, ExamQuestionImageFile>{});
  });

  setUp(() {
    examQueryService = MockExamQueryService();
    examResultsQueryService = MockExamResultsQueryService();
    examCreationService = MockExamCreationService();
    examUpdateService = MockExamUpdateService();
    examDeletionService = MockExamDeletionService();

    dataSource = FirebaseExamsRemoteDataSource(
      examQueryService: examQueryService,
      examResultsQueryService: examResultsQueryService,
      examCreationService: examCreationService,
      examUpdateService: examUpdateService,
      examDeletionService: examDeletionService,
    );
  });

  test('implements ExamsRemoteDataSource', () {
    expect(dataSource, isA<ExamsRemoteDataSource>());
  });

  group('read delegation', () {
    test('getExams delegates to the query service', () async {
      when(
        () => examQueryService.getExams(
          gradeId: any(named: 'gradeId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => [tExamModel]);

      final exams = await dataSource.getExams(
        gradeId: tGradeId,
        status: ExamStatus.unpublished,
      );

      expect(exams, [tExamModel]);

      verify(
        () => examQueryService.getExams(
          gradeId: tGradeId,
          status: ExamStatus.unpublished,
        ),
      ).called(1);
    });

    test('streamExams delegates to the query service', () async {
      when(
        () => examQueryService.streamExams(
          gradeId: any(named: 'gradeId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) => Stream.value([tExamModel]));

      await expectLater(
        dataSource.streamExams(gradeId: tGradeId),
        emits([tExamModel]),
      );
    });

    test('getExamById delegates to the query service', () async {
      when(
        () => examQueryService.getExamById(
          examId: any(named: 'examId'),
        ),
      ).thenAnswer((_) async => tExamModel);

      final exam = await dataSource.getExamById(examId: tExamId);

      expect(exam, tExamModel);
      verify(() => examQueryService.getExamById(examId: tExamId))
          .called(1);
    });

    test(
      'getExamResults delegates to the results query service',
      () async {
        when(
          () => examResultsQueryService.getExamResults(
            examId: any(named: 'examId'),
            status: any(named: 'status'),
          ),
        ).thenAnswer((_) async => [tExamResultModel]);

        final results = await dataSource.getExamResults(
          examId: tExamId,
          status: ExamAttemptStatus.submitted,
        );

        expect(results, [tExamResultModel]);
        verify(
          () => examResultsQueryService.getExamResults(
            examId: tExamId,
            status: ExamAttemptStatus.submitted,
          ),
        ).called(1);
      },
    );

    test(
      'streamExamResults delegates to the results query service',
      () async {
        when(
          () => examResultsQueryService.streamExamResults(
            examId: any(named: 'examId'),
            status: any(named: 'status'),
          ),
        ).thenAnswer((_) => Stream.value([tExamResultModel]));

        await expectLater(
          dataSource.streamExamResults(examId: tExamId),
          emits([tExamResultModel]),
        );
      },
    );
  });

  group('write delegation', () {
    test(
      'createExam delegates to the creation service',
      () async {
        when(
          () => examCreationService.createExam(
            exam: any(named: 'exam'),
            questions: any(named: 'questions'),
            questionImages: any(named: 'questionImages'),
          ),
        ).thenAnswer((_) async => tExamId);

        final examId = await dataSource.createExam(
          exam: tExamModel,
          questions: [tExamQuestionModel],
          questionImages: {
            tExamQuestionId: tExamQuestionImageFile,
          },
        );

        expect(examId, tExamId);
        verify(
          () => examCreationService.createExam(
            exam: tExamModel,
            questions: [tExamQuestionModel],
            questionImages: {
              tExamQuestionId: tExamQuestionImageFile,
            },
          ),
        ).called(1);
      },
    );

    test(
      'createQuestion delegates to the creation service',
      () async {
        when(
          () => examCreationService.createQuestion(
            examId: any(named: 'examId'),
            question: any(named: 'question'),
            image: any(named: 'image'),
          ),
        ).thenAnswer((_) async => tExamQuestionModel);

        final question = await dataSource.createQuestion(
          examId: tExamId,
          question: tExamQuestionModel,
          image: tExamQuestionImageFile,
        );

        expect(question, tExamQuestionModel);
        verify(
          () => examCreationService.createQuestion(
            examId: tExamId,
            question: tExamQuestionModel,
            image: tExamQuestionImageFile,
          ),
        ).called(1);
      },
    );

    test('updateExam delegates to the update service', () async {
      when(
        () => examUpdateService.updateExam(
          exam: any(named: 'exam'),
        ),
      ).thenAnswer((_) async {});

      await dataSource.updateExam(exam: tExamModel);

      verify(
        () => examUpdateService.updateExam(exam: tExamModel),
      ).called(1);
    });

    test(
      'updateQuestion delegates to the update service',
      () async {
        when(
          () => examUpdateService.updateQuestion(
            question: any(named: 'question'),
            newImage: any(named: 'newImage'),
            removeCurrentImage: any(named: 'removeCurrentImage'),
          ),
        ).thenAnswer((_) async {});

        await dataSource.updateQuestion(
          question: tExamQuestionModel,
          newImage: tExamQuestionImageFile,
          removeCurrentImage: false,
        );

        verify(
          () => examUpdateService.updateQuestion(
            question: tExamQuestionModel,
            newImage: tExamQuestionImageFile,
            removeCurrentImage: false,
          ),
        ).called(1);
      },
    );

    test(
      'deleteExam delegates to the deletion service',
      () async {
        when(
          () => examDeletionService.deleteExam(
            examId: any(named: 'examId'),
          ),
        ).thenAnswer((_) async {});

        await dataSource.deleteExam(examId: tExamId);

        verify(
          () => examDeletionService.deleteExam(examId: tExamId),
        ).called(1);
      },
    );

    test(
      'deleteQuestion delegates to the deletion service',
      () async {
        when(
          () => examDeletionService.deleteQuestion(
            examId: any(named: 'examId'),
            questionId: any(named: 'questionId'),
          ),
        ).thenAnswer((_) async {});

        await dataSource.deleteQuestion(
          examId: tExamId,
          questionId: tExamQuestionId,
        );

        verify(
          () => examDeletionService.deleteQuestion(
            examId: tExamId,
            questionId: tExamQuestionId,
          ),
        ).called(1);
      },
    );
  });
}

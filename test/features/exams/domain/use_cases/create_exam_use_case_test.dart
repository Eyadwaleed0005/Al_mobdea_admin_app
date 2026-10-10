import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_draft_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_question_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/create_exam_use_case.dart';
import 'package:al_mobdea_admin/features/exams/domain/exam_question_image_file.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockExamsRepository repository;
  late CreateExamUseCase useCase;

  const tExamDraft = ExamDraftEntity(
    examName: tExamName,
    gradeId: tGradeId,
    durationMinutes: tExamDurationMinutes,
    status: ExamStatus.unpublished,
  );

  setUpAll(() {
    registerFallbackValue(tExamDraft);
    registerFallbackValue(<ExamQuestionEntity>[]);
    registerFallbackValue(<String, ExamQuestionImageFile>{});
    registerFallbackValue(tExamQuestionEntity);
    registerFallbackValue(tExamQuestionImageFile);
  });

  setUp(() {
    repository = MockExamsRepository();
    useCase = CreateExamUseCase(examsRepository: repository);
  });

  test(
    'calls repository.createExam with unmodifiable collections',
    () async {
      when(
        () => repository.createExam(
          examDraft: any(named: 'examDraft'),
          questions: any(named: 'questions'),
          questionImages: any(named: 'questionImages'),
        ),
      ).thenAnswer((_) async => Right(tExamId));

      final result = await useCase(
        examDraft: tExamDraft,
        questions: [tExamQuestionEntity],
        questionImages: {
          tExamQuestionId: tExamQuestionImageFile,
        },
      );

      expect(
        result,
        equals(Right<AppErrorModel, String>(tExamId)),
      );

      final captured = verify(
        () => repository.createExam(
          examDraft: captureAny(named: 'examDraft'),
          questions: captureAny(named: 'questions'),
          questionImages: captureAny(named: 'questionImages'),
        ),
      ).captured;

      final questions = captured[1] as List<ExamQuestionEntity>;
      final images =
          captured[2] as Map<String, ExamQuestionImageFile>;

      expect(questions, [tExamQuestionEntity]);
      expect(
        () => questions.add(tExamQuestionEntity),
        throwsUnsupportedError,
      );
      expect(images[tExamQuestionId], tExamQuestionImageFile);
      expect(
        () => images['other'] = tExamQuestionImageFile,
        throwsUnsupportedError,
      );
    },
  );

  test('returns Left when the repository fails', () async {
    const tError = AppErrorModel(
      code: 'internal',
      message: 'server error',
      type: AppErrorType.server,
      isRetryable: true,
    );

    when(
      () => repository.createExam(
        examDraft: any(named: 'examDraft'),
        questions: any(named: 'questions'),
        questionImages: any(named: 'questionImages'),
      ),
    ).thenAnswer((_) async => const Left(tError));

    final result = await useCase(
      examDraft: tExamDraft,
      questions: [tExamQuestionEntity],
      questionImages: {},
    );

    expect(result.isLeft(), isTrue);
  });
}

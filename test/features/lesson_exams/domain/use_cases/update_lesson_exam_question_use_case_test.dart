import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/use_cases/update_lesson_exam_question_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockLessonExamRepository repository;
  late UpdateLessonExamQuestionUseCase useCase;

  const tAppError = AppErrorModel(
    code: 'internal',
    message: 'server error',
    type: AppErrorType.server,
    isRetryable: true,
  );

  setUpAll(() {
    registerFallbackValue(tLessonExamQuestionImageFile);
  });

  setUp(() {
    repository = MockLessonExamRepository();
    useCase = UpdateLessonExamQuestionUseCase(repository);
  });

  test('normalizes strings and forwards image flags', () async {
    when(
      () => repository.updateQuestion(
        lessonId: any(named: 'lessonId'),
        questionId: any(named: 'questionId'),
        questionText: any(named: 'questionText'),
        degree: any(named: 'degree'),
        choices: any(named: 'choices'),
        newImage: any(named: 'newImage'),
        removeCurrentImage: any(named: 'removeCurrentImage'),
      ),
    ).thenAnswer(
      (_) async => const Right<AppErrorModel, Unit>(unit),
    );

    final result = await useCase.call(
      lessonId: '  $tLessonId  ',
      questionId: '  $tLessonExamQuestionId  ',
      questionText: '  Updated?  ',
      degree: tLessonExamQuestionDegree,
      choices: const [' A ', ' B ', ' C ', ' D '],
      newImage: tLessonExamQuestionImageFile,
      removeCurrentImage: true,
    );

    expect(
      result,
      equals(const Right<AppErrorModel, Unit>(unit)),
    );

    verify(
      () => repository.updateQuestion(
        lessonId: tLessonId,
        questionId: tLessonExamQuestionId,
        questionText: 'Updated?',
        degree: tLessonExamQuestionDegree,
        choices: any(
          named: 'choices',
          that: equals(['A', 'B', 'C', 'D']),
        ),
        newImage: tLessonExamQuestionImageFile,
        removeCurrentImage: true,
      ),
    ).called(1);
  });

  test('returns Left when repository fails', () async {
    when(
      () => repository.updateQuestion(
        lessonId: any(named: 'lessonId'),
        questionId: any(named: 'questionId'),
        questionText: any(named: 'questionText'),
        degree: any(named: 'degree'),
        choices: any(named: 'choices'),
        newImage: any(named: 'newImage'),
        removeCurrentImage: any(named: 'removeCurrentImage'),
      ),
    ).thenAnswer(
      (_) async => const Left<AppErrorModel, Unit>(tAppError),
    );

    final result = await useCase.call(
      lessonId: tLessonId,
      questionId: tLessonExamQuestionId,
      questionText: tLessonExamQuestionText,
      degree: tLessonExamQuestionDegree,
      choices: tLessonExamChoices,
    );

    expect(result.isLeft(), isTrue);
    result.fold(
      (error) => expect(error.code, 'internal'),
      (_) => fail('expected Left'),
    );
  });
}

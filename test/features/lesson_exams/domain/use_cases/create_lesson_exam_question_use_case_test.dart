import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/use_cases/create_lesson_exam_question_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockLessonExamRepository repository;
  late CreateLessonExamQuestionUseCase useCase;

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
    useCase = CreateLessonExamQuestionUseCase(repository);
  });

  test('normalizes strings and forwards image file', () async {
    when(
      () => repository.createQuestion(
        lessonId: any(named: 'lessonId'),
        questionText: any(named: 'questionText'),
        degree: any(named: 'degree'),
        choices: any(named: 'choices'),
        image: any(named: 'image'),
      ),
    ).thenAnswer(
      (_) async => const Right<AppErrorModel, Unit>(unit),
    );

    final result = await useCase.call(
      lessonId: '  $tLessonId  ',
      questionText: '  $tLessonExamQuestionText  ',
      degree: tLessonExamQuestionDegree,
      choices: const [' A ', ' B ', ' C ', ' D '],
      image: tLessonExamQuestionImageFile,
    );

    expect(
      result,
      equals(const Right<AppErrorModel, Unit>(unit)),
    );

    verify(
      () => repository.createQuestion(
        lessonId: tLessonId,
        questionText: tLessonExamQuestionText,
        degree: tLessonExamQuestionDegree,
        choices: any(
          named: 'choices',
          that: equals(['A', 'B', 'C', 'D']),
        ),
        image: tLessonExamQuestionImageFile,
      ),
    ).called(1);
  });

  test('returns Left when repository fails', () async {
    when(
      () => repository.createQuestion(
        lessonId: any(named: 'lessonId'),
        questionText: any(named: 'questionText'),
        degree: any(named: 'degree'),
        choices: any(named: 'choices'),
        image: any(named: 'image'),
      ),
    ).thenAnswer(
      (_) async => const Left<AppErrorModel, Unit>(tAppError),
    );

    final result = await useCase.call(
      lessonId: tLessonId,
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

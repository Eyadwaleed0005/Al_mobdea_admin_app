import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/use_cases/delete_lesson_exam_question_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockLessonExamRepository repository;
  late DeleteLessonExamQuestionUseCase useCase;

  setUp(() {
    repository = MockLessonExamRepository();
    useCase = DeleteLessonExamQuestionUseCase(repository);
  });

  test('trims ids and forwards delete request', () async {
    when(
      () => repository.deleteQuestion(
        lessonId: any(named: 'lessonId'),
        questionId: any(named: 'questionId'),
      ),
    ).thenAnswer(
      (_) async => const Right<AppErrorModel, Unit>(unit),
    );

    final result = await useCase.call(
      lessonId: '  $tLessonId  ',
      questionId: '  $tLessonExamQuestionId  ',
    );

    expect(
      result,
      equals(const Right<AppErrorModel, Unit>(unit)),
    );
    verify(
      () => repository.deleteQuestion(
        lessonId: tLessonId,
        questionId: tLessonExamQuestionId,
      ),
    ).called(1);
  });

  test('returns Left when repository fails', () async {
    const tAppError = AppErrorModel(
      code: 'permission-denied',
      message: 'not allowed',
      type: AppErrorType.authorization,
      isRetryable: false,
    );

    when(
      () => repository.deleteQuestion(
        lessonId: any(named: 'lessonId'),
        questionId: any(named: 'questionId'),
      ),
    ).thenAnswer(
      (_) async => const Left<AppErrorModel, Unit>(tAppError),
    );

    final result = await useCase.call(
      lessonId: tLessonId,
      questionId: tLessonExamQuestionId,
    );

    expect(result.isLeft(), isTrue);
    result.fold(
      (error) => expect(error.code, 'permission-denied'),
      (_) => fail('expected Left'),
    );
  });
}

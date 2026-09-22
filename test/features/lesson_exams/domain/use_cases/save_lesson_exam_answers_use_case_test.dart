import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/use_cases/save_lesson_exam_answers_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockLessonExamRepository repository;
  late SaveLessonExamAnswersUseCase useCase;

  const tAppError = AppErrorModel(
    code: 'internal',
    message: 'server error',
    type: AppErrorType.server,
    isRetryable: true,
  );

  setUp(() {
    repository = MockLessonExamRepository();
    useCase = SaveLessonExamAnswersUseCase(repository);
  });

  test(
    'trims ids and forwards an unmodifiable answer map',
    () async {
      when(
        () => repository.saveCorrectAnswers(
          lessonId: any(named: 'lessonId'),
          correctChoiceIndexes: any(
            named: 'correctChoiceIndexes',
          ),
        ),
      ).thenAnswer(
        (_) async => const Right<AppErrorModel, Unit>(unit),
      );

      final result = await useCase.call(
        lessonId: '  $tLessonId  ',
        correctChoiceIndexes: {'  $tLessonExamQuestionId  ': 2},
      );

      expect(
        result,
        equals(const Right<AppErrorModel, Unit>(unit)),
      );

      final capturedAnswers =
          verify(
                () => repository.saveCorrectAnswers(
                  lessonId: tLessonId,
                  correctChoiceIndexes: captureAny(
                    named: 'correctChoiceIndexes',
                  ),
                ),
              ).captured.single
              as Map<String, int>;

      expect(capturedAnswers[tLessonExamQuestionId], 2);
      expect(
        () => capturedAnswers[tSecondLessonExamQuestionId] = 1,
        throwsUnsupportedError,
      );
    },
  );

  test('returns Left when repository fails', () async {
    when(
      () => repository.saveCorrectAnswers(
        lessonId: any(named: 'lessonId'),
        correctChoiceIndexes: any(named: 'correctChoiceIndexes'),
      ),
    ).thenAnswer(
      (_) async => const Left<AppErrorModel, Unit>(tAppError),
    );

    final result = await useCase.call(
      lessonId: tLessonId,
      correctChoiceIndexes: {tLessonExamQuestionId: 1},
    );

    expect(result.isLeft(), isTrue);
    result.fold(
      (error) => expect(error.code, 'internal'),
      (_) => fail('expected Left'),
    );
  });
}

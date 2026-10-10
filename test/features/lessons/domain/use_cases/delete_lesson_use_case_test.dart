import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/delete_lesson_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockLessonsRepository repository;
  late DeleteLessonUseCase useCase;

  setUp(() {
    repository = MockLessonsRepository();
    useCase = DeleteLessonUseCase(repository: repository);
  });

  test('calls deleteLesson on the repository with the given lesson id',
      () async {
    when(
      () => repository.deleteLesson(lessonId: any(named: 'lessonId')),
    ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));

    final result = await useCase.call(lessonId: tLessonId);

    expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
    verify(() => repository.deleteLesson(lessonId: tLessonId)).called(1);
  });

  test('returns Left when the repository fails', () async {
    const tAppError = AppErrorModel(
      code: 'permission-denied',
      message: 'not allowed',
      type: AppErrorType.authorization,
      isRetryable: false,
    );

    when(
      () => repository.deleteLesson(lessonId: any(named: 'lessonId')),
    ).thenAnswer((_) async => const Left<AppErrorModel, Unit>(tAppError));

    final result = await useCase.call(lessonId: tLessonId);

    expect(result.isLeft(), isTrue);
    result.fold(
      (error) => expect(error.code, 'permission-denied'),
      (_) => fail('expected Left'),
    );
  });
}

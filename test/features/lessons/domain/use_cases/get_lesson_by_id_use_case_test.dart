import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/lessons/domain/entities/lesson_entity.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/get_lesson_by_id_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockLessonsRepository repository;
  late GetLessonByIdUseCase useCase;

  setUp(() {
    repository = MockLessonsRepository();
    useCase = GetLessonByIdUseCase(repository: repository);
  });

  test('returns the lesson on success', () async {
    when(
      () => repository.getLessonById(lessonId: any(named: 'lessonId')),
    ).thenAnswer((_) async => Right(tLessonEntity));

    final result = await useCase.call(lessonId: tLessonId);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (lesson) => expect(lesson.lessonId, tLessonId),
    );
    verify(
      () => repository.getLessonById(lessonId: tLessonId),
    ).called(1);
  });

  test('returns Left when the lesson does not exist', () async {
    const tAppError = AppErrorModel(
      code: 'not-found',
      message: 'not found',
      type: AppErrorType.notFound,
      isRetryable: false,
    );

    when(
      () => repository.getLessonById(lessonId: any(named: 'lessonId')),
    ).thenAnswer((_) async => const Left<AppErrorModel, LessonEntity>(tAppError));

    final result = await useCase.call(lessonId: tLessonId);

    expect(result.isLeft(), isTrue);
    result.fold(
      (error) => expect(error.type, AppErrorType.notFound),
      (_) => fail('expected Left'),
    );
  });
}

import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/lessons/domain/entities/lesson_entity.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/get_lessons_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockLessonsRepository repository;
  late GetLessonsUseCase useCase;

  setUp(() {
    repository = MockLessonsRepository();
    useCase = GetLessonsUseCase(repository: repository);
  });

  test('returns the lesson list on success', () async {
    when(
      () => repository.getLessons(
        gradeId: any(named: 'gradeId'),
        isPublished: any(named: 'isPublished'),
      ),
    ).thenAnswer((_) async => Right([tLessonEntity]));

    final result = await useCase.call();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (lessons) => expect(lessons.single.lessonId, tLessonId),
    );
    verify(() => repository.getLessons()).called(1);
  });

  test('forwards the grade and publication filters', () async {
    when(
      () => repository.getLessons(
        gradeId: any(named: 'gradeId'),
        isPublished: any(named: 'isPublished'),
      ),
    ).thenAnswer((_) async => const Right([]));

    await useCase.call(gradeId: tGradeId, isPublished: true);

    verify(
      () => repository.getLessons(gradeId: tGradeId, isPublished: true),
    ).called(1);
  });

  test('returns Left when the repository fails', () async {
    const tAppError = AppErrorModel(
      code: 'unavailable',
      message: 'offline',
      type: AppErrorType.network,
      isRetryable: true,
    );

    when(
      () => repository.getLessons(
        gradeId: any(named: 'gradeId'),
        isPublished: any(named: 'isPublished'),
      ),
    ).thenAnswer((_) async => const Left<AppErrorModel, List<LessonEntity>>(tAppError));

    final result = await useCase.call();

    expect(result.isLeft(), isTrue);
    result.fold(
      (error) => expect(error.code, 'unavailable'),
      (_) => fail('expected Left'),
    );
  });
}

import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/lessons/domain/entities/lesson_entity.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/stream_lessons_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockLessonsRepository repository;
  late StreamLessonsUseCase useCase;

  setUp(() {
    repository = MockLessonsRepository();
    useCase = StreamLessonsUseCase(repository: repository);
  });

  test('returns the repository stream on success', () async {
    when(
      () => repository.streamLessons(
        gradeId: any(named: 'gradeId'),
        isPublished: any(named: 'isPublished'),
      ),
    ).thenAnswer((_) => Stream.value(Right([tLessonEntity])));

    final stream = useCase.call();

    await expectLater(
      stream,
      emits(
        isA<Right<AppErrorModel, List<dynamic>>>().having(
          (either) => either
              .getOrElse(() => <LessonEntity>[])
              .single
              .lessonId,
          'lessonId',
          tLessonId,
        ),
      ),
    );
    verify(() => repository.streamLessons()).called(1);
  });

  test('forwards the grade and publication filters', () async {
    when(
      () => repository.streamLessons(
        gradeId: any(named: 'gradeId'),
        isPublished: any(named: 'isPublished'),
      ),
    ).thenAnswer((_) => const Stream.empty());

    useCase.call(gradeId: tGradeId, isPublished: false);

    verify(
      () => repository.streamLessons(gradeId: tGradeId, isPublished: false),
    ).called(1);
  });  test('emits Left when the repository stream errors', () async {
    const tAppError = AppErrorModel(
      code: 'unavailable',
      message: 'offline',
      type: AppErrorType.network,
      isRetryable: true,
    );

    when(
      () => repository.streamLessons(
        gradeId: any(named: 'gradeId'),
        isPublished: any(named: 'isPublished'),
      ),
    ).thenAnswer((_) => Stream.value(Left<AppErrorModel, List<LessonEntity>>(tAppError)));

    final stream = useCase.call();

    await expectLater(
      stream,
      emits(isA<Left<AppErrorModel, List<dynamic>>>()),
    );
  });
}

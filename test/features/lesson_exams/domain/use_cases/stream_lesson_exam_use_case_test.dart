import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/entities/lesson_exam_entity.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/use_cases/stream_lesson_exam_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockLessonExamRepository repository;
  late StreamLessonExamUseCase useCase;

  setUp(() {
    repository = MockLessonExamRepository();
    useCase = StreamLessonExamUseCase(repository);
  });

  test('trims lessonId and streams repository result', () async {
    when(
      () => repository.streamLessonExam(
        lessonId: any(named: 'lessonId'),
      ),
    ).thenAnswer(
      (_) => Stream.value(
        Right<AppErrorModel, LessonExamEntity>(
          tLessonExamEntity,
        ),
      ),
    );

    final stream = useCase.call(lessonId: '  $tLessonId  ');

    await expectLater(
      stream,
      emits(isA<Right<AppErrorModel, LessonExamEntity>>()),
    );
    verify(
      () => repository.streamLessonExam(lessonId: tLessonId),
    ).called(1);
  });
}

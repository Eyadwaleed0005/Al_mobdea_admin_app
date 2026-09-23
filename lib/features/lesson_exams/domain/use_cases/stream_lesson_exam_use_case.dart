import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/entities/lesson_exam_entity.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/repositories/lesson_exam_repository.dart';
import 'package:dartz/dartz.dart';

class StreamLessonExamUseCase {
  const StreamLessonExamUseCase(this._repository);

  final LessonExamRepository _repository;

  Stream<Either<AppErrorModel, LessonExamEntity>> call({
    required String lessonId,
  }) {
    return _repository.streamLessonExam(
      lessonId: lessonId.trim(),
    );
  }
}

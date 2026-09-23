import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_attempt_status.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_result_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/repositories/exams_repository.dart';
import 'package:dartz/dartz.dart';

class GetExamResultsUseCase {
  const GetExamResultsUseCase({
    required ExamsRepository examsRepository,
  }) : _examsRepository = examsRepository;

  final ExamsRepository _examsRepository;

  Future<Either<AppErrorModel, List<ExamResultEntity>>> call({
    required String examId,
    ExamAttemptStatus? status,
  }) {
    return _examsRepository.getExamResults(
      examId: examId,
      status: status,
    );
  }
}

import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/repositories/exams_repository.dart';
import 'package:dartz/dartz.dart';

class GetExamsUseCase {
  const GetExamsUseCase({
    required ExamsRepository examsRepository,
  }) : _examsRepository = examsRepository;

  final ExamsRepository _examsRepository;

  Future<Either<AppErrorModel, List<ExamEntity>>> call({
    String? gradeId,
    ExamStatus? status,
  }) {
    return _examsRepository.getExams(
      gradeId: gradeId,
      status: status,
    );
  }
}

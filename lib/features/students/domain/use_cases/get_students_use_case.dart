import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/students/domain/entities/student_entity.dart';
import 'package:al_mobdea_admin/features/students/domain/helper/students_filter_helper.dart';
import 'package:al_mobdea_admin/features/students/domain/params/student_params.dart';
import 'package:al_mobdea_admin/features/students/domain/repositories/students_repository.dart';
import 'package:dartz/dartz.dart';

class GetStudentsUseCase {
  final StudentsRepository _studentsRepository;

  const GetStudentsUseCase({required StudentsRepository studentsRepository})
    : _studentsRepository = studentsRepository;

  Future<Either<AppErrorModel, List<StudentEntity>>> call({
    required StudentsFilterParams params,
  }) async {
    final normalizedGradeId = params.gradeId.trim();

    final result = await _studentsRepository.getStudents(
      gradeId: normalizedGradeId.isEmpty ? null : normalizedGradeId,
    );

    return result.map((students) {
      return StudentsFilterHelper.apply(students: students, params: params);
    });
  }
}

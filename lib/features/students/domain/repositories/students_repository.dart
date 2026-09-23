import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/students/domain/entities/student_entity.dart';
import 'package:dartz/dartz.dart';

abstract class StudentsRepository {
  Future<Either<AppErrorModel, List<StudentEntity>>> getStudents({
    String? gradeId,
  });

  Future<Either<AppErrorModel, StudentEntity>> getStudentById({
    required String studentId,
  });

  Stream<Either<AppErrorModel, List<StudentEntity>>> streamStudents({
    String? gradeId,
  });

  Future<Either<AppErrorModel, Unit>> createStudent({
    required StudentEntity student,
  });

  Future<Either<AppErrorModel, Unit>> updateStudent({
    required StudentEntity student,
  });

  Future<Either<AppErrorModel, Unit>> deleteStudent({
    required String studentId,
  });
}

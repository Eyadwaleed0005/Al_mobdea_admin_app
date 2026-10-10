import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/dashboard/domain/entities/dashboard_students_summary_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class DashboardRepository {
  Future<Either<AppErrorModel, DashboardStudentsSummaryEntity>>
      getStudentsSummary();
}

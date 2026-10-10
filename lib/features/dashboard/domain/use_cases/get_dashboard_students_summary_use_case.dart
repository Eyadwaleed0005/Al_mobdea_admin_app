import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/dashboard/domain/entities/dashboard_students_summary_entity.dart';
import 'package:al_mobdea_admin/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:dartz/dartz.dart';

class GetDashboardStudentsSummaryUseCase {
  const GetDashboardStudentsSummaryUseCase({
    required DashboardRepository dashboardRepository,
  }) : _dashboardRepository = dashboardRepository;

  final DashboardRepository _dashboardRepository;

  Future<Either<AppErrorModel, DashboardStudentsSummaryEntity>>
  call() {
    return _dashboardRepository.getStudentsSummary();
  }
}

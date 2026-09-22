import 'package:al_mobdea_admin/features/dashboard/data/models/dashboard_students_summary_model.dart';

abstract interface class DashboardLocalDataSource {
  Future<void> cacheStudentsSummary({
    required DashboardStudentsSummaryModel summary,
  });

  Future<DashboardStudentsSummaryModel?>
  getCachedStudentsSummary();
}

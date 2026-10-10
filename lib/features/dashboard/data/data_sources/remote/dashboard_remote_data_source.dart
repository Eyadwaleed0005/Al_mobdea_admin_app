import 'package:al_mobdea_admin/features/dashboard/data/models/dashboard_students_summary_model.dart';

abstract interface class DashboardRemoteDataSource {
  Future<DashboardStudentsSummaryModel> getStudentsSummary();
}

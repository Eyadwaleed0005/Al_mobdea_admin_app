import 'package:al_mobdea_admin/features/dashboard/data/models/dashboard_students_summary_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardStudentsSummaryModel', () {
    const tModel = DashboardStudentsSummaryModel(
      totalStudents: 100,
      expiredSubscriptions: 20,
    );

    test('should create model with correct values', () {
      // Assert
      expect(tModel.totalStudents, equals(100));
      expect(tModel.expiredSubscriptions, equals(20));
    });

    test('should create model with different values', () {
      // Arrange
      const model = DashboardStudentsSummaryModel(
        totalStudents: 50,
        expiredSubscriptions: 10,
      );

      // Assert
      expect(model.totalStudents, equals(50));
      expect(model.expiredSubscriptions, equals(10));
    });
  });
}

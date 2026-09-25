import 'package:al_mobdea_admin/core/cache/shared_preferences/shared_preference_keys.dart';
import 'package:al_mobdea_admin/core/cache/shared_preferences/shared_preferences.dart';
import 'package:al_mobdea_admin/features/dashboard/data/data_sources/cache/shared_preferences_dashboard_local_data_source.dart';
import 'package:al_mobdea_admin/features/dashboard/data/models/dashboard_students_summary_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferencesDashboardLocalDataSource dataSource;

  setUp(() {
    dataSource =
        const SharedPreferencesDashboardLocalDataSource();
  });

  group('cacheStudentsSummary', () {
    test(
      'should save summary data to SharedPreferences',
      () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        const tModel = DashboardStudentsSummaryModel(
          totalStudents: 100,
          expiredSubscriptions: 20,
        );

        // Act
        await dataSource.cacheStudentsSummary(summary: tModel);

        // Assert
        final totalStudents =
            await SharedPreferencesHelper.getInt(
              key: SharedPreferenceKeys.dashboardTotalStudents,
            );
        final expiredSubscriptions =
            await SharedPreferencesHelper.getInt(
              key: SharedPreferenceKeys
                  .dashboardExpiredSubscriptions,
            );
        final updatedAt =
            await SharedPreferencesHelper.getString(
              key:
                  SharedPreferenceKeys.dashboardSummaryUpdatedAt,
            );

        expect(totalStudents, equals(100));
        expect(expiredSubscriptions, equals(20));
        expect(updatedAt, isNotNull);
      },
    );
  });

  group('getCachedStudentsSummary', () {
    test(
      'should return cached summary when data exists',
      () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          SharedPreferenceKeys.dashboardTotalStudents: 100,
          SharedPreferenceKeys.dashboardExpiredSubscriptions: 20,
        });

        // Act
        final result = await dataSource
            .getCachedStudentsSummary();

        // Assert
        expect(result, isNotNull);
        expect(result!.totalStudents, equals(100));
        expect(result.expiredSubscriptions, equals(20));
      },
    );

    test(
      'should return null when no cached data exists',
      () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await dataSource
            .getCachedStudentsSummary();

        // Assert
        expect(result, isNull);
      },
    );

    test(
      'should return null when partial cached data exists',
      () async {
        // Arrange - Only one value cached
        SharedPreferences.setMockInitialValues({
          SharedPreferenceKeys.dashboardTotalStudents: 100,
        });

        // Act
        final result = await dataSource
            .getCachedStudentsSummary();

        // Assert
        expect(result, isNull);
      },
    );
  });
}

import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/features/dashboard/data/models/dashboard_students_summary_model.dart';
import 'package:al_mobdea_admin/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:al_mobdea_admin/features/dashboard/domain/entities/dashboard_students_summary_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late DashboardRepositoryImpl repository;
  late MockDashboardRemoteDataSource mockRemoteDataSource;
  late MockDashboardLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockDashboardRemoteDataSource();
    mockLocalDataSource = MockDashboardLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();

    repository = DashboardRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      cacheDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getStudentsSummary', () {
    const tModel = DashboardStudentsSummaryModel(
      totalStudents: 100,
      expiredSubscriptions: 20,
    );

    const tEntity = DashboardStudentsSummaryEntity(
      totalStudents: 100,
      expiredSubscriptions: 20,
    );

    test('should return remote data when call to remote data source is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.getStudentsSummary())
          .thenAnswer((_) async => tModel);
      when(
        () => mockLocalDataSource.cacheStudentsSummary(
          summary: tModel,
        ),
      ).thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.getStudentsSummary();

      // Assert
      verify(() => mockRemoteDataSource.getStudentsSummary())
          .called(1);
      expect(result.isRight(), true);
      result.fold((l) => fail('Should return Right'), (r) {
        expect(r.totalStudents, tEntity.totalStudents);
        expect(
          r.expiredSubscriptions,
          tEntity.expiredSubscriptions,
        );
      });
    });

    test(
      'should cache data when remote call is successful',
      () async {
        // Arrange
        when(() => mockRemoteDataSource.getStudentsSummary())
            .thenAnswer((_) async => tModel);
        when(
          () => mockLocalDataSource.cacheStudentsSummary(
            summary: tModel,
          ),
        ).thenAnswer((_) async => Future.value());

        // Act
        await repository.getStudentsSummary();

        // Assert
        verify(() => mockRemoteDataSource.getStudentsSummary())
            .called(1);
        verify(
          () => mockLocalDataSource.cacheStudentsSummary(
            summary: tModel,
          ),
        ).called(1);
      },
    );

    test('should return cached data when remote call fails and cache is available', () async {
      // Arrange
      const tCachedModel = DashboardStudentsSummaryModel(
        totalStudents: 80,
        expiredSubscriptions: 15,
      );

      when(() => mockRemoteDataSource.getStudentsSummary())
          .thenThrow(
            const FirebaseRemoteException(
              errorModel: AppErrorModel(
                code: 'test-error',
                message: 'Test error',
                type: AppErrorType.network,
                isRetryable: true,
              ),
            ),
          );
      when(() => mockLocalDataSource.getCachedStudentsSummary())
          .thenAnswer((_) async => tCachedModel);

      // Act
      final result = await repository.getStudentsSummary();

      // Assert
      verify(() => mockRemoteDataSource.getStudentsSummary())
          .called(1);
      verify(
        () => mockLocalDataSource.getCachedStudentsSummary(),
      ).called(1);
      expect(result.isRight(), true);
      result.fold((l) => fail('Should return Right'), (r) {
        expect(r.totalStudents, 80);
        expect(r.expiredSubscriptions, 15);
      });
    });

    test('should return zero values when remote call fails and no cache is available', () async {
      // Arrange
      when(() => mockRemoteDataSource.getStudentsSummary())
          .thenThrow(
            const FirebaseRemoteException(
              errorModel: AppErrorModel(
                code: 'test-error',
                message: 'Test error',
                type: AppErrorType.network,
                isRetryable: true,
              ),
            ),
          );
      when(() => mockLocalDataSource.getCachedStudentsSummary())
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.getStudentsSummary();

      // Assert
      verify(() => mockRemoteDataSource.getStudentsSummary())
          .called(1);
      verify(
        () => mockLocalDataSource.getCachedStudentsSummary(),
      ).called(1);
      expect(result.isRight(), true);
      result.fold((l) => fail('Should return Right'), (r) {
        expect(r.totalStudents, 0);
        expect(r.expiredSubscriptions, 0);
      });
    });

    test(
      'should not throw when cache operation fails',
      () async {
        // Arrange
        when(() => mockRemoteDataSource.getStudentsSummary())
            .thenAnswer((_) async => tModel);
        when(
          () => mockLocalDataSource.cacheStudentsSummary(
            summary: tModel,
          ),
        ).thenThrow(Exception('Cache error'));

        // Act
        final result = await repository.getStudentsSummary();

        // Assert
        verify(() => mockRemoteDataSource.getStudentsSummary())
            .called(1);
        expect(result.isRight(), true);
      },
    );

    test(
      'should not throw when get cached data fails',
      () async {
        // Arrange
        when(() => mockRemoteDataSource.getStudentsSummary())
            .thenThrow(
              const FirebaseRemoteException(
                errorModel: AppErrorModel(
                  code: 'test-error',
                  message: 'Test error',
                  type: AppErrorType.network,
                  isRetryable: true,
                ),
              ),
            );
        when(
          () => mockLocalDataSource.getCachedStudentsSummary(),
        ).thenThrow(Exception('Cache read error'));

        // Act
        final result = await repository.getStudentsSummary();

        // Assert
        expect(result.isRight(), true);
        result.fold((l) => fail('Should return Right'), (r) {
          expect(r.totalStudents, 0);
          expect(r.expiredSubscriptions, 0);
        });
      },
    );
  });
}

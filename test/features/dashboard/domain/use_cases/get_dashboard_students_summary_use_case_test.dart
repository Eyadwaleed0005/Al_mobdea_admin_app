import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/dashboard/domain/entities/dashboard_students_summary_entity.dart';
import 'package:al_mobdea_admin/features/dashboard/domain/use_cases/get_dashboard_students_summary_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late GetDashboardStudentsSummaryUseCase useCase;
  late MockDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockDashboardRepository();
    useCase = GetDashboardStudentsSummaryUseCase(
      dashboardRepository: mockRepository,
    );
  });

  group('GetDashboardStudentsSummaryUseCase', () {
    const tEntity = DashboardStudentsSummaryEntity(
      totalStudents: 100,
      expiredSubscriptions: 20,
    );

    test('should return DashboardStudentsSummaryEntity when repository succeeds',
        () async {
      // Arrange
      when(() => mockRepository.getStudentsSummary())
          .thenAnswer((_) async => const Right(tEntity));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.getStudentsSummary()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AppErrorModel when repository fails', () async {
      // Arrange
      const tError = AppErrorModel(
        code: 'test-error',
        message: 'Test error message',
        type: AppErrorType.network,
        isRetryable: true,
      );
      when(() => mockRepository.getStudentsSummary())
          .thenAnswer((_) async => const Left(tError));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isLeft(), true);
      verify(() => mockRepository.getStudentsSummary()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should call repository getStudentsSummary', () async {
      // Arrange
      when(() => mockRepository.getStudentsSummary())
          .thenAnswer((_) async => const Right(tEntity));

      // Act
      await useCase();

      // Assert
      verify(() => mockRepository.getStudentsSummary()).called(1);
    });
  });
}

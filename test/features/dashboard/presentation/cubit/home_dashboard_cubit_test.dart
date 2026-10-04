import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/dashboard/domain/entities/dashboard_students_summary_entity.dart';
import 'package:al_mobdea_admin/features/dashboard/presentation/cubit/home_dashboard_cubit.dart';
import 'package:al_mobdea_admin/features/dashboard/presentation/cubit/home_dashboard_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_helper.dart';

Matcher isLoadedWithSummary({
  required int totalStudents,
  required int expiredSubscriptions,
}) {
  return isA<HomeDashboardLoaded>()
      .having((s) => s.summary.totalStudents, 'totalStudents', totalStudents)
      .having(
        (s) => s.summary.expiredSubscriptions,
        'expiredSubscriptions',
        expiredSubscriptions,
      );
}

void main() {
  late HomeDashboardCubit cubit;
  late MockGetDashboardStudentsSummaryUseCase mockUseCase;
  late MockNetworkStatusCubit mockNetworkStatusCubit;

  const tSummary = DashboardStudentsSummaryEntity(
    totalStudents: 42,
    expiredSubscriptions: 7,
  );

  const tZeroSummary = DashboardStudentsSummaryEntity(
    totalStudents: 0,
    expiredSubscriptions: 0,
  );

  const tError = AppErrorModel(
    code: 'fetch-failed',
    message: 'Failed to fetch students summary',
    type: AppErrorType.network,
    isRetryable: true,
  );

  setUp(() {
    mockUseCase = MockGetDashboardStudentsSummaryUseCase();
    mockNetworkStatusCubit = MockNetworkStatusCubit();

    when(
      () => mockNetworkStatusCubit.checkConnection(
        forceShowOfflineBanner: any(named: 'forceShowOfflineBanner'),
      ),
    ).thenAnswer((_) async {});

    cubit = HomeDashboardCubit(
      getDashboardStudentsSummaryUseCase: mockUseCase,
      networkStatusCubit: mockNetworkStatusCubit,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('HomeDashboardCubit', () {
    test('initial state should be HomeDashboardInitial', () {
      expect(cubit.state, isA<HomeDashboardInitial>());
    });
  });

  group('loadStudentsSummary', () {
    blocTest<HomeDashboardCubit, HomeDashboardState>(
      'emits [HomeDashboardLoading, HomeDashboardLoaded] when use case returns Right(summary)',
      setUp: () {
        when(() => mockUseCase()).thenAnswer((_) async => const Right(tSummary));
      },
      build: () => cubit,
      act: (cubit) => cubit.loadStudentsSummary(),
      expect: () => [
        isA<HomeDashboardLoading>(),
        isLoadedWithSummary(
          totalStudents: tSummary.totalStudents,
          expiredSubscriptions: tSummary.expiredSubscriptions,
        ),
      ],
      verify: (_) {
        verify(() => mockUseCase()).called(1);
        verifyNever(
          () => mockNetworkStatusCubit.checkConnection(
            forceShowOfflineBanner: any(named: 'forceShowOfflineBanner'),
          ),
        );
      },
    );

    blocTest<HomeDashboardCubit, HomeDashboardState>(
      'emits [HomeDashboardLoading, HomeDashboardLoaded(0, 0)] when use case returns Left(error)',
      setUp: () {
        when(() => mockUseCase()).thenAnswer((_) async => const Left(tError));
      },
      build: () => cubit,
      act: (cubit) => cubit.loadStudentsSummary(),
      expect: () => [
        isA<HomeDashboardLoading>(),
        isLoadedWithSummary(
          totalStudents: tZeroSummary.totalStudents,
          expiredSubscriptions: tZeroSummary.expiredSubscriptions,
        ),
      ],
      verify: (_) {
        verify(() => mockUseCase()).called(1);
      },
    );

    blocTest<HomeDashboardCubit, HomeDashboardState>(
      'emits [HomeDashboardLoading, HomeDashboardLoaded(0, 0)] when use case throws an exception',
      setUp: () {
        when(() => mockUseCase()).thenThrow(Exception('Unexpected error'));
      },
      build: () => cubit,
      act: (cubit) => cubit.loadStudentsSummary(),
      expect: () => [
        isA<HomeDashboardLoading>(),
        isLoadedWithSummary(
          totalStudents: tZeroSummary.totalStudents,
          expiredSubscriptions: tZeroSummary.expiredSubscriptions,
        ),
      ],
      verify: (_) {
        verify(() => mockUseCase()).called(1);
      },
    );
  });

  group('refreshStudentsSummary', () {
    const tUpdatedSummary = DashboardStudentsSummaryEntity(
      totalStudents: 50,
      expiredSubscriptions: 10,
    );

    blocTest<HomeDashboardCubit, HomeDashboardState>(
      'triggers network check and emits [HomeDashboardLoaded] when refreshed',
      setUp: () {
        when(
          () => mockNetworkStatusCubit.checkConnection(
            forceShowOfflineBanner: true,
          ),
        ).thenAnswer((_) async {});
        when(() => mockUseCase()).thenAnswer((_) async => const Right(tUpdatedSummary));
      },
      build: () => cubit,
      seed: () => const HomeDashboardLoaded(summary: tSummary),
      act: (cubit) => cubit.refreshStudentsSummary(),
      expect: () => [
        isLoadedWithSummary(
          totalStudents: tUpdatedSummary.totalStudents,
          expiredSubscriptions: tUpdatedSummary.expiredSubscriptions,
        ),
      ],
      verify: (_) {
        verify(
          () => mockNetworkStatusCubit.checkConnection(
            forceShowOfflineBanner: true,
          ),
        ).called(1);
        verify(() => mockUseCase()).called(1);
      },
    );

    blocTest<HomeDashboardCubit, HomeDashboardState>(
      'does NOT overwrite existing loaded state with zero summary when refresh fails',
      setUp: () {
        when(
          () => mockNetworkStatusCubit.checkConnection(
            forceShowOfflineBanner: true,
          ),
        ).thenAnswer((_) async {});
        when(() => mockUseCase()).thenAnswer((_) async => const Left(tError));
      },
      build: () => cubit,
      seed: () => const HomeDashboardLoaded(summary: tSummary),
      act: (cubit) => cubit.refreshStudentsSummary(),
      expect: () => [],
      verify: (_) {
        verify(() => mockUseCase()).called(1);
      },
    );

    blocTest<HomeDashboardCubit, HomeDashboardState>(
      'handles network status check exception gracefully and still loads summary',
      setUp: () {
        when(
          () => mockNetworkStatusCubit.checkConnection(
            forceShowOfflineBanner: true,
          ),
        ).thenThrow(Exception('Network check error'));
        when(() => mockUseCase()).thenAnswer((_) async => const Right(tSummary));
      },
      build: () => cubit,
      act: (cubit) => cubit.refreshStudentsSummary(),
      expect: () => [
        isLoadedWithSummary(
          totalStudents: tSummary.totalStudents,
          expiredSubscriptions: tSummary.expiredSubscriptions,
        ),
      ],
      verify: (_) {
        verify(
          () => mockNetworkStatusCubit.checkConnection(
            forceShowOfflineBanner: true,
          ),
        ).called(1);
        verify(() => mockUseCase()).called(1);
      },
    );
  });
}

import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/result_student/domain/entities/student_exam_results_overview_entity.dart';
import 'package:al_mobdea_admin/features/result_student/presentation/cubit/student_exam_results_cubit.dart';
import 'package:al_mobdea_admin/features/result_student/presentation/cubit/student_exam_results_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late StudentExamResultsCubit cubit;
  late MockGetStudentExamResultsByStudentIdUseCase mockUseCase;

  const tError = AppErrorModel(
    code: 'fetch-failed',
    message: 'Failed to fetch student exam results',
    type: AppErrorType.network,
    isRetryable: true,
  );

  setUp(() {
    mockUseCase = MockGetStudentExamResultsByStudentIdUseCase();
    cubit = StudentExamResultsCubit(getStudentExamResultsByStudentIdUseCase: mockUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  group('StudentExamResultsCubit', () {
    test('initial state should be StudentExamResultsInitial', () {
      expect(cubit.state, isA<StudentExamResultsInitial>());
    });
  });

  group('getStudentExamResultsByStudentId', () {
    blocTest<StudentExamResultsCubit, StudentExamResultsState>(
      'emits [StudentExamResultsLoading, StudentExamResultsSuccess] when use case returns Right(overview) with results',
      setUp: () {
        when(() => mockUseCase(studentId: tResultStudentId))
            .thenAnswer((_) async => Right(tStudentExamResultsOverviewEntity));
      },
      build: () => cubit,
      act: (cubit) => cubit.getStudentExamResultsByStudentId(studentId: tResultStudentId),
      expect: () => [
        isA<StudentExamResultsLoading>(),
        isA<StudentExamResultsSuccess>()
            .having(
              (state) => state.studentExamResultsOverview.studentId,
              'studentId',
              tResultStudentId,
            )
            .having(
              (state) => state.studentExamResultsOverview.studentFullName,
              'studentFullName',
              tStudentName,
            )
            .having(
              (state) => state.studentExamResultsOverview.studentExamResults.length,
              'exam results count',
              2,
            ),
      ],
      verify: (_) {
        verify(() => mockUseCase(studentId: tResultStudentId)).called(1);
      },
    );

    blocTest<StudentExamResultsCubit, StudentExamResultsState>(
      'emits [StudentExamResultsLoading, StudentExamResultsEmpty] when overview has no exams',
      setUp: () {
        const emptyOverview = StudentExamResultsOverviewEntity(
          studentId: tResultStudentId,
          studentFullName: tStudentName,
          studentGradeId: tGradeId,
          studentGradeName: tGradeName,
          isStudentAccountActive: true,
          completedExamsCount: 0,
          totalExamsCount: 4,
          studentExamResults: [],
        );
        when(() => mockUseCase(studentId: tResultStudentId))
            .thenAnswer((_) async => const Right(emptyOverview));
      },
      build: () => cubit,
      act: (cubit) => cubit.getStudentExamResultsByStudentId(studentId: tResultStudentId),
      expect: () => [
        isA<StudentExamResultsLoading>(),
        isA<StudentExamResultsEmpty>().having(
          (state) => state.studentExamResultsOverview.studentExamResults.isEmpty,
          'exam results empty',
          true,
        ),
      ],
      verify: (_) {
        verify(() => mockUseCase(studentId: tResultStudentId)).called(1);
      },
    );

    blocTest<StudentExamResultsCubit, StudentExamResultsState>(
      'emits [StudentExamResultsLoading, StudentExamResultsError] when use case returns Left(error)',
      setUp: () {
        when(() => mockUseCase(studentId: tResultStudentId))
            .thenAnswer((_) async => const Left(tError));
      },
      build: () => cubit,
      act: (cubit) => cubit.getStudentExamResultsByStudentId(studentId: tResultStudentId),
      expect: () => [
        isA<StudentExamResultsLoading>(),
        isA<StudentExamResultsError>()
            .having(
              (state) => state.appErrorModel.message,
              'error message',
              'Failed to fetch student exam results',
            )
            .having((state) => state.appErrorModel.code, 'error code', 'fetch-failed'),
      ],
      verify: (_) {
        verify(() => mockUseCase(studentId: tResultStudentId)).called(1);
      },
    );

    blocTest<StudentExamResultsCubit, StudentExamResultsState>(
      'does not emit new states if cubit is closed',
      setUp: () {
        when(() => mockUseCase(studentId: tResultStudentId)).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return Right(tStudentExamResultsOverviewEntity);
        });
      },
      build: () => cubit,
      act: (cubit) async {
        cubit.getStudentExamResultsByStudentId(studentId: tResultStudentId);
        await cubit.close();
      },
      expect: () => [isA<StudentExamResultsLoading>()],
      verify: (_) {
        verify(() => mockUseCase(studentId: tResultStudentId)).called(1);
      },
    );

    blocTest<StudentExamResultsCubit, StudentExamResultsState>(
      'calculates highest and average percentages correctly',
      setUp: () {
        when(() => mockUseCase(studentId: tResultStudentId))
            .thenAnswer((_) async => Right(tStudentExamResultsOverviewEntity));
      },
      build: () => cubit,
      act: (cubit) => cubit.getStudentExamResultsByStudentId(studentId: tResultStudentId),
      expect: () => [
        isA<StudentExamResultsLoading>(),
        isA<StudentExamResultsSuccess>()
            .having(
              (state) => state.studentExamResultsOverview.highestResultPercentage,
              'highest percentage',
              90.0, // 90/100 = 90%
            )
            .having(
              (state) => state.studentExamResultsOverview.averageResultPercentage,
              'average percentage',
              85.0, // (80 + 90) / 2 = 85%
            ),
      ],
      verify: (_) {
        verify(() => mockUseCase(studentId: tResultStudentId)).called(1);
      },
    );
  });
}

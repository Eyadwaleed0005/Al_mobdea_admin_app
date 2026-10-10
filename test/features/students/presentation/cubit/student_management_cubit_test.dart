import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:al_mobdea_admin/features/students/domain/entities/student_entity.dart';
import 'package:al_mobdea_admin/features/students/domain/params/student_params.dart';
import 'package:al_mobdea_admin/features/students/presentation/cubit/student_management_cubit.dart';
import 'package:al_mobdea_admin/features/students/presentation/cubit/student_management_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStreamStudentsUseCase mockStreamStudentsUseCase;
  late MockStreamGradesUseCase mockStreamGradesUseCase;

  const tError = AppErrorModel(
    code: 'fetch-failed',
    message: 'Failed to fetch students',
    type: AppErrorType.network,
    isRetryable: true,
  );

  setUpAll(() {
    registerFallbackValue(const StudentsFilterParams());
    registerFallbackValue(false);
  });

  setUp(() {
    mockStreamStudentsUseCase = MockStreamStudentsUseCase();
    mockStreamGradesUseCase = MockStreamGradesUseCase();
  });

  StudentManagementCubit buildCubit() {
    return StudentManagementCubit(
      streamStudentsUseCase: mockStreamStudentsUseCase,
      streamGradesUseCase: mockStreamGradesUseCase,
    );
  }

  test('initial state should be StudentManagementInitial', () {
    final cubit = buildCubit();
    expect(cubit.state, equals(const StudentManagementInitial()));
    return cubit.close();
  });

  blocTest<StudentManagementCubit, StudentManagementState>(
    'emits [StudentManagementLoading, StudentManagementLoaded] when both streams emit data',
    setUp: () {
      when(
        () => mockStreamStudentsUseCase(params: any(named: 'params')),
      ).thenAnswer(
        (_) => Stream<Either<AppErrorModel, List<StudentEntity>>>.value(
          Right([tStudentEntity]),
        ),
      );
      when(
        () => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly')),
      ).thenAnswer(
        (_) => Stream<Either<AppErrorModel, List<GradeEntity>>>.value(
          Right([tGradeEntity]),
        ),
      );
    },
    build: buildCubit,
    act: (cubit) => cubit.watchStudentManagement(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<StudentManagementLoading>(),
      isA<StudentManagementLoaded>()
          .having((s) => s.students.length, 'students length', 1)
          .having((s) => s.grades.length, 'grades length', 1),
    ],
  );

  blocTest<StudentManagementCubit, StudentManagementState>(
    'emits [StudentManagementLoading, StudentManagementEmpty] when students stream emits empty list',
    setUp: () {
      when(
        () => mockStreamStudentsUseCase(params: any(named: 'params')),
      ).thenAnswer(
        (_) => Stream<Either<AppErrorModel, List<StudentEntity>>>.value(
          const Right([]),
        ),
      );
      when(
        () => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly')),
      ).thenAnswer(
        (_) => Stream<Either<AppErrorModel, List<GradeEntity>>>.value(
          Right([tGradeEntity]),
        ),
      );
    },
    build: buildCubit,
    act: (cubit) => cubit.watchStudentManagement(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<StudentManagementLoading>(),
      isA<StudentManagementEmpty>(),
    ],
  );

  blocTest<StudentManagementCubit, StudentManagementState>(
    'emits [StudentManagementLoading, StudentManagementFailure] when students stream emits error',
    setUp: () {
      when(
        () => mockStreamStudentsUseCase(params: any(named: 'params')),
      ).thenAnswer(
        (_) => Stream<Either<AppErrorModel, List<StudentEntity>>>.value(
          const Left(tError),
        ),
      );
      when(
        () => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly')),
      ).thenAnswer(
        (_) => Stream<Either<AppErrorModel, List<GradeEntity>>>.value(
          Right([tGradeEntity]),
        ),
      );
    },
    build: buildCubit,
    act: (cubit) => cubit.watchStudentManagement(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<StudentManagementLoading>(),
      isA<StudentManagementFailure>().having(
        (s) => s.error.message,
        'error message',
        'Failed to fetch students',
      ),
    ],
  );
}

import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:al_mobdea_admin/features/students/presentation/cubit/add_student_cubit.dart';
import 'package:al_mobdea_admin/features/students/presentation/cubit/add_student_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockCreateStudentUseCase mockCreateStudentUseCase;
  late MockStreamGradesUseCase mockStreamGradesUseCase;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(false);
  });

  setUp(() {
    mockCreateStudentUseCase = MockCreateStudentUseCase();
    mockStreamGradesUseCase = MockStreamGradesUseCase();
  });

  AddStudentCubit buildCubit() {
    return AddStudentCubit(
      createStudentUseCase: mockCreateStudentUseCase,
      streamGradesUseCase: mockStreamGradesUseCase,
    );
  }

  test('initial state has default AddStudentState', () async {
    final cubit = buildCubit();
    expect(cubit.state.status, equals(AddStudentStatus.idle));
    expect(cubit.state.grades, isEmpty);
    expect(cubit.state.selectedGradeId, isNull);
    await cubit.close();
  });

  test('selectGrade updates selectedGradeId in state', () async {
    final cubit = buildCubit();
    cubit.selectGrade(tGradeId);
    expect(cubit.state.selectedGradeId, equals(tGradeId));
    await cubit.close();
  });

  test('generateStrongPassword sets controllers and flags', () async {
    final cubit = buildCubit();
    cubit.generateStrongPassword();
    expect(cubit.passwordController.text, isNotEmpty);
    expect(
      cubit.confirmPasswordController.text,
      equals(cubit.passwordController.text),
    );
    expect(cubit.state.hasGeneratedPassword, isTrue);
    await cubit.close();
  });

  blocTest<AddStudentCubit, AddStudentState>(
    'watchGrades updates grades when stream emits',
    setUp: () {
      when(
        () => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly')),
      ).thenAnswer(
        (_) => Stream<Either<AppErrorModel, List<GradeEntity>>>.value(
          Right([tGradeEntity]),
        ),
      );
    },
    build: buildCubit,
    act: (cubit) => cubit.watchGrades(),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<AddStudentState>().having((s) => s.grades.length, 'grades', 1),
    ],
  );
}

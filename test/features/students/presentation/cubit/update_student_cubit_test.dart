import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:al_mobdea_admin/features/students/presentation/cubit/update_student_cubit.dart';
import 'package:al_mobdea_admin/features/students/presentation/cubit/update_student_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockGetStudentByIdUseCase mockGetStudentByIdUseCase;
  late MockStreamGradesUseCase mockStreamGradesUseCase;
  late MockUpdateStudentProfileUseCase mockUpdateStudentProfileUseCase;
  late MockUpdateStudentEmailUseCase mockUpdateStudentEmailUseCase;
  late MockUpdateStudentPasswordUseCase mockUpdateStudentPasswordUseCase;
  late MockUpdateStudentSubscriptionUseCase mockUpdateStudentSubscriptionUseCase;
  late MockDeleteStudentUseCase mockDeleteStudentUseCase;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(tStudentEntity);
    registerFallbackValue(false);
  });

  setUp(() {
    mockGetStudentByIdUseCase = MockGetStudentByIdUseCase();
    mockStreamGradesUseCase = MockStreamGradesUseCase();
    mockUpdateStudentProfileUseCase = MockUpdateStudentProfileUseCase();
    mockUpdateStudentEmailUseCase = MockUpdateStudentEmailUseCase();
    mockUpdateStudentPasswordUseCase = MockUpdateStudentPasswordUseCase();
    mockUpdateStudentSubscriptionUseCase = MockUpdateStudentSubscriptionUseCase();
    mockDeleteStudentUseCase = MockDeleteStudentUseCase();

    when(
      () => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly')),
    ).thenAnswer(
      (_) => Stream<Either<AppErrorModel, List<GradeEntity>>>.value(
        Right([tGradeEntity]),
      ),
    );
  });

  UpdateStudentCubit buildCubit() {
    return UpdateStudentCubit(
      studentId: tStudentId,
      getStudentByIdUseCase: mockGetStudentByIdUseCase,
      streamGradesUseCase: mockStreamGradesUseCase,
      updateStudentProfileUseCase: mockUpdateStudentProfileUseCase,
      updateStudentEmailUseCase: mockUpdateStudentEmailUseCase,
      updateStudentPasswordUseCase: mockUpdateStudentPasswordUseCase,
      updateStudentSubscriptionUseCase: mockUpdateStudentSubscriptionUseCase,
      deleteStudentUseCase: mockDeleteStudentUseCase,
    );
  }

  test('initial state has default UpdateStudentState', () async {
    final cubit = buildCubit();
    expect(cubit.state.status, equals(UpdateStudentStatus.initial));
    expect(cubit.state.student, isNull);
    expect(cubit.state.hasChanges, isFalse);
    await cubit.close();
  });

  blocTest<UpdateStudentCubit, UpdateStudentState>(
    'loadStudent loads student and fills controllers',
    setUp: () {
      when(
        () => mockGetStudentByIdUseCase(studentId: tStudentId),
      ).thenAnswer((_) async => Right(tStudentEntity));
    },
    build: buildCubit,
    act: (cubit) => cubit.loadStudent(),
    expect: () => [
      isA<UpdateStudentState>().having(
        (s) => s.status,
        'status',
        UpdateStudentStatus.loading,
      ),
      isA<UpdateStudentState>()
          .having((s) => s.status, 'status', UpdateStudentStatus.ready)
          .having((s) => s.student?.name, 'name', tStudentName),
    ],
    verify: (cubit) {
      expect(cubit.studentNameController.text, equals(tStudentName));
      expect(cubit.emailController.text, equals(tStudentEmail));
      expect(cubit.phoneController.text, equals(tStudentPhone));
    },
  );

  blocTest<UpdateStudentCubit, UpdateStudentState>(
    'deleteStudent emits [deleting, deleteSuccess] on success',
    setUp: () {
      when(
        () => mockGetStudentByIdUseCase(studentId: tStudentId),
      ).thenAnswer((_) async => Right(tStudentEntity));
      when(
        () => mockDeleteStudentUseCase(student: any(named: 'student')),
      ).thenAnswer((_) async => const Right(unit));
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.loadStudent();
      await cubit.deleteStudent();
    },
    skip: 2, // Skip loadStudent states
    expect: () => [
      isA<UpdateStudentState>().having(
        (s) => s.status,
        'status',
        UpdateStudentStatus.deleting,
      ),
      isA<UpdateStudentState>().having(
        (s) => s.status,
        'status',
        UpdateStudentStatus.deleteSuccess,
      ),
    ],
  );
}

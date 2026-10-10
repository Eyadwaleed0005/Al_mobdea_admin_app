import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/students/domain/entities/student_entity.dart';
import 'package:al_mobdea_admin/features/students/domain/params/student_params.dart';
import 'package:al_mobdea_admin/features/students/domain/use_cases/get_students_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStudentsRepository repository;
  late GetStudentsUseCase useCase;

  setUp(() {
    repository = MockStudentsRepository();
    useCase = GetStudentsUseCase(studentsRepository: repository);
  });

  const tParams = StudentsFilterParams();

  test('returns the filtered list of students on success', () async {
    when(
      () => repository.getStudents(gradeId: any(named: 'gradeId')),
    ).thenAnswer(
      (_) async => Right<AppErrorModel, List<StudentEntity>>([tStudentEntity]),
    );

    final result = await useCase.call(params: tParams);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (students) => expect(students.length, 1),
    );
    verify(() => repository.getStudents(gradeId: null)).called(1);
  });

  test('passes a normalized gradeId to the repository', () async {
    when(
      () => repository.getStudents(gradeId: any(named: 'gradeId')),
    ).thenAnswer(
      (_) async => Right<AppErrorModel, List<StudentEntity>>([tStudentEntity]),
    );

    await useCase.call(
      params: const StudentsFilterParams(gradeId: '  grade-1  '),
    );

    verify(() => repository.getStudents(gradeId: 'grade-1')).called(1);
  });

  test('returns Left when the repository fails', () async {
    when(
      () => repository.getStudents(gradeId: any(named: 'gradeId')),
    ).thenAnswer(
      (_) async => Left<AppErrorModel, List<StudentEntity>>(
        const AppErrorModel(
          code: 'internal',
          message: 'error',
          type: AppErrorType.server,
          isRetryable: true,
        ),
      ),
    );

    final result = await useCase.call(params: tParams);

    expect(result.isLeft(), isTrue);
  });
}

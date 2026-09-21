import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/students/domain/use_cases/delete_student_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStudentAuthRepository authRepository;
  late DeleteStudentUseCase useCase;

  setUp(() {
    authRepository = MockStudentAuthRepository();
    useCase = DeleteStudentUseCase(studentAuthRepository: authRepository);
  });

  test('delegates deletion to the auth repository on success', () async {
    when(
      () => authRepository.deleteStudentAccount(
        studentId: any(named: 'studentId'),
      ),
    ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));

    final result = await useCase.call(student: tStudentEntity);

    expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
    verify(
      () => authRepository.deleteStudentAccount(studentId: tStudentEntity.studentId),
    ).called(1);
  });

  test('returns Left when the auth repository fails', () async {
    when(
      () => authRepository.deleteStudentAccount(
        studentId: any(named: 'studentId'),
      ),
    ).thenAnswer(
      (_) async => Left<AppErrorModel, Unit>(
        const AppErrorModel(
          code: 'not-found',
          message: 'error',
          type: AppErrorType.notFound,
          isRetryable: false,
        ),
      ),
    );

    final result = await useCase.call(student: tStudentEntity);

    expect(result.isLeft(), isTrue);
  });
}

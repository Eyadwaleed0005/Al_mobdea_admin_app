import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/students/domain/entities/student_entity.dart';
import 'package:al_mobdea_admin/features/students/domain/use_cases/update_student_status_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStudentsRepository studentsRepository;
  late UpdateStudentStatusUseCase useCase;

  setUpAll(() {
    registerFallbackValue(tStudentEntity);
  });

  setUp(() {
    studentsRepository = MockStudentsRepository();
    useCase = UpdateStudentStatusUseCase(
      studentsRepository: studentsRepository,
    );
  });

  final tError = const AppErrorModel(
    code: 'internal',
    message: 'error',
    type: AppErrorType.server,
    isRetryable: true,
  );

  void stubUpdateSuccess() {
    when(
      () => studentsRepository.updateStudent(
        student: any(named: 'student'),
      ),
    ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));
  }

  test('returns the same student when status is unchanged', () async {
    final result = await useCase.call(
      student: tStudentEntity,
      isActive: true,
    );

    expect(result.isRight(), isTrue);
    verifyNever(
      () => studentsRepository.updateStudent(
        student: any(named: 'student'),
      ),
    );
  });

  test('blocks activation when the subscription has already expired', () async {
    final expiredStudent = tStudentEntity.copyWith(
      isActive: false,
      subscriptionEndAt: DateTime(2000, 1, 1),
    );

    final result = await useCase.call(
      student: expiredStudent,
      isActive: true,
    );

    expect(result.isLeft(), isTrue);
    result.fold(
      (error) => expect(error.code, 'expired-subscription'),
      (_) => fail('expected Left'),
    );
    verifyNever(
      () => studentsRepository.updateStudent(
        student: any(named: 'student'),
      ),
    );
  });

  test('blocks activation when the student has no subscription', () async {
    final studentWithoutSubscription = tStudentEntity.copyWith(
      isActive: false,
      clearSubscriptionDates: true,
    );

    final result = await useCase.call(
      student: studentWithoutSubscription,
      isActive: true,
    );

    expect(result.isLeft(), isTrue);
    verifyNever(
      () => studentsRepository.updateStudent(
        student: any(named: 'student'),
      ),
    );
  });

  test('updates firestore and returns the updated student', () async {
    stubUpdateSuccess();

    final inactiveStudent = tStudentEntity.copyWith(isActive: false);

    final result = await useCase.call(
      student: inactiveStudent,
      isActive: true,
    );

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (student) => expect(student.isActive, isTrue),
    );

    final captured = verify(
      () => studentsRepository.updateStudent(
        student: captureAny(named: 'student'),
      ),
    ).captured;

    final updatedStudent = captured.single as StudentEntity;
    expect(updatedStudent.isActive, isTrue);
  });

  test('deactivates a student without checking the subscription', () async {
    stubUpdateSuccess();

    final result = await useCase.call(
      student: tStudentEntity,
      isActive: false,
    );

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (student) => expect(student.isActive, isFalse),
    );

    verify(
      () => studentsRepository.updateStudent(
        student: any(named: 'student'),
      ),
    ).called(1);
  });

  test('returns Left when the firestore update fails', () async {
    when(
      () => studentsRepository.updateStudent(
        student: any(named: 'student'),
      ),
    ).thenAnswer((_) async => Left<AppErrorModel, Unit>(tError));

    final inactiveStudent = tStudentEntity.copyWith(isActive: false);

    final result = await useCase.call(
      student: inactiveStudent,
      isActive: true,
    );

    expect(result.isLeft(), isTrue);
  });
}

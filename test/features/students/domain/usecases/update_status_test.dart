import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/students/domain/use_cases/update_student_status_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStudentAuthRepository authRepository;
  late MockStudentsRepository studentsRepository;
  late UpdateStudentStatusUseCase useCase;

  setUpAll(() {
    registerFallbackValue(tStudentEntity);
  });

  setUp(() {
    authRepository = MockStudentAuthRepository();
    studentsRepository = MockStudentsRepository();
    useCase = UpdateStudentStatusUseCase(
      studentAuthRepository: authRepository,
      studentsRepository: studentsRepository,
    );
  });

  final tError = const AppErrorModel(
    code: 'internal',
    message: 'error',
    type: AppErrorType.server,
    isRetryable: true,
  );

  // Active student with a future subscription (from dummy_data).
  final tActiveStudent = tStudentEntity;

  test(
    'returns the same student when status is unchanged',
    () async {
      final result = await useCase.call(
        student: tActiveStudent,
        isActive: true,
      );

      expect(result.isRight(), isTrue);
      verifyNever(
        () => authRepository.updateStudentAccountStatus(
          studentId: any(named: 'studentId'),
          isActive: any(named: 'isActive'),
        ),
      );
    },
  );

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
    verifyNever(
      () => authRepository.updateStudentAccountStatus(
        studentId: any(named: 'studentId'),
        isActive: any(named: 'isActive'),
      ),
    );
  });

  test(
    'updates auth then firestore and returns updated student',
    () async {
      final inactiveStudent = tStudentEntity.copyWith(
        isActive: false,
      );

      when(
        () => authRepository.updateStudentAccountStatus(
          studentId: any(named: 'studentId'),
          isActive: any(named: 'isActive'),
        ),
      ).thenAnswer(
        (_) async => const Right<AppErrorModel, Unit>(unit),
      );
      when(
        () => studentsRepository.updateStudent(
          student: any(named: 'student'),
        ),
      ).thenAnswer(
        (_) async => const Right<AppErrorModel, Unit>(unit),
      );

      final result = await useCase.call(
        student: inactiveStudent,
        isActive: true,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (student) => expect(student.isActive, isTrue),
      );
    },
  );

  test(
    'rolls back auth status when firestore update fails',
    () async {
      final inactiveStudent = tStudentEntity.copyWith(
        isActive: false,
      );

      when(
        () => authRepository.updateStudentAccountStatus(
          studentId: any(named: 'studentId'),
          isActive: any(named: 'isActive'),
        ),
      ).thenAnswer(
        (_) async => const Right<AppErrorModel, Unit>(unit),
      );
      when(
        () => studentsRepository.updateStudent(
          student: any(named: 'student'),
        ),
      ).thenAnswer(
        (_) async => Left<AppErrorModel, Unit>(tError),
      );

      final result = await useCase.call(
        student: inactiveStudent,
        isActive: true,
      );

      expect(result.isLeft(), isTrue);
      // Called twice: once to apply, once to roll back.
      verify(
        () => authRepository.updateStudentAccountStatus(
          studentId: any(named: 'studentId'),
          isActive: any(named: 'isActive'),
        ),
      ).called(2);
    },
  );

  test('returns Left when the auth update fails', () async {
    final inactiveStudent = tStudentEntity.copyWith(
      isActive: false,
    );

    when(
      () => authRepository.updateStudentAccountStatus(
        studentId: any(named: 'studentId'),
        isActive: any(named: 'isActive'),
      ),
    ).thenAnswer((_) async => Left<AppErrorModel, Unit>(tError));

    final result = await useCase.call(
      student: inactiveStudent,
      isActive: true,
    );

    expect(result.isLeft(), isTrue);
    verifyNever(
      () => studentsRepository.updateStudent(
        student: any(named: 'student'),
      ),
    );
  });
}

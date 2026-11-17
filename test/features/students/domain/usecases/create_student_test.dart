import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/students/domain/entities/student_entity.dart';
import 'package:al_mobdea_admin/features/students/domain/params/student_params.dart';
import 'package:al_mobdea_admin/features/students/domain/use_cases/create_student_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStudentAuthRepository authRepository;
  late MockStudentsRepository studentsRepository;
  late CreateStudentUseCase useCase;

  setUpAll(() {
    registerFallbackValue(tStudentEntity);
  });

  setUp(() {
    authRepository = MockStudentAuthRepository();
    studentsRepository = MockStudentsRepository();
    useCase = CreateStudentUseCase(
      studentAuthRepository: authRepository,
      studentsRepository: studentsRepository,
    );
  });

  final tParams = CreateStudentParams(
    gradeId: tGradeId,
    name: tStudentName,
    email: tStudentEmail,
    password: 'Str0ng@Pass',
    phoneNumber: tStudentPhone,
    subscriptionStartAt: tSubscriptionStartAt,
    subscriptionEndAt: tSubscriptionEndAt,
  );

  final tError = const AppErrorModel(
    code: 'internal',
    message: 'error',
    type: AppErrorType.server,
    isRetryable: true,
  );

  test(
    'creates auth account then firestore document on success',
    () async {
      when(
        () => authRepository.createStudentAccount(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => Right<AppErrorModel, String>(tStudentId),
      );
      when(
        () => studentsRepository.createStudent(
          student: any(named: 'student'),
        ),
      ).thenAnswer(
        (_) async => const Right<AppErrorModel, Unit>(unit),
      );

      final result = await useCase.call(params: tParams);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (student) => expect(student.studentId, tStudentId),
      );
      verify(
        () => authRepository.createStudentAccount(
          email: tStudentEmail,
          password: 'Str0ng@Pass',
        ),
      ).called(1);

      final captured = verify(
        () => studentsRepository.createStudent(
          student: captureAny(named: 'student'),
        ),
      ).captured;

      final createdStudent = captured.single as StudentEntity;

      expect(createdStudent.studentId, tStudentId);
      expect(createdStudent.isActive, isTrue);
      expect(createdStudent.isLoggedIn, isFalse);
      expect(createdStudent.subscriptionStartAt, tSubscriptionStartAt);
      expect(createdStudent.subscriptionEndAt, tSubscriptionEndAt);
    },
  );

  test(
    'creates an inactive student without subscription dates',
    () async {
      when(
        () => authRepository.createStudentAccount(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => Right<AppErrorModel, String>(tStudentId),
      );
      when(
        () => studentsRepository.createStudent(
          student: any(named: 'student'),
        ),
      ).thenAnswer(
        (_) async => const Right<AppErrorModel, Unit>(unit),
      );

      final result = await useCase.call(
        params: CreateStudentParams(
          gradeId: tGradeId,
          name: tStudentName,
          email: tStudentEmail,
          password: 'Str0ng@Pass',
          phoneNumber: tStudentPhone,
        ),
      );

      expect(result.isRight(), isTrue);

      final captured = verify(
        () => studentsRepository.createStudent(
          student: captureAny(named: 'student'),
        ),
      ).captured;

      final createdStudent = captured.single as StudentEntity;

      expect(createdStudent.subscriptionStartAt, isNull);
      expect(createdStudent.subscriptionEndAt, isNull);
      expect(createdStudent.isActive, isFalse);
    },
  );

  test(
    'returns Left and skips firestore when auth creation fails',
    () async {
      when(
        () => authRepository.createStudentAccount(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => Left<AppErrorModel, String>(tError),
      );

      final result = await useCase.call(params: tParams);

      expect(result.isLeft(), isTrue);
      verifyNever(
        () => studentsRepository.createStudent(
          student: any(named: 'student'),
        ),
      );
    },
  );

  test(
    'rolls back auth account when firestore creation fails',
    () async {
      when(
        () => authRepository.createStudentAccount(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => Right<AppErrorModel, String>(tStudentId),
      );
      when(
        () => studentsRepository.createStudent(
          student: any(named: 'student'),
        ),
      ).thenAnswer(
        (_) async => Left<AppErrorModel, Unit>(tError),
      );
      when(
        () => authRepository.deleteStudentAccount(
          studentId: any(named: 'studentId'),
        ),
      ).thenAnswer(
        (_) async => const Right<AppErrorModel, Unit>(unit),
      );

      final result = await useCase.call(params: tParams);

      expect(result.isLeft(), isTrue);
      verify(
        () => authRepository.deleteStudentAccount(
          studentId: tStudentId,
        ),
      ).called(1);
    },
  );
}

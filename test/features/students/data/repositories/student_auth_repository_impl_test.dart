import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/features/students/data/repositories/student_auth_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late MockStudentAuthRemoteDataSource remoteDataSource;
  late StudentAuthRepositoryImpl repository;

  const tStudentId = 'student-123';
  const tEmail = 'ahmed@example.com';
  const tPassword = 'Str0ng@Pass';

  setUp(() {
    remoteDataSource = MockStudentAuthRemoteDataSource();
    repository = StudentAuthRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  final tRemoteException = FirebaseRemoteException(
    errorModel: const AppErrorModel(
      code: 'unavailable',
      message: 'network error',
      type: AppErrorType.network,
      isRetryable: true,
    ),
  );

  group('createStudentAccount', () {
    test('returns Right(studentId) on success', () async {
      when(
        () => remoteDataSource.createStudentAccount(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => tStudentId);

      final result = await repository.createStudentAccount(
        email: tEmail,
        password: tPassword,
      );

      expect(result, equals(const Right<AppErrorModel, String>(tStudentId)));
    });

    test('returns Left(AppErrorModel) when the datasource throws', () async {
      when(
        () => remoteDataSource.createStudentAccount(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.createStudentAccount(
        email: tEmail,
        password: tPassword,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (error) => expect(error, isA<AppErrorModel>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('updateStudentPassword', () {
    test('returns Right(unit) on success', () async {
      when(
        () => remoteDataSource.updateStudentPassword(
          studentId: any(named: 'studentId'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.updateStudentPassword(
        studentId: tStudentId,
        newPassword: tPassword,
      );

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
    });

    test('returns Left when the datasource throws', () async {
      when(
        () => remoteDataSource.updateStudentPassword(
          studentId: any(named: 'studentId'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.updateStudentPassword(
        studentId: tStudentId,
        newPassword: tPassword,
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('updateStudentEmail', () {
    test('returns Right(unit) on success', () async {
      when(
        () => remoteDataSource.updateStudentEmail(
          studentId: any(named: 'studentId'),
          newEmail: any(named: 'newEmail'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.updateStudentEmail(
        studentId: tStudentId,
        newEmail: tEmail,
      );

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
    });

    test('returns Left when the datasource throws', () async {
      when(
        () => remoteDataSource.updateStudentEmail(
          studentId: any(named: 'studentId'),
          newEmail: any(named: 'newEmail'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.updateStudentEmail(
        studentId: tStudentId,
        newEmail: tEmail,
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('updateStudentAccountStatus', () {
    test('returns Right(unit) on success', () async {
      when(
        () => remoteDataSource.updateStudentAccountStatus(
          studentId: any(named: 'studentId'),
          isActive: any(named: 'isActive'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.updateStudentAccountStatus(
        studentId: tStudentId,
        isActive: true,
      );

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
    });

    test('returns Left when the datasource throws', () async {
      when(
        () => remoteDataSource.updateStudentAccountStatus(
          studentId: any(named: 'studentId'),
          isActive: any(named: 'isActive'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.updateStudentAccountStatus(
        studentId: tStudentId,
        isActive: true,
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('deleteStudentAccount', () {
    test('returns Right(unit) on success', () async {
      when(
        () => remoteDataSource.deleteStudentAccount(
          studentId: any(named: 'studentId'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.deleteStudentAccount(
        studentId: tStudentId,
      );

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
    });

    test('returns Left when the datasource throws', () async {
      when(
        () => remoteDataSource.deleteStudentAccount(
          studentId: any(named: 'studentId'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.deleteStudentAccount(
        studentId: tStudentId,
      );

      expect(result.isLeft(), isTrue);
    });
  });
}

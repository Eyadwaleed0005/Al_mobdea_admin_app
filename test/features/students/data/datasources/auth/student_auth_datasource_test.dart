import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/core/firebase/functions/firebase_function_keys.dart';
import 'package:al_mobdea_admin/core/firebase/functions/firebase_function_names.dart';
import 'package:al_mobdea_admin/features/students/data/data_sources/auth/firebase_student_auth_remote_data_source.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/test_helper.dart';

void main() {
  late MockFirebaseFunctions functions;
  late MockHttpsCallable callable;
  late MockHttpsCallableResult callableResult;
  late FirebaseStudentAuthRemoteDataSource dataSource;

  const tEmail = 'ahmed@example.com';
  const tPassword = 'Str0ng@Pass';
  const tStudentId = 'student-123';

  setUp(() {
    functions = MockFirebaseFunctions();
    callable = MockHttpsCallable();
    callableResult = MockHttpsCallableResult();
    dataSource = FirebaseStudentAuthRemoteDataSource(
      firebaseFunctions: functions,
    );

    when(
      () => functions.httpsCallable(any()),
    ).thenReturn(callable);
  });

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('createStudentAccount', () {
    test('returns studentId when the function responds correctly', () async {
      when(() => callableResult.data).thenReturn({
        FirebaseFunctionKeys.studentId: tStudentId,
      });
      when(
        () => callable.call<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => callableResult);

      final result = await dataSource.createStudentAccount(
        email: tEmail,
        password: tPassword,
      );

      expect(result, tStudentId);
      verify(
        () => functions.httpsCallable(
          FirebaseFunctionNames.createStudentAccount,
        ),
      ).called(1);
    });

    test(
      'throws FirebaseRemoteException when studentId is missing/invalid',
      () async {
        when(() => callableResult.data).thenReturn(<String, dynamic>{});
        when(
          () => callable.call<Map<String, dynamic>>(any()),
        ).thenAnswer((_) async => callableResult);

        expect(
          () => dataSource.createStudentAccount(
            email: tEmail,
            password: tPassword,
          ),
          throwsA(isA<FirebaseRemoteException>()),
        );
      },
    );

    test(
      'maps FirebaseFunctionsException into FirebaseRemoteException',
      () async {
        when(
          () => callable.call<Map<String, dynamic>>(any()),
        ).thenThrow(
          FirebaseFunctionsException(
            message: 'already exists',
            code: 'already-exists',
          ),
        );

        expect(
          () => dataSource.createStudentAccount(
            email: tEmail,
            password: tPassword,
          ),
          throwsA(isA<FirebaseRemoteException>()),
        );
      },
    );
  });

  group('updateStudentPassword', () {
    test('calls the updateStudentPassword callable', () async {
      when(() => callableResult.data).thenReturn(<String, dynamic>{});
      when(
        () => callable.call<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => callableResult);

      await dataSource.updateStudentPassword(
        studentId: tStudentId,
        newPassword: tPassword,
      );

      verify(
        () => functions.httpsCallable(
          FirebaseFunctionNames.updateStudentPassword,
        ),
      ).called(1);
    });
  });

  group('updateStudentEmail', () {
    test('calls the updateStudentEmail callable', () async {
      when(() => callableResult.data).thenReturn(<String, dynamic>{});
      when(
        () => callable.call<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => callableResult);

      await dataSource.updateStudentEmail(
        studentId: tStudentId,
        newEmail: tEmail,
      );

      verify(
        () => functions.httpsCallable(
          FirebaseFunctionNames.updateStudentEmail,
        ),
      ).called(1);
    });
  });

  group('updateStudentAccountStatus', () {
    test('calls the updateStudentAccountStatus callable', () async {
      when(() => callableResult.data).thenReturn(<String, dynamic>{});
      when(
        () => callable.call<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => callableResult);

      await dataSource.updateStudentAccountStatus(
        studentId: tStudentId,
        isActive: false,
      );

      verify(
        () => functions.httpsCallable(
          FirebaseFunctionNames.updateStudentAccountStatus,
        ),
      ).called(1);
    });
  });

  group('deleteStudentAccount', () {
    test('calls the deleteStudentAccount callable', () async {
      when(() => callableResult.data).thenReturn(<String, dynamic>{});
      when(
        () => callable.call<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => callableResult);

      await dataSource.deleteStudentAccount(studentId: tStudentId);

      verify(
        () => functions.httpsCallable(
          FirebaseFunctionNames.deleteStudentAccount,
        ),
      ).called(1);
    });

    test(
      'maps FirebaseFunctionsException into FirebaseRemoteException',
      () async {
        when(
          () => callable.call<Map<String, dynamic>>(any()),
        ).thenThrow(
          FirebaseFunctionsException(
            message: 'not found',
            code: 'not-found',
          ),
        );

        expect(
          () => dataSource.deleteStudentAccount(studentId: tStudentId),
          throwsA(isA<FirebaseRemoteException>()),
        );
      },
    );
  });
}

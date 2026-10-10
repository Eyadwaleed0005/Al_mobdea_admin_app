import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/features/students/data/models/student_model.dart';
import 'package:al_mobdea_admin/features/students/data/repositories/students_repository_impl.dart';
import 'package:al_mobdea_admin/features/students/domain/entities/student_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStudentsRemoteDataSource remoteDataSource;
  late StudentsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(StudentModel.fromEntity(tStudentEntity));
  });

  setUp(() {
    remoteDataSource = MockStudentsRemoteDataSource();
    repository = StudentsRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  final tRemoteException = FirebaseRemoteException(
    errorModel: const AppErrorModel(
      code: 'internal',
      message: 'server error',
      type: AppErrorType.server,
      isRetryable: true,
    ),
  );

  group('getStudents', () {
    test('returns a list of students on success', () async {
      when(
        () => remoteDataSource.getStudents(gradeId: any(named: 'gradeId')),
      ).thenAnswer((_) async => [tStudentModel]);

      final result = await repository.getStudents();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (students) => expect(students, isA<List<StudentEntity>>()),
      );
      verify(() => remoteDataSource.getStudents()).called(1);
    });

    test('returns Left(AppErrorModel) when the datasource throws', () async {
      when(
        () => remoteDataSource.getStudents(gradeId: any(named: 'gradeId')),
      ).thenThrow(tRemoteException);

      final result = await repository.getStudents();

      expect(result.isLeft(), isTrue);
      result.fold(
        (error) => expect(error, isA<AppErrorModel>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('getStudentById', () {
    test('returns the student on success', () async {
      when(
        () => remoteDataSource.getStudentById(studentId: any(named: 'studentId')),
      ).thenAnswer((_) async => tStudentModel);

      final result = await repository.getStudentById(studentId: tStudentId);

      expect(result.isRight(), isTrue);
    });

    test('returns Left when the datasource throws', () async {
      when(
        () => remoteDataSource.getStudentById(studentId: any(named: 'studentId')),
      ).thenThrow(tRemoteException);

      final result = await repository.getStudentById(studentId: tStudentId);

      expect(result.isLeft(), isTrue);
    });
  });

  group('createStudent', () {
    test('returns Right(unit) on success', () async {
      when(
        () => remoteDataSource.createStudent(student: any(named: 'student')),
      ).thenAnswer((_) async {});

      final result = await repository.createStudent(student: tStudentEntity);

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
      verify(
        () => remoteDataSource.createStudent(student: any(named: 'student')),
      ).called(1);
    });

    test('returns Left when the datasource throws', () async {
      when(
        () => remoteDataSource.createStudent(student: any(named: 'student')),
      ).thenThrow(tRemoteException);

      final result = await repository.createStudent(student: tStudentEntity);

      expect(result.isLeft(), isTrue);
    });
  });

  group('updateStudent', () {
    test('returns Right(unit) on success', () async {
      when(
        () => remoteDataSource.updateStudent(student: any(named: 'student')),
      ).thenAnswer((_) async {});

      final result = await repository.updateStudent(student: tStudentEntity);

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
    });

    test('returns Left when the datasource throws', () async {
      when(
        () => remoteDataSource.updateStudent(student: any(named: 'student')),
      ).thenThrow(tRemoteException);

      final result = await repository.updateStudent(student: tStudentEntity);

      expect(result.isLeft(), isTrue);
    });
  });

  group('deleteStudent', () {
    test('returns Right(unit) on success', () async {
      when(
        () => remoteDataSource.deleteStudent(studentId: any(named: 'studentId')),
      ).thenAnswer((_) async {});

      final result = await repository.deleteStudent(studentId: tStudentId);

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
    });

    test('returns Left when the datasource throws', () async {
      when(
        () => remoteDataSource.deleteStudent(studentId: any(named: 'studentId')),
      ).thenThrow(tRemoteException);

      final result = await repository.deleteStudent(studentId: tStudentId);

      expect(result.isLeft(), isTrue);
    });
  });

  group('streamStudents', () {
    test('emits Right(list) on success', () async {
      when(
        () => remoteDataSource.streamStudents(gradeId: any(named: 'gradeId')),
      ).thenAnswer((_) => Stream.value([tStudentModel]));

      final stream = repository.streamStudents();

      await expectLater(
        stream,
        emits(isA<Right<AppErrorModel, List<StudentEntity>>>()),
      );
    });

    test('emits Left(AppErrorModel) when the stream throws', () async {
      when(
        () => remoteDataSource.streamStudents(gradeId: any(named: 'gradeId')),
      ).thenAnswer((_) => Stream.error(tRemoteException));

      final stream = repository.streamStudents();

      await expectLater(
        stream,
        emits(isA<Left<AppErrorModel, List<StudentEntity>>>()),
      );
    });
  });
}

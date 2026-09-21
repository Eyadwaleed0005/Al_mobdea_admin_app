import 'package:al_mobdea_admin/core/connection/network/network_info.dart';
import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firebase_firestore_service.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_collections.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_service.dart';
import 'package:al_mobdea_admin/features/students/data/data_sources/firestore/firebase_students_remote_data_source.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/dummy_data.dart';

class _AlwaysOnlineNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;

  @override
  Stream<bool> get onConnectionChanged =>
      const Stream<bool>.empty();

  @override
  Future<void> dispose() async {}
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreService firestoreService;
  late FirebaseStudentsRemoteDataSource dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    firestoreService = FirebaseFirestoreService(
      networkInfo: _AlwaysOnlineNetworkInfo(),
      firestore: fakeFirestore,
      enableLogging: false,
    );
    dataSource = FirebaseStudentsRemoteDataSource(
      firestoreService: firestoreService,
    );
  });

  Future<void> seedStudent({
    String studentId = tStudentId,
    String gradeId = tGradeId,
    String name = tStudentName,
  }) async {
    final map = tStudentJson()
      ..[FirestoreFields.studentId] = studentId
      ..[FirestoreFields.gradeId] = gradeId
      ..[FirestoreFields.name] = name;

    await fakeFirestore
        .collection(FirestoreCollections.students)
        .doc(studentId)
        .set(map);
  }

  group('createStudent', () {
    test(
      'writes a student document to the students collection',
      () async {
        await dataSource.createStudent(student: tStudentModel);

        final snapshot = await fakeFirestore
            .collection(FirestoreCollections.students)
            .doc(tStudentId)
            .get();

        expect(snapshot.exists, isTrue);
        expect(
          snapshot.data()![FirestoreFields.name],
          tStudentName,
        );
        expect(
          snapshot.data()![FirestoreFields.email],
          tStudentEmail,
        );
      },
    );
  });

  group('getStudents', () {
    test('returns all students sorted by name', () async {
      await seedStudent(studentId: 's-b', name: 'Zaid');
      await seedStudent(studentId: 's-a', name: 'Adam');

      final result = await dataSource.getStudents();

      expect(result.length, 2);
      expect(result.first.name, 'Adam');
      expect(result.last.name, 'Zaid');
    });

    test('filters students by gradeId when provided', () async {
      await seedStudent(studentId: 's-1', gradeId: 'grade-1');
      await seedStudent(studentId: 's-2', gradeId: 'grade-2');

      final result = await dataSource.getStudents(
        gradeId: 'grade-2',
      );

      expect(result.length, 1);
      expect(result.first.studentId, 's-2');
    });

    test(
      'returns an empty list when no students exist',
      () async {
        final result = await dataSource.getStudents();

        expect(result, isEmpty);
      },
    );
  });

  group('getStudentById', () {
    test('returns the matching student', () async {
      await seedStudent();

      final result = await dataSource.getStudentById(
        studentId: tStudentId,
      );

      expect(result.studentId, tStudentId);
      expect(result.name, tStudentName);
    });

    test('throws FirebaseRemoteException when the document does not exist', () async {
      expect(
        () => dataSource.getStudentById(studentId: 'missing'),
        throwsA(isA<FirebaseRemoteException>()),
      );
    });
  });

  group('updateStudent', () {
    test('patches an existing student document', () async {
      await seedStudent();

      final updated = tStudentModel.copyWith(
        name: 'Updated Name',
      );
      await dataSource.updateStudent(student: updated);

      final snapshot = await fakeFirestore
          .collection(FirestoreCollections.students)
          .doc(tStudentId)
          .get();

      expect(
        snapshot.data()![FirestoreFields.name],
        'Updated Name',
      );
    });
  });

  group('deleteStudent', () {
    test('removes the student document', () async {
      await seedStudent();

      await dataSource.deleteStudent(studentId: tStudentId);

      final snapshot = await fakeFirestore
          .collection(FirestoreCollections.students)
          .doc(tStudentId)
          .get();

      expect(snapshot.exists, isFalse);
    });
  });

  group('streamStudents', () {
    test('emits the current list of students', () async {
      await seedStudent(studentId: 's-1', name: 'Adam');

      final stream = dataSource.streamStudents();

      await expectLater(
        stream.map(
          (students) => students.map((s) => s.name).toList(),
        ),
        emits(['Adam']),
      );
    });
  });
}

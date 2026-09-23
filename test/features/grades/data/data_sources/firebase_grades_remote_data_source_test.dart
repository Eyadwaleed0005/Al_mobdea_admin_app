import 'package:al_mobdea_admin/core/connection/network/network_info.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firebase_firestore_service.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_collections.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_service.dart';
import 'package:al_mobdea_admin/features/grades/data/data_sources/firebase_grades_remote_data_source.dart';
import 'package:al_mobdea_admin/features/grades/data/models/grade_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dummy_data.dart';

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
  late FirebaseGradesRemoteDataSource dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    firestoreService = FirebaseFirestoreService(
      networkInfo: _AlwaysOnlineNetworkInfo(),
      firestore: fakeFirestore,
      enableLogging: false,
    );

    dataSource = FirebaseGradesRemoteDataSource(
      firestoreService: firestoreService,
    );
  });

  Future<void> seedGrade({
    required String documentId,
    required Map<String, dynamic> map,
  }) {
    return fakeFirestore
        .collection(FirestoreCollections.grades)
        .doc(documentId)
        .set(map);
  }

  group('getGrades', () {
    test('returns grades ordered by displayOrder', () async {
      await seedGrade(
        documentId: 'grade-2',
        map: tSecondGradeJson(),
      );
      await seedGrade(documentId: tGradeId, map: tGradeJson());
      await seedGrade(
        documentId: 'grade-3',
        map: tThirdGradeJson(),
      );

      final grades = await dataSource.getGrades(
        activeOnly: false,
      );

      expect(grades.map((grade) => grade.gradeId), [
        'grade-3',
        tGradeId,
        'grade-2',
      ]);
    });

    test('returns only active grades when activeOnly is true (default)', () async {
      await seedGrade(documentId: tGradeId, map: tGradeJson());
      await seedGrade(
        documentId: 'grade-2',
        map: tSecondGradeJson(),
      );

      final grades = await dataSource.getGrades();

      expect(grades, hasLength(1));
      expect(grades.single.gradeId, tGradeId);
      expect(grades.single.isActive, isTrue);
    });

    test(
      'returns all grades when activeOnly is false',
      () async {
        await seedGrade(documentId: tGradeId, map: tGradeJson());
        await seedGrade(
          documentId: 'grade-2',
          map: tSecondGradeJson(),
        );

        final grades = await dataSource.getGrades(
          activeOnly: false,
        );

        expect(grades, hasLength(2));
        expect(grades.map((grade) => grade.gradeId), [
          tGradeId,
          'grade-2',
        ]);
      },
    );

    test('maps documents into GradeModel fields', () async {
      await seedGrade(documentId: tGradeId, map: tGradeJson());

      final grades = await dataSource.getGrades();

      expect(grades.single, isA<GradeModel>());
      expect(grades.single.gradeId, tGradeId);
      expect(grades.single.name, tGradeName);
      expect(grades.single.displayOrder, tGradeDisplayOrder);
      expect(grades.single.isActive, isTrue);
    });

    test(
      'uses the document id when the map has no gradeId',
      () async {
        final map = tGradeJson()
          ..remove(FirestoreFields.gradeId);

        await seedGrade(
          documentId: 'firestore-doc-id',
          map: map,
        );

        final grades = await dataSource.getGrades();

        expect(grades.single.gradeId, 'firestore-doc-id');
      },
    );

    test(
      'returns an empty list when there are no grades',
      () async {
        final grades = await dataSource.getGrades();

        expect(grades, isEmpty);
      },
    );
  });

  group('streamGrades', () {
    test('emits grades ordered by displayOrder', () async {
      await seedGrade(
        documentId: 'grade-2',
        map: tSecondGradeJson(),
      );
      await seedGrade(documentId: tGradeId, map: tGradeJson());

      final stream = dataSource.streamGrades(activeOnly: false);

      await expectLater(
        stream,
        emits(
          isA<List<GradeModel>>()
              .having((grades) => grades, 'length', hasLength(2))
              .having(
                (grades) => grades.first.gradeId,
                'first gradeId',
                tGradeId,
              )
              .having(
                (grades) => grades.last.gradeId,
                'last gradeId',
                'grade-2',
              ),
        ),
      );
    });

    test('emits only active grades when activeOnly is true (default)', () async {
      await seedGrade(documentId: tGradeId, map: tGradeJson());
      await seedGrade(
        documentId: 'grade-2',
        map: tSecondGradeJson(),
      );

      final stream = dataSource.streamGrades();

      await expectLater(
        stream,
        emits(
          isA<List<GradeModel>>().having(
            (grades) => grades.single.gradeId,
            'gradeId',
            tGradeId,
          ),
        ),
      );
    });

    test('emits again when a grade is added later', () async {
      await seedGrade(documentId: tGradeId, map: tGradeJson());

      final stream = dataSource.streamGrades(activeOnly: false);

      final expectation = expectLater(
        stream,
        emits(
          isA<List<GradeModel>>().having(
            (grades) => grades.map((grade) => grade.gradeId),
            'gradeIds',
            containsAll([tGradeId, 'grade-2']),
          ),
        ),
      );

      await seedGrade(
        documentId: 'grade-2',
        map: tSecondGradeJson(),
      );

      await expectation;
    });

    test(
      'emits an empty list when there are no grades',
      () async {
        final stream = dataSource.streamGrades();

        await expectLater(
          stream,
          emits(
            isA<List<GradeModel>>().having(
              (grades) => grades,
              'length',
              isEmpty,
            ),
          ),
        );
      },
    );
  });
}

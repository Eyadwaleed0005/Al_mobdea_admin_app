import 'package:al_mobdea_admin/core/firebase/firestore/firestore_collections.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/dashboard/data/data_sources/remote/firebase_dashboard_remote_data_source_impl.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirebaseDashboardRemoteDataSourceImpl dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = FirebaseDashboardRemoteDataSourceImpl(
      firestore: fakeFirestore,
    );
  });

  group('getStudentsSummary', () {
    test(
      'should return correct counts when there are students',
      () async {
        // Arrange - Add test documents
        await fakeFirestore
            .collection(FirestoreCollections.students)
            .doc('student1')
            .set({
              'name': 'Student 1',
              FirestoreFields.isActive: true,
            });

        await fakeFirestore
            .collection(FirestoreCollections.students)
            .doc('student2')
            .set({
              'name': 'Student 2',
              FirestoreFields.isActive: false,
            });

        await fakeFirestore
            .collection(FirestoreCollections.students)
            .doc('student3')
            .set({
              'name': 'Student 3',
              FirestoreFields.isActive: true,
            });

        await fakeFirestore
            .collection(FirestoreCollections.students)
            .doc('student4')
            .set({
              'name': 'Student 4',
              FirestoreFields.isActive: false,
            });

        // Act
        final result = await dataSource.getStudentsSummary();

        // Assert
        expect(result.totalStudents, equals(4));
        expect(result.expiredSubscriptions, equals(2));
      },
    );

    test(
      'should return zero counts when there are no students',
      () async {
        // Act
        final result = await dataSource.getStudentsSummary();

        // Assert
        expect(result.totalStudents, equals(0));
        expect(result.expiredSubscriptions, equals(0));
      },
    );

    test('should count only inactive students as expired subscriptions', () async {
      // Arrange
      await fakeFirestore
          .collection(FirestoreCollections.students)
          .doc('student1')
          .set({
            'name': 'Active Student',
            FirestoreFields.isActive: true,
          });

      await fakeFirestore
          .collection(FirestoreCollections.students)
          .doc('student2')
          .set({
            'name': 'Inactive Student',
            FirestoreFields.isActive: false,
          });

      // Act
      final result = await dataSource.getStudentsSummary();

      // Assert
      expect(result.totalStudents, equals(2));
      expect(result.expiredSubscriptions, equals(1));
    });
  });
}

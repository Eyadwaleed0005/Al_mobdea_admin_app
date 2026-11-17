import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/students/data/models/student_model.dart';
import 'package:al_mobdea_admin/features/students/domain/entities/student_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dummy_data.dart';

void main() {
  group('StudentModel', () {
    test('is a subclass of StudentEntity', () {
      expect(tStudentModel, isA<StudentEntity>());
    });

    group('fromMap', () {
      test('returns a valid model from a Firestore map', () {
        final result = StudentModel.fromMap(
          documentId: tStudentId,
          map: tStudentJson(),
        );

        expect(result.studentId, tStudentId);
        expect(result.gradeId, tGradeId);
        expect(result.name, tStudentName);
        expect(result.email, tStudentEmail);
        expect(result.phoneNumber, tStudentPhone);
        expect(
          result.subscriptionStartAt!.isAtSameMomentAs(tSubscriptionStartAt),
          isTrue,
        );
        expect(
          result.subscriptionEndAt!.isAtSameMomentAs(tSubscriptionEndAt),
          isTrue,
        );
        expect(result.isActive, isTrue);
        expect(result.isLoggedIn, isFalse);
        expect(result.createdAt!.isAtSameMomentAs(tCreatedAt), isTrue);
        expect(result.updatedAt!.isAtSameMomentAs(tUpdatedAt), isTrue);
      });

      test('falls back to documentId when studentId field is missing', () {
        final map = tStudentJson()
          ..remove(FirestoreFields.studentId);

        final result = StudentModel.fromMap(
          documentId: 'fallback-id',
          map: map,
        );

        expect(result.studentId, 'fallback-id');
      });

      test('converts Timestamp fields into DateTime', () {
        final result = StudentModel.fromMap(
          documentId: tStudentId,
          map: tStudentJson(),
        );

        expect(result.subscriptionStartAt, isA<DateTime>());
        expect(result.subscriptionEndAt, isA<DateTime>());
      });

      test('keeps subscription dates nullable when missing', () {
        final map = tStudentJson()
          ..remove(FirestoreFields.subscriptionStartAt)
          ..remove(FirestoreFields.subscriptionEndAt);

        final result = StudentModel.fromMap(
          documentId: tStudentId,
          map: map,
        );

        expect(result.subscriptionStartAt, isNull);
        expect(result.subscriptionEndAt, isNull);
      });

      test('defaults isActive and isLoggedIn to false when missing', () {
        final map = tStudentJson()
          ..remove(FirestoreFields.isActive)
          ..remove(FirestoreFields.isLoggedIn);

        final result = StudentModel.fromMap(
          documentId: tStudentId,
          map: map,
        );

        expect(result.isActive, isFalse);
        expect(result.isLoggedIn, isFalse);
      });
    });

    group('fromEntity', () {
      test('creates a model that mirrors the entity fields', () {
        final result = StudentModel.fromEntity(tStudentEntity);

        expect(result.studentId, tStudentEntity.studentId);
        expect(result.gradeId, tStudentEntity.gradeId);
        expect(result.name, tStudentEntity.name);
        expect(result.email, tStudentEntity.email);
        expect(result.phoneNumber, tStudentEntity.phoneNumber);
        expect(result.isActive, tStudentEntity.isActive);
        expect(result.isLoggedIn, tStudentEntity.isLoggedIn);
        expect(result.createdAt, isNull);
        expect(result.updatedAt, isNull);
      });
    });

    group('toCreateMap', () {
      test('serializes dates to Timestamp and stamps server timestamps', () {
        final map = tStudentModel.toCreateMap();

        expect(map[FirestoreFields.studentId], tStudentId);
        expect(map[FirestoreFields.gradeId], tGradeId);
        expect(map[FirestoreFields.name], tStudentName);
        expect(map[FirestoreFields.email], tStudentEmail);
        expect(map[FirestoreFields.phoneNumber], tStudentPhone);
        expect(
          map[FirestoreFields.subscriptionStartAt],
          Timestamp.fromDate(tSubscriptionStartAt),
        );
        expect(
          map[FirestoreFields.subscriptionEndAt],
          Timestamp.fromDate(tSubscriptionEndAt),
        );
        expect(map[FirestoreFields.isActive], isTrue);
        expect(map[FirestoreFields.isLoggedIn], isFalse);
        expect(map[FirestoreFields.createdAt], isA<FieldValue>());
        expect(map[FirestoreFields.updatedAt], isA<FieldValue>());
        expect(map.containsKey(FirestoreFields.age), isFalse);
      });

      test('writes null subscription dates when the student has none', () {
        final studentWithoutSubscription = StudentModel.fromEntity(
          StudentEntity(
            studentId: tStudentId,
            gradeId: tGradeId,
            name: tStudentName,
            email: tStudentEmail,
            phoneNumber: tStudentPhone,
            isActive: false,
            isLoggedIn: false,
          ),
        );

        final map = studentWithoutSubscription.toCreateMap();

        expect(map[FirestoreFields.subscriptionStartAt], isNull);
        expect(map[FirestoreFields.subscriptionEndAt], isNull);
        expect(map[FirestoreFields.isActive], isFalse);
      });
    });

    group('toUpdateMap', () {
      test('excludes studentId and createdAt but stamps updatedAt', () {
        final map = tStudentModel.toUpdateMap();

        expect(map.containsKey(FirestoreFields.studentId), isFalse);
        expect(map.containsKey(FirestoreFields.createdAt), isFalse);
        expect(map[FirestoreFields.updatedAt], isA<FieldValue>());
        expect(map[FirestoreFields.gradeId], tGradeId);
        expect(
          map[FirestoreFields.subscriptionEndAt],
          Timestamp.fromDate(tSubscriptionEndAt),
        );
      });
    });

    group('copyWith', () {
      test('overrides only the provided fields', () {
        final result = tStudentModel.copyWith(
          name: 'New Name',
          isActive: false,
        );

        expect(result.name, 'New Name');
        expect(result.isActive, isFalse);
        expect(result.studentId, tStudentModel.studentId);
        expect(result.email, tStudentModel.email);
        expect(result.subscriptionEndAt, tStudentModel.subscriptionEndAt);
      });

      test('returns an equivalent entity when no arguments are passed', () {
        final result = tStudentModel.copyWith();

        expect(result.studentId, tStudentModel.studentId);
        expect(result.name, tStudentModel.name);
        expect(result.email, tStudentModel.email);
        expect(result.gradeId, tStudentModel.gradeId);
      });
    });
  });
}

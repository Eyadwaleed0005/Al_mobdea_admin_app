import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/grades/data/models/grade_model.dart';
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dummy_data.dart';

void main() {
  group('GradeModel', () {
    group('fromMap', () {
      test('maps valid data into the correct fields', () {
        final model = GradeModel.fromMap(
          documentId: tGradeId,
          map: tGradeJson(),
        );

        expect(model.gradeId, tGradeId);
        expect(model.name, tGradeName);
        expect(model.displayOrder, tGradeDisplayOrder);
        expect(model.isActive, isTrue);
        expect(model, isA<GradeEntity>());
      });

      test('throws FormatException when the name is missing', () {
        expect(
          () => GradeModel.fromMap(
            documentId: tGradeId,
            map: {},
          ),
          throwsA(isA<FormatException>()),
        );
      });

      test('throws FormatException when the name is empty', () {
        expect(
          () => GradeModel.fromMap(
            documentId: tGradeId,
            map: {
              FirestoreFields.name: '   ',
            },
          ),
          throwsA(isA<FormatException>()),
        );
      });

      test('throws FormatException when the name is not a String', () {
        expect(
          () => GradeModel.fromMap(
            documentId: tGradeId,
            map: {
              FirestoreFields.name: 42,
            },
          ),
          throwsA(isA<FormatException>()),
        );
      });

      test('trims the name', () {
        final model = GradeModel.fromMap(
          documentId: tGradeId,
          map: {
            FirestoreFields.name: '  $tGradeName  ',
          },
        );

        expect(model.name, tGradeName);
      });

      test('uses gradeId from the map when present', () {
        final model = GradeModel.fromMap(
          documentId: 'document-id',
          map: {
            ...tGradeJson(),
            FirestoreFields.gradeId: 'from-map-id',
          },
        );

        expect(model.gradeId, 'from-map-id');
      });

      test('falls back to the documentId when gradeId is missing', () {
        final map = tGradeJson()
          ..remove(FirestoreFields.gradeId);

        final model = GradeModel.fromMap(
          documentId: tGradeId,
          map: map,
        );

        expect(model.gradeId, tGradeId);
      });

      test('falls back to the documentId when gradeId is null', () {
        final model = GradeModel.fromMap(
          documentId: tGradeId,
          map: {
            ...tGradeJson(),
            FirestoreFields.gradeId: null,
          },
        );

        expect(model.gradeId, tGradeId);
      });

      test('defaults displayOrder to 0 when missing or null', () {
        final missingOrderModel = GradeModel.fromMap(
          documentId: tGradeId,
          map: {FirestoreFields.name: tGradeName},
        );

        final nullOrderModel = GradeModel.fromMap(
          documentId: tGradeId,
          map: {
            FirestoreFields.name: tGradeName,
            FirestoreFields.displayOrder: null,
          },
        );

        expect(missingOrderModel.displayOrder, 0);
        expect(nullOrderModel.displayOrder, 0);
      });

      test('converts displayOrder from num to int', () {
        final model = GradeModel.fromMap(
          documentId: tGradeId,
          map: {
            FirestoreFields.name: tGradeName,
            FirestoreFields.displayOrder: 3.0,
          },
        );

        expect(model.displayOrder, 3);
        expect(model.displayOrder, isA<int>());
      });

      test('defaults isActive to true when missing or null', () {
        final missingFlagModel = GradeModel.fromMap(
          documentId: tGradeId,
          map: {FirestoreFields.name: tGradeName},
        );

        final nullFlagModel = GradeModel.fromMap(
          documentId: tGradeId,
          map: {
            FirestoreFields.name: tGradeName,
            FirestoreFields.isActive: null,
          },
        );

        expect(missingFlagModel.isActive, isTrue);
        expect(nullFlagModel.isActive, isTrue);
      });

      test('reads isActive false from the map', () {
        final model = GradeModel.fromMap(
          documentId: tGradeId,
          map: {
            ...tGradeJson(),
            FirestoreFields.isActive: false,
          },
        );

        expect(model.isActive, isFalse);
      });
    });
  });
}

import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/study_notes/data/models/study_note_model.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dummy_data.dart';

void main() {
  group('StudyNoteModel', () {
    group('fromEntity', () {
      test('maps all entity fields including pdf metadata', () {
        final model = StudyNoteModel.fromEntity(tStudyNoteEntity);

        expect(model.noteId, tStudyNoteId);
        expect(model.name, tStudyNoteName);
        expect(model.description, tStudyNoteDescription);
        expect(model.gradeId, tGradeId);
        expect(model.isPublished, isTrue);
        expect(model.isFree, isTrue);
        expect(model.pdfFileName, tStudyNotePdfFileName);
        expect(model.pdfFileSize, tStudyNotePdfFileSize);
        expect(model.pdfStoragePath, tStudyNotePdfStoragePath);
        expect(model.createdAt, isNull);
        expect(model.updatedAt, isNull);
      });

      test('maps a note without pdf data to empty pdf fields', () {
        final model = StudyNoteModel.fromEntity(tStudyNoteEntityWithoutPdf);

        expect(model.pdfFileName, isEmpty);
        expect(model.pdfFileSize, 0);
        expect(model.pdfStoragePath, isEmpty);
      });

      test('maps the free access flag', () {
        final paidNote = StudyNoteEntity(
          noteId: tStudyNoteId,
          name: tStudyNoteName,
          description: tStudyNoteDescription,
          gradeId: tGradeId,
          isPublished: true,
          isFree: false,
          pdfFileName: tStudyNotePdfFileName,
          pdfFileSize: tStudyNotePdfFileSize,
          pdfStoragePath: tStudyNotePdfStoragePath,
        );

        expect(StudyNoteModel.fromEntity(paidNote).isFree, isFalse);
      });

      test('is an instance of StudyNoteEntity', () {
        expect(
          StudyNoteModel.fromEntity(tStudyNoteEntity),
          isA<StudyNoteEntity>(),
        );
      });
    });

    group('fromMap', () {
      test('maps a full document map with pdf fields', () {
        final model = StudyNoteModel.fromMap(
          documentId: tStudyNoteId,
          map: tStudyNoteJson(),
        );

        expect(model.noteId, tStudyNoteId);
        expect(model.name, tStudyNoteName);
        expect(model.description, tStudyNoteDescription);
        expect(model.gradeId, tGradeId);
        expect(model.isPublished, isTrue);
        expect(model.pdfFileName, tStudyNotePdfFileName);
        expect(model.pdfFileSize, tStudyNotePdfFileSize);
        expect(model.pdfStoragePath, tStudyNotePdfStoragePath);
        expect(model.createdAt!.isAtSameMomentAs(tStudyNoteCreatedAt), isTrue);
        expect(model.updatedAt!.isAtSameMomentAs(tStudyNoteUpdatedAt), isTrue);
      });

      test('defaults missing pdf fields to empty values', () {
        final model = StudyNoteModel.fromMap(
          documentId: tStudyNoteId,
          map: tStudyNoteJsonWithoutPdf(),
        );

        expect(model.pdfFileName, isEmpty);
        expect(model.pdfFileSize, 0);
        expect(model.pdfStoragePath, isEmpty);
      });

      test('keeps raw string values from the map', () {
        final model = StudyNoteModel.fromMap(
          documentId: tStudyNoteId,
          map: {
            FirestoreFields.name: '  $tStudyNoteName  ',
            FirestoreFields.description: '  $tStudyNoteDescription  ',
            FirestoreFields.gradeId: '  $tGradeId  ',
            FirestoreFields.pdfFileName: '',
            FirestoreFields.pdfStoragePath: '   ',
          },
        );

        expect(model.name, '  $tStudyNoteName  ');
        expect(model.description, '  $tStudyNoteDescription  ');
        expect(model.gradeId, '  $tGradeId  ');
        expect(model.pdfFileName, isEmpty);
        expect(model.pdfStoragePath, '   ');
      });

      test('converts numeric pdf file sizes and ignores invalid values', () {
        final zeroSizeModel = StudyNoteModel.fromMap(
          documentId: tStudyNoteId,
          map: {FirestoreFields.pdfFileSize: 0},
        );

        final doubleSizeModel = StudyNoteModel.fromMap(
          documentId: tStudyNoteId,
          map: {FirestoreFields.pdfFileSize: 2048.0},
        );

        final stringSizeModel = StudyNoteModel.fromMap(
          documentId: tStudyNoteId,
          map: {FirestoreFields.pdfFileSize: 'big'},
        );

        expect(zeroSizeModel.pdfFileSize, 0);
        expect(doubleSizeModel.pdfFileSize, 2048);
        expect(stringSizeModel.pdfFileSize, 0);
      });

      test('defaults isPublished to false when missing', () {
        final model = StudyNoteModel.fromMap(
          documentId: tStudyNoteId,
          map: const <String, dynamic>{},
        );

        expect(model.isPublished, isFalse);
      });

      test('defaults isFree to true when missing', () {
        final model = StudyNoteModel.fromMap(
          documentId: tStudyNoteId,
          map: const <String, dynamic>{},
        );

        expect(model.isFree, isTrue);
      });

      test('parses createdAt as ISO string', () {
        final model = StudyNoteModel.fromMap(
          documentId: tStudyNoteId,
          map: {
            FirestoreFields.createdAt: tStudyNoteCreatedAt.toIso8601String(),
          },
        );

        expect(model.createdAt!.isAtSameMomentAs(tStudyNoteCreatedAt), isTrue);
      });

      test('parses createdAt as epoch milliseconds', () {
        final epoch = tStudyNoteCreatedAt.millisecondsSinceEpoch;

        final model = StudyNoteModel.fromMap(
          documentId: tStudyNoteId,
          map: {FirestoreFields.createdAt: epoch},
        );

        expect(
          model.createdAt!.isAtSameMomentAs(tStudyNoteCreatedAt),
          isTrue,
        );
      });

      test('returns null dates for invalid string values', () {
        final model = StudyNoteModel.fromMap(
          documentId: tStudyNoteId,
          map: {FirestoreFields.updatedAt: 'not-a-date'},
        );

        expect(model.updatedAt, isNull);
      });
    });

    group('toCreateMap', () {
      test('writes base fields and server timestamps', () {
        final map = tStudyNoteModel.toCreateMap();

        expect(map[FirestoreFields.name], tStudyNoteName);
        expect(map[FirestoreFields.description], tStudyNoteDescription);
        expect(map[FirestoreFields.gradeId], tGradeId);
        expect(map[FirestoreFields.isPublished], isTrue);
        expect(map[FirestoreFields.isFree], isTrue);
        expect(map[FirestoreFields.createdAt], isA<FieldValue>());
        expect(map[FirestoreFields.updatedAt], isA<FieldValue>());
      });

      test('writes pdf fields when the note has a valid pdf', () {
        final map = tStudyNoteModel.toCreateMap();

        expect(map[FirestoreFields.pdfFileName], tStudyNotePdfFileName);
        expect(map[FirestoreFields.pdfFileSize], tStudyNotePdfFileSize);
        expect(map[FirestoreFields.pdfStoragePath], tStudyNotePdfStoragePath);
      });

      test('writes empty pdf fields when the note has no pdf', () {
        final map = StudyNoteModel.fromEntity(
          tStudyNoteEntityWithoutPdf,
        ).toCreateMap();

        expect(map[FirestoreFields.pdfFileName], isEmpty);
        expect(map[FirestoreFields.pdfFileSize], 0);
        expect(map[FirestoreFields.pdfStoragePath], isEmpty);
      });

      test('trims string values', () {
        final map = StudyNoteModel.fromEntity(
          StudyNoteEntity(
            noteId: tStudyNoteId,
            name: '  $tStudyNoteName  ',
            description: '  $tStudyNoteDescription  ',
            gradeId: '  $tGradeId  ',
            isPublished: true,
            pdfFileName: '  $tStudyNotePdfFileName  ',
            pdfFileSize: tStudyNotePdfFileSize,
            pdfStoragePath: '  $tStudyNotePdfStoragePath  ',
          ),
        ).toCreateMap();

        expect(map[FirestoreFields.name], tStudyNoteName);
        expect(map[FirestoreFields.description], tStudyNoteDescription);
        expect(map[FirestoreFields.gradeId], tGradeId);
        expect(map[FirestoreFields.pdfFileName], tStudyNotePdfFileName);
        expect(map[FirestoreFields.pdfStoragePath], tStudyNotePdfStoragePath);
      });
    });

    group('toUpdateMap', () {
      test('does not write createdAt on update', () {
        final map = tStudyNoteModel.toUpdateMap();

        expect(map.containsKey(FirestoreFields.createdAt), isFalse);
        expect(map[FirestoreFields.updatedAt], isA<FieldValue>());
      });

      test('keeps pdf fields when the note has a valid pdf', () {
        final map = tStudyNoteModel.toUpdateMap();

        expect(map[FirestoreFields.pdfFileName], tStudyNotePdfFileName);
        expect(map[FirestoreFields.pdfFileSize], tStudyNotePdfFileSize);
        expect(map[FirestoreFields.pdfStoragePath], tStudyNotePdfStoragePath);
      });

      test('writes empty pdf fields when the note has no pdf', () {
        final map = StudyNoteModel.fromEntity(
          tStudyNoteEntityWithoutPdf,
        ).toUpdateMap();

        expect(map[FirestoreFields.pdfFileName], isEmpty);
        expect(map[FirestoreFields.pdfFileSize], 0);
        expect(map[FirestoreFields.pdfStoragePath], isEmpty);
      });

      test('writes the free access flag', () {
        final map = tStudyNoteModel.toUpdateMap();

        expect(map[FirestoreFields.isFree], isTrue);
      });
    });
  });
}

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
        expect(model.pdfFileName, tStudyNotePdfFileName);
        expect(model.pdfFileSize, tStudyNotePdfFileSize);
        expect(model.pdfStoragePath, tStudyNotePdfStoragePath);
        expect(model.createdAt, isNull);
        expect(model.updatedAt, isNull);
      });

      test('maps a note without pdf fields', () {
        final model = StudyNoteModel.fromEntity(tStudyNoteEntityWithoutPdf);

        expect(model.pdfFileName, isNull);
        expect(model.pdfFileSize, isNull);
        expect(model.pdfStoragePath, isNull);
        expect(model.hasPdfFile, isFalse);
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

      test('maps a document map without pdf fields', () {
        final model = StudyNoteModel.fromMap(
          documentId: tStudyNoteId,
          map: tStudyNoteJsonWithoutPdf(),
        );

        expect(model.pdfFileName, isNull);
        expect(model.pdfFileSize, isNull);
        expect(model.pdfStoragePath, isNull);
        expect(model.hasPdfFile, isFalse);
      });

      test('treats blank strings as null for optional fields', () {
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

        expect(model.name, tStudyNoteName);
        expect(model.description, tStudyNoteDescription);
        expect(model.gradeId, tGradeId);
        expect(model.pdfFileName, isNull);
        expect(model.pdfStoragePath, isNull);
      });

      test('ignores non-positive and non-int pdf file sizes', () {
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

        expect(zeroSizeModel.pdfFileSize, isNull);
        expect(doubleSizeModel.pdfFileSize, 2048);
        expect(stringSizeModel.pdfFileSize, isNull);
      });

      test('defaults isPublished to false for non-bool values', () {
        final model = StudyNoteModel.fromMap(
          documentId: tStudyNoteId,
          map: {FirestoreFields.isPublished: 'yes'},
        );

        expect(model.isPublished, isFalse);
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

      test('returns null dates for missing or invalid values', () {
        final model = StudyNoteModel.fromMap(
          documentId: tStudyNoteId,
          map: {
            FirestoreFields.createdAt: 42,
            FirestoreFields.updatedAt: 'not-a-date',
          },
        );

        expect(model.createdAt, isNull);
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
        expect(map[FirestoreFields.createdAt], isA<FieldValue>());
        expect(map[FirestoreFields.updatedAt], isA<FieldValue>());
      });

      test('writes pdf fields when the note has a valid pdf', () {
        final map = tStudyNoteModel.toCreateMap();

        expect(map[FirestoreFields.pdfFileName], tStudyNotePdfFileName);
        expect(map[FirestoreFields.pdfFileSize], tStudyNotePdfFileSize);
        expect(map[FirestoreFields.pdfStoragePath], tStudyNotePdfStoragePath);
      });

      test('omits pdf fields when the note has no pdf', () {
        final map = StudyNoteModel.fromEntity(
          tStudyNoteEntityWithoutPdf,
        ).toCreateMap();

        expect(map.containsKey(FirestoreFields.pdfFileName), isFalse);
        expect(map.containsKey(FirestoreFields.pdfFileSize), isFalse);
        expect(map.containsKey(FirestoreFields.pdfStoragePath), isFalse);
      });

      test('omits pdf fields when pdf data is incomplete', () {
        final map = StudyNoteModel(
          noteId: tStudyNoteId,
          name: tStudyNoteName,
          description: tStudyNoteDescription,
          gradeId: tGradeId,
          isPublished: true,
          pdfStoragePath: tStudyNotePdfStoragePath,
        ).toCreateMap();

        expect(map.containsKey(FirestoreFields.pdfStoragePath), isFalse);
        expect(map.containsKey(FirestoreFields.pdfFileName), isFalse);
        expect(map.containsKey(FirestoreFields.pdfFileSize), isFalse);
      });

      test('trims string values', () {
        final map = StudyNoteModel.fromEntity(
          tStudyNoteEntity.copyWith(
            name: '  $tStudyNoteName  ',
            description: '  $tStudyNoteDescription  ',
          ),
        ).toCreateMap();

        expect(map[FirestoreFields.name], tStudyNoteName);
        expect(map[FirestoreFields.description], tStudyNoteDescription);
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

      test('does not touch pdf fields when the note has no pdf', () {
        final map = StudyNoteModel.fromEntity(
          tStudyNoteEntityWithoutPdf,
        ).toUpdateMap();

        expect(map.containsKey(FirestoreFields.pdfFileName), isFalse);
        expect(map.containsKey(FirestoreFields.pdfFileSize), isFalse);
        expect(map.containsKey(FirestoreFields.pdfStoragePath), isFalse);
      });

      test('marks pdf fields for deletion when removePdf is true', () {
        final map = tStudyNoteModel.toUpdateMap(removePdf: true);

        expect(map[FirestoreFields.pdfFileName], FieldValue.delete());
        expect(map[FirestoreFields.pdfFileSize], FieldValue.delete());
        expect(map[FirestoreFields.pdfStoragePath], FieldValue.delete());
      });
    });

    group('entity helpers', () {
      test('hasPdfFile reflects the pdf storage path', () {
        expect(tStudyNoteEntity.hasPdfFile, isTrue);
        expect(tStudyNoteEntityWithoutPdf.hasPdfFile, isFalse);
      });

      test('copyWith keeps pdf fields unless clearPdf is true', () {
        final kept = tStudyNoteEntity.copyWith(name: 'New name');

        expect(kept.pdfStoragePath, tStudyNotePdfStoragePath);

        final cleared = tStudyNoteEntity.copyWith(clearPdf: true);

        expect(cleared.pdfFileName, isNull);
        expect(cleared.pdfFileSize, isNull);
        expect(cleared.pdfStoragePath, isNull);
      });
    });
  });
}

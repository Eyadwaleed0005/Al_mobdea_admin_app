import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/lessons/data/models/lesson_model.dart';
import 'package:al_mobdea_admin/features/lessons/domain/entities/lesson_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dummy_data.dart';

void main() {
  group('LessonModel', () {
    group('fromEntity', () {
      test('maps all entity fields including pdf metadata', () {
        final model = LessonModel.fromEntity(tLessonEntity);

        expect(model.lessonId, tLessonId);
        expect(model.gradeId, tGradeId);
        expect(model.title, tLessonTitle);
        expect(model.subtitle, tLessonSubtitle);
        expect(model.youtubeUrl, tYoutubeUrl);
        expect(model.pdfFileName, tPdfFileName);
        expect(model.pdfFileSize, tPdfFileSize);
        expect(model.pdfStoragePath, tPdfStoragePath);
        expect(model.isPublished, isTrue);
        expect(model.createdAt, isNull);
        expect(model.updatedAt, isNull);
      });

      test('maps a lesson without pdf fields', () {
        final model = LessonModel.fromEntity(
          tLessonEntityWithoutPdf,
        );

        expect(model.pdfFileName, isNull);
        expect(model.pdfFileSize, isNull);
        expect(model.pdfStoragePath, isNull);
        expect(model.hasPdfFile, isFalse);
      });

      test('is an instance of LessonEntity', () {
        expect(
          LessonModel.fromEntity(tLessonEntity),
          isA<LessonEntity>(),
        );
      });
    });

    group('fromMap', () {
      test('maps a full document map with pdf fields', () {
        final model = LessonModel.fromMap(
          documentId: tLessonId,
          map: tLessonJson(),
        );

        expect(model.lessonId, tLessonId);
        expect(model.gradeId, tGradeId);
        expect(model.title, tLessonTitle);
        expect(model.subtitle, tLessonSubtitle);
        expect(model.youtubeUrl, tYoutubeUrl);
        expect(model.pdfFileName, tPdfFileName);
        expect(model.pdfFileSize, tPdfFileSize);
        expect(model.pdfStoragePath, tPdfStoragePath);
        expect(model.isPublished, isTrue);
        expect(
          model.createdAt!.isAtSameMomentAs(tLessonCreatedAt),
          isTrue,
        );
        expect(
          model.updatedAt!.isAtSameMomentAs(tLessonUpdatedAt),
          isTrue,
        );
      });

      test('maps a document map without pdf fields', () {
        final model = LessonModel.fromMap(
          documentId: tLessonId,
          map: tLessonJsonWithoutPdf(),
        );

        expect(model.pdfFileName, isNull);
        expect(model.pdfFileSize, isNull);
        expect(model.pdfStoragePath, isNull);
        expect(model.hasPdfFile, isFalse);
      });

      test(
        'treats blank strings as null for optional fields',
        () {
          final model = LessonModel.fromMap(
            documentId: tLessonId,
            map: {
              FirestoreFields.gradeId: '  $tGradeId  ',
              FirestoreFields.title: '  $tLessonTitle  ',
              FirestoreFields.description: '',
              FirestoreFields.youtubeUrl: '   ',
              FirestoreFields.pdfFileName: '',
              FirestoreFields.pdfStoragePath: '',
            },
          );

          expect(model.gradeId, tGradeId);
          expect(model.title, tLessonTitle);
          expect(model.subtitle, isEmpty);
          expect(model.youtubeUrl, isNull);
          expect(model.pdfFileName, isNull);
          expect(model.pdfStoragePath, isNull);
        },
      );

      test(
        'ignores non-positive and non-int pdf file sizes',
        () {
          final zeroSizeModel = LessonModel.fromMap(
            documentId: tLessonId,
            map: {FirestoreFields.pdfFileSize: 0},
          );

          final doubleSizeModel = LessonModel.fromMap(
            documentId: tLessonId,
            map: {FirestoreFields.pdfFileSize: 2048.0},
          );

          final stringSizeModel = LessonModel.fromMap(
            documentId: tLessonId,
            map: {FirestoreFields.pdfFileSize: 'big'},
          );

          expect(zeroSizeModel.pdfFileSize, isNull);
          expect(doubleSizeModel.pdfFileSize, 2048);
          expect(stringSizeModel.pdfFileSize, isNull);
        },
      );

      test(
        'defaults isPublished to false for non-bool values',
        () {
          final model = LessonModel.fromMap(
            documentId: tLessonId,
            map: {FirestoreFields.isPublished: 'yes'},
          );

          expect(model.isPublished, isFalse);
        },
      );      test('parses createdAt as ISO string', () {
        final model = LessonModel.fromMap(
          documentId: tLessonId,
          map: {
            FirestoreFields.createdAt: tLessonCreatedAt.toIso8601String(),
          },
        );

        expect(
          model.createdAt!.isAtSameMomentAs(tLessonCreatedAt),
          isTrue,
        );
      });

      test(
        'returns null dates for missing or invalid values',
        () {
          final model = LessonModel.fromMap(
            documentId: tLessonId,
            map: {
              FirestoreFields.createdAt: 42,
              FirestoreFields.updatedAt: 'not-a-date',
            },
          );

          expect(model.createdAt, isNull);
          expect(model.updatedAt, isNull);
        },
      );
    });

    group('toCreateMap', () {
      test('writes base fields and server timestamps', () {
        final map = tLessonModel.toCreateMap();

        expect(map[FirestoreFields.gradeId], tGradeId);
        expect(map[FirestoreFields.title], tLessonTitle);
        expect(
          map[FirestoreFields.description],
          tLessonSubtitle,
        );
        expect(map[FirestoreFields.youtubeUrl], tYoutubeUrl);
        expect(map[FirestoreFields.isPublished], isTrue);
        expect(
          map[FirestoreFields.createdAt],
          isA<FieldValue>(),
        );
        expect(
          map[FirestoreFields.updatedAt],
          isA<FieldValue>(),
        );
      });

      test(
        'writes pdf fields when the lesson has a valid pdf',
        () {
          final map = tLessonModel.toCreateMap();

          expect(map[FirestoreFields.pdfFileName], tPdfFileName);
          expect(map[FirestoreFields.pdfFileSize], tPdfFileSize);
          expect(
            map[FirestoreFields.pdfStoragePath],
            tPdfStoragePath,
          );
        },
      );

      test('omits pdf fields when the lesson has no pdf (pdf-optional)', () {
        final map = LessonModel.fromEntity(
          tLessonEntityWithoutPdf,
        ).toCreateMap();

        expect(
          map.containsKey(FirestoreFields.pdfFileName),
          isFalse,
        );
        expect(
          map.containsKey(FirestoreFields.pdfFileSize),
          isFalse,
        );
        expect(
          map.containsKey(FirestoreFields.pdfStoragePath),
          isFalse,
        );
      });

      test('omits pdf fields when pdf data is incomplete', () {
        final map = LessonModel(
          lessonId: tLessonId,
          gradeId: tGradeId,
          title: tLessonTitle,
          subtitle: tLessonSubtitle,
          isPublished: true,
          pdfStoragePath: tPdfStoragePath,
        ).toCreateMap();

        expect(
          map.containsKey(FirestoreFields.pdfStoragePath),
          isFalse,
        );
        expect(map.containsKey(FirestoreFields.pdfFileName), isFalse);
        expect(map.containsKey(FirestoreFields.pdfFileSize), isFalse);
      });

      test('trims string values', () {
        final map = LessonModel.fromEntity(
          tLessonEntity.copyWith(
            title: '  $tLessonTitle  ',
            subtitle: '  $tLessonSubtitle  ',
          ),
        ).toCreateMap();

        expect(map[FirestoreFields.title], tLessonTitle);
        expect(
          map[FirestoreFields.description],
          tLessonSubtitle,
        );
      });

      test('writes empty youtube url when missing', () {
        final map = LessonModel.fromEntity(
          tLessonEntity.copyWith(clearYoutubeUrl: true),
        ).toCreateMap();

        expect(map[FirestoreFields.youtubeUrl], isEmpty);
      });
    });

    group('toUpdateMap', () {
      test('does not write createdAt on update', () {
        final map = tLessonModel.toUpdateMap();

        expect(
          map.containsKey(FirestoreFields.createdAt),
          isFalse,
        );
        expect(
          map[FirestoreFields.updatedAt],
          isA<FieldValue>(),
        );
      });

      test(
        'keeps pdf fields when the lesson has a valid pdf',
        () {
          final map = tLessonModel.toUpdateMap();

          expect(map[FirestoreFields.pdfFileName], tPdfFileName);
          expect(map[FirestoreFields.pdfFileSize], tPdfFileSize);
          expect(
            map[FirestoreFields.pdfStoragePath],
            tPdfStoragePath,
          );
        },
      );

      test(
        'does not touch pdf fields when the lesson has no pdf',
        () {
          final map = LessonModel.fromEntity(
            tLessonEntityWithoutPdf,
          ).toUpdateMap();

          expect(
            map.containsKey(FirestoreFields.pdfFileName),
            isFalse,
          );
          expect(
            map.containsKey(FirestoreFields.pdfFileSize),
            isFalse,
          );
          expect(
            map.containsKey(FirestoreFields.pdfStoragePath),
            isFalse,
          );
        },
      );

      test(
        'marks pdf fields for deletion when removePdf is true',
        () {
          final map = tLessonModel.toUpdateMap(removePdf: true);

          expect(
            map[FirestoreFields.pdfFileName],
            FieldValue.delete(),
          );
          expect(
            map[FirestoreFields.pdfFileSize],
            FieldValue.delete(),
          );
          expect(
            map[FirestoreFields.pdfStoragePath],
            FieldValue.delete(),
          );
        },
      );
    });

    group('entity helpers', () {
      test('hasYoutubeVideo reflects the youtube url', () {
        expect(tLessonEntity.hasYoutubeVideo, isTrue);

        final withoutYoutube = tLessonEntity.copyWith(
          clearYoutubeUrl: true,
        );

        expect(withoutYoutube.hasYoutubeVideo, isFalse);
        expect(
          tLessonEntity
              .copyWith(youtubeUrl: '   ')
              .hasYoutubeVideo,
          isFalse,
        );
      });

      test('hasPdfFile reflects the pdf storage path', () {
        expect(tLessonEntity.hasPdfFile, isTrue);
        expect(tLessonEntityWithoutPdf.hasPdfFile, isFalse);
      });

      test(
        'copyWith keeps pdf fields unless clearPdf is true',
        () {
          final kept = tLessonEntity.copyWith(
            title: 'New title',
          );

          expect(kept.pdfStoragePath, tPdfStoragePath);

          final cleared = tLessonEntity.copyWith(clearPdf: true);

          expect(cleared.pdfFileName, isNull);
          expect(cleared.pdfFileSize, isNull);
          expect(cleared.pdfStoragePath, isNull);
        },
      );
    });
  });
}

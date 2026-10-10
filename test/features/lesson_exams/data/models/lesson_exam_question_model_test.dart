import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/lesson_exams/data/models/lesson_exam_question_model.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/entities/lesson_exam_question_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dummy_data.dart';

void main() {
  group('LessonExamQuestionModel', () {
    group('fromEntity', () {
      test('maps all question fields including image metadata', () {
        final model = LessonExamQuestionModel.fromEntity(
          tLessonExamQuestionEntity,
        );

        expect(model.questionId, tLessonExamQuestionId);
        expect(model.lessonId, tLessonId);
        expect(model.questionText, tLessonExamQuestionText);
        expect(model.degree, tLessonExamQuestionDegree);
        expect(model.choices, tLessonExamChoices);
        expect(model.correctChoiceIndex, tLessonExamCorrectChoiceIndex);
        expect(model.imageUrl, tQuestionImageUrl);
        expect(model.imageStoragePath, tQuestionImageStoragePath);
        expect(model.createdAt, tLessonExamQuestionCreatedAt);
      });

      test('is an instance of LessonExamQuestionEntity', () {
        expect(
          LessonExamQuestionModel.fromEntity(tLessonExamQuestionEntity),
          isA<LessonExamQuestionEntity>(),
        );
      });
    });

    group('fromMap', () {
      test('maps a full Firestore document map', () {
        final model = LessonExamQuestionModel.fromMap(
          map: tLessonExamQuestionJson(),
          questionId: tLessonExamQuestionId,
        );

        expect(model.questionId, tLessonExamQuestionId);
        expect(model.lessonId, tLessonId);
        expect(model.questionText, tLessonExamQuestionText);
        expect(model.degree, tLessonExamQuestionDegree);
        expect(model.choices, tLessonExamChoices);
        expect(model.correctChoiceIndex, tLessonExamCorrectChoiceIndex);
        expect(model.imageUrl, tQuestionImageUrl);
        expect(model.imageStoragePath, tQuestionImageStoragePath);
        expect(
          model.createdAt!.isAtSameMomentAs(tLessonExamQuestionCreatedAt),
          isTrue,
        );
      });

      test('maps a document without image fields', () {
        final model = LessonExamQuestionModel.fromMap(
          map: tLessonExamQuestionJsonWithoutImage(),
          questionId: tLessonExamQuestionId,
        );

        expect(model.hasImage, isFalse);
        expect(model.imageUrl, isNull);
        expect(model.imageStoragePath, isNull);
      });

      test('trims strings and treats blank optional strings as null', () {
        final model = LessonExamQuestionModel.fromMap(
          questionId: tLessonExamQuestionId,
          map: {
            FirestoreFields.lessonId: '  $tLessonId  ',
            FirestoreFields.questionText: '  $tLessonExamQuestionText  ',
            FirestoreFields.option1: '  A  ',
            FirestoreFields.option2: '  B  ',
            FirestoreFields.option3: '',
            FirestoreFields.option4: '  D  ',
            FirestoreFields.questionImageUrl: '   ',
            FirestoreFields.questionImageStoragePath: '',
          },
        );

        expect(model.lessonId, tLessonId);
        expect(model.questionText, tLessonExamQuestionText);
        expect(model.choices, ['A', 'B', '', 'D']);
        expect(model.imageUrl, isNull);
        expect(model.imageStoragePath, isNull);
      });

      test('reads numeric fields from int, num, and string values', () {
        final model = LessonExamQuestionModel.fromMap(
          questionId: tLessonExamQuestionId,
          map: {
            FirestoreFields.questionScore: 5.7,
            FirestoreFields.correctOption: '2',
          },
        );

        expect(model.degree, 5);
        expect(model.correctChoiceIndex, 2);
      });

      test('parses date values from ISO strings', () {
        final model = LessonExamQuestionModel.fromMap(
          questionId: tLessonExamQuestionId,
          map: {
            FirestoreFields.createdAt: tLessonExamQuestionCreatedAt
                .toIso8601String(),
            FirestoreFields.updatedAt: tLessonExamQuestionUpdatedAt,
          },
        );

        expect(
          model.createdAt!.isAtSameMomentAs(tLessonExamQuestionCreatedAt),
          isTrue,
        );
        expect(model.updatedAt, tLessonExamQuestionUpdatedAt);
      });

      test('returns null dates for invalid values', () {
        final model = LessonExamQuestionModel.fromMap(
          questionId: tLessonExamQuestionId,
          map: {
            FirestoreFields.createdAt: 'not-a-date',
            FirestoreFields.updatedAt: 42,
          },
        );

        expect(model.createdAt, isNull);
        expect(model.updatedAt, isNull);
      });
    });

    group('toCreateMap', () {
      test('writes Firestore fields with null correct answer by default', () {
        final map = tLessonExamQuestionModel.toCreateMap();

        expect(map[FirestoreFields.lessonId], tLessonId);
        expect(map[FirestoreFields.questionText], tLessonExamQuestionText);
        expect(map[FirestoreFields.questionScore], tLessonExamQuestionDegree);
        expect(map[FirestoreFields.option1], tLessonExamChoices[0]);
        expect(map[FirestoreFields.option2], tLessonExamChoices[1]);
        expect(map[FirestoreFields.option3], tLessonExamChoices[2]);
        expect(map[FirestoreFields.option4], tLessonExamChoices[3]);
        expect(map[FirestoreFields.correctOption], isNull);
      });

      test('fills missing choices with empty strings', () {
        final map = const LessonExamQuestionModel(
          questionId: tLessonExamQuestionId,
          lessonId: tLessonId,
          questionText: tLessonExamQuestionText,
          degree: tLessonExamQuestionDegree,
          choices: ['A'],
        ).toCreateMap();

        expect(map[FirestoreFields.option1], 'A');
        expect(map[FirestoreFields.option2], isEmpty);
        expect(map[FirestoreFields.option3], isEmpty);
        expect(map[FirestoreFields.option4], isEmpty);
      });

      test('trims writable string fields', () {
        final map = const LessonExamQuestionModel(
          questionId: tLessonExamQuestionId,
          lessonId: '  $tLessonId  ',
          questionText: '  Question?  ',
          degree: tLessonExamQuestionDegree,
          choices: [' A ', ' B ', ' C ', ' D '],
        ).toCreateMap();

        expect(map[FirestoreFields.lessonId], tLessonId);
        expect(map[FirestoreFields.questionText], 'Question?');
        expect(map[FirestoreFields.option1], 'A');
      });
    });

    group('toUpdateMap', () {
      test('writes editable fields only', () {
        final map = tLessonExamQuestionModel.toUpdateMap();

        expect(
          map.containsKey(FirestoreFields.lessonId),
          isFalse,
        );
        expect(
          map.containsKey(FirestoreFields.correctOption),
          isFalse,
        );
        expect(map[FirestoreFields.questionText], tLessonExamQuestionText);
        expect(map[FirestoreFields.questionScore], tLessonExamQuestionDegree);
      });
    });

    group('entity helpers', () {
      test('hasImage reflects the image url', () {
        expect(tLessonExamQuestionEntity.hasImage, isTrue);
        expect(tLessonExamQuestionEntityWithoutImage.hasImage, isFalse);
      });

      test('hasCorrectChoice and correctChoice validate the answer index', () {
        expect(tLessonExamQuestionEntity.hasCorrectChoice, isTrue);
        expect(
          tLessonExamQuestionEntity.correctChoice,
          tLessonExamChoices[tLessonExamCorrectChoiceIndex],
        );

        final invalid = tLessonExamQuestionEntity.copyWith(
          correctChoiceIndex: 9,
        );

        expect(invalid.hasCorrectChoice, isFalse);
        expect(invalid.correctChoice, isNull);
      });

      test('copyWith can clear answer and image fields', () {
        final copied = tLessonExamQuestionEntity.copyWith(
          clearCorrectChoiceIndex: true,
          clearImage: true,
        );

        expect(copied.correctChoiceIndex, isNull);
        expect(copied.imageUrl, isNull);
        expect(copied.imageStoragePath, isNull);
      });
    });
  });
}

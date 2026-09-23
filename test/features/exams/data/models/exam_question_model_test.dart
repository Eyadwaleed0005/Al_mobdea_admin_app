import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/exams/data/models/exam_question_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_question_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dummy_data.dart';

void main() {
  group('ExamQuestionModel', () {
    group('fromMap', () {
      test('maps option1..option4 into choices and correct option', () {
        final question = ExamQuestionModel.fromMap(
          questionId: tExamQuestionId,
          data: tExamQuestionJson(),
        );

        expect(question.questionId, tExamQuestionId);
        expect(question.examId, tExamId);
        expect(question.questionText, tExamQuestionText);
        expect(question.degree, tExamQuestionDegree);
        expect(question.choices, tExamChoices);
        expect(question.correctChoiceIndex, tExamCorrectChoiceIndex);
        expect(question.imageUrl, tExamQuestionImageUrl);
        expect(question.imageStoragePath, tExamQuestionImageStoragePath);
        expect(
          question.createdAt!.isAtSameMomentAs(tExamCreatedAt),
          isTrue,
        );
        expect(
          question.updatedAt!.isAtSameMomentAs(tExamUpdatedAt),
          isTrue,
        );
      });

      test('maps null image fields to null (image optional)', () {
        final question = ExamQuestionModel.fromMap(
          questionId: tExamQuestionId,
          data: tExamQuestionJsonWithoutImage(),
        );

        expect(question.imageUrl, isNull);
        expect(question.imageStoragePath, isNull);
        expect(question.hasImage, isFalse);
      });

      test('maps empty string image fields to null', () {
        final question = ExamQuestionModel.fromMap(
          questionId: tExamQuestionId,
          data: {
            ...tExamQuestionJsonWithoutImage(),
            FirestoreFields.questionImageUrl: '   ',
            FirestoreFields.questionImageStoragePath: '',
          },
        );

        expect(question.imageUrl, isNull);
        expect(question.imageStoragePath, isNull);
      });

      test('maps null correctOption to null correctChoiceIndex', () {
        final question = ExamQuestionModel.fromMap(
          questionId: tExamQuestionId,
          data: tExamQuestionJsonWithoutImage(),
        );

        expect(question.correctChoiceIndex, isNull);
        expect(question.hasCorrectChoice, isFalse);
        expect(question.correctChoice, isNull);
      });

      test('always produces exactly four choices', () {
        final question = ExamQuestionModel.fromMap(
          questionId: tExamQuestionId,
          data: {
            ...tExamQuestionJsonWithoutImage(),
            FirestoreFields.option4: null,
          },
        );

        expect(question.choices, hasLength(4));
        expect(question.choices[3], isEmpty);
      });
    });

    group('toMap / toCreateMap', () {
      test('toMap keeps choices and image fields', () {
        final map = tExamQuestionModel.toMap();

        expect(map[FirestoreFields.examId], tExamId);
        expect(map[FirestoreFields.questionText], tExamQuestionText);
        expect(map[FirestoreFields.questionScore], tExamQuestionDegree);
        expect(map[FirestoreFields.option1], tExamChoices[0]);
        expect(map[FirestoreFields.option2], tExamChoices[1]);
        expect(map[FirestoreFields.option3], tExamChoices[2]);
        expect(map[FirestoreFields.option4], tExamChoices[3]);
        expect(map[FirestoreFields.correctOption], tExamCorrectChoiceIndex);
        expect(map[FirestoreFields.questionImageUrl], tExamQuestionImageUrl);
        expect(
          map[FirestoreFields.questionImageStoragePath],
          tExamQuestionImageStoragePath,
        );
        expect(map[FirestoreFields.createdAt], isA<Timestamp>());
      });

      test('toCreateMap uses server timestamps', () {
        final map = tExamQuestionModel.toCreateMap();

        expect(map[FirestoreFields.createdAt], FieldValue.serverTimestamp());
        expect(map[FirestoreFields.updatedAt], FieldValue.serverTimestamp());
      });

      test('round-trips through fromMap', () {
        final map = tExamQuestionModel.toMap();

        final parsed = ExamQuestionModel.fromMap(
          questionId: tExamQuestionModel.questionId,
          data: map,
        );

        expect(parsed.questionId, tExamQuestionModel.questionId);
        expect(parsed.examId, tExamQuestionModel.examId);
        expect(parsed.questionText, tExamQuestionModel.questionText);
        expect(parsed.degree, tExamQuestionModel.degree);
        expect(parsed.choices, tExamQuestionModel.choices);
        expect(parsed.correctChoiceIndex, tExamQuestionModel.correctChoiceIndex);
        expect(parsed.imageUrl, tExamQuestionModel.imageUrl);
        expect(parsed.imageStoragePath, tExamQuestionModel.imageStoragePath);
      });
    });

    group('fromEntity', () {
      test('copies every entity field', () {
        final model = ExamQuestionModel.fromEntity(tExamQuestionEntity);

        expect(model.questionId, tExamQuestionEntity.questionId);
        expect(model.examId, tExamQuestionEntity.examId);
        expect(model.questionText, tExamQuestionEntity.questionText);
        expect(model.degree, tExamQuestionEntity.degree);
        expect(model.choices, tExamQuestionEntity.choices);
        expect(model.correctChoiceIndex, tExamQuestionEntity.correctChoiceIndex);
        expect(model.imageUrl, tExamQuestionEntity.imageUrl);
        expect(model.imageStoragePath, tExamQuestionEntity.imageStoragePath);
      });

      test('result is an ExamQuestionEntity subclass', () {
        expect(ExamQuestionModel.fromEntity(tExamQuestionEntity),
            isA<ExamQuestionEntity>());
      });
    });

    group('hasImage / hasCorrectChoice on model', () {
      test('hasImage is true only when url is non-empty', () {
        expect(tExamQuestionModel.hasImage, isTrue);
        expect(
          ExamQuestionModel.fromEntity(
            tExamQuestionEntityWithoutImage,
          ).hasImage,
          isFalse,
        );
      });

      test('hasCorrectChoice validates the index range', () {
        expect(tExamQuestionModel.hasCorrectChoice, isTrue);

        final outOfRange = tExamQuestionModel.copyWith(
          correctChoiceIndex: tExamChoices.length,
        );

        expect(outOfRange.hasCorrectChoice, isFalse);
        expect(outOfRange.correctChoice, isNull);
      });

      test('correctChoice returns the choice at the index', () {
        expect(
          tExamQuestionModel.correctChoice,
          tExamChoices[tExamCorrectChoiceIndex],
        );
      });
    });
  });
}

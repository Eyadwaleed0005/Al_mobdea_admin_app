import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/exams/data/models/exam_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dummy_data.dart';

void main() {
  group('ExamModel', () {
    group('fromMap', () {
      test('maps a full exam document correctly', () {
        final exam = ExamModel.fromMap(
          examId: tExamId,
          data: tExamJson(),
        );

        expect(exam.examId, tExamId);
        expect(exam.gradeId, tGradeId);
        expect(exam.examName, tExamName);
        expect(exam.durationMinutes, tExamDurationMinutes);
        expect(exam.questionCount, tExamQuestionCount);
        expect(exam.totalScore, tExamTotalScore);
        expect(exam.participantsCount, tExamParticipantsCount);
        expect(exam.status, ExamStatus.unpublished);
        expect(
          exam.createdAt!.isAtSameMomentAs(tExamCreatedAt),
          isTrue,
        );
        expect(
          exam.updatedAt!.isAtSameMomentAs(tExamUpdatedAt),
          isTrue,
        );
        expect(exam.firstAttemptAt, isNull);
        expect(exam.closedAt, isNull);
      });

      test('parses published and ended statuses', () {
        final published = ExamModel.fromMap(
          examId: tExamId,
          data: tPublishedExamJson(),
        );

        final ended = ExamModel.fromMap(
          examId: tExamId,
          data: tEndedExamJson(),
        );

        expect(published.status, ExamStatus.published);
        expect(ended.status, ExamStatus.ended);
        expect(
          ended.closedAt!.isAtSameMomentAs(tExamUpdatedAt),
          isTrue,
        );
      });

      test('falls back to unpublished for unknown status values', () {
        final exam = ExamModel.fromMap(
          examId: tExamId,
          data: {
            ...tExamJson(),
            FirestoreFields.examStatus: 'unknown-status',
          },
        );

        expect(exam.status, ExamStatus.unpublished);
      });

      test('defaults missing numeric fields to zero', () {
        final exam = ExamModel.fromMap(
          examId: tExamId,
          data: const <String, dynamic>{},
        );

        expect(exam.gradeId, isEmpty);
        expect(exam.examName, isEmpty);
        expect(exam.durationMinutes, 0);
        expect(exam.questionCount, 0);
        expect(exam.totalScore, 0);
        expect(exam.participantsCount, 0);
        expect(exam.status, ExamStatus.unpublished);
      });

      test('parses numeric values stored as strings', () {
        final exam = ExamModel.fromMap(
          examId: tExamId,
          data: {
            ...tExamJson(),
            FirestoreFields.durationMinutes: '45',
          },
        );

        expect(exam.durationMinutes, 45);
      });
    });

    group('toMap', () {
      test('serializes status as its json name and timestamps', () {
        final map = tExamModel.toMap();

        expect(map[FirestoreFields.gradeId], tGradeId);
        expect(map[FirestoreFields.examName], tExamName);
        expect(map[FirestoreFields.durationMinutes], tExamDurationMinutes);
        expect(map[FirestoreFields.examStatus], 'unpublished');
        expect(map[FirestoreFields.createdAt], isA<Timestamp>());
        expect(map[FirestoreFields.updatedAt], isA<Timestamp>());
        expect(map[FirestoreFields.firstAttemptAt], isNull);
      });

      test('round-trips through fromMap', () {
        final map = tExamModel.toMap();

        final parsed = ExamModel.fromMap(
          examId: tExamModel.examId,
          data: map,
        );

        expect(parsed.examId, tExamModel.examId);
        expect(parsed.gradeId, tExamModel.gradeId);
        expect(parsed.examName, tExamModel.examName);
        expect(parsed.durationMinutes, tExamModel.durationMinutes);
        expect(parsed.questionCount, tExamModel.questionCount);
        expect(parsed.totalScore, tExamModel.totalScore);
        expect(parsed.participantsCount, tExamModel.participantsCount);
        expect(parsed.status, tExamModel.status);
        expect(
          parsed.createdAt!.isAtSameMomentAs(tExamModel.createdAt!),
          isTrue,
        );
        expect(
          parsed.updatedAt!.isAtSameMomentAs(tExamModel.updatedAt!),
          isTrue,
        );
      });
    });

    group('statusToJson/statusFromJson', () {
      test('statusToJson maps every status value', () {
        expect(ExamModel.statusToJson(ExamStatus.unpublished), 'unpublished');
        expect(ExamModel.statusToJson(ExamStatus.published), 'published');
        expect(ExamModel.statusToJson(ExamStatus.ended), 'ended');
      });

      test('statusFromJson is case-insensitive', () {
        expect(
          ExamModel.statusFromJson('  PUBLISHED '),
          ExamStatus.published,
        );
      });
    });

    group('toEntity / subclass', () {
      test('ExamModel is an ExamEntity and copies questions unmodifiable', () {
        final ExamEntity entity = tExamModel.toEntity();

        expect(entity.examId, tExamId);
        expect(entity.questions.single.questionId, tExamQuestionId);

        expect(
          () => entity.questions.add(tExamQuestionEntity),
          throwsUnsupportedError,
        );
      });

      test('is an ExamEntity instance', () {
        expect(tExamModel, isA<ExamEntity>());
      });
    });
  });
}

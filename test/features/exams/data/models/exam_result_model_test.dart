import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/exams/data/models/exam_result_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_attempt_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dummy_data.dart';

void main() {
  group('ExamResultModel', () {
    group('fromMap', () {
      test('maps a submitted result document', () {
        final result = ExamResultModel.fromMap(
          resultId: tExamResultId,
          data: tExamResultJson(),
        );

        expect(result.resultId, tExamResultId);
        expect(result.examId, tExamId);
        expect(result.studentId, tExamResultStudentId);
        expect(result.studentName, tExamResultStudentName);
        expect(result.gradeId, tGradeId);
        expect(result.gradeName, tExamResultGradeName);
        expect(result.score, tExamResultScore);
        expect(result.totalScore, tExamResultTotalScore);
        expect(result.status, ExamAttemptStatus.submitted);
        expect(
          result.startedAt.isAtSameMomentAs(tExamResultStartedAt),
          isTrue,
        );
        expect(
          result.expiresAt.isAtSameMomentAs(tExamResultExpiresAt),
          isTrue,
        );
        expect(
          result.submittedAt!.isAtSameMomentAs(tExamResultSubmittedAt),
          isTrue,
        );
      });

      test('infers submitted status when only a score exists', () {
        final result = ExamResultModel.fromMap(
          resultId: tExamResultId,
          data: {
            ...tExamResultJson(),
            FirestoreFields.resultStatus: null,
          },
        );

        expect(result.status, ExamAttemptStatus.submitted);
      });

      test('infers inProgress when no score, no submittedAt, no status', () {
        final result = ExamResultModel.fromMap(
          resultId: tExamResultId,
          data: {
            ...tExamResultJson(),
            FirestoreFields.score: null,
            FirestoreFields.submittedAt: null,
            FirestoreFields.resultStatus: null,
          },
        );

        expect(result.status, ExamAttemptStatus.inProgress);
      });

      test('throws FormatException when startedAt is missing', () {
        final data = tExamResultJson()
          ..remove(FirestoreFields.startedAt);

        expect(
          () => ExamResultModel.fromMap(resultId: tExamResultId, data: data),
          throwsFormatException,
        );
      });

      test('throws FormatException when expiresAt is missing', () {
        final data = tExamResultJson()
          ..remove(FirestoreFields.expiresAt);

        expect(
          () => ExamResultModel.fromMap(resultId: tExamResultId, data: data),
          throwsFormatException,
        );
      });
    });

    group('toMap', () {
      test('serializes with trimmed fields and timestamps', () {
        final map = tExamResultModel.toMap();

        expect(map[FirestoreFields.examId], tExamId);
        expect(map[FirestoreFields.studentId], tExamResultStudentId);
        expect(map[FirestoreFields.studentName], tExamResultStudentName);
        expect(map[FirestoreFields.score], tExamResultScore);
        expect(map[FirestoreFields.totalScore], tExamResultTotalScore);
        expect(map[FirestoreFields.resultStatus], 'submitted');
        expect(map[FirestoreFields.startedAt], isA<Timestamp>());
        expect(map[FirestoreFields.expiresAt], isA<Timestamp>());
        expect(map[FirestoreFields.submittedAt], isA<Timestamp>());
      });

      test('round-trips through fromMap', () {
        final map = tExamResultModel.toMap();

        final parsed = ExamResultModel.fromMap(
          resultId: tExamResultModel.resultId,
          data: map,
        );

        expect(parsed.resultId, tExamResultModel.resultId);
        expect(parsed.examId, tExamResultModel.examId);
        expect(parsed.studentId, tExamResultModel.studentId);
        expect(parsed.score, tExamResultModel.score);
        expect(parsed.totalScore, tExamResultModel.totalScore);
        expect(parsed.status, tExamResultModel.status);
        expect(
          parsed.startedAt.isAtSameMomentAs(tExamResultModel.startedAt),
          isTrue,
        );
        expect(
          parsed.expiresAt.isAtSameMomentAs(tExamResultModel.expiresAt),
          isTrue,
        );
        expect(
          parsed.submittedAt!
              .isAtSameMomentAs(tExamResultModel.submittedAt!),
          isTrue,
        );
      });
    });

    group('status helpers', () {
      test('statusToJson maps both statuses', () {
        expect(
          ExamResultModel.statusToJson(ExamAttemptStatus.inProgress),
          'inProgress',
        );
        expect(
          ExamResultModel.statusToJson(ExamAttemptStatus.submitted),
          'submitted',
        );
      });

      test('createResultId combines exam and student ids', () {
        expect(
          ExamResultModel.createResultId(
            examId: tExamId,
            studentId: tExamResultStudentId,
          ),
          tExamResultId,
        );
      });
    });

    group('entity getters on model', () {
      test('percentage, isPassed and isFailed reflect the score', () {
        expect(tExamResultModel.percentage, 80);
        expect(tExamResultModel.isPassed, isTrue);
        expect(tExamResultModel.isFailed, isFalse);
      });

      test('a failing score marks isFailed', () {
        final failing = tExamResultModel.copyWith(score: 2);

        expect(failing.percentage, 40);
        expect(failing.isPassed, isFalse);
        expect(failing.isFailed, isTrue);
      });

      test('an expired inProgress attempt should auto submit', () {
        final expired = tExamResultModel.copyWith(
          status: ExamAttemptStatus.inProgress,
          clearScore: true,
          clearSubmittedAt: true,
          expiresAt: tPastDateTime,
        );

        expect(expired.isExpired, isTrue);
        expect(expired.shouldAutoSubmit, isTrue);
        expect(expired.remainingDuration, Duration.zero);
      });
    });
  });
}

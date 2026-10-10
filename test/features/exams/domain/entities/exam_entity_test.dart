import 'package:al_mobdea_admin/features/exams/domain/entities/exam_attempt_status.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dummy_data.dart';

void main() {
  group('ExamEntity', () {
    group('status getters', () {
      test('isUnpublished / isPublished / isEnded reflect status', () {
        expect(tExamEntity.isUnpublished, isTrue);
        expect(tExamEntity.isPublished, isFalse);
        expect(tExamEntity.isEnded, isFalse);

        expect(tPublishedExamEntity.isPublished, isTrue);

        expect(tEndedExamEntity.isEnded, isTrue);
      });
    });

    group('content getters', () {
      test('hasQuestions is true with questionCount or questions', () {
        expect(tExamEntity.hasQuestions, isTrue);

        final emptyExam = ExamEntity.empty(examId: tExamId);

        expect(emptyExam.hasQuestions, isFalse);
      });

      test('hasParticipants is true only with participants', () {
        expect(tExamEntity.hasParticipants, isFalse);

        final withParticipants = tExamEntity.copyWith(participantsCount: 3);

        expect(withParticipants.hasParticipants, isTrue);
      });
    });

    group('hasStartedAttempts', () {
      test('false when no firstAttemptAt and no participants', () {
        expect(tExamEntity.hasStartedAttempts, isFalse);
      });

      test('true when firstAttemptAt exists', () {
        final started = tExamEntity.copyWith(firstAttemptAt: tExamCreatedAt);

        expect(started.hasStartedAttempts, isTrue);
      });

      test('true when participants exist', () {
        final started = tExamEntity.copyWith(participantsCount: 1);

        expect(started.hasStartedAttempts, isTrue);
      });
    });

    group('edit guards', () {
      test('unpublished exam without attempts can edit everything', () {
        expect(tExamEntity.canEditSettings, isTrue);
        expect(tExamEntity.canEditQuestions, isTrue);
        expect(tExamEntity.canEditDuration, isTrue);
        expect(tExamEntity.canEditGrade, isTrue);
        expect(tExamEntity.canEditName, isTrue);
        expect(tExamEntity.canChangePublicationStatus, isTrue);
        expect(tExamEntity.canDelete, isTrue);
      });

      test('ended exam cannot be edited or deleted', () {
        expect(tEndedExamEntity.canEditSettings, isFalse);
        expect(tEndedExamEntity.canEditQuestions, isFalse);
        expect(tEndedExamEntity.canChangePublicationStatus, isFalse);
        expect(tEndedExamEntity.canDelete, isFalse);
        expect(tEndedExamEntity.canViewResults, isTrue);
      });

      test('exam with started attempts locks editing but allows close only',
          () {
        final started = tExamEntity.copyWith(
          status: ExamStatus.published,
          participantsCount: 2,
        );

        expect(started.canEditSettings, isFalse);
        expect(started.canEditQuestions, isFalse);
        expect(started.canChangePublicationStatus, isFalse);
        expect(started.canDelete, isFalse);
      });

      test('published exam without attempts cannot view results yet', () {
        expect(tPublishedExamEntity.canViewResults, isFalse);
      });
    });

    group('correct answer getters', () {
      test(
          'allQuestionsHaveCorrectAnswers is false for an exam without questions',
          () {
        final noQuestions = tExamEntity.copyWith(questions: []);

        expect(noQuestions.allQuestionsHaveCorrectAnswers, isFalse);
        expect(noQuestions.hasQuestionsWithoutCorrectAnswer, isFalse);
      });

      test('a question without a correct choice blocks publication', () {
        final incomplete = tExamEntity.copyWith(
          questions: [
            tExamQuestionEntity.copyWith(clearCorrectChoiceIndex: true),
          ],
        );

        expect(incomplete.hasQuestionsWithoutCorrectAnswer, isTrue);
        expect(incomplete.allQuestionsHaveCorrectAnswers, isFalse);
      });
    });

    group('canPublish', () {
      test('unpublished exam with valid questions can publish', () {
        expect(tExamEntity.canPublish, isTrue);
      });

      test('published exam cannot publish again', () {
        expect(tPublishedExamEntity.canPublish, isFalse);
      });

      test('exam with started attempts cannot publish', () {
        final started = tExamEntity.copyWith(participantsCount: 1);

        expect(started.canPublish, isFalse);
      });

      test('exam without questions cannot publish', () {
        final noQuestions = tExamEntity.copyWith(questions: []);

        expect(noQuestions.canPublish, isFalse);
      });

      test(
          'exam with missing correct answers cannot publish even when valid',
          () {
        final invalid = tExamEntity.copyWith(
          questions: [
            tExamQuestionEntity.copyWith(clearCorrectChoiceIndex: true),
          ],
        );

        expect(invalid.canPublish, isFalse);
      });
    });

    group('canEnd', () {
      test('only a published exam can end', () {
        expect(tExamEntity.canEnd, isFalse);
        expect(tPublishedExamEntity.canEnd, isTrue);
        expect(tEndedExamEntity.canEnd, isFalse);
      });
    });

    group('copyWith', () {
      test('keeps existing values when nothing is passed', () {
        final copy = tExamEntity.copyWith();

        expect(copy.examId, tExamEntity.examId);
        expect(copy.status, tExamEntity.status);
        expect(copy.firstAttemptAt, tExamEntity.firstAttemptAt);
      });

      test('overrides provided fields', () {
        final copy = tExamEntity.copyWith(
          examName: 'New name',
          durationMinutes: 120,
          status: ExamStatus.published,
        );

        expect(copy.examName, 'New name');
        expect(copy.durationMinutes, 120);
        expect(copy.status, ExamStatus.published);
      });

      test('clearFirstAttemptAt and clearClosedAt reset nullable fields', () {
        final withDates = tExamEntity.copyWith(
          firstAttemptAt: tExamCreatedAt,
          closedAt: tExamUpdatedAt,
        );

        final cleared = withDates.copyWith(
          clearFirstAttemptAt: true,
          clearClosedAt: true,
        );

        expect(cleared.firstAttemptAt, isNull);
        expect(cleared.closedAt, isNull);
      });

      test('clearFirstAttemptAt does not clear when explicitly passed', () {
        final withDate = tExamEntity.copyWith(firstAttemptAt: tExamCreatedAt);

        final reSet = withDate.copyWith(firstAttemptAt: tExamUpdatedAt);

        expect(reSet.firstAttemptAt, tExamUpdatedAt);
      });
    });

    group('empty factory', () {
      test('creates an unpublished empty exam', () {
        final exam = ExamEntity.empty(examId: tExamId);

        expect(exam.examId, tExamId);
        expect(exam.gradeId, isEmpty);
        expect(exam.examName, isEmpty);
        expect(exam.durationMinutes, 0);
        expect(exam.questionCount, 0);
        expect(exam.totalScore, 0);
        expect(exam.participantsCount, 0);
        expect(exam.status, ExamStatus.unpublished);
        expect(exam.questions, isEmpty);
      });
    });

    group('results entity getters', () {
      test('exam result entity percentage and pass logic', () {
        expect(tExamResultEntity.percentage, 80);
        expect(tExamResultEntity.isSubmitted, isTrue);
        expect(tExamResultEntity.isInProgress, isFalse);
        expect(tExamResultEntity.isPassed, isTrue);
        expect(tExamResultEntity.isFailed, isFalse);
      });

      test('boundary score of exactly 50 percent passes', () {
        final boundary = tExamResultEntity.copyWith(
          score: 10,
          totalScore: 20,
        );

        expect(boundary.percentage, 50);
        expect(boundary.isPassed, isTrue);
      });

      test('hasValidScore rejects out-of-range scores', () {
        expect(tExamResultEntity.hasValidScore, isTrue);

        final negative = tExamResultEntity.copyWith(score: -1);
        final tooBig = tExamResultEntity.copyWith(
          score: tExamResultTotalScore + 1,
        );
        final zeroTotal = tExamResultEntity.copyWith(totalScore: 0);

        expect(negative.hasValidScore, isFalse);
        expect(tooBig.hasValidScore, isFalse);
        expect(zeroTotal.hasValidScore, isFalse);
      });

      test('inProgress attempt that has not expired is not auto submitted', () {
        expect(tInProgressExamResultEntity.isInProgress, isTrue);
        expect(tInProgressExamResultEntity.isExpired, isFalse);
        expect(tInProgressExamResultEntity.shouldAutoSubmit, isFalse);
        expect(tInProgressExamResultEntity.remainingDuration,
            isA<Duration>());
        expect(tInProgressExamResultEntity.percentage, 0);
      });

      test('copyWith clearScore and clearSubmittedAt reset values', () {
        final cleared = tExamResultEntity.copyWith(
          clearScore: true,
          clearSubmittedAt: true,
        );

        expect(cleared.score, isNull);
        expect(cleared.submittedAt, isNull);
        expect(cleared.hasScore, isFalse);
      });

      test('status enum values are exhaustive', () {
        expect(ExamAttemptStatus.values, hasLength(2));
        expect(
          ExamAttemptStatus.values,
          containsAll([
            ExamAttemptStatus.inProgress,
            ExamAttemptStatus.submitted,
          ]),
        );
      });
    });
  });
}

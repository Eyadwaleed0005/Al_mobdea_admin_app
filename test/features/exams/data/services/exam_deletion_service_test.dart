import 'package:al_mobdea_admin/core/firebase/firestore/firestore_collections.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_deletion_service.dart';
import 'package:al_mobdea_admin/features/exams/data/validation/exams_data_validator.dart';
import 'package:al_mobdea_admin/features/exams/data/validation/policy/exam_editing_policy.dart';
import 'package:al_mobdea_admin/features/exams/domain/exam_question_image_file.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockExamQuestionImageService imageService;
  late ExamDeletionService deletionService;

  setUpAll(() {
    registerFallbackValue(tExamQuestionImageFile);
  });

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    imageService = MockExamQuestionImageService();

    when(
      () => imageService.deleteImage(
        storagePath: any(named: 'storagePath'),
      ),
    ).thenAnswer((_) async {});

    deletionService = ExamDeletionService(
      firebaseFirestore: fakeFirestore,
      examsDataValidator: const ExamsDataValidator(),
      examEditingPolicy: const ExamEditingPolicy(),
      examQuestionImageService: imageService,
    );
  });

  Future<void> seedExam({Map<String, dynamic>? map}) {
    return fakeFirestore
        .collection(FirestoreCollections.exams)
        .doc(tExamId)
        .set(map ?? tExamJson());
  }

  Future<void> seedQuestion({Map<String, dynamic>? map}) {
    return fakeFirestore
        .collection(FirestoreCollections.examQuestions)
        .doc(tExamQuestionId)
        .set(map ?? tExamQuestionJson());
  }

  group('deleteQuestion', () {
    test(
      'deletes the question and decrements exam counters',
      () async {
        await seedExam();
        await seedQuestion();

        await deletionService.deleteQuestion(
          examId: tExamId,
          questionId: tExamQuestionId,
        );

        final questionSnapshot = await fakeFirestore
            .collection(FirestoreCollections.examQuestions)
            .doc(tExamQuestionId)
            .get();

        expect(questionSnapshot.exists, isFalse);

        final examData = await fakeFirestore
            .collection(FirestoreCollections.exams)
            .doc(tExamId)
            .get()
            .then((snapshot) => snapshot.data()!);

        expect(examData[FirestoreFields.questionCount], 0);
        expect(examData[FirestoreFields.totalScore], 0);
        expect(
          examData[FirestoreFields.examStatus],
          'unpublished',
        );
      },
    );

    test('deletes the question image when it exists', () async {
      await seedExam();
      await seedQuestion();

      await deletionService.deleteQuestion(
        examId: tExamId,
        questionId: tExamQuestionId,
      );

      verify(
        () => imageService.deleteImage(
          storagePath: tExamQuestionImageStoragePath,
        ),
      ).called(1);
    });

    test(
      'does not delete any image for a question without image',
      () async {
        await seedExam();
        await seedQuestion(map: tExamQuestionJsonWithoutImage());

        await deletionService.deleteQuestion(
          examId: tExamId,
          questionId: tExamQuestionId,
        );

        verify(
          () => imageService.deleteImage(storagePath: null),
        ).called(1);
      },
    );

    test('throws when the exam has started attempts', () async {
      await seedExam();
      await seedQuestion();

      await fakeFirestore
          .collection(FirestoreCollections.exams)
          .doc(tExamId)
          .update({FirestoreFields.participantsCount: 2});

      await expectLater(
        () => deletionService.deleteQuestion(
          examId: tExamId,
          questionId: tExamQuestionId,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('throws when the exam is missing', () async {
      await expectLater(
        () => deletionService.deleteQuestion(
          examId: 'missing-exam',
          questionId: tExamQuestionId,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'returns silently when the question is already gone',
      () async {
        await seedExam();

        await expectLater(
          deletionService.deleteQuestion(
            examId: tExamId,
            questionId: 'already-deleted',
          ),
          completes,
        );
      },
    );
  });

  group('deleteExam', () {
    test(
      'deletes the exam, its questions, results, and answers',
      () async {
        await seedExam();
        await seedQuestion();
        await fakeFirestore
            .collection(FirestoreCollections.examResults)
            .doc(tExamResultId)
            .set(tExamResultJson());
        await fakeFirestore
            .collection(FirestoreCollections.examAttemptAnswers)
            .doc('answer-1')
            .set({
              FirestoreFields.examId: tExamId,
              FirestoreFields.studentId: tExamResultStudentId,
            });

        await deletionService.deleteExam(examId: tExamId);

        final examSnapshot = await fakeFirestore
            .collection(FirestoreCollections.exams)
            .doc(tExamId)
            .get();

        final questionsSnapshot = await fakeFirestore
            .collection(FirestoreCollections.examQuestions)
            .where(FirestoreFields.examId, isEqualTo: tExamId)
            .get();

        final resultsSnapshot = await fakeFirestore
            .collection(FirestoreCollections.examResults)
            .where(FirestoreFields.examId, isEqualTo: tExamId)
            .get();

        final answersSnapshot = await fakeFirestore
            .collection(FirestoreCollections.examAttemptAnswers)
            .where(FirestoreFields.examId, isEqualTo: tExamId)
            .get();

        expect(examSnapshot.exists, isFalse);
        expect(questionsSnapshot.docs, isEmpty);
        expect(resultsSnapshot.docs, isEmpty);
        expect(answersSnapshot.docs, isEmpty);
      },
    );

    test('deletes every question image', () async {
      await seedExam();
      await seedQuestion();
      await fakeFirestore
          .collection(FirestoreCollections.examQuestions)
          .doc(tSecondExamQuestionId)
          .set(tSecondExamQuestionJson());

      await deletionService.deleteExam(examId: tExamId);

      verify(
        () => imageService.deleteImage(
          storagePath: tExamQuestionImageStoragePath,
        ),
      ).called(1);
    });

    test('skips an already deleted exam silently', () async {
      await expectLater(
        deletionService.deleteExam(examId: 'missing-exam'),
        completes,
      );
    });

    test(
      'marks the exam as deleting before cascading',
      () async {
        await seedExam();
        await seedQuestion();

        ExamQuestionImageFile? capturedImage;

        await deletionService.deleteExam(examId: tExamId);

        final questionsSnapshot = await fakeFirestore
            .collection(FirestoreCollections.examQuestions)
            .where(FirestoreFields.examId, isEqualTo: tExamId)
            .get();

        expect(questionsSnapshot.docs, isEmpty);

        // The image deletion receives the storage path of the seeded question.
        final captured = verify(
          () => imageService.deleteImage(
            storagePath: captureAny(named: 'storagePath'),
          ),
        ).captured;

        capturedImage;
        expect(
          captured,
          contains(tExamQuestionImageStoragePath),
        );
      },
    );

    test(
      'refuses to delete an exam with started attempts',
      () async {
        await seedExam(
          map: {
            ...tExamJson(),
            FirestoreFields.participantsCount: 3,
          },
        );

        await expectLater(
          () => deletionService.deleteExam(examId: tExamId),
          throwsA(isA<Exception>()),
        );

        final examSnapshot = await fakeFirestore
            .collection(FirestoreCollections.exams)
            .doc(tExamId)
            .get();

        expect(examSnapshot.exists, isTrue);
      },
    );

    test('ended exams can be deleted', () async {
      await seedExam(map: tEndedExamJson());

      await expectLater(
        deletionService.deleteExam(examId: tExamId),
        completes,
      );

      final examSnapshot = await fakeFirestore
          .collection(FirestoreCollections.exams)
          .doc(tExamId)
          .get();

      expect(examSnapshot.exists, isFalse);
    });
  });
}

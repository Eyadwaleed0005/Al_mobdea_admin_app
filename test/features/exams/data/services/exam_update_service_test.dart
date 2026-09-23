import 'package:al_mobdea_admin/core/firebase/firestore/firestore_collections.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/exams/data/models/exam_model.dart';
import 'package:al_mobdea_admin/features/exams/data/models/exam_question_model.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_firestore_guard_service.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_question_image_service.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_update_service.dart';
import 'package:al_mobdea_admin/features/exams/data/validation/exams_data_validator.dart';
import 'package:al_mobdea_admin/features/exams/data/validation/policy/exam_editing_policy.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockExamQuestionImageService imageService;
  late ExamUpdateService updateService;

  setUpAll(() {
    registerFallbackValue(tExamQuestionImageFile);
  });

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    imageService = MockExamQuestionImageService();

    when(
      () => imageService.deleteImageSilently(
        storagePath: any(named: 'storagePath'),
      ),
    ).thenAnswer((_) async {});

    updateService = ExamUpdateService(
      firebaseFirestore: fakeFirestore,
      examsDataValidator: const ExamsDataValidator(),
      examFirestoreGuardService: ExamFirestoreGuardService(
        editingPolicy: const ExamEditingPolicy(),
      ),
      examQuestionImageService: imageService,
    );
  });

  Future<void> seedExam({
    Map<String, dynamic>? map,
    int questionCount = tExamQuestionCount,
    int totalScore = tExamTotalScore,
  }) {
    return fakeFirestore
        .collection(FirestoreCollections.exams)
        .doc(tExamId)
        .set({
          ...tExamJson(),
          ...?map,
          FirestoreFields.questionCount: questionCount,
          FirestoreFields.totalScore: totalScore,
        });
  }

  Future<void> seedQuestion({Map<String, dynamic>? map}) {
    return fakeFirestore
        .collection(FirestoreCollections.examQuestions)
        .doc(tExamQuestionId)
        .set(map ?? tExamQuestionJson());
  }

  ExamQuestionModel updatedQuestion() {
    final updated = ExamQuestionModel(
      questionId: tExamQuestionModel.questionId,
      examId: tExamQuestionModel.examId,
      questionText: 'Updated question?',
      degree: 8,
      choices: const ['A', 'B', 'C', 'D'],
      correctChoiceIndex: 2,
      imageUrl: tExamQuestionModel.imageUrl,
      imageStoragePath: tExamQuestionModel.imageStoragePath,
    );
    return updated;
  }

  group('updateExam', () {
    test(
      'updates the exam settings inside a transaction',
      () async {
        await seedExam();

        final updated = ExamModel(
          examId: tExamId,
          gradeId: tGradeId,
          examName: 'Renamed Exam',
          durationMinutes: 45,
          questionCount: tExamQuestionCount,
          totalScore: tExamTotalScore,
          status: ExamStatus.published,
          participantsCount: tExamParticipantsCount,
          questions: const [],
        );

        await updateService.updateExam(exam: updated);

        final data = await fakeFirestore
            .collection(FirestoreCollections.exams)
            .doc(tExamId)
            .get()
            .then((snapshot) => snapshot.data()!);

        expect(data[FirestoreFields.examName], 'Renamed Exam');
        expect(data[FirestoreFields.durationMinutes], 45);
        expect(data[FirestoreFields.examStatus], 'published');
        expect(data[FirestoreFields.closedAt], isNull);
      },
    );

    test('sets closedAt when the exam is being ended', () async {
      await seedExam();

      final ending = ExamModel(
        examId: tExamId,
        gradeId: tGradeId,
        examName: tExamName,
        durationMinutes: tExamDurationMinutes,
        questionCount: tExamQuestionCount,
        totalScore: tExamTotalScore,
        status: ExamStatus.ended,
        questions: const [],
      );

      await updateService.updateExam(exam: ending);

      final data = await fakeFirestore
          .collection(FirestoreCollections.exams)
          .doc(tExamId)
          .get()
          .then((snapshot) => snapshot.data()!);

      expect(data[FirestoreFields.examStatus], 'ended');
      expect(data[FirestoreFields.closedAt], isA<Timestamp>());
    });

    test(
      'rejects publishing an exam without questions',
      () async {
        await seedExam(questionCount: 0);

        final publishing = ExamModel(
          examId: tExamId,
          gradeId: tGradeId,
          examName: tExamName,
          durationMinutes: tExamDurationMinutes,
          questionCount: 0,
          totalScore: 0,
          status: ExamStatus.published,
          questions: const [],
        );

        await expectLater(
          () => updateService.updateExam(exam: publishing),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('rejects updates for an ended exam', () async {
      await seedExam(map: tEndedExamJson());

      final updated = ExamModel(
        examId: tExamId,
        gradeId: tGradeId,
        examName: 'Should fail',
        durationMinutes: 30,
        questionCount: tExamQuestionCount,
        totalScore: tExamTotalScore,
        status: ExamStatus.ended,
        questions: const [],
      );

      await expectLater(
        () => updateService.updateExam(exam: updated),
        throwsA(isA<Exception>()),
      );
    });

    test('rejects invalid payloads', () async {
      await seedExam();

      final invalid = ExamModel(
        examId: tExamId,
        gradeId: tGradeId,
        examName: '   ',
        durationMinutes: 0,
        questionCount: tExamQuestionCount,
        totalScore: tExamTotalScore,
        status: ExamStatus.published,
        questions: const [],
      );

      await expectLater(
        () => updateService.updateExam(exam: invalid),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateQuestion', () {
    test(
      'updates question fields without touching the image',
      () async {
        await seedExam();
        await seedQuestion();

        await updateService.updateQuestion(
          question: updatedQuestion(),
          removeCurrentImage: false,
        );

        final data = await fakeFirestore
            .collection(FirestoreCollections.examQuestions)
            .doc(tExamQuestionId)
            .get()
            .then((snapshot) => snapshot.data()!);

        expect(
          data[FirestoreFields.questionText],
          'Updated question?',
        );
        expect(data[FirestoreFields.questionScore], 8);
        expect(data[FirestoreFields.correctOption], 2);
        expect(
          data[FirestoreFields.questionImageUrl],
          tExamQuestionImageUrl,
        );
        expect(
          data[FirestoreFields.questionImageStoragePath],
          tExamQuestionImageStoragePath,
        );

        final examData = await fakeFirestore
            .collection(FirestoreCollections.exams)
            .doc(tExamId)
            .get()
            .then((snapshot) => snapshot.data()!);

        // Degree changed 5 -> 8, so totalScore increases by 3.
        expect(
          examData[FirestoreFields.totalScore],
          tExamTotalScore + 3,
        );

        verifyNever(
          () => imageService.uploadImage(
            image: any(named: 'image'),
            examId: any(named: 'examId'),
            questionId: any(named: 'questionId'),
          ),
        );
        verifyNever(
          () => imageService.deleteImageSilently(
            storagePath: any(named: 'storagePath'),
          ),
        );
      },
    );

    test('removes the current image when removeCurrentImage is true', () async {
      await seedExam();
      await seedQuestion();

      await updateService.updateQuestion(
        question: tExamQuestionModel,
        removeCurrentImage: true,
      );

      final data = await fakeFirestore
          .collection(FirestoreCollections.examQuestions)
          .doc(tExamQuestionId)
          .get()
          .then((snapshot) => snapshot.data()!);

      expect(data[FirestoreFields.questionImageUrl], isNull);
      expect(
        data[FirestoreFields.questionImageStoragePath],
        isNull,
      );

      verify(
        () => imageService.deleteImageSilently(
          storagePath: tExamQuestionImageStoragePath,
        ),
      ).called(1);
    });

    test(
      'uploads a replacement image and deletes the old one',
      () async {
        await seedExam();
        await seedQuestion();

        when(
          () => imageService.uploadImage(
            image: any(named: 'image'),
            examId: any(named: 'examId'),
            questionId: any(named: 'questionId'),
          ),
        ).thenAnswer(
          (_) async => const ExamQuestionImageUploadResult(
            downloadUrl: tExamQuestionImageDownloadUrl,
            storagePath:
                tReplacementExamQuestionImageStoragePath,
          ),
        );

        await updateService.updateQuestion(
          question: tExamQuestionModel,
          newImage: tExamQuestionImageFile,
          removeCurrentImage: false,
        );

        final data = await fakeFirestore
            .collection(FirestoreCollections.examQuestions)
            .doc(tExamQuestionId)
            .get()
            .then((snapshot) => snapshot.data()!);

        expect(
          data[FirestoreFields.questionImageUrl],
          tExamQuestionImageDownloadUrl,
        );
        expect(
          data[FirestoreFields.questionImageStoragePath],
          tReplacementExamQuestionImageStoragePath,
        );

        verify(
          () => imageService.deleteImageSilently(
            storagePath: tExamQuestionImageStoragePath,
          ),
        ).called(1);
      },
    );

    test(
      'throws when replacing and removing an image at once',
      () async {
        await seedExam();
        await seedQuestion();

        await expectLater(
          () => updateService.updateQuestion(
            question: tExamQuestionModel,
            newImage: tExamQuestionImageFile,
            removeCurrentImage: true,
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('throws when the exam has started attempts', () async {
      await seedExam();
      await seedQuestion();

      await fakeFirestore
          .collection(FirestoreCollections.exams)
          .doc(tExamId)
          .update({
            FirestoreFields.firstAttemptAt: Timestamp.fromDate(
              tExamCreatedAt,
            ),
          });

      await expectLater(
        () => updateService.updateQuestion(
          question: tExamQuestionModel,
          removeCurrentImage: false,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'throws when the question belongs to another exam',
      () async {
        await seedExam();
        await seedQuestion(
          map: tExamQuestionJson(examId: 'another-exam'),
        );

        await expectLater(
          () => updateService.updateQuestion(
            question: tExamQuestionModel,
            removeCurrentImage: false,
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('rolls the replacement image back when the transaction fails', () async {
      final failingFirestore = _FailingTransactionFakeFirestore();

      // Seed the exam and question into the same instance the failing
      // service reads from, so the pre-transaction reads succeed.
      await failingFirestore
          .collection(FirestoreCollections.exams)
          .doc(tExamId)
          .set(tExamJson());
      await failingFirestore
          .collection(FirestoreCollections.examQuestions)
          .doc(tExamQuestionId)
          .set(tExamQuestionJson());

      when(
        () => imageService.uploadImage(
          image: any(named: 'image'),
          examId: any(named: 'examId'),
          questionId: any(named: 'questionId'),
        ),
      ).thenAnswer(
        (_) async => const ExamQuestionImageUploadResult(
          downloadUrl: tExamQuestionImageDownloadUrl,
          storagePath: tReplacementExamQuestionImageStoragePath,
        ),
      );

      final failingService = ExamUpdateService(
        firebaseFirestore: failingFirestore,
        examsDataValidator: const ExamsDataValidator(),
        examFirestoreGuardService: ExamFirestoreGuardService(
          editingPolicy: const ExamEditingPolicy(),
        ),
        examQuestionImageService: imageService,
      );

      await expectLater(
        () => failingService.updateQuestion(
          question: tExamQuestionModel,
          newImage: tExamQuestionImageFile,
          removeCurrentImage: false,
        ),
        throwsA(isA<Exception>()),
      );

      verify(
        () => imageService.deleteImageSilently(
          storagePath: tReplacementExamQuestionImageStoragePath,
        ),
      ).called(1);
      verifyNever(
        () => imageService.deleteImageSilently(
          storagePath: tExamQuestionImageStoragePath,
        ),
      );
    });
  });
}

/// A fake firestore whose transactions always fail.
class _FailingTransactionFakeFirestore
    extends FakeFirebaseFirestore {
  @override
  Future<T> runTransaction<T>(
    TransactionHandler<T> transactionHandler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) {
    throw Exception('transaction failed');
  }
}

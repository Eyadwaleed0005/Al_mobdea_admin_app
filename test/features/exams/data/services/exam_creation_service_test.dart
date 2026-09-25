import 'package:al_mobdea_admin/core/firebase/firestore/firestore_collections.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/exams/data/models/exam_model.dart';
import 'package:al_mobdea_admin/features/exams/data/models/exam_question_model.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_creation_service.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_firestore_guard_service.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_question_image_service.dart';
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
  late ExamCreationService creationService;

  setUpAll(() {
    registerFallbackValue(tExamQuestionImageFile);
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    imageService = MockExamQuestionImageService();

    when(
      () => imageService.uploadImage(
        image: any(named: 'image'),
        examId: any(named: 'examId'),
        questionId: any(named: 'questionId'),
      ),
    ).thenAnswer(
      (_) async => const ExamQuestionImageUploadResult(
        downloadUrl: tExamQuestionImageDownloadUrl,
        storagePath: tExamQuestionImageStoragePath,
      ),
    );

    when(
      () => imageService.deleteImagesSilently(
        storagePaths: any(named: 'storagePaths'),
      ),
    ).thenAnswer((_) async {});

    when(
      () => imageService.deleteImageSilently(
        storagePath: any(named: 'storagePath'),
      ),
    ).thenAnswer((_) async {});

    creationService = ExamCreationService(
      firebaseFirestore: fakeFirestore,
      examsDataValidator: const ExamsDataValidator(),
      examFirestoreGuardService: ExamFirestoreGuardService(
        editingPolicy: const ExamEditingPolicy(),
      ),
      examQuestionImageService: imageService,
    );
  });

  ExamQuestionModel questionWithoutImage() {
    return ExamQuestionModel(
      questionId: tExamQuestionId,
      examId: tExamId,
      questionText: tExamQuestionText,
      degree: tExamQuestionDegree,
      choices: tExamChoices,
      correctChoiceIndex: tExamCorrectChoiceIndex,
    );
  }

  ExamModel buildExam({
    String? examName,
    int? questionCount,
    int? totalScore,
    ExamStatus status = ExamStatus.unpublished,
  }) {
    return ExamModel(
      examId: '',
      gradeId: tGradeId,
      examName: examName ?? tExamName,
      durationMinutes: tExamDurationMinutes,
      questionCount: questionCount ?? 1,
      totalScore: totalScore ?? tExamTotalScore,
      status: status,
      questions: const [],
    );
  }

  group('createExam', () {
    test('creates the exam document and questions with generated ids', () async {
      final examId = await creationService.createExam(
        exam: buildExam(),
        questions: [questionWithoutImage()],
        questionImages: const {},
      );

      expect(examId, isNotEmpty);

      final examSnapshot = await fakeFirestore
          .collection(FirestoreCollections.exams)
          .doc(examId)
          .get();

      expect(examSnapshot.exists, isTrue);

      final examData = examSnapshot.data()!;

      expect(examData[FirestoreFields.gradeId], tGradeId);
      expect(examData[FirestoreFields.examName], tExamName);
      expect(examData[FirestoreFields.questionCount], 1);
      expect(
        examData[FirestoreFields.totalScore],
        tExamTotalScore,
      );
      expect(
        examData[FirestoreFields.examStatus],
        'unpublished',
      );
      expect(examData[FirestoreFields.isDeleting], false);
      expect(
        examData[FirestoreFields.createdAt],
        isA<Timestamp>(),
      );

      final questions = await fakeFirestore
          .collection(FirestoreCollections.examQuestions)
          .where(FirestoreFields.examId, isEqualTo: examId)
          .get();

      expect(questions.docs, hasLength(1));
      expect(
        questions.docs.single
            .data()[FirestoreFields.questionText],
        tExamQuestionText,
      );
      expect(questions.docs.single.id, '${examId}_0000');
    });

    test(
      'uploads images for the questions that have one',
      () async {
        final examId = await creationService.createExam(
          exam: buildExam(),
          questions: [tExamQuestionModel],
          questionImages: {
            tExamQuestionId: tExamQuestionImageFile,
          },
        );

        verify(
          () => imageService.uploadImage(
            image: tExamQuestionImageFile,
            examId: examId,
            questionId: '${examId}_0000',
          ),
        ).called(1);

        final questions = await fakeFirestore
            .collection(FirestoreCollections.examQuestions)
            .where(FirestoreFields.examId, isEqualTo: examId)
            .get();

        final questionData = questions.docs.single.data();

        expect(
          questionData[FirestoreFields.questionImageUrl],
          tExamQuestionImageDownloadUrl,
        );
        expect(
          questionData[FirestoreFields.questionImageStoragePath],
          tExamQuestionImageStoragePath,
        );
      },
    );

    test(
      'does not touch storage when no images are provided',
      () async {
        await creationService.createExam(
          exam: buildExam(),
          questions: [questionWithoutImage()],
          questionImages: const {},
        );

        verifyNever(
          () => imageService.uploadImage(
            image: any(named: 'image'),
            examId: any(named: 'examId'),
            questionId: any(named: 'questionId'),
          ),
        );
      },
    );

    test('throws for an empty questions list', () async {
      await expectLater(
        () => creationService.createExam(
          exam: buildExam(questionCount: 0, totalScore: 0),
          questions: const [],
          questionImages: const {},
        ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'throws when the total score does not match the degrees',
      () async {
        await expectLater(
          () => creationService.createExam(
            exam: buildExam(totalScore: 999),
            questions: [questionWithoutImage()],
            questionImages: const {},
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test(
      'throws when the question count does not match',
      () async {
        await expectLater(
          () => creationService.createExam(
            exam: buildExam(questionCount: 5),
            questions: [questionWithoutImage()],
            questionImages: const {},
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('throws for an ended status', () async {
      await expectLater(
        () => creationService.createExam(
          exam: buildExam(status: ExamStatus.ended),
          questions: [questionWithoutImage()],
          questionImages: const {},
        ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'throws when an image key does not match any question',
      () async {
        await expectLater(
          () => creationService.createExam(
            exam: buildExam(),
            questions: [questionWithoutImage()],
            questionImages: {
              'unknown-question': tExamQuestionImageFile,
            },
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test(
      'rolls back uploaded images when a later upload fails',
      () async {
        var callCount = 0;

        when(
          () => imageService.uploadImage(
            image: any(named: 'image'),
            examId: any(named: 'examId'),
            questionId: any(named: 'questionId'),
          ),
        ).thenAnswer((_) async {
          callCount++;

          if (callCount == 2) {
            throw Exception('upload failed');
          }

          return const ExamQuestionImageUploadResult(
            downloadUrl: tExamQuestionImageDownloadUrl,
            storagePath: tExamQuestionImageStoragePath,
          );
        });

        await expectLater(
          () => creationService.createExam(
            exam: buildExam(questionCount: 2, totalScore: 15),
            questions: [
              tExamQuestionModel,
              tSecondExamQuestionModel,
            ],
            questionImages: {
              tExamQuestionId: tExamQuestionImageFile,
              tSecondExamQuestionId: tExamQuestionImageFile,
            },
          ),
          throwsA(isA<Exception>()),
        );

        verify(
          () => imageService.deleteImagesSilently(
            storagePaths: any(named: 'storagePaths'),
          ),
        ).called(1);
      },
    );
  });

  group('createQuestion', () {
    Future<void> seedExam({
      ExamStatus status = ExamStatus.unpublished,
    }) {
      return fakeFirestore
          .collection(FirestoreCollections.exams)
          .doc(tExamId)
          .set({
            ...tExamJson(),
            FirestoreFields.examStatus: ExamModel.statusToJson(
              status,
            ),
          });
    }

    test(
      'adds the question and increments exam counters',
      () async {
        await seedExam();

        final created = await creationService.createQuestion(
          examId: tExamId,
          question: questionWithoutImage(),
        );

        expect(created.questionId, isNotEmpty);
        expect(created.examId, tExamId);

        final examData = await fakeFirestore
            .collection(FirestoreCollections.exams)
            .doc(tExamId)
            .get()
            .then((snapshot) => snapshot.data()!);

        expect(examData[FirestoreFields.questionCount], 2);
        expect(
          examData[FirestoreFields.totalScore],
          tExamTotalScore + tExamQuestionDegree,
        );

        final storedQuestion = await fakeFirestore
            .collection(FirestoreCollections.examQuestions)
            .doc(created.questionId)
            .get();

        expect(storedQuestion.exists, isTrue);
        expect(
          storedQuestion.data()![FirestoreFields.questionText],
          tExamQuestionText,
        );
      },
    );

    test('uploads the image when provided', () async {
      await seedExam();

      final created = await creationService.createQuestion(
        examId: tExamId,
        question: questionWithoutImage(),
        image: tExamQuestionImageFile,
      );

      verify(
        () => imageService.uploadImage(
          image: tExamQuestionImageFile,
          examId: tExamId,
          questionId: created.questionId,
        ),
      ).called(1);

      final storedQuestion = await fakeFirestore
          .collection(FirestoreCollections.examQuestions)
          .doc(created.questionId)
          .get()
          .then((snapshot) => snapshot.data()!);

      expect(
        storedQuestion[FirestoreFields.questionImageUrl],
        tExamQuestionImageDownloadUrl,
      );
      expect(
        storedQuestion[FirestoreFields.questionImageStoragePath],
        tExamQuestionImageStoragePath,
      );
    });

    test('throws when the question has an image url but no image file', () async {
      await seedExam();

      await expectLater(
        () => creationService.createQuestion(
          examId: tExamId,
          question: tExamQuestionModel,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('throws when the exam is missing', () async {
      await expectLater(
        () => creationService.createQuestion(
          examId: 'missing-exam',
          question: questionWithoutImage(),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('throws when the exam has started attempts', () async {
      await seedExam();

      await fakeFirestore
          .collection(FirestoreCollections.exams)
          .doc(tExamId)
          .update({
            FirestoreFields.firstAttemptAt: Timestamp.fromDate(
              tExamCreatedAt,
            ),
          });

      await expectLater(
        () => creationService.createQuestion(
          examId: tExamId,
          question: questionWithoutImage(),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'rolls back the uploaded image when the transaction fails',
      () async {
        final failingFirestore =
            _FailingTransactionFakeFirestore();

        await failingFirestore
            .collection(FirestoreCollections.exams)
            .doc(tExamId)
            .set(tExamJson());

        final failingImageService =
            MockExamQuestionImageService();

        when(
          () => failingImageService.uploadImage(
            image: any(named: 'image'),
            examId: any(named: 'examId'),
            questionId: any(named: 'questionId'),
          ),
        ).thenAnswer(
          (_) async => const ExamQuestionImageUploadResult(
            downloadUrl: tExamQuestionImageDownloadUrl,
            storagePath: tExamQuestionImageStoragePath,
          ),
        );

        when(
          () => failingImageService.deleteImageSilently(
            storagePath: any(named: 'storagePath'),
          ),
        ).thenAnswer((_) async {});

        final failingService = ExamCreationService(
          firebaseFirestore: failingFirestore,
          examsDataValidator: const ExamsDataValidator(),
          examFirestoreGuardService: ExamFirestoreGuardService(
            editingPolicy: const ExamEditingPolicy(),
          ),
          examQuestionImageService: failingImageService,
        );

        await expectLater(
          () => failingService.createQuestion(
            examId: tExamId,
            question: questionWithoutImage(),
            image: tExamQuestionImageFile,
          ),
          throwsA(isA<Exception>()),
        );

        verify(
          () => failingImageService.deleteImageSilently(
            storagePath: tExamQuestionImageStoragePath,
          ),
        ).called(1);
      },
    );
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

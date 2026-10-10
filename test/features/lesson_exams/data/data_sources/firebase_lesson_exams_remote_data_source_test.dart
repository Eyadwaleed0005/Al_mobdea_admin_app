import 'dart:typed_data';

import 'package:al_mobdea_admin/core/connection/network/network_info.dart';
import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firebase_firestore_service.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_collections.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_service.dart';
import 'package:al_mobdea_admin/core/firebase/storage/storage_metadata_fields.dart';
import 'package:al_mobdea_admin/features/lesson_exams/data/data_sources/firebase_lesson_exams_remote_data_source.dart';
import 'package:al_mobdea_admin/features/lesson_exams/data/models/lesson_exam_question_model.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/lesson_exam_question_image_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

class _AlwaysOnlineNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;

  @override
  Stream<bool> get onConnectionChanged => const Stream<bool>.empty();

  @override
  Future<void> dispose() async {}
}

class _MockFullMetadata extends Mock implements FullMetadata {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreService firestoreService;
  late MockStorageService storageService;
  late FirebaseLessonExamsRemoteDataSource dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    firestoreService = FirebaseFirestoreService(
      networkInfo: _AlwaysOnlineNetworkInfo(),
      firestore: fakeFirestore,
      enableLogging: false,
    );
    storageService = MockStorageService();

    when(
      () => storageService.deleteFile(
        storagePath: any(named: 'storagePath'),
      ),
    ).thenAnswer((_) async {});

    dataSource = FirebaseLessonExamsRemoteDataSource(
      firestoreService: firestoreService,
      storageService: storageService,
    );
  });

  Future<void> seedQuestion({
    String questionId = tLessonExamQuestionId,
    Map<String, dynamic>? map,
  }) {
    return fakeFirestore
        .collection(FirestoreCollections.lessonQuestions)
        .doc(questionId)
        .set(map ?? tLessonExamQuestionJson());
  }

  void stubSuccessfulUpload({
    String storagePath = tQuestionImageStoragePath,
    String downloadUrl = tQuestionImageDownloadUrl,
  }) {
    final metadata = _MockFullMetadata();
    when(() => metadata.fullPath).thenReturn(storagePath);

    when(
      () => storageService.uploadFile(
        localFilePath: any(named: 'localFilePath'),
        storagePath: any(named: 'storagePath'),
        contentType: any(named: 'contentType'),
        customMetadata: any(named: 'customMetadata'),
      ),
    ).thenAnswer((_) async => metadata);

    when(
      () => storageService.getDownloadUrl(
        storagePath: any(named: 'storagePath'),
      ),
    ).thenAnswer((_) async => downloadUrl);
  }

  group('streamQuestions', () {
    test('emits lesson questions sorted by createdAt ascending', () async {
      await seedQuestion();
      await seedQuestion(
        questionId: tSecondLessonExamQuestionId,
        map: {
          ...tLessonExamQuestionJsonWithoutImage(),
          FirestoreFields.questionText:
              tSecondLessonExamQuestionModel.questionText,
          FirestoreFields.createdAt: Timestamp.fromDate(
            tSecondLessonExamQuestionModel.createdAt!,
          ),
        },
      );

      final stream = dataSource.streamQuestions(lessonId: tLessonId);

      await expectLater(
        stream,
        emits(
          isA<List<LessonExamQuestionModel>>()
              .having((questions) => questions, 'length', hasLength(2))
              .having(
                (questions) => questions.first.questionId,
                'first questionId',
                tLessonExamQuestionId,
              )
              .having(
                (questions) => questions.last.questionId,
                'last questionId',
                tSecondLessonExamQuestionId,
              ),
        ),
      );
    });

    test('emits only questions for the requested lesson', () async {
      await seedQuestion();
      await seedQuestion(
        questionId: tSecondLessonExamQuestionId,
        map: {
          ...tLessonExamQuestionJsonWithoutImage(),
          FirestoreFields.lessonId: 'another-lesson',
        },
      );

      final stream = dataSource.streamQuestions(lessonId: tLessonId);

      await expectLater(
        stream,
        emits(
          isA<List<LessonExamQuestionModel>>().having(
            (questions) => questions.single.questionId,
            'questionId',
            tLessonExamQuestionId,
          ),
        ),
      );
    });
  });

  group('createQuestion', () {
    test('creates a question without image upload when no image is given',
        () async {
      await dataSource.createQuestion(
        question: LessonExamQuestionModel.fromEntity(
          tLessonExamQuestionEntityWithoutImage,
        ),
      );

      final snapshot = await fakeFirestore
          .collection(FirestoreCollections.lessonQuestions)
          .where(FirestoreFields.lessonId, isEqualTo: tLessonId)
          .get();

      final data = snapshot.docs.single.data();

      expect(data[FirestoreFields.questionText], tLessonExamQuestionText);
      expect(data[FirestoreFields.questionImageUrl], isNull);
      expect(data[FirestoreFields.questionImageStoragePath], isNull);
      expect(data[FirestoreFields.createdAt], isA<Timestamp>());

      verifyNever(
        () => storageService.uploadFile(
          localFilePath: any(named: 'localFilePath'),
          storagePath: any(named: 'storagePath'),
          contentType: any(named: 'contentType'),
        ),
      );
    });

    test('uploads image and persists its URL and storage path', () async {
      stubSuccessfulUpload();

      await dataSource.createQuestion(
        question: tLessonExamQuestionModel,
        image: tLessonExamQuestionImageFile,
      );

      final snapshot = await fakeFirestore
          .collection(FirestoreCollections.lessonQuestions)
          .where(FirestoreFields.lessonId, isEqualTo: tLessonId)
          .get();

      final data = snapshot.docs.single.data();

      expect(data[FirestoreFields.questionImageUrl], tQuestionImageDownloadUrl);
      expect(
        data[FirestoreFields.questionImageStoragePath],
        tQuestionImageStoragePath,
      );

      final captured = verify(
        () => storageService.uploadFile(
          localFilePath: captureAny(named: 'localFilePath'),
          storagePath: captureAny(named: 'storagePath'),
          contentType: captureAny(named: 'contentType'),
          customMetadata: captureAny(named: 'customMetadata'),
        ),
      ).captured;

      final localPath = captured[0] as String;
      final storagePath = captured[1] as String;
      final contentType = captured[2] as String;
      final customMetadata = captured[3] as Map<String, String>;

      expect(localPath, endsWith('.jpg'));
      expect(
        storagePath,
        startsWith('lesson_question_images/$tLessonId/'),
      );
      expect(contentType, 'image/jpeg');
      expect(customMetadata[StorageMetadataFields.lessonId], tLessonId);
      expect(
        customMetadata[StorageMetadataFields.originalFileName],
        tQuestionImageName,
      );

      verify(
        () => storageService.getDownloadUrl(
          storagePath: tQuestionImageStoragePath,
        ),
      ).called(1);
    });

    test('throws when image bytes are empty', () async {
      await expectLater(
        () => dataSource.createQuestion(
          question: tLessonExamQuestionModel,
          image: tLessonExamQuestionImageFile.copyWithEmptyBytes(),
        ),
        throwsA(isA<FirebaseRemoteException>()),
      );

      verifyNever(
        () => storageService.uploadFile(
          localFilePath: any(named: 'localFilePath'),
          storagePath: any(named: 'storagePath'),
          contentType: any(named: 'contentType'),
        ),
      );
    });

    test('rolls uploaded image back when Firestore write fails', () async {
      stubSuccessfulUpload();

      final mockedFirestoreService = MockFirestoreService();
      when(
        () => mockedFirestoreService.postData(
          collectionPath: any(named: 'collectionPath'),
          data: any(named: 'data'),
          documentId: any(named: 'documentId'),
        ),
      ).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'internal',
        ),
      );

      final failingDataSource = FirebaseLessonExamsRemoteDataSource(
        firestoreService: mockedFirestoreService,
        storageService: storageService,
      );

      await expectLater(
        () => failingDataSource.createQuestion(
          question: tLessonExamQuestionModel,
          image: tLessonExamQuestionImageFile,
        ),
        throwsA(isA<FirebaseRemoteException>()),
      );

      verify(
        () => storageService.deleteFile(
          storagePath: tQuestionImageStoragePath,
        ),
      ).called(1);
      verifyNever(
        () => storageService.deleteFile(
          storagePath: tReplacementQuestionImageStoragePath,
        ),
      );
    });
  });

  group('updateQuestion', () {
    test('updates question fields without touching the current image',
        () async {
      await seedQuestion();

      await dataSource.updateQuestion(
        question: LessonExamQuestionModel.fromEntity(
          tLessonExamQuestionEntity.copyWith(questionText: 'Updated?'),
        ),
      );

      final data = await fakeFirestore
          .collection(FirestoreCollections.lessonQuestions)
          .doc(tLessonExamQuestionId)
          .get()
          .then((snapshot) => snapshot.data()!);

      expect(data[FirestoreFields.questionText], 'Updated?');
      expect(data[FirestoreFields.questionImageUrl], tQuestionImageUrl);
      expect(
        data[FirestoreFields.questionImageStoragePath],
        tQuestionImageStoragePath,
      );
      verifyNever(
        () => storageService.uploadFile(
          localFilePath: any(named: 'localFilePath'),
          storagePath: any(named: 'storagePath'),
          contentType: any(named: 'contentType'),
        ),
      );
      verifyNever(
        () => storageService.deleteFile(
          storagePath: any(named: 'storagePath'),
        ),
      );
    });

    test('removes the current image when removeCurrentImage is true', () async {
      await seedQuestion();

      await dataSource.updateQuestion(
        question: tLessonExamQuestionModel,
        removeCurrentImage: true,
      );

      final data = await fakeFirestore
          .collection(FirestoreCollections.lessonQuestions)
          .doc(tLessonExamQuestionId)
          .get()
          .then((snapshot) => snapshot.data()!);

      expect(data[FirestoreFields.questionImageUrl], isNull);
      expect(data[FirestoreFields.questionImageStoragePath], isNull);
      verify(
        () => storageService.deleteFile(
          storagePath: tQuestionImageStoragePath,
        ),
      ).called(1);
    });

    test('uploads replacement image and deletes old image', () async {
      await seedQuestion();
      stubSuccessfulUpload(
        storagePath: tReplacementQuestionImageStoragePath,
      );

      await dataSource.updateQuestion(
        question: tLessonExamQuestionModel,
        newImage: tLessonExamQuestionImageFile,
      );

      final data = await fakeFirestore
          .collection(FirestoreCollections.lessonQuestions)
          .doc(tLessonExamQuestionId)
          .get()
          .then((snapshot) => snapshot.data()!);

      expect(data[FirestoreFields.questionImageUrl], tQuestionImageDownloadUrl);
      expect(
        data[FirestoreFields.questionImageStoragePath],
        tReplacementQuestionImageStoragePath,
      );
      verify(
        () => storageService.deleteFile(
          storagePath: tQuestionImageStoragePath,
        ),
      ).called(1);
    });

    test('rolls replacement image back when Firestore update fails', () async {
      await seedQuestion();

      final currentSnapshot = await fakeFirestore
          .collection(FirestoreCollections.lessonQuestions)
          .doc(tLessonExamQuestionId)
          .get();

      final mockedFirestoreService = MockFirestoreService();
      when(
        () => mockedFirestoreService.getDocument(
          collectionPath: any(named: 'collectionPath'),
          documentId: any(named: 'documentId'),
        ),
      ).thenAnswer((_) async => currentSnapshot);
      when(
        () => mockedFirestoreService.patchData(
          collectionPath: any(named: 'collectionPath'),
          documentId: any(named: 'documentId'),
          data: any(named: 'data'),
        ),
      ).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'internal',
        ),
      );

      stubSuccessfulUpload(
        storagePath: tReplacementQuestionImageStoragePath,
      );

      final failingDataSource = FirebaseLessonExamsRemoteDataSource(
        firestoreService: mockedFirestoreService,
        storageService: storageService,
      );

      await expectLater(
        () => failingDataSource.updateQuestion(
          question: tLessonExamQuestionModel,
          newImage: tLessonExamQuestionImageFile,
        ),
        throwsA(isA<FirebaseRemoteException>()),
      );

      verify(
        () => storageService.deleteFile(
          storagePath: tReplacementQuestionImageStoragePath,
        ),
      ).called(1);
      verifyNever(
        () => storageService.deleteFile(
          storagePath: tQuestionImageStoragePath,
        ),
      );
    });

    test('throws when the question belongs to another lesson', () async {
      await seedQuestion(
        map: {
          ...tLessonExamQuestionJson(),
          FirestoreFields.lessonId: 'another-lesson',
        },
      );

      await expectLater(
        () => dataSource.updateQuestion(question: tLessonExamQuestionModel),
        throwsA(isA<FirebaseRemoteException>()),
      );
    });
  });

  group('deleteQuestion', () {
    test('deletes the question document and its image', () async {
      await seedQuestion();

      await dataSource.deleteQuestion(
        lessonId: tLessonId,
        questionId: tLessonExamQuestionId,
      );

      final snapshot = await fakeFirestore
          .collection(FirestoreCollections.lessonQuestions)
          .doc(tLessonExamQuestionId)
          .get();

      expect(snapshot.exists, isFalse);
      verify(
        () => storageService.deleteFile(
          storagePath: tQuestionImageStoragePath,
        ),
      ).called(1);
    });

    test('deletes a question without image without touching storage',
        () async {
      await seedQuestion(map: tLessonExamQuestionJsonWithoutImage());

      await dataSource.deleteQuestion(
        lessonId: tLessonId,
        questionId: tLessonExamQuestionId,
      );

      verifyNever(
        () => storageService.deleteFile(
          storagePath: any(named: 'storagePath'),
        ),
      );
    });
  });

  group('saveCorrectAnswers', () {
    test('saves correct answers for existing lesson questions', () async {
      await seedQuestion();
      await seedQuestion(
        questionId: tSecondLessonExamQuestionId,
        map: {
          ...tLessonExamQuestionJsonWithoutImage(),
          FirestoreFields.questionText:
              tSecondLessonExamQuestionModel.questionText,
        },
      );

      await dataSource.saveCorrectAnswers(
        lessonId: tLessonId,
        correctChoiceIndexes: {
          tLessonExamQuestionId: 2,
          tSecondLessonExamQuestionId: 3,
        },
      );

      final firstData = await fakeFirestore
          .collection(FirestoreCollections.lessonQuestions)
          .doc(tLessonExamQuestionId)
          .get()
          .then((snapshot) => snapshot.data()!);

      final secondData = await fakeFirestore
          .collection(FirestoreCollections.lessonQuestions)
          .doc(tSecondLessonExamQuestionId)
          .get()
          .then((snapshot) => snapshot.data()!);

      expect(firstData[FirestoreFields.correctOption], 2);
      expect(secondData[FirestoreFields.correctOption], 3);
    });

    test('throws when saving an answer for a missing question', () async {
      await seedQuestion();

      await expectLater(
        () => dataSource.saveCorrectAnswers(
          lessonId: tLessonId,
          correctChoiceIndexes: {'missing-question': 1},
        ),
        throwsA(isA<FirebaseRemoteException>()),
      );
    });

    test('throws when the selected choice index is outside the choices range',
        () async {
      await seedQuestion();

      await expectLater(
        () => dataSource.saveCorrectAnswers(
          lessonId: tLessonId,
          correctChoiceIndexes: {tLessonExamQuestionId: 4},
        ),
        throwsA(isA<FirebaseRemoteException>()),
      );
    });
  });
}

extension on LessonExamQuestionImageFile {
  LessonExamQuestionImageFile copyWithEmptyBytes() {
    return LessonExamQuestionImageFile(
      name: name,
      sizeInBytes: 0,
      bytes: Uint8List(0),
      path: path,
    );
  }
}

import 'package:al_mobdea_admin/core/connection/network/network_info.dart';
import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firebase_firestore_service.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_collections.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_service.dart';
import 'package:al_mobdea_admin/core/firebase/storage/storage_metadata_fields.dart';
import 'package:al_mobdea_admin/features/lessons/data/data_sources/firebase_lessons_remote_data_source.dart';
import 'package:al_mobdea_admin/features/lessons/data/models/lesson_model.dart';
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
  Stream<bool> get onConnectionChanged =>
      const Stream<bool>.empty();

  @override
  Future<void> dispose() async {}
}

class _MockFullMetadata extends Mock implements FullMetadata {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreService firestoreService;
  late MockStorageService storageService;
  late FirebaseLessonsRemoteDataSource dataSource;

  setUpAll(() {
    registerFallbackValue(_MockFullMetadata());
  });

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

    dataSource = FirebaseLessonsRemoteDataSource(
      firestoreService: firestoreService,
      storageService: storageService,
    );
  });

  Future<void> seedLesson({
    String lessonId = tLessonId,
    Map<String, dynamic>? map,
  }) {
    return fakeFirestore
        .collection(FirestoreCollections.lessons)
        .doc(lessonId)
        .set(map ?? tLessonJson());
  }

  void stubSuccessfulUpload({
    String storagePath = tPdfStoragePath,
    int fileSize = tPdfFileSize,
  }) {
    final metadata = _MockFullMetadata();
    when(() => metadata.fullPath).thenReturn(storagePath);
    when(() => metadata.size).thenReturn(fileSize);

    when(
      () => storageService.uploadFile(
        localFilePath: any(named: 'localFilePath'),
        storagePath: any(named: 'storagePath'),
        contentType: any(named: 'contentType'),
        customMetadata: any(named: 'customMetadata'),
      ),
    ).thenAnswer((_) async => metadata);
  }

  String capturedUploadStoragePath() {
    final captured = verify(
      () => storageService.uploadFile(
        localFilePath: any(named: 'localFilePath'),
        storagePath: captureAny(named: 'storagePath'),
        contentType: any(named: 'contentType'),
        customMetadata: any(named: 'customMetadata'),
      ),
    ).captured;

    return captured.single as String;
  }

  group('getLessons', () {
    test(
      'returns all lessons sorted by createdAt descending',
      () async {
        await seedLesson(lessonId: tLessonId);
        await seedLesson(
          lessonId: tSecondLessonModel.lessonId,
          map: {
            ...tLessonJsonWithoutPdf(),
            FirestoreFields.title: tSecondLessonModel.title,
            FirestoreFields.isPublished: false,
            FirestoreFields.createdAt: Timestamp.fromDate(
              tSecondLessonModel.createdAt!,
            ),
          },
        );

        final lessons = await dataSource.getLessons();

        expect(lessons, hasLength(2));
        expect(lessons.first.lessonId, tLessonId);
        expect(
          lessons.last.lessonId,
          tSecondLessonModel.lessonId,
        );
      },
    );

    test('filters by gradeId', () async {
      await seedLesson();
      await seedLesson(
        lessonId: tSecondLessonModel.lessonId,
        map: {
          ...tLessonJsonWithoutPdf(),
          FirestoreFields.gradeId: 'grade-9',
        },
      );

      final lessons = await dataSource.getLessons(
        gradeId: tGradeId,
      );

      expect(lessons, hasLength(1));
      expect(lessons.single.lessonId, tLessonId);
    });

    test('filters by isPublished', () async {
      await seedLesson();
      await seedLesson(
        lessonId: tSecondLessonModel.lessonId,
        map: {
          ...tLessonJsonWithoutPdf(),
          FirestoreFields.isPublished: false,
        },
      );

      final published = await dataSource.getLessons(
        isPublished: true,
      );

      expect(published, hasLength(1));
      expect(published.single.lessonId, tLessonId);
    });

    test('maps a lesson without pdf fields', () async {
      await seedLesson(map: tLessonJsonWithoutPdf());

      final lessons = await dataSource.getLessons();

      expect(lessons, hasLength(1));
      expect(lessons.single.hasPdfFile, isFalse);
    });
  });

  group('getLessonById', () {
    test('returns the lesson when it exists', () async {
      await seedLesson();

      final lesson = await dataSource.getLessonById(
        lessonId: tLessonId,
      );

      expect(lesson.lessonId, tLessonId);
      expect(lesson.title, tLessonTitle);
      expect(lesson.pdfStoragePath, tPdfStoragePath);
    });

    test('throws FirebaseRemoteException when the lesson does not exist', () async {
      expect(
        () =>
            dataSource.getLessonById(lessonId: 'missing-lesson'),
        throwsA(isA<FirebaseRemoteException>()),
      );
    });
  });

  group('streamLessons', () {
    test('emits mapped lessons', () async {
      await seedLesson();

      final stream = dataSource.streamLessons();

      await expectLater(
        stream,
        emits(
          isA<List<LessonModel>>().having(
            (lessons) => lessons.single.lessonId,
            'lessonId',
            tLessonId,
          ),
        ),
      );
    });

    test(
      'emits only matching lessons when filtered by isPublished',
      () async {
        await seedLesson();
        await seedLesson(
          lessonId: tSecondLessonModel.lessonId,
          map: {
            ...tLessonJsonWithoutPdf(),
            FirestoreFields.isPublished: false,
          },
        );

        final stream = dataSource.streamLessons(
          isPublished: false,
        );

        await expectLater(
          stream,
          emits(
            isA<List<LessonModel>>().having(
              (lessons) => lessons.single.lessonId,
              'lessonId',
              tSecondLessonModel.lessonId,
            ),
          ),
        );
      },
    );
  });

  group('createLesson', () {
    test('creates a lesson without a pdf when no local file path is given', () async {
      await dataSource.createLesson(
        lesson: LessonModel.fromEntity(tLessonEntityWithoutPdf),
      );

      final data = await fakeFirestore
          .collection(FirestoreCollections.lessons)
          .doc(tLessonId)
          .get()
          .then((snapshot) => snapshot.data()!);

      expect(data[FirestoreFields.title], tLessonTitle);
      expect(data[FirestoreFields.description], tLessonSubtitle);
      expect(data[FirestoreFields.gradeId], tGradeId);
      expect(data[FirestoreFields.isPublished], isTrue);
      expect(
        data.containsKey(FirestoreFields.pdfFileName),
        isFalse,
      );
      expect(
        data.containsKey(FirestoreFields.pdfFileSize),
        isFalse,
      );
      expect(
        data.containsKey(FirestoreFields.pdfStoragePath),
        isFalse,
      );
      expect(data[FirestoreFields.createdAt], isA<Timestamp>());

      verifyNever(
        () => storageService.uploadFile(
          localFilePath: any(named: 'localFilePath'),
          storagePath: any(named: 'storagePath'),
          contentType: any(named: 'contentType'),
        ),
      );
    });

    test('persists model-carried pdf metadata without uploading when no '
        'local file path is given', () async {
      await dataSource.createLesson(lesson: tLessonModel);

      final data = await fakeFirestore
          .collection(FirestoreCollections.lessons)
          .doc(tLessonId)
          .get()
          .then((snapshot) => snapshot.data()!);

      expect(
        data[FirestoreFields.pdfStoragePath],
        tPdfStoragePath,
      );
      expect(data[FirestoreFields.pdfFileName], tPdfFileName);
      expect(data[FirestoreFields.pdfFileSize], tPdfFileSize);

      verifyNever(
        () => storageService.uploadFile(
          localFilePath: any(named: 'localFilePath'),
          storagePath: any(named: 'storagePath'),
          contentType: any(named: 'contentType'),
        ),
      );
    });

    test('uploads the pdf and persists its metadata when a file is given', () async {
      stubSuccessfulUpload();

      await dataSource.createLesson(
        lesson: tLessonModel,
        localPdfFilePath: tLocalPdfFilePath,
      );

      final data = await fakeFirestore
          .collection(FirestoreCollections.lessons)
          .doc(tLessonId)
          .get()
          .then((snapshot) => snapshot.data()!);

      expect(
        data[FirestoreFields.pdfStoragePath],
        tPdfStoragePath,
      );
      expect(data[FirestoreFields.pdfFileName], tPdfFileName);
      expect(data[FirestoreFields.pdfFileSize], tPdfFileSize);

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

      expect(localPath, tLocalPdfFilePath);
      expect(storagePath, startsWith('lessons/$tLessonId/'));
      expect(contentType, 'application/pdf');
      expect(
        customMetadata[StorageMetadataFields.lessonId],
        tLessonId,
      );
      expect(
        customMetadata[StorageMetadataFields.originalFileName],
        tPdfFileName,
      );
    });

    test('rolls the uploaded pdf back when the firestore write fails', () async {
      stubSuccessfulUpload();

      final mockedFirestoreService = MockFirestoreService();
      when(
        () => mockedFirestoreService.postData(
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

      final failingDataSource = FirebaseLessonsRemoteDataSource(
        firestoreService: mockedFirestoreService,
        storageService: storageService,
      );

      await expectLater(
        () => failingDataSource.createLesson(
          lesson: tLessonModel,
          localPdfFilePath: tLocalPdfFilePath,
        ),
        throwsA(isA<FirebaseRemoteException>()),
      );

      final uploadedPath = capturedUploadStoragePath();

      verify(
        () =>
            storageService.deleteFile(storagePath: uploadedPath),
      ).called(1);
    });

    test(
      'does not delete anything when the upload itself fails',
      () async {
        when(
          () => storageService.uploadFile(
            localFilePath: any(named: 'localFilePath'),
            storagePath: any(named: 'storagePath'),
            contentType: any(named: 'contentType'),
            customMetadata: any(named: 'customMetadata'),
          ),
        ).thenThrow(
          FirebaseException(
            plugin: 'firebase_storage',
            code: 'unauthorized',
          ),
        );

        await expectLater(
          () => dataSource.createLesson(
            lesson: tLessonModel,
            localPdfFilePath: tLocalPdfFilePath,
          ),
          throwsA(isA<FirebaseRemoteException>()),
        );

        verifyNever(
          () => storageService.deleteFile(
            storagePath: any(named: 'storagePath'),
          ),
        );
      },
    );
  });

  group('updateLesson', () {
    test('updates the lesson fields without touching the pdf', () async {
      await seedLesson();

      final updatedLesson = LessonModel.fromEntity(
        tLessonEntity.copyWith(title: 'Updated title'),
      );

      await dataSource.updateLesson(lesson: updatedLesson);

      final data = await fakeFirestore
          .collection(FirestoreCollections.lessons)
          .doc(tLessonId)
          .get()
          .then((snapshot) => snapshot.data()!);

      expect(data[FirestoreFields.title], 'Updated title');
      // The existing pdf metadata is preserved on plain updates.
      expect(
        data[FirestoreFields.pdfStoragePath],
        tPdfStoragePath,
      );
      expect(data[FirestoreFields.pdfFileName], tPdfFileName);

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

    test('supports updating a lesson that has no pdf (pdf-optional)', () async {
      await seedLesson(map: tLessonJsonWithoutPdf());

      final updatedLesson = LessonModel.fromEntity(
        tLessonEntityWithoutPdf.copyWith(
          subtitle: 'New subtitle',
        ),
      );

      await dataSource.updateLesson(lesson: updatedLesson);

      final data = await fakeFirestore
          .collection(FirestoreCollections.lessons)
          .doc(tLessonId)
          .get()
          .then((snapshot) => snapshot.data()!);

      expect(data[FirestoreFields.description], 'New subtitle');
      expect(
        data.containsKey(FirestoreFields.pdfStoragePath),
        isFalse,
      );
    });

    test(
      'removes the existing pdf when removeExistingPdf is true',
      () async {
        await seedLesson();

        await dataSource.updateLesson(
          lesson: LessonModel.fromEntity(tLessonEntity),
          removeExistingPdf: true,
        );

        final data = await fakeFirestore
            .collection(FirestoreCollections.lessons)
            .doc(tLessonId)
            .get()
            .then((snapshot) => snapshot.data()!);

        expect(
          data.containsKey(FirestoreFields.pdfStoragePath),
          isFalse,
        );
        expect(
          data.containsKey(FirestoreFields.pdfFileName),
          isFalse,
        );
        expect(
          data.containsKey(FirestoreFields.pdfFileSize),
          isFalse,
        );

        verify(
          () => storageService.deleteFile(
            storagePath: tPdfStoragePath,
          ),
        ).called(1);
      },
    );

    test('keeps the storage file when the lesson had no pdf to remove', () async {
      await seedLesson(map: tLessonJsonWithoutPdf());

      await dataSource.updateLesson(
        lesson: LessonModel.fromEntity(tLessonEntityWithoutPdf),
        removeExistingPdf: true,
      );

      verifyNever(
        () => storageService.deleteFile(
          storagePath: any(named: 'storagePath'),
        ),
      );
    });

    test('throws when removeExistingPdf and a replacement pdf are both given', () async {
      await seedLesson();

      await expectLater(
        () => dataSource.updateLesson(
          lesson: LessonModel.fromEntity(tLessonEntity),
          replacementPdfFilePath: tLocalPdfFilePath,
          removeExistingPdf: true,
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

    test(
      'uploads a replacement pdf and deletes the old one',
      () async {
        await seedLesson();

        const newStoragePath = 'lessons/$tLessonId/2.pdf';
        stubSuccessfulUpload(
          storagePath: newStoragePath,
          fileSize: 2048,
        );

        await dataSource.updateLesson(
          lesson: LessonModel.fromEntity(
            tLessonEntity.copyWith(
              pdfFileName: 'new-lesson.pdf',
            ),
          ),
          replacementPdfFilePath: tLocalPdfFilePath,
        );

        final data = await fakeFirestore
            .collection(FirestoreCollections.lessons)
            .doc(tLessonId)
            .get()
            .then((snapshot) => snapshot.data()!);

        expect(
          data[FirestoreFields.pdfStoragePath],
          newStoragePath,
        );
        expect(
          data[FirestoreFields.pdfFileName],
          'new-lesson.pdf',
        );
        expect(data[FirestoreFields.pdfFileSize], 2048);

        verify(
          () => storageService.deleteFile(
            storagePath: tPdfStoragePath,
          ),
        ).called(1);
      },
    );

    test('rolls the replacement pdf back when the firestore write fails', () async {
      await seedLesson();

      final currentSnapshot = await fakeFirestore
          .collection(FirestoreCollections.lessons)
          .doc(tLessonId)
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
        storagePath: 'lessons/$tLessonId/2.pdf',
      );

      final failingDataSource = FirebaseLessonsRemoteDataSource(
        firestoreService: mockedFirestoreService,
        storageService: storageService,
      );

      await expectLater(
        () => failingDataSource.updateLesson(
          lesson: LessonModel.fromEntity(tLessonEntity),
          replacementPdfFilePath: tLocalPdfFilePath,
        ),
        throwsA(isA<FirebaseRemoteException>()),
      );

      final uploadedPath = capturedUploadStoragePath();

      verify(
        () =>
            storageService.deleteFile(storagePath: uploadedPath),
      ).called(1);
      verifyNever(
        () => storageService.deleteFile(
          storagePath: tPdfStoragePath,
        ),
      );
    });

    test('throws when the lesson does not exist', () async {
      await expectLater(
        () => dataSource.updateLesson(
          lesson: LessonModel.fromEntity(tLessonEntity),
        ),
        throwsA(isA<FirebaseRemoteException>()),
      );
    });
  });

  group('deleteLesson', () {
    test(
      'deletes the lesson document and its pdf file',
      () async {
        await seedLesson();

        await dataSource.deleteLesson(lessonId: tLessonId);

        final snapshot = await fakeFirestore
            .collection(FirestoreCollections.lessons)
            .doc(tLessonId)
            .get();

        expect(snapshot.exists, isFalse);
        verify(
          () => storageService.deleteFile(
            storagePath: tPdfStoragePath,
          ),
        ).called(1);
      },
    );

    test(
      'deletes a lesson without pdf without touching storage',
      () async {
        await seedLesson(map: tLessonJsonWithoutPdf());

        await dataSource.deleteLesson(lessonId: tLessonId);

        final snapshot = await fakeFirestore
            .collection(FirestoreCollections.lessons)
            .doc(tLessonId)
            .get();

        expect(snapshot.exists, isFalse);
        verifyNever(
          () => storageService.deleteFile(
            storagePath: any(named: 'storagePath'),
          ),
        );
      },
    );

    test('throws when the lesson does not exist', () async {
      await expectLater(
        () =>
            dataSource.deleteLesson(lessonId: 'missing-lesson'),
        throwsA(isA<FirebaseRemoteException>()),
      );
    });
  });
}

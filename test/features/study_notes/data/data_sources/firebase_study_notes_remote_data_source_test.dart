import 'package:al_mobdea_admin/core/connection/network/network_info.dart';
import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firebase_firestore_service.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_collections.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_service.dart';
import 'package:al_mobdea_admin/core/firebase/storage/storage_metadata_fields.dart';
import 'package:al_mobdea_admin/features/study_notes/data/data_sources/firebase_study_notes_remote_data_source.dart';
import 'package:al_mobdea_admin/features/study_notes/data/models/study_note_model.dart';
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
  late FirebaseStudyNotesRemoteDataSource dataSource;

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
      () => storageService.deleteFile(storagePath: any(named: 'storagePath')),
    ).thenAnswer((_) async {});

    dataSource = FirebaseStudyNotesRemoteDataSource(
      firestoreService: firestoreService,
      storageService: storageService,
    );
  });

  Future<void> seedStudyNote({
    String noteId = tStudyNoteId,
    Map<String, dynamic>? map,
  }) {
    return fakeFirestore
        .collection(FirestoreCollections.studyNotes)
        .doc(noteId)
        .set(map ?? tStudyNoteJson());
  }

  void stubSuccessfulUpload({
    String storagePath = tStudyNotePdfStoragePath,
    int fileSize = tStudyNotePdfFileSize,
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

  group('getStudyNotes', () {
    test('returns all notes sorted by createdAt descending', () async {
      await seedStudyNote(noteId: tStudyNoteId);
      await seedStudyNote(
        noteId: tSecondStudyNoteModel.noteId,
        map: {
          ...tStudyNoteJsonWithoutPdf(),
          FirestoreFields.name: tSecondStudyNoteModel.name,
          FirestoreFields.isPublished: false,
          FirestoreFields.createdAt: Timestamp.fromDate(
            tSecondStudyNoteModel.createdAt!,
          ),
        },
      );

      final notes = await dataSource.getStudyNotes();

      expect(notes, hasLength(2));
      expect(notes.first.noteId, tStudyNoteId);
      expect(notes.last.noteId, tSecondStudyNoteModel.noteId);
    });

    test('filters by gradeId', () async {
      await seedStudyNote();
      await seedStudyNote(
        noteId: tSecondStudyNoteModel.noteId,
        map: {
          ...tStudyNoteJsonWithoutPdf(),
          FirestoreFields.gradeId: 'grade-9',
        },
      );

      final notes = await dataSource.getStudyNotes(gradeId: tGradeId);

      expect(notes, hasLength(1));
      expect(notes.single.noteId, tStudyNoteId);
    });

    test('filters by isPublished', () async {
      await seedStudyNote();
      await seedStudyNote(
        noteId: tSecondStudyNoteModel.noteId,
        map: {
          ...tStudyNoteJsonWithoutPdf(),
          FirestoreFields.isPublished: false,
        },
      );

      final published = await dataSource.getStudyNotes(isPublished: true);

      expect(published, hasLength(1));
      expect(published.single.noteId, tStudyNoteId);
    });

    test('maps a note without pdf fields', () async {
      await seedStudyNote(map: tStudyNoteJsonWithoutPdf());

      final notes = await dataSource.getStudyNotes();

      expect(notes, hasLength(1));
      expect(notes.single.hasPdfFile, isFalse);
    });
  });

  group('getStudyNoteById', () {
    test('returns the note when it exists', () async {
      await seedStudyNote();

      final note = await dataSource.getStudyNoteById(noteId: tStudyNoteId);

      expect(note.noteId, tStudyNoteId);
      expect(note.name, tStudyNoteName);
      expect(note.pdfStoragePath, tStudyNotePdfStoragePath);
    });

    test('throws FirebaseRemoteException when the note does not exist', () {
      expect(
        () => dataSource.getStudyNoteById(noteId: 'missing-note'),
        throwsA(isA<FirebaseRemoteException>()),
      );
    });
  });

  group('streamStudyNotes', () {
    test('emits mapped notes', () async {
      await seedStudyNote();

      final stream = dataSource.streamStudyNotes();

      await expectLater(
        stream,
        emits(
          isA<List<StudyNoteModel>>().having(
            (notes) => notes.single.noteId,
            'noteId',
            tStudyNoteId,
          ),
        ),
      );
    });

    test('emits only matching notes when filtered by isPublished', () async {
      await seedStudyNote();
      await seedStudyNote(
        noteId: tSecondStudyNoteModel.noteId,
        map: {
          ...tStudyNoteJsonWithoutPdf(),
          FirestoreFields.isPublished: false,
        },
      );

      final stream = dataSource.streamStudyNotes(isPublished: false);

      await expectLater(
        stream,
        emits(
          isA<List<StudyNoteModel>>().having(
            (notes) => notes.single.noteId,
            'noteId',
            tSecondStudyNoteModel.noteId,
          ),
        ),
      );
    });
  });

  group('createStudyNote', () {
    test(
      'creates a note without a pdf when no local file path is given',
      () async {
        await dataSource.createStudyNote(
          note: StudyNoteModel.fromEntity(tStudyNoteEntityWithoutPdf),
        );

        final data = await fakeFirestore
            .collection(FirestoreCollections.studyNotes)
            .doc(tStudyNoteId)
            .get()
            .then((snapshot) => snapshot.data()!);

        expect(data[FirestoreFields.name], tStudyNoteName);
        expect(data[FirestoreFields.description], tStudyNoteDescription);
        expect(data[FirestoreFields.gradeId], tGradeId);
        expect(data[FirestoreFields.isPublished], isTrue);
        expect(data.containsKey(FirestoreFields.pdfFileName), isFalse);
        expect(data.containsKey(FirestoreFields.pdfFileSize), isFalse);
        expect(data.containsKey(FirestoreFields.pdfStoragePath), isFalse);
        expect(data[FirestoreFields.createdAt], isA<Timestamp>());

        verifyNever(
          () => storageService.uploadFile(
            localFilePath: any(named: 'localFilePath'),
            storagePath: any(named: 'storagePath'),
            contentType: any(named: 'contentType'),
          ),
        );
      },
    );

    test('persists model-carried pdf metadata without uploading', () async {
      await dataSource.createStudyNote(note: tStudyNoteModel);

      final data = await fakeFirestore
          .collection(FirestoreCollections.studyNotes)
          .doc(tStudyNoteId)
          .get()
          .then((snapshot) => snapshot.data()!);

      expect(data[FirestoreFields.pdfStoragePath], tStudyNotePdfStoragePath);
      expect(data[FirestoreFields.pdfFileName], tStudyNotePdfFileName);
      expect(data[FirestoreFields.pdfFileSize], tStudyNotePdfFileSize);

      verifyNever(
        () => storageService.uploadFile(
          localFilePath: any(named: 'localFilePath'),
          storagePath: any(named: 'storagePath'),
          contentType: any(named: 'contentType'),
        ),
      );
    });

    test(
      'uploads the pdf and persists its metadata when a file is given',
      () async {
        stubSuccessfulUpload();

        await dataSource.createStudyNote(
          note: tStudyNoteModel,
          localPdfFilePath: tStudyNoteLocalPdfFilePath,
        );

        final data = await fakeFirestore
            .collection(FirestoreCollections.studyNotes)
            .doc(tStudyNoteId)
            .get()
            .then((snapshot) => snapshot.data()!);

        expect(data[FirestoreFields.pdfStoragePath], tStudyNotePdfStoragePath);
        expect(data[FirestoreFields.pdfFileName], tStudyNotePdfFileName);
        expect(data[FirestoreFields.pdfFileSize], tStudyNotePdfFileSize);

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

        expect(localPath, tStudyNoteLocalPdfFilePath);
        expect(storagePath, startsWith('study_notes/$tStudyNoteId/'));
        expect(contentType, 'application/pdf');
        expect(customMetadata[StorageMetadataFields.noteId], tStudyNoteId);
        expect(
          customMetadata[StorageMetadataFields.originalFileName],
          tStudyNotePdfFileName,
        );
      },
    );

    test(
      'rolls the uploaded pdf back when the firestore write fails',
      () async {
        stubSuccessfulUpload();

        final mockedFirestoreService = MockFirestoreService();
        when(
          () => mockedFirestoreService.postData(
            collectionPath: any(named: 'collectionPath'),
            documentId: any(named: 'documentId'),
            data: any(named: 'data'),
          ),
        ).thenThrow(
          FirebaseException(plugin: 'cloud_firestore', code: 'internal'),
        );

        final failingDataSource = FirebaseStudyNotesRemoteDataSource(
          firestoreService: mockedFirestoreService,
          storageService: storageService,
        );

        await expectLater(
          () => failingDataSource.createStudyNote(
            note: tStudyNoteModel,
            localPdfFilePath: tStudyNoteLocalPdfFilePath,
          ),
          throwsA(isA<FirebaseRemoteException>()),
        );

        final uploadedPath = capturedUploadStoragePath();

        verify(
          () => storageService.deleteFile(storagePath: uploadedPath),
        ).called(1);
      },
    );

    test('does not delete anything when the upload itself fails', () async {
      when(
        () => storageService.uploadFile(
          localFilePath: any(named: 'localFilePath'),
          storagePath: any(named: 'storagePath'),
          contentType: any(named: 'contentType'),
          customMetadata: any(named: 'customMetadata'),
        ),
      ).thenThrow(
        FirebaseException(plugin: 'firebase_storage', code: 'unauthorized'),
      );

      await expectLater(
        () => dataSource.createStudyNote(
          note: tStudyNoteModel,
          localPdfFilePath: tStudyNoteLocalPdfFilePath,
        ),
        throwsA(isA<FirebaseRemoteException>()),
      );

      verifyNever(
        () => storageService.deleteFile(storagePath: any(named: 'storagePath')),
      );
    });
  });

  group('updateStudyNote', () {
    test('updates the note fields without touching the pdf', () async {
      await seedStudyNote();

      final updatedNote = StudyNoteModel.fromEntity(
        tStudyNoteEntity.copyWith(name: 'Updated name'),
      );

      await dataSource.updateStudyNote(note: updatedNote);

      final data = await fakeFirestore
          .collection(FirestoreCollections.studyNotes)
          .doc(tStudyNoteId)
          .get()
          .then((snapshot) => snapshot.data()!);

      expect(data[FirestoreFields.name], 'Updated name');
      expect(data[FirestoreFields.pdfStoragePath], tStudyNotePdfStoragePath);
      expect(data[FirestoreFields.pdfFileName], tStudyNotePdfFileName);

      verifyNever(
        () => storageService.uploadFile(
          localFilePath: any(named: 'localFilePath'),
          storagePath: any(named: 'storagePath'),
          contentType: any(named: 'contentType'),
        ),
      );
      verifyNever(
        () => storageService.deleteFile(storagePath: any(named: 'storagePath')),
      );
    });

    test('supports updating a note that has no pdf', () async {
      await seedStudyNote(map: tStudyNoteJsonWithoutPdf());

      final updatedNote = StudyNoteModel.fromEntity(
        tStudyNoteEntityWithoutPdf.copyWith(description: 'New description'),
      );

      await dataSource.updateStudyNote(note: updatedNote);

      final data = await fakeFirestore
          .collection(FirestoreCollections.studyNotes)
          .doc(tStudyNoteId)
          .get()
          .then((snapshot) => snapshot.data()!);

      expect(data[FirestoreFields.description], 'New description');
      expect(data.containsKey(FirestoreFields.pdfStoragePath), isFalse);
    });

    test('removes the existing pdf when removeExistingPdf is true', () async {
      await seedStudyNote();

      await dataSource.updateStudyNote(
        note: StudyNoteModel.fromEntity(tStudyNoteEntity),
        removeExistingPdf: true,
      );

      final data = await fakeFirestore
          .collection(FirestoreCollections.studyNotes)
          .doc(tStudyNoteId)
          .get()
          .then((snapshot) => snapshot.data()!);

      expect(data.containsKey(FirestoreFields.pdfStoragePath), isFalse);
      expect(data.containsKey(FirestoreFields.pdfFileName), isFalse);
      expect(data.containsKey(FirestoreFields.pdfFileSize), isFalse);

      verify(
        () => storageService.deleteFile(storagePath: tStudyNotePdfStoragePath),
      ).called(1);
    });

    test('keeps storage when the note had no pdf to remove', () async {
      await seedStudyNote(map: tStudyNoteJsonWithoutPdf());

      await dataSource.updateStudyNote(
        note: StudyNoteModel.fromEntity(tStudyNoteEntityWithoutPdf),
        removeExistingPdf: true,
      );

      verifyNever(
        () => storageService.deleteFile(storagePath: any(named: 'storagePath')),
      );
    });

    test(
      'throws when removeExistingPdf and replacement pdf are both given',
      () async {
        await seedStudyNote();

        await expectLater(
          () => dataSource.updateStudyNote(
            note: StudyNoteModel.fromEntity(tStudyNoteEntity),
            replacementPdfFilePath: tStudyNoteLocalPdfFilePath,
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
      },
    );

    test('uploads a replacement pdf and deletes the old one', () async {
      await seedStudyNote();

      const newStoragePath = 'study_notes/$tStudyNoteId/2.pdf';
      stubSuccessfulUpload(storagePath: newStoragePath, fileSize: 2048);

      await dataSource.updateStudyNote(
        note: StudyNoteModel.fromEntity(
          tStudyNoteEntity.copyWith(pdfFileName: 'new-study-note.pdf'),
        ),
        replacementPdfFilePath: tStudyNoteLocalPdfFilePath,
      );

      final data = await fakeFirestore
          .collection(FirestoreCollections.studyNotes)
          .doc(tStudyNoteId)
          .get()
          .then((snapshot) => snapshot.data()!);

      expect(data[FirestoreFields.pdfStoragePath], newStoragePath);
      expect(data[FirestoreFields.pdfFileName], 'new-study-note.pdf');
      expect(data[FirestoreFields.pdfFileSize], 2048);

      verify(
        () => storageService.deleteFile(storagePath: tStudyNotePdfStoragePath),
      ).called(1);
    });

    test(
      'rolls the replacement pdf back when the firestore write fails',
      () async {
        await seedStudyNote();

        final currentSnapshot = await fakeFirestore
            .collection(FirestoreCollections.studyNotes)
            .doc(tStudyNoteId)
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
          FirebaseException(plugin: 'cloud_firestore', code: 'internal'),
        );

        stubSuccessfulUpload(storagePath: 'study_notes/$tStudyNoteId/2.pdf');

        final failingDataSource = FirebaseStudyNotesRemoteDataSource(
          firestoreService: mockedFirestoreService,
          storageService: storageService,
        );

        await expectLater(
          () => failingDataSource.updateStudyNote(
            note: StudyNoteModel.fromEntity(tStudyNoteEntity),
            replacementPdfFilePath: tStudyNoteLocalPdfFilePath,
          ),
          throwsA(isA<FirebaseRemoteException>()),
        );

        final uploadedPath = capturedUploadStoragePath();

        verify(
          () => storageService.deleteFile(storagePath: uploadedPath),
        ).called(1);
        verifyNever(
          () =>
              storageService.deleteFile(storagePath: tStudyNotePdfStoragePath),
        );
      },
    );

    test('throws when the note does not exist', () async {
      await expectLater(
        () => dataSource.updateStudyNote(
          note: StudyNoteModel.fromEntity(tStudyNoteEntity),
        ),
        throwsA(isA<FirebaseRemoteException>()),
      );
    });
  });

  group('deleteStudyNote', () {
    test('deletes the note document and its pdf file', () async {
      await seedStudyNote();

      await dataSource.deleteStudyNote(noteId: tStudyNoteId);

      final snapshot = await fakeFirestore
          .collection(FirestoreCollections.studyNotes)
          .doc(tStudyNoteId)
          .get();

      expect(snapshot.exists, isFalse);
      verify(
        () => storageService.deleteFile(storagePath: tStudyNotePdfStoragePath),
      ).called(1);
    });

    test('deletes a note without pdf without touching storage', () async {
      await seedStudyNote(map: tStudyNoteJsonWithoutPdf());

      await dataSource.deleteStudyNote(noteId: tStudyNoteId);

      final snapshot = await fakeFirestore
          .collection(FirestoreCollections.studyNotes)
          .doc(tStudyNoteId)
          .get();

      expect(snapshot.exists, isFalse);
      verifyNever(
        () => storageService.deleteFile(storagePath: any(named: 'storagePath')),
      );
    });

    test('throws when the note does not exist', () async {
      await expectLater(
        () => dataSource.deleteStudyNote(noteId: 'missing-note'),
        throwsA(isA<FirebaseRemoteException>()),
      );
    });
  });
}

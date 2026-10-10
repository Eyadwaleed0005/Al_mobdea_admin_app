import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/features/study_notes/data/models/study_note_model.dart';
import 'package:al_mobdea_admin/features/study_notes/data/repositories/study_notes_repository_impl.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStudyNotesRemoteDataSource remoteDataSource;
  late StudyNotesRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(tStudyNoteModel);
    registerFallbackValue(tStudyNoteEntity);
  });

  setUp(() {
    remoteDataSource = MockStudyNotesRemoteDataSource();
    repository = StudyNotesRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  const tAppError = AppErrorModel(
    code: 'internal',
    message: 'server error',
    type: AppErrorType.server,
    isRetryable: true,
  );

  final tRemoteException = FirebaseRemoteException(errorModel: tAppError);

  group('getStudyNotes', () {
    test('returns an unmodifiable list of note entities on success', () async {
      when(
        () => remoteDataSource.getStudyNotes(
          gradeId: any(named: 'gradeId'),
          isPublished: any(named: 'isPublished'),
        ),
      ).thenAnswer((_) async => [tStudyNoteModel]);

      final result = await repository.getStudyNotes();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (notes) {
        expect(notes, isA<List<StudyNoteEntity>>());
        expect(notes.single.noteId, tStudyNoteId);
        expect(() => notes.add(tStudyNoteEntity), throwsUnsupportedError);
      });
    });

    test('forwards the grade and publication filters', () async {
      when(
        () => remoteDataSource.getStudyNotes(
          gradeId: any(named: 'gradeId'),
          isPublished: any(named: 'isPublished'),
        ),
      ).thenAnswer((_) async => <StudyNoteModel>[]);

      await repository.getStudyNotes(gradeId: tGradeId, isPublished: true);

      final captured = verify(
        () => remoteDataSource.getStudyNotes(
          gradeId: captureAny(named: 'gradeId'),
          isPublished: captureAny(named: 'isPublished'),
        ),
      ).captured;

      expect(captured[0], tGradeId);
      expect(captured[1], isTrue);
    });

    test('returns Left(AppErrorModel) when the datasource throws', () async {
      when(
        () => remoteDataSource.getStudyNotes(
          gradeId: any(named: 'gradeId'),
          isPublished: any(named: 'isPublished'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.getStudyNotes();

      expect(result.isLeft(), isTrue);
      result.fold(
        (error) => expect(error.code, 'internal'),
        (_) => fail('expected Left'),
      );
    });
  });

  group('getStudyNoteById', () {
    test('returns the note on success', () async {
      when(
        () => remoteDataSource.getStudyNoteById(noteId: any(named: 'noteId')),
      ).thenAnswer((_) async => tStudyNoteModel);

      final result = await repository.getStudyNoteById(noteId: tStudyNoteId);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (note) => expect(note.noteId, tStudyNoteId),
      );
    });

    test('returns Left when the datasource throws', () async {
      when(
        () => remoteDataSource.getStudyNoteById(noteId: any(named: 'noteId')),
      ).thenThrow(tRemoteException);

      final result = await repository.getStudyNoteById(noteId: tStudyNoteId);

      expect(result.isLeft(), isTrue);
    });
  });

  group('createStudyNote', () {
    test('returns Right(unit) on success without a pdf', () async {
      when(
        () => remoteDataSource.createStudyNote(
          note: any(named: 'note'),
          localPdfFilePath: any(named: 'localPdfFilePath'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.createStudyNote(
        note: tStudyNoteEntityWithoutPdf,
      );

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
      verify(
        () => remoteDataSource.createStudyNote(
          note: any(named: 'note'),
          localPdfFilePath: null,
        ),
      ).called(1);
    });

    test('forwards the local pdf file path when a pdf is attached', () async {
      when(
        () => remoteDataSource.createStudyNote(
          note: any(named: 'note'),
          localPdfFilePath: any(named: 'localPdfFilePath'),
        ),
      ).thenAnswer((_) async {});

      await repository.createStudyNote(
        note: tStudyNoteEntity,
        localPdfFilePath: tStudyNoteLocalPdfFilePath,
      );

      final captured = verify(
        () => remoteDataSource.createStudyNote(
          note: captureAny(named: 'note'),
          localPdfFilePath: captureAny(named: 'localPdfFilePath'),
        ),
      ).captured;

      final note = captured[0] as StudyNoteModel;
      expect(captured[1], tStudyNoteLocalPdfFilePath);
      expect(note.pdfStoragePath, tStudyNotePdfStoragePath);
      expect(note.createdAt, isNull);
    });

    test('returns Left when the datasource throws', () async {
      when(
        () => remoteDataSource.createStudyNote(
          note: any(named: 'note'),
          localPdfFilePath: any(named: 'localPdfFilePath'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.createStudyNote(note: tStudyNoteEntity);

      expect(result.isLeft(), isTrue);
    });
  });

  group('updateStudyNote', () {
    test('returns Right(unit) on success without pdf changes', () async {
      when(
        () => remoteDataSource.updateStudyNote(
          note: any(named: 'note'),
          replacementPdfFilePath: any(named: 'replacementPdfFilePath'),
          removeExistingPdf: any(named: 'removeExistingPdf'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.updateStudyNote(
        note: tStudyNoteEntityWithoutPdf,
      );

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
      verify(
        () => remoteDataSource.updateStudyNote(
          note: any(named: 'note'),
          replacementPdfFilePath: null,
          removeExistingPdf: false,
        ),
      ).called(1);
    });

    test('forwards removeExistingPdf and replacement pdf path', () async {
      when(
        () => remoteDataSource.updateStudyNote(
          note: any(named: 'note'),
          replacementPdfFilePath: any(named: 'replacementPdfFilePath'),
          removeExistingPdf: any(named: 'removeExistingPdf'),
        ),
      ).thenAnswer((_) async {});

      await repository.updateStudyNote(
        note: tStudyNoteEntity,
        replacementPdfFilePath: tStudyNoteLocalPdfFilePath,
        removeExistingPdf: true,
      );

      verify(
        () => remoteDataSource.updateStudyNote(
          note: any(named: 'note'),
          replacementPdfFilePath: tStudyNoteLocalPdfFilePath,
          removeExistingPdf: true,
        ),
      ).called(1);
    });

    test('returns Left when the datasource throws', () async {
      when(
        () => remoteDataSource.updateStudyNote(
          note: any(named: 'note'),
          replacementPdfFilePath: any(named: 'replacementPdfFilePath'),
          removeExistingPdf: any(named: 'removeExistingPdf'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.updateStudyNote(note: tStudyNoteEntity);

      expect(result.isLeft(), isTrue);
    });
  });

  group('deleteStudyNote', () {
    test('returns Right(unit) on success', () async {
      when(
        () => remoteDataSource.deleteStudyNote(noteId: any(named: 'noteId')),
      ).thenAnswer((_) async {});

      final result = await repository.deleteStudyNote(noteId: tStudyNoteId);

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
    });

    test('returns Left when the datasource throws', () async {
      when(
        () => remoteDataSource.deleteStudyNote(noteId: any(named: 'noteId')),
      ).thenThrow(tRemoteException);

      final result = await repository.deleteStudyNote(noteId: tStudyNoteId);

      expect(result.isLeft(), isTrue);
    });
  });

  group('streamStudyNotes', () {
    test('emits Right(list) on success', () async {
      when(
        () => remoteDataSource.streamStudyNotes(
          gradeId: any(named: 'gradeId'),
          isPublished: any(named: 'isPublished'),
        ),
      ).thenAnswer((_) => Stream.value([tStudyNoteModel]));

      final stream = repository.streamStudyNotes();

      await expectLater(
        stream,
        emits(isA<Right<AppErrorModel, List<StudyNoteEntity>>>()),
      );
    });

    test('emits Left(AppErrorModel) when the stream throws', () async {
      when(
        () => remoteDataSource.streamStudyNotes(
          gradeId: any(named: 'gradeId'),
          isPublished: any(named: 'isPublished'),
        ),
      ).thenAnswer((_) => Stream.error(tRemoteException));

      final stream = repository.streamStudyNotes();

      await expectLater(
        stream,
        emits(isA<Left<AppErrorModel, List<StudyNoteEntity>>>()),
      );
    });
  });
}

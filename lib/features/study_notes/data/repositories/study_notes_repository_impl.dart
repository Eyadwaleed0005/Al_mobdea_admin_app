// ignore_for_file: prefer_initializing_formals

import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/features/study_notes/data/data_sources/study_notes_remote_data_source.dart';
import 'package:al_mobdea_admin/features/study_notes/data/models/study_note_model.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/repositories/study_notes_repository.dart';
import 'package:dartz/dartz.dart';

class StudyNotesRepositoryImpl implements StudyNotesRepository {
  const StudyNotesRepositoryImpl({
    required StudyNotesRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final StudyNotesRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppErrorModel, List<StudyNoteEntity>>> getStudyNotes({
    String? gradeId,
    bool? isPublished,
  }) {
    return _execute<List<StudyNoteEntity>>(() async {
      final notes = await _remoteDataSource.getStudyNotes(
        gradeId: gradeId,
        isPublished: isPublished,
      );

      return List<StudyNoteEntity>.unmodifiable(notes);
    });
  }

  @override
  Future<Either<AppErrorModel, StudyNoteEntity>> getStudyNoteById({
    required String noteId,
  }) {
    return _execute<StudyNoteEntity>(() {
      return _remoteDataSource.getStudyNoteById(noteId: noteId);
    });
  }

  @override
  Stream<Either<AppErrorModel, List<StudyNoteEntity>>> streamStudyNotes({
    String? gradeId,
    bool? isPublished,
  }) {
    return _executeStream<List<StudyNoteEntity>>(() {
      return _remoteDataSource
          .streamStudyNotes(gradeId: gradeId, isPublished: isPublished)
          .map<List<StudyNoteEntity>>((notes) {
            return List<StudyNoteEntity>.unmodifiable(notes);
          });
    });
  }

  @override
  Future<Either<AppErrorModel, Unit>> createStudyNote({
    required StudyNoteEntity note,
    String? localPdfFilePath,
  }) {
    return _execute<Unit>(() async {
      final noteModel = StudyNoteModel.fromEntity(note);

      await _remoteDataSource.createStudyNote(
        note: noteModel,
        localPdfFilePath: localPdfFilePath,
      );

      return unit;
    });
  }

  @override
  Future<Either<AppErrorModel, Unit>> updateStudyNote({
    required StudyNoteEntity note,
    String? replacementPdfFilePath,
    bool removeExistingPdf = false,
  }) {
    return _execute<Unit>(() async {
      final noteModel = StudyNoteModel.fromEntity(note);

      await _remoteDataSource.updateStudyNote(
        note: noteModel,
        replacementPdfFilePath: replacementPdfFilePath,
        removeExistingPdf: removeExistingPdf,
      );

      return unit;
    });
  }

  @override
  Future<Either<AppErrorModel, Unit>> deleteStudyNote({
    required String noteId,
  }) {
    return _execute<Unit>(() async {
      await _remoteDataSource.deleteStudyNote(noteId: noteId);

      return unit;
    });
  }

  Future<Either<AppErrorModel, T>> _execute<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();

      return Right<AppErrorModel, T>(result);
    } on FirebaseRemoteException catch (error) {
      return Left<AppErrorModel, T>(error.errorModel);
    }
  }

  Stream<Either<AppErrorModel, T>> _executeStream<T>(
    Stream<T> Function() operation,
  ) async* {
    try {
      await for (final result in operation()) {
        yield Right<AppErrorModel, T>(result);
      }
    } on FirebaseRemoteException catch (error) {
      yield Left<AppErrorModel, T>(error.errorModel);
    }
  }
}

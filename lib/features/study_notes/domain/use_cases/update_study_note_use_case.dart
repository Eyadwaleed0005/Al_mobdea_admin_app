// ignore_for_file: prefer_initializing_formals

import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/repositories/study_notes_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateStudyNoteUseCase {
  const UpdateStudyNoteUseCase({required StudyNotesRepository repository})
    : _repository = repository;

  final StudyNotesRepository _repository;

  Future<Either<AppErrorModel, Unit>> call({
    required StudyNoteEntity note,
    String? replacementPdfFilePath,
    bool removeExistingPdf = false,
  }) {
    return _repository.updateStudyNote(
      note: note,
      replacementPdfFilePath: replacementPdfFilePath,
      removeExistingPdf: removeExistingPdf,
    );
  }
}

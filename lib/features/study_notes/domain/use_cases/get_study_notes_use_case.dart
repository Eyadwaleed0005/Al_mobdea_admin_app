// ignore_for_file: prefer_initializing_formals

import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/repositories/study_notes_repository.dart';
import 'package:dartz/dartz.dart';

class GetStudyNotesUseCase {
  const GetStudyNotesUseCase({required StudyNotesRepository repository})
    : _repository = repository;

  final StudyNotesRepository _repository;

  Future<Either<AppErrorModel, List<StudyNoteEntity>>> call({
    String? gradeId,
    bool? isPublished,
  }) {
    return _repository.getStudyNotes(
      gradeId: gradeId,
      isPublished: isPublished,
    );
  }
}

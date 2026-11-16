import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';

class UpdateStudyNoteParams {
  const UpdateStudyNoteParams({
    required this.note,
    this.replacementPdfFilePath,
  });

  final StudyNoteEntity note;

  final String? replacementPdfFilePath;
}

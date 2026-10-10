import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';

class CreateStudyNoteParams {
  const CreateStudyNoteParams({required this.note, this.localPdfFilePath});

  final StudyNoteEntity note;
  final String? localPdfFilePath;
}

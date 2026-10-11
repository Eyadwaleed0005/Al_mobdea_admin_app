import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';

sealed class ContentManagementState {
  const ContentManagementState();
}

final class ContentManagementInitial extends ContentManagementState {
  const ContentManagementInitial();
}

final class ContentManagementLoading extends ContentManagementState {
  const ContentManagementLoading();
}

final class ContentManagementLoaded extends ContentManagementState {
  ContentManagementLoaded({required List<StudyNoteEntity> notes})
    : notes = List<StudyNoteEntity>.unmodifiable(notes);

  final List<StudyNoteEntity> notes;

  int get notesCount => notes.length;

  int get publishedNotesCount => notes.where((note) => note.isPublished).length;

  int get draftNotesCount => notesCount - publishedNotesCount;

  String get notesSubtitle {
    return StudyNoteEntity.summarySubtitle(notes);
  }

  String get welcomeSubtitle {
    return StudyNoteEntity.contentSummarySubtitle(notesCount: notesCount);
  }
}

final class ContentManagementFailure extends ContentManagementState {
  const ContentManagementFailure({required this.error});

  final Object error;
}

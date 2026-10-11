import 'package:al_mobdea_admin/features/lessons/domain/entities/lesson_entity.dart';
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
  ContentManagementLoaded({
    required List<LessonEntity> lessons,
    required List<StudyNoteEntity> notes,
  }) : lessons = List<LessonEntity>.unmodifiable(lessons),
       notes = List<StudyNoteEntity>.unmodifiable(notes);

  final List<LessonEntity> lessons;
  final List<StudyNoteEntity> notes;

  int get lessonsCount => lessons.length;

  int get notesCount => notes.length;

  String get lessonsSubtitle => LessonEntity.summarySubtitle(lessons);

  String get notesSubtitle => StudyNoteEntity.summarySubtitle(notes);

  String get welcomeSubtitle => [
    LessonEntity.countSubtitle(lessons),
    StudyNoteEntity.countSubtitle(notes),
  ].join(' • ');
}

final class ContentManagementFailure extends ContentManagementState {
  const ContentManagementFailure({required this.error});

  final Object error;
}

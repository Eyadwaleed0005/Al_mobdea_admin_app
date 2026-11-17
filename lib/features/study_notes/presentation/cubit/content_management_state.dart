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

  String get lessonsSubtitle => _lessonsSummary(lessons);

  String get notesSubtitle => _notesSummary(notes);

  String get welcomeSubtitle =>
      [_lessonsCount(lessons), _notesCount(notes)].join(' • ');
}

final class ContentManagementFailure extends ContentManagementState {
  const ContentManagementFailure({required this.error});

  final Object error;
}

String _lessonsSummary(List<LessonEntity> lessons) {
  return _summary(
    total: lessons.length,
    published: lessons.where((lesson) => lesson.isPublished).length,
    emptyLabel: 'لا توجد دروس حتى الآن',
    countLabel: _lessonsCount(lessons),
  );
}

String _notesSummary(List<StudyNoteEntity> notes) {
  return _summary(
    total: notes.length,
    published: notes.where((note) => note.isPublished).length,
    emptyLabel: 'لا توجد مذكرات حتى الآن',
    countLabel: _notesCount(notes),
  );
}

String _summary({
  required int total,
  required int published,
  required String emptyLabel,
  required String countLabel,
}) {
  if (total == 0) {
    return emptyLabel;
  }

  final drafts = total - published;

  if (published == total) {
    return '$countLabel • جميعها منشورة';
  }

  if (drafts == total) {
    return '$countLabel • جميعها مسودات';
  }

  return '$countLabel'
      ' • منشورة: ${_arabicNumber(published)}'
      ' • مسودات: ${_arabicNumber(drafts)}';
}

String _lessonsCount(List<LessonEntity> lessons) {
  final count = lessons.length;

  if (count == 0) return '٠ دروس';
  if (count == 1) return 'درس واحد';
  if (count == 2) return 'درسان';

  final remainder = count % 100;
  final noun = remainder >= 3 && remainder <= 10 ? 'دروس' : 'درسًا';

  return '${_arabicNumber(count)} $noun';
}

String _notesCount(List<StudyNoteEntity> notes) {
  final count = notes.length;

  if (count == 0) return '٠ ملفات PDF';
  if (count == 1) return 'ملف PDF واحد';
  if (count == 2) return 'ملفان PDF';

  final remainder = count % 100;
  final noun = remainder >= 3 && remainder <= 10 ? 'ملفات PDF' : 'ملف PDF';

  return '${_arabicNumber(count)} $noun';
}

String _arabicNumber(int number) {
  const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  return number.toString().split('').map((character) {
    final digit = int.tryParse(character);
    return digit == null ? character : digits[digit];
  }).join();
}

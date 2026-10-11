class StudyNoteEntity {
  const StudyNoteEntity({
    required this.noteId,
    required this.name,
    required this.description,
    required this.gradeId,
    required this.isPublished,
    this.pdfStoragePath,
    this.pdfFileName,
    this.pdfFileSize,
    this.createdAt,
    this.updatedAt,
  });

  final String noteId;
  final String name;
  final String description;
  final String gradeId;
  final bool isPublished;
  final String? pdfStoragePath;
  final String? pdfFileName;
  final int? pdfFileSize;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasPdfFile {
    return pdfStoragePath?.trim().isNotEmpty ?? false;
  }

  // Welcome card summary.
  static String contentSummarySubtitle({
    int? lessonsCount,
    int? notesCount,
    int? unitsCount,
  }) {
    final parts = <String>[];

    if (lessonsCount != null) {
      parts.add(_lessonsCountLabel(lessonsCount));
    }

    if (notesCount != null) {
      parts.add(_pdfCountLabel(notesCount));
    }

    if (unitsCount != null) {
      parts.add(_unitsCountLabel(unitsCount));
    }

    return parts.isEmpty ? 'إدارة الدروس والمذكرات' : parts.join(' • ');
  }

  // Notes section summary.
  static String summarySubtitle(List<StudyNoteEntity> notes) {
    if (notes.isEmpty) {
      return 'لا توجد مذكرات حتى الآن';
    }

    final total = notes.length;
    final published = notes.where((note) => note.isPublished).length;
    final drafts = total - published;
    final countLabel = _pdfCountLabel(total);

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

  static bool _usesPlural(int count) {
    final remainder = count % 100;
    return remainder >= 3 && remainder <= 10;
  }

  static String _lessonsCountLabel(int count) {
    if (count == 1) return 'درس واحد';
    if (count == 2) return 'درسان';

    final noun = _usesPlural(count) ? 'دروس' : 'درس';

    return '${_arabicNumber(count)} $noun';
  }

  static String _pdfCountLabel(int count) {
    if (count == 1) return 'ملف PDF واحد';
    if (count == 2) return 'ملفان PDF';

    final noun = _usesPlural(count) ? 'ملفات PDF' : 'ملف PDF';

    return '${_arabicNumber(count)} $noun';
  }

  static String _unitsCountLabel(int count) {
    if (count == 1) return 'وحدة دراسية واحدة';
    if (count == 2) return 'وحدتان دراسيتان';

    final noun = _usesPlural(count) ? 'وحدات دراسية' : 'وحدة دراسية';

    return '${_arabicNumber(count)} $noun';
  }

  static String _arabicNumber(int number) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    return number.toString().split('').map((character) {
      final digit = int.tryParse(character);
      return digit == null ? character : digits[digit];
    }).join();
  }

  StudyNoteEntity copyWith({
    String? noteId,
    String? name,
    String? description,
    String? gradeId,
    bool? isPublished,
    String? pdfStoragePath,
    String? pdfFileName,
    int? pdfFileSize,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearPdf = false,
  }) {
    return StudyNoteEntity(
      noteId: noteId ?? this.noteId,
      name: name ?? this.name,
      description: description ?? this.description,
      gradeId: gradeId ?? this.gradeId,
      isPublished: isPublished ?? this.isPublished,
      pdfStoragePath: clearPdf ? null : pdfStoragePath ?? this.pdfStoragePath,
      pdfFileName: clearPdf ? null : pdfFileName ?? this.pdfFileName,
      pdfFileSize: clearPdf ? null : pdfFileSize ?? this.pdfFileSize,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

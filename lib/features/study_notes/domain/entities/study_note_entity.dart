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

  static String countSubtitle(List<StudyNoteEntity> notes) {
    return _countLabel(notes.length);
  }

  static String summarySubtitle(List<StudyNoteEntity> notes) {
    if (notes.isEmpty) {
      return 'لا توجد مذكرات حتى الآن';
    }

    final total = notes.length;
    final published = notes.where((note) => note.isPublished).length;
    final drafts = total - published;
    final countLabel = countSubtitle(notes);

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

  static String _countLabel(int count) {
    if (count == 0) return '٠ ملفات PDF';
    if (count == 1) return 'ملف PDF واحد';
    if (count == 2) return 'ملفان PDF';

    final remainder = count % 100;
    final noun = remainder >= 3 && remainder <= 10
        ? 'ملفات PDF'
        : 'ملف PDF';

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
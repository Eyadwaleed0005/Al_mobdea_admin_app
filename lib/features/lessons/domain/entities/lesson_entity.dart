class LessonEntity {
  const LessonEntity({
    required this.lessonId,
    required this.gradeId,
    required this.title,
    required this.subtitle,
    required this.isPublished,
    this.youtubeUrl,
    this.pdfFileName,
    this.pdfFileSize,
    this.pdfStoragePath,
  });

  final String lessonId;
  final String gradeId;
  final String title;
  final String subtitle;
  final String? youtubeUrl;
  final String? pdfFileName;
  final int? pdfFileSize;
  final String? pdfStoragePath;
  final bool isPublished;

  bool get hasYoutubeVideo {
    return youtubeUrl?.trim().isNotEmpty ?? false;
  }

  bool get hasPdfFile {
    return pdfStoragePath?.trim().isNotEmpty ?? false;
  }

  static String countSubtitle(List<LessonEntity> lessons) {
    return _countLabel(lessons.length);
  }

  static String summarySubtitle(List<LessonEntity> lessons) {
    if (lessons.isEmpty) {
      return 'لا توجد دروس حتى الآن';
    }

    final total = lessons.length;
    final published = lessons.where((lesson) => lesson.isPublished).length;
    final drafts = total - published;
    final countLabel = countSubtitle(lessons);

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
    if (count == 0) return '٠ دروس';
    if (count == 1) return 'درس واحد';
    if (count == 2) return 'درسان';

    final remainder = count % 100;
    final noun = remainder >= 3 && remainder <= 10 ? 'دروس' : 'درسًا';

    return '${_arabicNumber(count)} $noun';
  }

  static String _arabicNumber(int number) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    return number.toString().split('').map((character) {
      final digit = int.tryParse(character);
      return digit == null ? character : digits[digit];
    }).join();
  }

  LessonEntity copyWith({
    String? lessonId,
    String? gradeId,
    String? title,
    String? subtitle,
    String? youtubeUrl,
    String? pdfFileName,
    int? pdfFileSize,
    String? pdfStoragePath,
    bool? isPublished,
    bool clearYoutubeUrl = false,
    bool clearPdf = false,
  }) {
    return LessonEntity(
      lessonId: lessonId ?? this.lessonId,
      gradeId: gradeId ?? this.gradeId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      youtubeUrl: clearYoutubeUrl ? null : youtubeUrl ?? this.youtubeUrl,
      pdfFileName: clearPdf ? null : pdfFileName ?? this.pdfFileName,
      pdfFileSize: clearPdf ? null : pdfFileSize ?? this.pdfFileSize,
      pdfStoragePath: clearPdf ? null : pdfStoragePath ?? this.pdfStoragePath,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}

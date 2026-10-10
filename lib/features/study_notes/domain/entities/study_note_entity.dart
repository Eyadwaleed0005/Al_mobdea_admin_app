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

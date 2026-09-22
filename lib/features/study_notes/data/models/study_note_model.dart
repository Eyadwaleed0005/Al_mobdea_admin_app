import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudyNoteModel extends StudyNoteEntity {
  const StudyNoteModel({
    required super.noteId,
    required super.name,
    required super.description,
    required super.gradeId,
    required super.isPublished,
    super.pdfStoragePath,
    super.pdfFileName,
    super.pdfFileSize,
    super.createdAt,
    super.updatedAt,
  });

  factory StudyNoteModel.fromEntity(StudyNoteEntity note) {
    return StudyNoteModel(
      noteId: note.noteId,
      name: note.name,
      description: note.description,
      gradeId: note.gradeId,
      isPublished: note.isPublished,
      pdfStoragePath: note.pdfStoragePath,
      pdfFileName: note.pdfFileName,
      pdfFileSize: note.pdfFileSize,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }

  factory StudyNoteModel.fromMap({
    required String documentId,
    required Map<String, dynamic> map,
  }) {
    return StudyNoteModel(
      noteId: documentId,
      name: _readString(map[FirestoreFields.name]),
      description: _readString(map[FirestoreFields.description]),
      gradeId: _readString(map[FirestoreFields.gradeId]),
      isPublished: _readBool(map[FirestoreFields.isPublished]),
      pdfStoragePath: _readNullableString(map[FirestoreFields.pdfStoragePath]),
      pdfFileName: _readNullableString(map[FirestoreFields.pdfFileName]),
      pdfFileSize: _readNullablePositiveInt(map[FirestoreFields.pdfFileSize]),
      createdAt: _readDateTime(map[FirestoreFields.createdAt]),
      updatedAt: _readDateTime(map[FirestoreFields.updatedAt]),
    );
  }

  Map<String, dynamic> toCreateMap() {
    final map = <String, dynamic>{
      FirestoreFields.name: name.trim(),
      FirestoreFields.description: description.trim(),
      FirestoreFields.gradeId: gradeId.trim(),
      FirestoreFields.isPublished: isPublished,
      FirestoreFields.createdAt: FieldValue.serverTimestamp(),
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    };

    _addPdfFieldsIfAvailable(map);

    return map;
  }

  Map<String, dynamic> toUpdateMap({bool removePdf = false}) {
    final map = <String, dynamic>{
      FirestoreFields.name: name.trim(),
      FirestoreFields.description: description.trim(),
      FirestoreFields.gradeId: gradeId.trim(),
      FirestoreFields.isPublished: isPublished,
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    };

    if (removePdf) {
      _addDeletedPdfFields(map);
    } else {
      _addPdfFieldsIfAvailable(map);
    }

    return map;
  }

  void _addPdfFieldsIfAvailable(Map<String, dynamic> map) {
    final normalizedStoragePath = pdfStoragePath?.trim();
    final normalizedFileName = pdfFileName?.trim();
    final normalizedFileSize = pdfFileSize;

    final hasValidPdf =
        normalizedStoragePath != null &&
        normalizedStoragePath.isNotEmpty &&
        normalizedFileName != null &&
        normalizedFileName.isNotEmpty &&
        normalizedFileSize != null &&
        normalizedFileSize > 0;

    if (!hasValidPdf) {
      return;
    }

    map[FirestoreFields.pdfStoragePath] = normalizedStoragePath;
    map[FirestoreFields.pdfFileName] = normalizedFileName;
    map[FirestoreFields.pdfFileSize] = normalizedFileSize;
  }

  void _addDeletedPdfFields(Map<String, dynamic> map) {
    map[FirestoreFields.pdfStoragePath] = FieldValue.delete();
    map[FirestoreFields.pdfFileName] = FieldValue.delete();
    map[FirestoreFields.pdfFileSize] = FieldValue.delete();
  }

  static String _readString(dynamic value) {
    return value is String ? value.trim() : '';
  }

  static String? _readNullableString(dynamic value) {
    if (value is! String) {
      return null;
    }

    final normalizedValue = value.trim();

    return normalizedValue.isEmpty ? null : normalizedValue;
  }

  static int? _readNullablePositiveInt(dynamic value) {
    final intValue = value is int
        ? value
        : value is num
        ? value.toInt()
        : null;

    if (intValue == null || intValue <= 0) {
      return null;
    }

    return intValue;
  }

  static bool _readBool(dynamic value) {
    return value is bool ? value : false;
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}

import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/lessons/data/models/lesson_model.dart';
import 'package:al_mobdea_admin/features/lessons/domain/entities/lesson_entity.dart';
import 'package:al_mobdea_admin/features/students/data/models/student_model.dart';
import 'package:al_mobdea_admin/features/students/domain/entities/student_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Students feature dummy data

final DateTime tSubscriptionStartAt = DateTime.utc(2024, 1, 1);
final DateTime tSubscriptionEndAt = DateTime.utc(2100, 1, 1);
final DateTime tCreatedAt = DateTime.utc(2024, 1, 1, 12);
final DateTime tUpdatedAt = DateTime.utc(2024, 1, 2, 12);

const String tStudentId = 'student-123';
const String tGradeId = 'grade-1';
const String tStudentName = 'Ahmed Ali';
const int tStudentAge = 16;
const String tStudentEmail = 'ahmed@example.com';
const String tStudentPhone = '01000000000';

final StudentEntity tStudentEntity = StudentEntity(
  studentId: tStudentId,
  gradeId: tGradeId,
  name: tStudentName,
  age: tStudentAge,
  email: tStudentEmail,
  phoneNumber: tStudentPhone,
  subscriptionStartAt: tSubscriptionStartAt,
  subscriptionEndAt: tSubscriptionEndAt,
  isActive: true,
  isLoggedIn: false,
);

final StudentModel tStudentModel = StudentModel(
  studentId: tStudentId,
  gradeId: tGradeId,
  name: tStudentName,
  age: tStudentAge,
  email: tStudentEmail,
  phoneNumber: tStudentPhone,
  subscriptionStartAt: tSubscriptionStartAt,
  subscriptionEndAt: tSubscriptionEndAt,
  isActive: true,
  isLoggedIn: false,
  createdAt: tCreatedAt,
  updatedAt: tUpdatedAt,
);

Map<String, dynamic> tStudentJson() {
  return {
    FirestoreFields.studentId: tStudentId,
    FirestoreFields.gradeId: tGradeId,
    FirestoreFields.name: tStudentName,
    FirestoreFields.age: tStudentAge,
    FirestoreFields.email: tStudentEmail,
    FirestoreFields.phoneNumber: tStudentPhone,
    FirestoreFields.subscriptionStartAt: Timestamp.fromDate(
      tSubscriptionStartAt,
    ),
    FirestoreFields.subscriptionEndAt: Timestamp.fromDate(
      tSubscriptionEndAt,
    ),
    FirestoreFields.isActive: true,
    FirestoreFields.isLoggedIn: false,
    FirestoreFields.createdAt: Timestamp.fromDate(tCreatedAt),
    FirestoreFields.updatedAt: Timestamp.fromDate(tUpdatedAt),
  };
}

// Lessons feature dummy data

const String tLessonId = 'lesson-123';
const String tLessonTitle = 'Introduction to Physics';
const String tLessonSubtitle = 'A beginner lesson about motion';
const String tYoutubeUrl = 'https://youtube.com/watch?v=abc123';
const String tPdfFileName = 'lesson-notes.pdf';
const int tPdfFileSize = 1024;
const String tPdfStoragePath = 'lessons/lesson-123/1.pdf';
const String tLocalPdfFilePath = '/tmp/lesson-notes.pdf';

final DateTime tLessonCreatedAt = DateTime.utc(2024, 5, 1, 10);
final DateTime tLessonUpdatedAt = DateTime.utc(2024, 5, 2, 12);

final LessonEntity tLessonEntity = LessonEntity(
  lessonId: tLessonId,
  gradeId: tGradeId,
  title: tLessonTitle,
  subtitle: tLessonSubtitle,
  youtubeUrl: tYoutubeUrl,
  pdfFileName: tPdfFileName,
  pdfFileSize: tPdfFileSize,
  pdfStoragePath: tPdfStoragePath,
  isPublished: true,
);

/// A lesson created without any PDF attachment (PDF-optional path).
final LessonEntity tLessonEntityWithoutPdf = LessonEntity(
  lessonId: tLessonId,
  gradeId: tGradeId,
  title: tLessonTitle,
  subtitle: tLessonSubtitle,
  youtubeUrl: tYoutubeUrl,
  isPublished: true,
);

final LessonModel tLessonModel = LessonModel(
  lessonId: tLessonId,
  gradeId: tGradeId,
  title: tLessonTitle,
  subtitle: tLessonSubtitle,
  youtubeUrl: tYoutubeUrl,
  pdfFileName: tPdfFileName,
  pdfFileSize: tPdfFileSize,
  pdfStoragePath: tPdfStoragePath,
  isPublished: true,
  createdAt: tLessonCreatedAt,
  updatedAt: tLessonUpdatedAt,
);

final LessonModel tSecondLessonModel = LessonModel(
  lessonId: 'lesson-456',
  gradeId: tGradeId,
  title: 'Advanced Physics',
  subtitle: 'An advanced lesson about energy',
  youtubeUrl: null,
  isPublished: false,
  createdAt: tLessonCreatedAt.subtract(const Duration(days: 1)),
  updatedAt: tLessonUpdatedAt,
);

/// Firestore document map for a lesson that has a PDF attached.
Map<String, dynamic> tLessonJson() {
  return {
    FirestoreFields.gradeId: tGradeId,
    FirestoreFields.title: tLessonTitle,
    FirestoreFields.description: tLessonSubtitle,
    FirestoreFields.youtubeUrl: tYoutubeUrl,
    FirestoreFields.pdfFileName: tPdfFileName,
    FirestoreFields.pdfFileSize: tPdfFileSize,
    FirestoreFields.pdfStoragePath: tPdfStoragePath,
    FirestoreFields.isPublished: true,
    FirestoreFields.createdAt: Timestamp.fromDate(tLessonCreatedAt),
    FirestoreFields.updatedAt: Timestamp.fromDate(tLessonUpdatedAt),
  };
}

/// Firestore document map for a lesson without any PDF (PDF-optional path).
Map<String, dynamic> tLessonJsonWithoutPdf() {
  return {
    FirestoreFields.gradeId: tGradeId,
    FirestoreFields.title: tLessonTitle,
    FirestoreFields.description: tLessonSubtitle,
    FirestoreFields.youtubeUrl: tYoutubeUrl,
    FirestoreFields.isPublished: true,
    FirestoreFields.createdAt: Timestamp.fromDate(tLessonCreatedAt),
    FirestoreFields.updatedAt: Timestamp.fromDate(tLessonUpdatedAt),
  };
}

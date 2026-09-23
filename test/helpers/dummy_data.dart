import 'dart:typed_data';

import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/exams/data/models/exam_model.dart';
import 'package:al_mobdea_admin/features/exams/data/models/exam_question_model.dart';
import 'package:al_mobdea_admin/features/exams/data/models/exam_result_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_attempt_status.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_question_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_result_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/exam_question_image_file.dart';
import 'package:al_mobdea_admin/features/lesson_exams/data/models/lesson_exam_question_model.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/entities/lesson_exam_entity.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/entities/lesson_exam_question_entity.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/lesson_exam_question_image_file.dart';
import 'package:al_mobdea_admin/features/lessons/data/models/lesson_model.dart';
import 'package:al_mobdea_admin/features/live_session/data/models/live_session_model.dart';
import 'package:al_mobdea_admin/features/live_session/domain/entities/live_session_entity.dart';
import 'package:al_mobdea_admin/features/live_session/domain/entities/meeting_type.dart';
import 'package:al_mobdea_admin/features/lessons/domain/entities/lesson_entity.dart';
import 'package:al_mobdea_admin/features/grades/data/models/grade_model.dart';
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:al_mobdea_admin/features/study_notes/data/models/study_note_model.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';
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
    FirestoreFields.createdAt: Timestamp.fromDate(
      tLessonCreatedAt,
    ),
    FirestoreFields.updatedAt: Timestamp.fromDate(
      tLessonUpdatedAt,
    ),
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
    FirestoreFields.createdAt: Timestamp.fromDate(
      tLessonCreatedAt,
    ),
    FirestoreFields.updatedAt: Timestamp.fromDate(
      tLessonUpdatedAt,
    ),
  };
}

// Lesson exams feature dummy data

const String tLessonExamQuestionId = 'question-123';
const String tSecondLessonExamQuestionId = 'question-456';
const String tLessonExamQuestionText = 'What is velocity?';
const int tLessonExamQuestionDegree = 5;
const int tLessonExamCorrectChoiceIndex = 1;
const List<String> tLessonExamChoices = [
  'Distance only',
  'Displacement over time',
  'Mass over volume',
  'Force over area',
];
const String tQuestionImageUrl =
    'https://storage.example.com/question.jpg';
const String tQuestionImageStoragePath =
    'lesson_question_images/lesson-123/1.jpg';
const String tReplacementQuestionImageStoragePath =
    'lesson_question_images/lesson-123/2.jpg';
const String tQuestionImageName = 'question.jpg';
const String tQuestionImageDownloadUrl =
    'https://storage.example.com/new-question.jpg';

final DateTime tLessonExamQuestionCreatedAt = DateTime.utc(
  2024,
  7,
  1,
  10,
);
final DateTime tLessonExamQuestionUpdatedAt = DateTime.utc(
  2024,
  7,
  2,
  12,
);

final LessonExamQuestionEntity tLessonExamQuestionEntity =
    LessonExamQuestionEntity(
      questionId: tLessonExamQuestionId,
      lessonId: tLessonId,
      questionText: tLessonExamQuestionText,
      degree: tLessonExamQuestionDegree,
      choices: tLessonExamChoices,
      correctChoiceIndex: tLessonExamCorrectChoiceIndex,
      imageUrl: tQuestionImageUrl,
      imageStoragePath: tQuestionImageStoragePath,
      createdAt: tLessonExamQuestionCreatedAt,
      updatedAt: tLessonExamQuestionUpdatedAt,
    );

final LessonExamQuestionEntity
tLessonExamQuestionEntityWithoutImage = tLessonExamQuestionEntity
    .copyWith(clearImage: true);

final LessonExamQuestionModel tLessonExamQuestionModel =
    LessonExamQuestionModel(
      questionId: tLessonExamQuestionId,
      lessonId: tLessonId,
      questionText: tLessonExamQuestionText,
      degree: tLessonExamQuestionDegree,
      choices: tLessonExamChoices,
      correctChoiceIndex: tLessonExamCorrectChoiceIndex,
      imageUrl: tQuestionImageUrl,
      imageStoragePath: tQuestionImageStoragePath,
      createdAt: tLessonExamQuestionCreatedAt,
      updatedAt: tLessonExamQuestionUpdatedAt,
    );

final LessonExamQuestionModel tSecondLessonExamQuestionModel =
    LessonExamQuestionModel(
      questionId: tSecondLessonExamQuestionId,
      lessonId: tLessonId,
      questionText: 'What is acceleration?',
      degree: 10,
      choices: const [
        'Velocity over time',
        'Mass over time',
        'Distance only',
        'Energy over force',
      ],
      createdAt: tLessonExamQuestionCreatedAt.add(
        const Duration(minutes: 1),
      ),
      updatedAt: tLessonExamQuestionUpdatedAt,
    );

final LessonExamEntity tLessonExamEntity = LessonExamEntity(
  lessonId: tLessonId,
  questions: [tLessonExamQuestionEntity],
);

final LessonExamQuestionImageFile tLessonExamQuestionImageFile =
    LessonExamQuestionImageFile(
      name: tQuestionImageName,
      sizeInBytes: 4,
      bytes: Uint8List.fromList(const [1, 2, 3, 4]),
    );

Map<String, dynamic> tLessonExamQuestionJson() {
  return {
    FirestoreFields.lessonId: tLessonId,
    FirestoreFields.questionText: tLessonExamQuestionText,
    FirestoreFields.questionScore: tLessonExamQuestionDegree,
    FirestoreFields.option1: tLessonExamChoices[0],
    FirestoreFields.option2: tLessonExamChoices[1],
    FirestoreFields.option3: tLessonExamChoices[2],
    FirestoreFields.option4: tLessonExamChoices[3],
    FirestoreFields.correctOption: tLessonExamCorrectChoiceIndex,
    FirestoreFields.questionImageUrl: tQuestionImageUrl,
    FirestoreFields.questionImageStoragePath:
        tQuestionImageStoragePath,
    FirestoreFields.createdAt: Timestamp.fromDate(
      tLessonExamQuestionCreatedAt,
    ),
    FirestoreFields.updatedAt: Timestamp.fromDate(
      tLessonExamQuestionUpdatedAt,
    ),
  };
}

Map<String, dynamic> tLessonExamQuestionJsonWithoutImage() {
  return {
    FirestoreFields.lessonId: tLessonId,
    FirestoreFields.questionText: tLessonExamQuestionText,
    FirestoreFields.questionScore: tLessonExamQuestionDegree,
    FirestoreFields.option1: tLessonExamChoices[0],
    FirestoreFields.option2: tLessonExamChoices[1],
    FirestoreFields.option3: tLessonExamChoices[2],
    FirestoreFields.option4: tLessonExamChoices[3],
    FirestoreFields.correctOption: null,
    FirestoreFields.createdAt: Timestamp.fromDate(
      tLessonExamQuestionCreatedAt,
    ),
    FirestoreFields.updatedAt: Timestamp.fromDate(
      tLessonExamQuestionUpdatedAt,
    ),
  };
}

// Study notes feature dummy data

const String tStudyNoteId = 'note-123';
const String tStudyNoteName = 'Physics summary';
const String tStudyNoteDescription =
    'Compact notes for chapter one';
const String tStudyNotePdfFileName = 'physics-summary.pdf';
const int tStudyNotePdfFileSize = 4096;
const String tStudyNotePdfStoragePath =
    'study_notes/note-123/1.pdf';
const String tStudyNoteLocalPdfFilePath =
    '/tmp/physics-summary.pdf';

final DateTime tStudyNoteCreatedAt = DateTime.utc(
  2024,
  6,
  1,
  10,
);
final DateTime tStudyNoteUpdatedAt = DateTime.utc(
  2024,
  6,
  2,
  12,
);

final StudyNoteEntity tStudyNoteEntity = StudyNoteEntity(
  noteId: tStudyNoteId,
  name: tStudyNoteName,
  description: tStudyNoteDescription,
  gradeId: tGradeId,
  isPublished: true,
  pdfFileName: tStudyNotePdfFileName,
  pdfFileSize: tStudyNotePdfFileSize,
  pdfStoragePath: tStudyNotePdfStoragePath,
);

final StudyNoteEntity tStudyNoteEntityWithoutPdf =
    StudyNoteEntity(
      noteId: tStudyNoteId,
      name: tStudyNoteName,
      description: tStudyNoteDescription,
      gradeId: tGradeId,
      isPublished: true,
    );

final StudyNoteModel tStudyNoteModel = StudyNoteModel(
  noteId: tStudyNoteId,
  name: tStudyNoteName,
  description: tStudyNoteDescription,
  gradeId: tGradeId,
  isPublished: true,
  pdfFileName: tStudyNotePdfFileName,
  pdfFileSize: tStudyNotePdfFileSize,
  pdfStoragePath: tStudyNotePdfStoragePath,
  createdAt: tStudyNoteCreatedAt,
  updatedAt: tStudyNoteUpdatedAt,
);

final StudyNoteModel tSecondStudyNoteModel = StudyNoteModel(
  noteId: 'note-456',
  name: 'Chemistry summary',
  description: 'Compact notes for chapter two',
  gradeId: tGradeId,
  isPublished: false,
  createdAt: tStudyNoteCreatedAt.subtract(
    const Duration(days: 1),
  ),
  updatedAt: tStudyNoteUpdatedAt,
);

Map<String, dynamic> tStudyNoteJson() {
  return {
    FirestoreFields.name: tStudyNoteName,
    FirestoreFields.description: tStudyNoteDescription,
    FirestoreFields.gradeId: tGradeId,
    FirestoreFields.isPublished: true,
    FirestoreFields.pdfFileName: tStudyNotePdfFileName,
    FirestoreFields.pdfFileSize: tStudyNotePdfFileSize,
    FirestoreFields.pdfStoragePath: tStudyNotePdfStoragePath,
    FirestoreFields.createdAt: Timestamp.fromDate(
      tStudyNoteCreatedAt,
    ),
    FirestoreFields.updatedAt: Timestamp.fromDate(
      tStudyNoteUpdatedAt,
    ),
  };
}

Map<String, dynamic> tStudyNoteJsonWithoutPdf() {
  return {
    FirestoreFields.name: tStudyNoteName,
    FirestoreFields.description: tStudyNoteDescription,
    FirestoreFields.gradeId: tGradeId,
    FirestoreFields.isPublished: true,
    FirestoreFields.createdAt: Timestamp.fromDate(
      tStudyNoteCreatedAt,
    ),
    FirestoreFields.updatedAt: Timestamp.fromDate(
      tStudyNoteUpdatedAt,
    ),
  };
}

// Exams feature dummy data

const String tExamId = 'exam-123';
const String tSecondExamId = 'exam-456';
const String tExamName = 'Midterm Physics Exam';
const int tExamDurationMinutes = 60;
const int tExamQuestionCount = 1;
const int tExamTotalScore = 5;
const int tExamParticipantsCount = 0;

final DateTime tExamCreatedAt = DateTime.utc(2024, 8, 1, 9);
final DateTime tExamUpdatedAt = DateTime.utc(2024, 8, 2, 10);

const String tExamQuestionId = 'question-123';
const String tSecondExamQuestionId = 'question-456';
const String tExamQuestionText = 'What is velocity?';
const int tExamQuestionDegree = 5;
const int tExamCorrectChoiceIndex = 1;
const List<String> tExamChoices = [
  'Distance only',
  'Displacement over time',
  'Mass over volume',
  'Force over area',
];
const String tExamQuestionImageUrl =
    'https://storage.example.com/exam-question.jpg';
const String tExamQuestionImageStoragePath =
    'exam_question_images/exam-123/question-123/1.jpg';
const String tExamQuestionImageName = 'question.jpg';
const String tExamQuestionImageDownloadUrl =
    'https://storage.example.com/new-exam-question.jpg';
const String tReplacementExamQuestionImageStoragePath =
    'exam_question_images/exam-123/question-123/2.jpg';

const String tExamResultId = 'exam-123_student-123';
const String tExamResultStudentId = 'student-123';
const String tExamResultStudentName = 'Ahmed Ali';
const String tExamResultGradeName = 'Grade 1';
const int tExamResultScore = 4;
const int tExamResultTotalScore = 5;

final DateTime tExamResultStartedAt = DateTime.utc(
  2024,
  9,
  1,
  9,
);
final DateTime tExamResultExpiresAt = DateTime.utc(
  2024,
  9,
  1,
  10,
);
final DateTime tExamResultSubmittedAt = DateTime.utc(
  2024,
  9,
  1,
  9,
  40,
);
final DateTime tFutureDateTime = DateTime.utc(2100, 1, 1);
final DateTime tPastDateTime = DateTime.utc(2020, 1, 1);

final ExamQuestionEntity tExamQuestionEntity =
    ExamQuestionEntity(
      questionId: tExamQuestionId,
      examId: tExamId,
      questionText: tExamQuestionText,
      degree: tExamQuestionDegree,
      choices: tExamChoices,
      correctChoiceIndex: tExamCorrectChoiceIndex,
      imageUrl: tExamQuestionImageUrl,
      imageStoragePath: tExamQuestionImageStoragePath,
      createdAt: tExamCreatedAt,
      updatedAt: tExamUpdatedAt,
    );

final ExamQuestionEntity tExamQuestionEntityWithoutImage =
    tExamQuestionEntity.copyWith(clearImage: true);

final ExamQuestionModel tExamQuestionModel = ExamQuestionModel(
  questionId: tExamQuestionId,
  examId: tExamId,
  questionText: tExamQuestionText,
  degree: tExamQuestionDegree,
  choices: tExamChoices,
  correctChoiceIndex: tExamCorrectChoiceIndex,
  imageUrl: tExamQuestionImageUrl,
  imageStoragePath: tExamQuestionImageStoragePath,
  createdAt: tExamCreatedAt,
  updatedAt: tExamUpdatedAt,
);

final ExamQuestionModel tSecondExamQuestionModel =
    ExamQuestionModel(
      questionId: tSecondExamQuestionId,
      examId: tExamId,
      questionText: 'What is acceleration?',
      degree: 10,
      choices: const [
        'Velocity over time',
        'Mass over time',
        'Distance only',
        'Energy over force',
      ],
      correctChoiceIndex: 0,
      createdAt: tExamCreatedAt.add(const Duration(minutes: 1)),
      updatedAt: tExamUpdatedAt,
    );

final ExamQuestionImageFile tExamQuestionImageFile =
    ExamQuestionImageFile(
      name: tExamQuestionImageName,
      sizeInBytes: 4,
      bytes: Uint8List.fromList(const [1, 2, 3, 4]),
    );

Map<String, dynamic> tExamQuestionJson({
  String examId = tExamId,
}) {
  return {
    FirestoreFields.examId: examId,
    FirestoreFields.questionText: tExamQuestionText,
    FirestoreFields.questionScore: tExamQuestionDegree,
    FirestoreFields.option1: tExamChoices[0],
    FirestoreFields.option2: tExamChoices[1],
    FirestoreFields.option3: tExamChoices[2],
    FirestoreFields.option4: tExamChoices[3],
    FirestoreFields.correctOption: tExamCorrectChoiceIndex,
    FirestoreFields.questionImageUrl: tExamQuestionImageUrl,
    FirestoreFields.questionImageStoragePath:
        tExamQuestionImageStoragePath,
    FirestoreFields.createdAt: Timestamp.fromDate(
      tExamCreatedAt,
    ),
    FirestoreFields.updatedAt: Timestamp.fromDate(
      tExamUpdatedAt,
    ),
  };
}

Map<String, dynamic> tExamQuestionJsonWithoutImage({
  String examId = tExamId,
}) {
  return {
    FirestoreFields.examId: examId,
    FirestoreFields.questionText: tExamQuestionText,
    FirestoreFields.questionScore: tExamQuestionDegree,
    FirestoreFields.option1: tExamChoices[0],
    FirestoreFields.option2: tExamChoices[1],
    FirestoreFields.option3: tExamChoices[2],
    FirestoreFields.option4: tExamChoices[3],
    FirestoreFields.correctOption: null,
    FirestoreFields.createdAt: Timestamp.fromDate(
      tExamCreatedAt,
    ),
    FirestoreFields.updatedAt: Timestamp.fromDate(
      tExamUpdatedAt,
    ),
  };
}

Map<String, dynamic> tSecondExamQuestionJson({
  String examId = tExamId,
}) {
  return {
    ...tExamQuestionJsonWithoutImage(examId: examId),
    FirestoreFields.questionId: tSecondExamQuestionId,
    FirestoreFields.questionText:
        tSecondExamQuestionModel.questionText,
    FirestoreFields.questionScore:
        tSecondExamQuestionModel.degree,
    FirestoreFields.option1: tSecondExamQuestionModel.choices[0],
    FirestoreFields.option2: tSecondExamQuestionModel.choices[1],
    FirestoreFields.option3: tSecondExamQuestionModel.choices[2],
    FirestoreFields.option4: tSecondExamQuestionModel.choices[3],
    FirestoreFields.correctOption:
        tSecondExamQuestionModel.correctChoiceIndex,
    FirestoreFields.createdAt: Timestamp.fromDate(
      tSecondExamQuestionModel.createdAt!,
    ),
  };
}

final ExamEntity tExamEntity = ExamEntity(
  examId: tExamId,
  gradeId: tGradeId,
  examName: tExamName,
  durationMinutes: tExamDurationMinutes,
  questionCount: tExamQuestionCount,
  totalScore: tExamTotalScore,
  status: ExamStatus.unpublished,
  questions: [tExamQuestionEntity],
);

final ExamEntity tPublishedExamEntity = tExamEntity.copyWith(
  status: ExamStatus.published,
);

final ExamEntity tEndedExamEntity = tExamEntity.copyWith(
  status: ExamStatus.ended,
  closedAt: tExamUpdatedAt,
);

final ExamModel tExamModel = ExamModel(
  examId: tExamId,
  gradeId: tGradeId,
  examName: tExamName,
  durationMinutes: tExamDurationMinutes,
  questionCount: tExamQuestionCount,
  totalScore: tExamTotalScore,
  status: ExamStatus.unpublished,
  questions: [tExamQuestionModel],
  createdAt: tExamCreatedAt,
  updatedAt: tExamUpdatedAt,
);

final ExamModel tSecondExamModel = ExamModel(
  examId: tSecondExamId,
  gradeId: tGradeId,
  examName: 'Final Chemistry Exam',
  durationMinutes: 90,
  questionCount: 0,
  totalScore: 0,
  status: ExamStatus.published,
  createdAt: tExamCreatedAt.subtract(const Duration(days: 1)),
  updatedAt: tExamUpdatedAt,
);

Map<String, dynamic> tExamJson({String examId = tExamId}) {
  return {
    FirestoreFields.gradeId: tGradeId,
    FirestoreFields.examName: tExamName,
    FirestoreFields.durationMinutes: tExamDurationMinutes,
    FirestoreFields.questionCount: tExamQuestionCount,
    FirestoreFields.totalScore: tExamTotalScore,
    FirestoreFields.participantsCount: tExamParticipantsCount,
    FirestoreFields.examStatus: 'unpublished',
    FirestoreFields.firstAttemptAt: null,
    FirestoreFields.closedAt: null,
    FirestoreFields.createdAt: Timestamp.fromDate(
      tExamCreatedAt,
    ),
    FirestoreFields.updatedAt: Timestamp.fromDate(
      tExamUpdatedAt,
    ),
    'isDeleting': false,
  };
}

Map<String, dynamic> tEndedExamJson({String examId = tExamId}) {
  return {
    ...tExamJson(examId: examId),
    FirestoreFields.examStatus: 'ended',
    FirestoreFields.closedAt: Timestamp.fromDate(tExamUpdatedAt),
  };
}

Map<String, dynamic> tPublishedExamJson({
  String examId = tExamId,
}) {
  return {
    ...tExamJson(examId: examId),
    FirestoreFields.examStatus: 'published',
  };
}

final ExamResultEntity tExamResultEntity = ExamResultEntity(
  resultId: tExamResultId,
  examId: tExamId,
  studentId: tExamResultStudentId,
  studentName: tExamResultStudentName,
  gradeId: tGradeId,
  gradeName: tExamResultGradeName,
  score: tExamResultScore,
  totalScore: tExamResultTotalScore,
  status: ExamAttemptStatus.submitted,
  startedAt: tExamResultStartedAt,
  expiresAt: tExamResultExpiresAt,
  submittedAt: tExamResultSubmittedAt,
);

final ExamResultEntity tInProgressExamResultEntity =
    ExamResultEntity(
      resultId: tExamResultId,
      examId: tExamId,
      studentId: tExamResultStudentId,
      studentName: tExamResultStudentName,
      gradeId: tGradeId,
      gradeName: tExamResultGradeName,
      score: null,
      totalScore: tExamResultTotalScore,
      status: ExamAttemptStatus.inProgress,
      startedAt: tExamResultStartedAt,
      expiresAt: tFutureDateTime,
    );

final ExamResultModel tExamResultModel = ExamResultModel(
  resultId: tExamResultId,
  examId: tExamId,
  studentId: tExamResultStudentId,
  studentName: tExamResultStudentName,
  gradeId: tGradeId,
  gradeName: tExamResultGradeName,
  score: tExamResultScore,
  totalScore: tExamResultTotalScore,
  status: ExamAttemptStatus.submitted,
  startedAt: tExamResultStartedAt,
  expiresAt: tExamResultExpiresAt,
  submittedAt: tExamResultSubmittedAt,
);

Map<String, dynamic> tExamResultJson({String examId = tExamId}) {
  return {
    FirestoreFields.examId: examId,
    FirestoreFields.studentId: tExamResultStudentId,
    FirestoreFields.studentName: tExamResultStudentName,
    FirestoreFields.gradeId: tGradeId,
    FirestoreFields.gradeName: tExamResultGradeName,
    FirestoreFields.score: tExamResultScore,
    FirestoreFields.totalScore: tExamResultTotalScore,
    FirestoreFields.resultStatus: 'submitted',
    FirestoreFields.startedAt: Timestamp.fromDate(
      tExamResultStartedAt,
    ),
    FirestoreFields.expiresAt: Timestamp.fromDate(
      tExamResultExpiresAt,
    ),
    FirestoreFields.submittedAt: Timestamp.fromDate(
      tExamResultSubmittedAt,
    ),
  };
}

// Live session feature dummy data

const String tLiveSessionGradeId = tGradeId;
const String tMeetingUrl = 'https://zoom.us/j/1234567890';
const String tGoogleMeetUrl = 'https://meet.google.com/abc-defg-hij';

final LiveSessionEntity tLiveSessionEntity = LiveSessionEntity(
  gradeId: tLiveSessionGradeId,
  platformType: MeetingType.zoom,
  meetingUrl: tMeetingUrl,
);

final LiveSessionEntity tGoogleMeetLiveSessionEntity = LiveSessionEntity(
  gradeId: tLiveSessionGradeId,
  platformType: MeetingType.googleMeet,
  meetingUrl: tGoogleMeetUrl,
);

final LiveSessionModel tLiveSessionModel = LiveSessionModel(
  gradeId: tLiveSessionGradeId,
  platformType: MeetingType.zoom.value,
  meetingUrl: tMeetingUrl,
);

Map<String, dynamic> tLiveSessionJson({String gradeId = tLiveSessionGradeId}) {
  return {
    FirestoreFields.gradeId: gradeId,
    FirestoreFields.platformType: MeetingType.zoom.value,
    FirestoreFields.meetingUrl: tMeetingUrl,
  };
}

// Grades feature dummy data

const String tGradeName = 'Grade 1';
const int tGradeDisplayOrder = 1;

final GradeEntity tGradeEntity = GradeEntity(
  gradeId: tGradeId,
  name: tGradeName,
  displayOrder: tGradeDisplayOrder,
  isActive: true,
);

final GradeEntity tSecondGradeEntity = GradeEntity(
  gradeId: 'grade-2',
  name: 'Grade 2',
  displayOrder: 2,
  isActive: false,
);

final GradeModel tGradeModel = GradeModel(
  gradeId: tGradeId,
  name: tGradeName,
  displayOrder: tGradeDisplayOrder,
  isActive: true,
);

final GradeModel tSecondGradeModel = GradeModel(
  gradeId: 'grade-2',
  name: 'Grade 2',
  displayOrder: 2,
  isActive: false,
);

Map<String, dynamic> tGradeJson({String gradeId = tGradeId}) {
  return {
    FirestoreFields.gradeId: gradeId,
    FirestoreFields.name: tGradeName,
    FirestoreFields.displayOrder: tGradeDisplayOrder,
    FirestoreFields.isActive: true,
  };
}

Map<String, dynamic> tSecondGradeJson({String gradeId = 'grade-2'}) {
  return {
    FirestoreFields.gradeId: gradeId,
    FirestoreFields.name: 'Grade 2',
    FirestoreFields.displayOrder: 2,
    FirestoreFields.isActive: false,
  };
}

Map<String, dynamic> tThirdGradeJson({String gradeId = 'grade-3'}) {
  return {
    FirestoreFields.gradeId: gradeId,
    FirestoreFields.name: 'Grade 3',
    FirestoreFields.displayOrder: 0,
    FirestoreFields.isActive: true,
  };
}

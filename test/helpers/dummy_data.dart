import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/students/data/models/student_model.dart';
import 'package:al_mobdea_admin/features/students/domain/entities/student_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

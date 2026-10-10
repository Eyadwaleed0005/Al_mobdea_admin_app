import 'package:al_mobdea_admin/core/firebase/firestore/firestore_collections.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/result_student/data/models/student_exam_result_model.dart';
import 'package:al_mobdea_admin/features/result_student/domain/entities/student_exam_result_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dummy_data.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  Future<DocumentSnapshot<Map<String, dynamic>>> seedResultDocument({
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await fakeFirestore
        .collection(FirestoreCollections.examResults)
        .doc(documentId)
        .set(data);

    return fakeFirestore
        .collection(FirestoreCollections.examResults)
        .doc(documentId)
        .get();
  }

  group('StudentExamResultModel', () {
    group('fromFirestoreDocument', () {
      test(
        'parses a Firestore document snapshot correctly',
        () async {
          final DocumentSnapshot<Map<String, dynamic>> document =
              await seedResultDocument(
                documentId: 'result-doc-1',
                data: tStudentExamResultJson(),
              );

          final StudentExamResultModel model =
              StudentExamResultModel.fromFirestoreDocument(
                resultDocument: document,
                examName: tStudentExamResultExamName,
              );

          expect(model, isA<StudentExamResultEntity>());
          expect(model.resultId, tStudentExamResultId);
          expect(model.examId, tStudentExamResultExamId);
          expect(model.examName, tStudentExamResultExamName);
          expect(model.studentObtainedScore, tStudentExamResultObtainedScore);
          expect(model.examTotalScore, tStudentExamResultTotalScore);
          expect(
            model.examSubmittedAt.millisecondsSinceEpoch,
            tStudentExamResultSubmittedAt.millisecondsSinceEpoch,
          );
        },
      );

      test(
        'falls back to the document id when resultId is missing',
        () async {
          final Map<String, dynamic> data = tStudentExamResultJson()
            ..remove(FirestoreFields.resultId);

          final DocumentSnapshot<Map<String, dynamic>> document =
              await seedResultDocument(
                documentId: 'result-doc-2',
                data: data,
              );

          final StudentExamResultModel model =
              StudentExamResultModel.fromFirestoreDocument(
                resultDocument: document,
                examName: tStudentExamResultExamName,
              );

          expect(model.resultId, 'result-doc-2');
        },
      );

      test(
        'converts integer scores to double values',
        () async {
          final DocumentSnapshot<Map<String, dynamic>> document =
              await seedResultDocument(
                documentId: 'result-doc-3',
                data: {
                  FirestoreFields.examId: tStudentExamResultExamId,
                  FirestoreFields.score: 15,
                  FirestoreFields.totalScore: 20,
                  FirestoreFields.submittedAt: Timestamp.fromDate(
                    tStudentExamResultSubmittedAt,
                  ),
                },
              );

          final StudentExamResultModel model =
              StudentExamResultModel.fromFirestoreDocument(
                resultDocument: document,
                examName: tStudentExamResultExamName,
              );

          expect(model.studentObtainedScore, isA<double>());
          expect(model.studentObtainedScore, 15.0);
          expect(model.examTotalScore, isA<double>());
          expect(model.examTotalScore, 20.0);
        },
      );

      test(
        'uses the examName passed from the exam document, not the result data',
        () async {
          final DocumentSnapshot<Map<String, dynamic>> document =
              await seedResultDocument(
                documentId: 'result-doc-4',
                data: tStudentExamResultJson(),
              );

          final StudentExamResultModel model =
              StudentExamResultModel.fromFirestoreDocument(
                resultDocument: document,
                examName: tSecondStudentExamResultExamName,
              );

          expect(model.examName, tSecondStudentExamResultExamName);
        },
      );
    });
  });
}

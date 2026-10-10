import 'package:al_mobdea_admin/core/firebase/firestore/firestore_collections.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/result_student/data/models/student_exam_results_overview_model.dart';
import 'package:al_mobdea_admin/features/result_student/domain/entities/student_exam_results_overview_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dummy_data.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  Future<DocumentSnapshot<Map<String, dynamic>>>
  seedStudentDocument({
    String documentId = tResultStudentId,
    required Map<String, dynamic> data,
  }) async {
    await fakeFirestore
        .collection(FirestoreCollections.students)
        .doc(documentId)
        .set(data);

    return fakeFirestore
        .collection(FirestoreCollections.students)
        .doc(documentId)
        .get();
  }

  group('StudentExamResultsOverviewModel', () {
    group('fromFirestoreStudentDocument', () {
      test('parses a Firestore student document snapshot correctly', () async {
        final DocumentSnapshot<Map<String, dynamic>> document =
            await seedStudentDocument(
              data: tResultStudentJson(),
            );

        final StudentExamResultsOverviewModel model =
            StudentExamResultsOverviewModel.fromFirestoreStudentDocument(
              studentDocument: document,
              studentGradeName: tGradeName,
              completedExamsCount: 2,
              totalExamsCount: 4,
              studentExamResultModels: tStudentExamResultModels,
            );

        expect(model, isA<StudentExamResultsOverviewEntity>());
        expect(model.studentId, tResultStudentId);
        expect(model.studentFullName, tStudentName);
        expect(model.studentGradeId, tGradeId);
        expect(model.studentGradeName, tGradeName);
        expect(model.isStudentAccountActive, isTrue);
        expect(model.completedExamsCount, 2);
        expect(model.totalExamsCount, 4);
        expect(model.studentExamResults, hasLength(2));
      });

      test('matches the dummy overview model values', () async {
        final DocumentSnapshot<Map<String, dynamic>> document =
            await seedStudentDocument(
              data: tResultStudentJson(),
            );

        final StudentExamResultsOverviewModel model =
            StudentExamResultsOverviewModel.fromFirestoreStudentDocument(
              studentDocument: document,
              studentGradeName: tStudentExamResultsOverviewModel
                  .studentGradeName,
              completedExamsCount:
                  tStudentExamResultsOverviewModel
                      .completedExamsCount,
              totalExamsCount: tStudentExamResultsOverviewModel
                  .totalExamsCount,
              studentExamResultModels: tStudentExamResultModels,
            );

        expect(
          model.studentId,
          tStudentExamResultsOverviewModel.studentId,
        );
        expect(
          model.studentFullName,
          tStudentExamResultsOverviewModel.studentFullName,
        );
        expect(
          model.studentGradeId,
          tStudentExamResultsOverviewModel.studentGradeId,
        );
        expect(
          model.isStudentAccountActive,
          tStudentExamResultsOverviewModel
              .isStudentAccountActive,
        );
      });

      test('falls back to the document id when studentId is missing', () async {
        final Map<String, dynamic> data = tResultStudentJson()
          ..remove(FirestoreFields.studentId);

        final DocumentSnapshot<Map<String, dynamic>> document =
            await seedStudentDocument(data: data);

        final StudentExamResultsOverviewModel model =
            StudentExamResultsOverviewModel.fromFirestoreStudentDocument(
              studentDocument: document,
              studentGradeName: tGradeName,
              completedExamsCount: 0,
              totalExamsCount: 0,
              studentExamResultModels: [],
            );

        expect(model.studentId, tResultStudentId);
      });

      test('defaults isStudentAccountActive to false when missing', () async {
        final Map<String, dynamic> data = tResultStudentJson()
          ..remove(FirestoreFields.isActive);

        final DocumentSnapshot<Map<String, dynamic>> document =
            await seedStudentDocument(data: data);

        final StudentExamResultsOverviewModel model =
            StudentExamResultsOverviewModel.fromFirestoreStudentDocument(
              studentDocument: document,
              studentGradeName: tGradeName,
              completedExamsCount: 0,
              totalExamsCount: 0,
              studentExamResultModels: [],
            );

        expect(model.isStudentAccountActive, isFalse);
      });

      test('wraps the results list in an unmodifiable list', () async {
        final DocumentSnapshot<Map<String, dynamic>> document =
            await seedStudentDocument(
              data: tResultStudentJson(),
            );

        final StudentExamResultsOverviewModel model =
            StudentExamResultsOverviewModel.fromFirestoreStudentDocument(
              studentDocument: document,
              studentGradeName: tGradeName,
              completedExamsCount: 2,
              totalExamsCount: 4,
              studentExamResultModels: tStudentExamResultModels,
            );

        expect(
          () => model.studentExamResults.add(
            tStudentExamResultModel,
          ),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });
  });
}

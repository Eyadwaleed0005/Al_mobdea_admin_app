import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_collections.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/result_student/data/data_sources/firebase_student_exam_results_remote_data_source.dart';
import 'package:al_mobdea_admin/features/result_student/data/models/student_exam_results_overview_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dummy_data.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirebaseStudentExamResultsRemoteDataSource dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = FirebaseStudentExamResultsRemoteDataSource(
      firebaseFirestore: fakeFirestore,
    );
  });

  Future<void> seedStudent({
    String documentId = tResultStudentId,
    required Map<String, dynamic> data,
  }) {
    return fakeFirestore
        .collection(FirestoreCollections.students)
        .doc(documentId)
        .set(data);
  }

  Future<void> seedGrade({
    String documentId = tGradeId,
    required Map<String, dynamic> data,
  }) {
    return fakeFirestore
        .collection(FirestoreCollections.grades)
        .doc(documentId)
        .set(data);
  }

  Future<void> seedExam({
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return fakeFirestore
        .collection(FirestoreCollections.exams)
        .doc(documentId)
        .set(data);
  }

  Future<void> seedExamResult({
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return fakeFirestore
        .collection(FirestoreCollections.examResults)
        .doc(documentId)
        .set(data);
  }

  /// Seeds a complete consistent scenario:
  /// - student-123 in grade-1 with two submitted results and one pending result
  /// - grade-1 contains exams: exam-123, exam-456, exam-789
  /// - exam-999 belongs to another grade but has a submitted result too
  Future<void> seedFullScenario() async {
    await seedStudent(data: tResultStudentJson());

    await seedGrade(
      data: {
        FirestoreFields.gradeId: tGradeId,
        FirestoreFields.name: tGradeName,
      },
    );

    await seedExam(
      documentId: tStudentExamResultExamId,
      data: {
        FirestoreFields.gradeId: tGradeId,
        FirestoreFields.examName: tStudentExamResultExamName,
      },
    );
    await seedExam(
      documentId: tSecondStudentExamResultExamId,
      data: {
        FirestoreFields.gradeId: tGradeId,
        FirestoreFields.examName: tSecondStudentExamResultExamName,
      },
    );
    await seedExam(
      documentId: 'exam-789',
      data: {
        FirestoreFields.gradeId: tGradeId,
        FirestoreFields.examName: 'Quiz Exam',
      },
    );
    await seedExam(
      documentId: 'exam-999',
      data: {
        FirestoreFields.gradeId: 'grade-2',
        FirestoreFields.examName: 'Other Grade Exam',
      },
    );

    await seedExamResult(
      documentId: tStudentExamResultId,
      data: tStudentExamResultJson(),
    );
    await seedExamResult(
      documentId: tSecondStudentExamResultId,
      data: tSecondStudentExamResultJson(),
    );
    await seedExamResult(
      documentId: 'result-789',
      data: {
        FirestoreFields.resultId: 'result-789',
        FirestoreFields.studentId: tResultStudentId,
        FirestoreFields.examId: 'exam-999',
        FirestoreFields.score: 70,
        FirestoreFields.totalScore: 100,
        FirestoreFields.submittedAt: Timestamp.fromDate(
          DateTime.utc(2024, 9, 15),
        ),
      },
    );
    await seedExamResult(
      documentId: 'result-pending',
      data: {
        FirestoreFields.resultId: 'result-pending',
        FirestoreFields.studentId: tResultStudentId,
        FirestoreFields.examId: 'exam-789',
        FirestoreFields.score: 50,
        FirestoreFields.totalScore: 100,
      },
    );
    await seedExamResult(
      documentId: 'result-other-student',
      data: {
        FirestoreFields.resultId: 'result-other-student',
        FirestoreFields.studentId: 'student-999',
        FirestoreFields.examId: 'exam-789',
        FirestoreFields.score: 60,
        FirestoreFields.totalScore: 100,
        FirestoreFields.submittedAt: Timestamp.fromDate(
          DateTime.utc(2024, 9, 12),
        ),
      },
    );
  }

  group('getStudentExamResultsByStudentId', () {
    test(
      'throws invalid-argument when studentId is empty',
      () async {
        await expectLater(
          dataSource.getStudentExamResultsByStudentId(studentId: ''),
          throwsA(
            isA<FirebaseRemoteException>().having(
              (exception) => exception.errorModel.code,
              'code',
              'invalid-argument',
            ),
          ),
        );
      },
    );

    test(
      'throws invalid-argument when studentId is only whitespace',
      () async {
        await expectLater(
          dataSource.getStudentExamResultsByStudentId(studentId: '   '),
          throwsA(
            isA<FirebaseRemoteException>().having(
              (exception) => exception.errorModel.code,
              'code',
              'invalid-argument',
            ),
          ),
        );
      },
    );

    test(
      'throws not-found when the student document does not exist',
      () async {
        await expectLater(
          dataSource.getStudentExamResultsByStudentId(
            studentId: 'missing-student',
          ),
          throwsA(
            isA<FirebaseRemoteException>().having(
              (exception) => exception.errorModel.code,
              'code',
              'not-found',
            ),
          ),
        );
      },
    );

    test(
      'throws not-found when the student grade document does not exist',
      () async {
        await seedStudent(
          data: {
            ...tResultStudentJson(),
            FirestoreFields.gradeId: 'missing-grade',
          },
        );

        await expectLater(
          dataSource.getStudentExamResultsByStudentId(
            studentId: tResultStudentId,
          ),
          throwsA(
            isA<FirebaseRemoteException>().having(
              (exception) => exception.errorModel.code,
              'code',
              'not-found',
            ),
          ),
        );
      },
    );

    test(
      'throws data-loss when the student document has no gradeId',
      () async {
        final Map<String, dynamic> data = tResultStudentJson()
          ..remove(FirestoreFields.gradeId);

        await seedStudent(data: data);

        await expectLater(
          dataSource.getStudentExamResultsByStudentId(
            studentId: tResultStudentId,
          ),
          throwsA(
            isA<FirebaseRemoteException>().having(
              (exception) => exception.errorModel.code,
              'code',
              'data-loss',
            ),
          ),
        );
      },
    );

    test(
      'throws data-loss when a submitted exam document has a missing examName',
      () async {
        await seedStudent(data: tResultStudentJson());
        await seedGrade(
          data: {
            FirestoreFields.gradeId: tGradeId,
            FirestoreFields.name: tGradeName,
          },
        );
        await seedExam(
          documentId: tStudentExamResultExamId,
          data: {FirestoreFields.gradeId: tGradeId},
        );
        await seedExamResult(
          documentId: tStudentExamResultId,
          data: tStudentExamResultJson(),
        );

        await expectLater(
          dataSource.getStudentExamResultsByStudentId(
            studentId: tResultStudentId,
          ),
          throwsA(
            isA<FirebaseRemoteException>().having(
              (exception) => exception.errorModel.code,
              'code',
              'data-loss',
            ),
          ),
        );
      },
    );

    test(
      'throws data-loss when a submitted exam document has an empty examName',
      () async {
        await seedStudent(data: tResultStudentJson());
        await seedGrade(
          data: {
            FirestoreFields.gradeId: tGradeId,
            FirestoreFields.name: tGradeName,
          },
        );
        await seedExam(
          documentId: tStudentExamResultExamId,
          data: {
            FirestoreFields.gradeId: tGradeId,
            FirestoreFields.examName: '   ',
          },
        );
        await seedExamResult(
          documentId: tStudentExamResultId,
          data: tStudentExamResultJson(),
        );

        await expectLater(
          dataSource.getStudentExamResultsByStudentId(
            studentId: tResultStudentId,
          ),
          throwsA(
            isA<FirebaseRemoteException>().having(
              (exception) => exception.errorModel.code,
              'code',
              'data-loss',
            ),
          ),
        );
      },
    );

    test(
      'calculates totalExamsCount and completedExamsCount via intersection',
      () async {
        await seedFullScenario();

        final StudentExamResultsOverviewModel overview =
            await dataSource.getStudentExamResultsByStudentId(
              studentId: tResultStudentId,
            );

        // Grade 1 contains exam-123, exam-456 and exam-789.
        expect(overview.totalExamsCount, 3);

        // student-123 submitted exam-123, exam-456 and exam-999 (other
        // grade), so only exam-123 and exam-456 are completed in-grade.
        expect(overview.completedExamsCount, 2);

        // All three submitted results are returned.
        expect(overview.studentExamResults, hasLength(3));
      },
    );

    test(
      'sorts exam results descending by submittedAt',
      () async {
        await seedFullScenario();

        final StudentExamResultsOverviewModel overview =
            await dataSource.getStudentExamResultsByStudentId(
              studentId: tResultStudentId,
            );

        expect(
          overview.studentExamResults.map((result) => result.examId),
          [
            tSecondStudentExamResultExamId,
            'exam-999',
            tStudentExamResultExamId,
          ],
        );
      },
    );

    test(
      'filters out results without a submittedAt Timestamp',
      () async {
        await seedFullScenario();

        final StudentExamResultsOverviewModel overview =
            await dataSource.getStudentExamResultsByStudentId(
              studentId: tResultStudentId,
            );

        expect(
          overview.studentExamResults.map((result) => result.resultId),
          isNot(contains('result-pending')),
        );
      },
    );

    test(
      'only returns results belonging to the requested student',
      () async {
        await seedFullScenario();

        final StudentExamResultsOverviewModel overview =
            await dataSource.getStudentExamResultsByStudentId(
              studentId: tResultStudentId,
            );

        expect(
          overview.studentExamResults.map((result) => result.resultId),
          isNot(contains('result-other-student')),
        );
      },
    );

    test(
      'maps student and grade information into the overview',
      () async {
        await seedFullScenario();

        final StudentExamResultsOverviewModel overview =
            await dataSource.getStudentExamResultsByStudentId(
              studentId: tResultStudentId,
            );

        expect(overview.studentId, tResultStudentId);
        expect(overview.studentFullName, tStudentName);
        expect(overview.studentGradeId, tGradeId);
        expect(overview.studentGradeName, tGradeName);
        expect(overview.isStudentAccountActive, isTrue);
      },
    );

    test(
      'trims the studentId before querying',
      () async {
        await seedFullScenario();

        final StudentExamResultsOverviewModel overview =
            await dataSource.getStudentExamResultsByStudentId(
              studentId: '  $tResultStudentId  ',
            );

        expect(overview.studentId, tResultStudentId);
        expect(overview.studentExamResults, hasLength(3));
      },
    );

    test(
      'returns zero counts when the student has no results at all',
      () async {
        await seedStudent(data: tResultStudentJson());
        await seedGrade(
          data: {
            FirestoreFields.gradeId: tGradeId,
            FirestoreFields.name: tGradeName,
          },
        );

        final StudentExamResultsOverviewModel overview =
            await dataSource.getStudentExamResultsByStudentId(
              studentId: tResultStudentId,
            );

        expect(overview.completedExamsCount, 0);
        expect(overview.totalExamsCount, 0);
        expect(overview.studentExamResults, isEmpty);
      },
    );
  });
}

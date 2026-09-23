import 'package:al_mobdea_admin/core/connection/network/network_info.dart';
import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firebase_firestore_service.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_collections.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_service.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_firestore_guard_service.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_results_query_service.dart';
import 'package:al_mobdea_admin/features/exams/data/validation/exams_data_validator.dart';
import 'package:al_mobdea_admin/features/exams/data/validation/policy/exam_editing_policy.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_attempt_status.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dummy_data.dart';

class _AlwaysOnlineNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;

  @override
  Stream<bool> get onConnectionChanged => const Stream<bool>.empty();

  @override
  Future<void> dispose() async {}
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreService firestoreService;
  late ExamResultsQueryService resultsService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    firestoreService = FirebaseFirestoreService(
      networkInfo: _AlwaysOnlineNetworkInfo(),
      firestore: fakeFirestore,
      enableLogging: false,
    );

    resultsService = ExamResultsQueryService(
      firestoreService: firestoreService,
      examsDataValidator: const ExamsDataValidator(),
      examFirestoreGuardService: ExamFirestoreGuardService(
        editingPolicy: const ExamEditingPolicy(),
      ),
    );
  });

  Future<void> seedExam({Map<String, dynamic>? map}) {
    return fakeFirestore
        .collection(FirestoreCollections.exams)
        .doc(tExamId)
        .set(map ?? tEndedExamJson());
  }

  Future<void> seedResult({
    String resultId = tExamResultId,
    Map<String, dynamic>? map,
  }) {
    return fakeFirestore
        .collection(FirestoreCollections.examResults)
        .doc(resultId)
        .set(map ?? tExamResultJson());
  }

  group('getExamResults', () {
    test('returns results only for the requested ended exam', () async {
      await seedExam();
      await seedResult();
      await seedResult(
        resultId: 'other-result',
        map: {
          ...tExamResultJson(),
          FirestoreFields.examId: 'other-exam',
        },
      );

      final results = await resultsService.getExamResults(examId: tExamId);

      expect(results, hasLength(1));
      expect(results.single.resultId, tExamResultId);
    });

    test('filters by attempt status', () async {
      await seedExam();
      await seedResult();
      await seedResult(
        resultId: 'in-progress-result',
        map: {
          ...tExamResultJson(),
          FirestoreFields.score: null,
          FirestoreFields.submittedAt: null,
          FirestoreFields.resultStatus: 'inProgress',
        },
      );

      final submitted = await resultsService.getExamResults(
        examId: tExamId,
        status: ExamAttemptStatus.submitted,
      );

      final inProgress = await resultsService.getExamResults(
        examId: tExamId,
        status: ExamAttemptStatus.inProgress,
      );

      expect(submitted, hasLength(1));
      expect(submitted.single.resultId, tExamResultId);
      expect(inProgress, hasLength(1));
      expect(inProgress.single.resultId, 'in-progress-result');
    });

    test('sorts submitted results by score descending', () async {
      await seedExam();
      await seedResult(
        map: {
          ...tExamResultJson(),
          FirestoreFields.score: 2,
          FirestoreFields.studentName: 'Low Score',
        },
      );
      await seedResult(
        resultId: 'top-result',
        map: {
          ...tExamResultJson(),
          FirestoreFields.score: 5,
          FirestoreFields.studentName: 'Top Score',
        },
      );

      final results = await resultsService.getExamResults(examId: tExamId);

      expect(results, hasLength(2));
      expect(results.first.score, 5);
      expect(results.last.score, 2);
    });

    test('throws when the exam is not ended yet', () async {
      await seedExam(map: tPublishedExamJson());

      await expectLater(
        () => resultsService.getExamResults(examId: tExamId),
        throwsA(isA<FirebaseRemoteException>()),
      );
    });

    test('throws when the exam is missing', () async {
      await expectLater(
        () => resultsService.getExamResults(examId: 'missing-exam'),
        throwsA(isA<FirebaseRemoteException>()),
      );
    });
  });

  group('streamExamResults', () {
    test('emits results as snapshots arrive', () async {
      await seedExam();
      await seedResult();

      final stream = resultsService.streamExamResults(examId: tExamId);

      await expectLater(
        stream,
        emits(
          isA<List>().having(
            (results) => results.single.resultId,
            'resultId',
            tExamResultId,
          ),
        ),
      );
    });

    test('throws before streaming when the exam is not ended', () async {
      await seedExam(map: tPublishedExamJson());

      await expectLater(
        () => resultsService.streamExamResults(examId: tExamId).drain<void>(),
        throwsA(isA<FirebaseRemoteException>()),
      );
    });
  });
}

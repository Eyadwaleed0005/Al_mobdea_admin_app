import 'package:al_mobdea_admin/core/firebase/firestore/firebase_firestore_service.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_collections.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_service.dart';
import 'package:al_mobdea_admin/core/connection/network/network_info.dart';
import 'package:al_mobdea_admin/features/exams/data/models/exam_model.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_firestore_guard_service.dart';
import 'package:al_mobdea_admin/features/exams/data/services/exam_query_service.dart';
import 'package:al_mobdea_admin/features/exams/data/validation/exams_data_validator.dart';
import 'package:al_mobdea_admin/features/exams/data/validation/policy/exam_editing_policy.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  late ExamQueryService queryService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    firestoreService = FirebaseFirestoreService(
      networkInfo: _AlwaysOnlineNetworkInfo(),
      firestore: fakeFirestore,
      enableLogging: false,
    );

    queryService = ExamQueryService(
      firestoreService: firestoreService,
      examsDataValidator: const ExamsDataValidator(),
      examFirestoreGuardService: ExamFirestoreGuardService(
        editingPolicy: const ExamEditingPolicy(),
      ),
    );
  });

  Future<void> seedExam({
    String examId = tExamId,
    Map<String, dynamic>? map,
  }) {
    return fakeFirestore
        .collection(FirestoreCollections.exams)
        .doc(examId)
        .set(map ?? tExamJson(examId: examId));
  }

  Future<void> seedQuestion({
    String questionId = tExamQuestionId,
    Map<String, dynamic>? map,
  }) {
    return fakeFirestore
        .collection(FirestoreCollections.examQuestions)
        .doc(questionId)
        .set(map ?? tExamQuestionJson());
  }

  group('getExams', () {
    test('returns all exams sorted by updatedAt descending', () async {
      await seedExam();
      await seedExam(
        examId: tSecondExamId,
        map: {
          ...tPublishedExamJson(examId: tSecondExamId),
          FirestoreFields.createdAt:
              Timestamp.fromDate(tSecondExamModel.createdAt!),
        },
      );

      final exams = await queryService.getExams();

      expect(exams, hasLength(2));
      expect(exams.first.examId, tExamId);
      expect(exams.last.examId, tSecondExamId);
    });

    test('filters by gradeId', () async {
      await seedExam();
      await seedExam(
        examId: tSecondExamId,
        map: {
          ...tExamJson(examId: tSecondExamId),
          FirestoreFields.gradeId: 'other-grade',
        },
      );

      final exams = await queryService.getExams(gradeId: tGradeId);

      expect(exams, hasLength(1));
      expect(exams.single.examId, tExamId);
    });

    test('filters by status', () async {
      await seedExam();
      await seedExam(
        examId: tSecondExamId,
        map: tPublishedExamJson(examId: tSecondExamId),
      );

      final publishedExams = await queryService.getExams(
        status: ExamStatus.published,
      );

      expect(publishedExams, hasLength(1));
      expect(publishedExams.single.examId, tSecondExamId);
    });

    test('skips exams flagged as deleting', () async {
      await seedExam(
        map: {
          ...tExamJson(),
          'isDeleting': true,
        },
      );

      final exams = await queryService.getExams();

      expect(exams, isEmpty);
    });

    test('ignores blank gradeId filters', () async {
      await seedExam();

      final exams = await queryService.getExams(gradeId: '   ');

      expect(exams, hasLength(1));
    });
  });

  group('streamExams', () {
    test('emits exams as snapshots arrive', () async {
      await seedExam();

      final stream = queryService.streamExams();

      await expectLater(
        stream,
        emits(
          isA<List<ExamModel>>().having(
            (exams) => exams.single.examId,
            'examId',
            tExamId,
          ),
        ),
      );
    });

    test('emits only exams matching the status filter', () async {
      await seedExam();
      await seedExam(
        examId: tSecondExamId,
        map: tPublishedExamJson(examId: tSecondExamId),
      );

      final stream = queryService.streamExams(
        status: ExamStatus.published,
      );

      await expectLater(
        stream,
        emits(
          isA<List<ExamModel>>().having(
            (exams) => exams.single.examId,
            'examId',
            tSecondExamId,
          ),
        ),
      );
    });
  });

  group('getExamById', () {
    test('returns the exam with its questions sorted by createdAt', () async {
      await seedExam();
      await seedQuestion();
      await seedQuestion(
        questionId: tSecondExamQuestionId,
        map: tSecondExamQuestionJson(),
      );

      final exam = await queryService.getExamById(examId: tExamId);

      expect(exam.examId, tExamId);
      expect(exam.questions, hasLength(2));
      expect(exam.questions.first.questionId, tExamQuestionId);
      expect(exam.questions.last.questionId, tSecondExamQuestionId);
    });

    test('returns an exam without questions when none exist', () async {
      await seedExam();

      final exam = await queryService.getExamById(examId: tExamId);

      expect(exam.questions, isEmpty);
      expect(exam.status, ExamStatus.unpublished);
    });

    test('throws for a missing exam', () async {
      await expectLater(
        () => queryService.getExamById(examId: 'missing-exam'),
        throwsA(isA<Exception>()),
      );
    });

    test('throws when the exam id is blank', () async {
      await expectLater(
        () => queryService.getExamById(examId: '  '),
        throwsA(isA<Exception>()),
      );
    });

    test('excludes questions that belong to another exam', () async {
      await seedExam();
      await seedQuestion();
      await fakeFirestore
          .collection(FirestoreCollections.examQuestions)
          .doc('foreign-question')
          .set(tExamQuestionJson(examId: 'another-exam'));

      final exam = await queryService.getExamById(examId: tExamId);

      expect(exam.questions, hasLength(1));
      expect(exam.questions.single.questionId, tExamQuestionId);
    });
  });
}

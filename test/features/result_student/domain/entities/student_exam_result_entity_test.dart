import 'package:al_mobdea_admin/features/result_student/domain/entities/student_exam_result_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dummy_data.dart';

void main() {
  group('StudentExamResultEntity', () {
    group('resultPercentage', () {
      test('computes percentage correctly (80 / 100 = 80%)', () {
        expect(tStudentExamResultEntity.resultPercentage, 80);
      });

      test('computes percentage for partial scores', () {
        final StudentExamResultEntity result = StudentExamResultEntity(
          resultId: tStudentExamResultId,
          examId: tStudentExamResultExamId,
          examName: tStudentExamResultExamName,
          studentObtainedScore: 7.5,
          examTotalScore: 10,
          examSubmittedAt: tStudentExamResultSubmittedAt,
        );

        expect(result.resultPercentage, 75);
      });

      test('returns 100 for a full score', () {
        final StudentExamResultEntity result = StudentExamResultEntity(
          resultId: tStudentExamResultId,
          examId: tStudentExamResultExamId,
          examName: tStudentExamResultExamName,
          studentObtainedScore: 100,
          examTotalScore: 100,
          examSubmittedAt: tStudentExamResultSubmittedAt,
        );

        expect(result.resultPercentage, 100);
      });

      test('returns 0 when examTotalScore is 0', () {
        final StudentExamResultEntity result = StudentExamResultEntity(
          resultId: tStudentExamResultId,
          examId: tStudentExamResultExamId,
          examName: tStudentExamResultExamName,
          studentObtainedScore: 80,
          examTotalScore: 0,
          examSubmittedAt: tStudentExamResultSubmittedAt,
        );

        expect(result.resultPercentage, 0);
      });

      test('returns 0 when examTotalScore is negative', () {
        final StudentExamResultEntity result = StudentExamResultEntity(
          resultId: tStudentExamResultId,
          examId: tStudentExamResultExamId,
          examName: tStudentExamResultExamName,
          studentObtainedScore: 80,
          examTotalScore: -10,
          examSubmittedAt: tStudentExamResultSubmittedAt,
        );

        expect(result.resultPercentage, 0);
      });
    });
  });
}

import 'package:al_mobdea_admin/features/result_student/domain/entities/student_exam_result_entity.dart';
import 'package:al_mobdea_admin/features/result_student/domain/entities/student_exam_results_overview_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dummy_data.dart';

void main() {
  StudentExamResultEntity buildResult({
    required String examId,
    required double obtainedScore,
    double totalScore = 100,
  }) {
    return StudentExamResultEntity(
      resultId: 'result-$examId',
      examId: examId,
      examName: 'Exam $examId',
      studentObtainedScore: obtainedScore,
      examTotalScore: totalScore,
      examSubmittedAt: tStudentExamResultSubmittedAt,
    );
  }

  StudentExamResultsOverviewEntity buildOverview({
    List<StudentExamResultEntity> results = const [],
  }) {
    return StudentExamResultsOverviewEntity(
      studentId: tResultStudentId,
      studentFullName: tStudentName,
      studentGradeId: tGradeId,
      studentGradeName: tGradeName,
      isStudentAccountActive: true,
      completedExamsCount: results.length,
      totalExamsCount: 10,
      studentExamResults: results,
    );
  }

  group('StudentExamResultsOverviewEntity', () {
    group('highestResultPercentage', () {
      test('returns the highest percentage among the results', () {
        final StudentExamResultsOverviewEntity overview = buildOverview(
          results: [
            buildResult(examId: 'exam-1', obtainedScore: 50),
            buildResult(examId: 'exam-2', obtainedScore: 90),
            buildResult(examId: 'exam-3', obtainedScore: 75),
          ],
        );

        expect(overview.highestResultPercentage, 90);
      });

      test('returns the highest percentage of the dummy results', () {
        expect(
          tStudentExamResultsOverviewEntity.highestResultPercentage,
          90,
        );
      });

      test('returns 0 when there are no results', () {
        expect(buildOverview().highestResultPercentage, 0);
      });

      test('returns the single result percentage for one result', () {
        final StudentExamResultsOverviewEntity overview = buildOverview(
          results: [buildResult(examId: 'exam-1', obtainedScore: 62.5)],
        );

        expect(overview.highestResultPercentage, 62.5);
      });
    });

    group('averageResultPercentage', () {
      test('calculates the average of all result percentages', () {
        final StudentExamResultsOverviewEntity overview = buildOverview(
          results: [
            buildResult(examId: 'exam-1', obtainedScore: 80),
            buildResult(examId: 'exam-2', obtainedScore: 60),
            buildResult(examId: 'exam-3', obtainedScore: 100),
          ],
        );

        expect(overview.averageResultPercentage, closeTo(80, 0.001));
      });

      test('calculates the dummy results average (85%)', () {
        expect(
          tStudentExamResultsOverviewEntity.averageResultPercentage,
          closeTo(85, 0.001),
        );
      });

      test('returns 0 when there are no results', () {
        expect(buildOverview().averageResultPercentage, 0);
      });

      test('handles non-uniform total scores when averaging', () {
        final StudentExamResultsOverviewEntity overview = buildOverview(
          results: [
            buildResult(
              examId: 'exam-1',
              obtainedScore: 10,
              totalScore: 20,
            ),
            buildResult(examId: 'exam-2', obtainedScore: 90, totalScore: 90),
          ],
        );

        expect(overview.averageResultPercentage, closeTo(75, 0.001));
      });
    });
  });
}

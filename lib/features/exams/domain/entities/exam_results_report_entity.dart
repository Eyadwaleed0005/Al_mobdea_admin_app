import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_result_entity.dart';

class ExamResultsReportEntity {
  const ExamResultsReportEntity({
    required this.exam,
    required this.results,
  });

  final ExamEntity exam;
  final List<ExamResultEntity> results;

  List<ExamResultEntity> get submittedResults {
    return List<ExamResultEntity>.unmodifiable(
      results.where((ExamResultEntity result) {
        return result.isSubmitted && result.hasValidScore;
      }),
    );
  }

  List<ExamResultEntity> get inProgressResults {
    return List<ExamResultEntity>.unmodifiable(
      results.where((ExamResultEntity result) {
        return result.isInProgress;
      }),
    );
  }

  int get totalAttemptsCount {
    return results.length;
  }

  int get submittedCount {
    return results.where((ExamResultEntity result) {
      return result.isSubmitted;
    }).length;
  }

  int get inProgressCount {
    return inProgressResults.length;
  }

  int get passedStudentsCount {
    return submittedResults.where((ExamResultEntity result) {
      return result.isPassed;
    }).length;
  }

  int get failedStudentsCount {
    return submittedResults.where((ExamResultEntity result) {
      return result.isFailed;
    }).length;
  }

  double get averagePercentage {
    final List<ExamResultEntity> validResults = submittedResults;

    if (validResults.isEmpty) {
      return 0;
    }

    final double percentagesTotal = validResults.fold<double>(
      0,
      (double total, ExamResultEntity result) {
        return total + result.percentage;
      },
    );

    return percentagesTotal / validResults.length;
  }

  bool get isEmpty {
    return results.isEmpty;
  }

  bool get hasSubmittedResults {
    return submittedResults.isNotEmpty;
  }

  bool get hasInProgressResults {
    return inProgressResults.isNotEmpty;
  }
}

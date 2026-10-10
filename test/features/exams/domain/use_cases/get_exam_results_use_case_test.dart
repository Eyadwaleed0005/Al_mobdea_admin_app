import 'package:al_mobdea_admin/features/exams/domain/entities/exam_attempt_status.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/get_exam_results_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockExamsRepository repository;
  late GetExamResultsUseCase useCase;

  setUp(() {
    repository = MockExamsRepository();
    useCase = GetExamResultsUseCase(examsRepository: repository);
  });

  test('calls repository.getExamResults without a status filter', () async {
    when(
      () => repository.getExamResults(
        examId: any(named: 'examId'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => Right([tExamResultEntity]));

    final result = await useCase(examId: tExamId);

    expect(result.isRight(), isTrue);
    expect(
      result.fold((_) => null, (results) => results.single),
      tExamResultEntity,
    );
    verify(
      () => repository.getExamResults(examId: tExamId, status: null),
    ).called(1);
  });

  test('forwards the status filter', () async {
    when(
      () => repository.getExamResults(
        examId: any(named: 'examId'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => Right([tExamResultEntity]));

    await useCase(examId: tExamId, status: ExamAttemptStatus.submitted);

    verify(
      () => repository.getExamResults(
        examId: tExamId,
        status: ExamAttemptStatus.submitted,
      ),
    ).called(1);
  });
}

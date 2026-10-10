import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/delete_exam_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockExamsRepository repository;
  late DeleteExamUseCase useCase;

  setUp(() {
    repository = MockExamsRepository();
    useCase = DeleteExamUseCase(examsRepository: repository);
  });

  test('calls repository.deleteExam with the given exam id', () async {
    when(
      () => repository.deleteExam(examId: any(named: 'examId')),
    ).thenAnswer((_) async => const Right(unit));

    final result = await useCase(examId: tExamId);

    expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
    verify(
      () => repository.deleteExam(examId: tExamId),
    ).called(1);
  });

  test('returns Left when the repository fails', () async {
    const tError = AppErrorModel(
      code: 'failed-precondition',
      message: 'deletion locked',
      type: AppErrorType.validation,
      isRetryable: false,
    );

    when(
      () => repository.deleteExam(examId: any(named: 'examId')),
    ).thenAnswer((_) async => const Left(tError));

    final result = await useCase(examId: tExamId);

    expect(result, equals(const Left<AppErrorModel, Unit>(tError)));
  });
}

import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/get_exam_by_id_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  const tAppError = AppErrorModel(
    code: 'internal',
    message: 'server error',
    type: AppErrorType.server,
    isRetryable: true,
  );

  late MockExamsRepository repository;
  late GetExamByIdUseCase useCase;

  setUp(() {
    repository = MockExamsRepository();
    useCase = GetExamByIdUseCase(examsRepository: repository);
  });

  test('calls repository.getExamById with the given exam id', () async {
    when(
      () => repository.getExamById(examId: any(named: 'examId')),
    ).thenAnswer((_) async => Right(tExamEntity));

    final result = await useCase(examId: tExamId);

    expect(result.isRight(), isTrue);
    expect(result.fold((_) => null, (exam) => exam), tExamEntity);
    verify(
      () => repository.getExamById(examId: tExamId),
    ).called(1);
  });

  test('returns Left when the repository fails', () async {
    when(
      () => repository.getExamById(examId: any(named: 'examId')),
    ).thenAnswer((_) async => Left(tAppError));

    final result = await useCase(examId: tExamId);

    expect(result, equals(Left(tAppError)));
  });
}

import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/update_exam_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(tExamEntity);
  });

  const tAppError = AppErrorModel(
    code: 'internal',
    message: 'server error',
    type: AppErrorType.server,
    isRetryable: true,
  );

  late MockExamsRepository repository;
  late UpdateExamUseCase useCase;

  setUp(() {
    repository = MockExamsRepository();
    useCase = UpdateExamUseCase(examsRepository: repository);
  });

  test('calls repository.updateExam with the given exam', () async {
    when(
      () => repository.updateExam(exam: any(named: 'exam')),
    ).thenAnswer((_) async => const Right(unit));

    final result = await useCase(exam: tExamEntity);

    expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
    verify(
      () => repository.updateExam(exam: tExamEntity),
    ).called(1);
  });

  test('returns Left when the repository fails', () async {
    when(
      () => repository.updateExam(exam: any(named: 'exam')),
    ).thenAnswer((_) async => Left(tAppError));

    final result = await useCase(exam: tExamEntity);

    expect(result.isLeft(), isTrue);
  });
}

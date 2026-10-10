import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/delete_exam_question_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockExamsRepository repository;
  late DeleteExamQuestionUseCase useCase;

  setUp(() {
    repository = MockExamsRepository();
    useCase = DeleteExamQuestionUseCase(examsRepository: repository);
  });

  test('calls repository.deleteQuestion with the given ids', () async {
    when(
      () => repository.deleteQuestion(
        examId: any(named: 'examId'),
        questionId: any(named: 'questionId'),
      ),
    ).thenAnswer((_) async => const Right(unit));

    final result = await useCase(
      examId: tExamId,
      questionId: tExamQuestionId,
    );

    expect(result, equals(const Right<AppErrorModel, Unit>(unit)));

    verify(
      () => repository.deleteQuestion(
        examId: tExamId,
        questionId: tExamQuestionId,
      ),
    ).called(1);
  });

  test('returns Left when the repository fails', () async {
    const tError = AppErrorModel(
      code: 'failed-precondition',
      message: 'editing locked',
      type: AppErrorType.validation,
      isRetryable: false,
    );

    when(
      () => repository.deleteQuestion(
        examId: any(named: 'examId'),
        questionId: any(named: 'questionId'),
      ),
    ).thenAnswer((_) async => const Left(tError));

    final result = await useCase(
      examId: tExamId,
      questionId: tExamQuestionId,
    );

    expect(result.isLeft(), isTrue);
  });
}

import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/stream_exam_results_use_case.dart';
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
  late StreamExamResultsUseCase useCase;

  setUp(() {
    repository = MockExamsRepository();
    useCase = StreamExamResultsUseCase(
      examsRepository: repository,
    );
  });

  test('returns the repository stream of results', () async {
    when(
      () => repository.streamExamResults(
        examId: any(named: 'examId'),
        status: any(named: 'status'),
      ),
    ).thenAnswer(
      (_) => Stream.value(Right([tExamResultEntity])),
    );

    final stream = useCase(examId: tExamId);

    await expectLater(
      stream,
      emits(
        predicate<Either<AppErrorModel, List<dynamic>>>((
          either,
        ) {
          return either.fold(
            (_) => false,
            (results) =>
                (results).single.resultId == tExamResultId,
          );
        }),
      ),
    );
  });

  test('emits Left when the repository stream errors', () async {
    when(
      () => repository.streamExamResults(
        examId: any(named: 'examId'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) => Stream.value(Left(tAppError)));

    final stream = useCase(examId: tExamId);

    await expectLater(stream, emits(isA<Left>()));
  });
}

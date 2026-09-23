import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/use_case/stream_exams_use_case.dart';
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
  late StreamExamsUseCase useCase;

  setUp(() {
    repository = MockExamsRepository();
    useCase = StreamExamsUseCase(examsRepository: repository);
  });

  test('returns the repository stream of exams', () async {
    when(
      () => repository.streamExams(
        gradeId: any(named: 'gradeId'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) => Stream.value(Right([tExamEntity])));

    final stream = useCase(gradeId: tGradeId);

    await expectLater(
      stream,
      emits(
        predicate<Either<AppErrorModel, List<ExamEntity>>>((either) {
          return either.fold(
            (_) => false,
            (exams) => exams.single.examId == tExamId,
          );
        }),
      ),
    );

    verify(
      () => repository.streamExams(gradeId: tGradeId, status: null),
    ).called(1);
  });

  test('emits Left when the repository stream errors', () async {
    when(
      () => repository.streamExams(
        gradeId: any(named: 'gradeId'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) => Stream.value(Left(tAppError)));

    final stream = useCase();

    await expectLater(stream, emits(isA<Left<AppErrorModel, List<ExamEntity>>>()));
  });
}

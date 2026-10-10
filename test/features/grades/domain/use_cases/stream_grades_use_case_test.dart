import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:al_mobdea_admin/features/grades/domain/use_cases/stream_grades_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockGradesRepository repository;
  late StreamGradesUseCase useCase;

  setUp(() {
    repository = MockGradesRepository();
    useCase = StreamGradesUseCase(
      gradesRepository: repository,
    );
  });

  test(
    'returns the repository stream with Right(list) on success',
    () async {
      when(
        () => repository.streamGrades(
          activeOnly: any(named: 'activeOnly'),
        ),
      ).thenAnswer((_) => Stream.value(Right([tGradeEntity])));

      final stream = useCase.call();

      await expectLater(
        stream,
        emits(
          isA<Right<AppErrorModel, List<dynamic>>>().having(
            (either) =>
                either.getOrElse(() => <GradeEntity>[]).single.gradeId,
            'gradeId',
            tGradeId,
          ),
        ),
      );
      verify(
        () => repository.streamGrades(
          activeOnly: any(named: 'activeOnly'),
        ),
      ).called(1);
    },
  );

  test('defaults activeOnly to true', () async {
    when(
      () => repository.streamGrades(
        activeOnly: any(named: 'activeOnly'),
      ),
    ).thenAnswer((_) => const Stream.empty());

    useCase.call();

    final captured = verify(
      () => repository.streamGrades(
        activeOnly: captureAny(named: 'activeOnly'),
      ),
    ).captured;

    expect(captured.single, isTrue);
  });

  test('forwards activeOnly=false to the repository', () async {
    when(
      () => repository.streamGrades(
        activeOnly: any(named: 'activeOnly'),
      ),
    ).thenAnswer((_) => const Stream.empty());

    useCase.call(activeOnly: false);

    verify(
      () => repository.streamGrades(activeOnly: false),
    ).called(1);
  });

  test(
    'emits Left when the repository stream contains an error',
    () async {
      const tAppError = AppErrorModel(
        code: 'unavailable',
        message: 'offline',
        type: AppErrorType.network,
        isRetryable: true,
      );

      when(
        () => repository.streamGrades(
          activeOnly: any(named: 'activeOnly'),
        ),
      ).thenAnswer(
        (_) => Stream.value(
          Left<AppErrorModel, List<GradeEntity>>(tAppError),
        ),
      );

      final stream = useCase.call();

      await expectLater(
        stream,
        emits(isA<Left<AppErrorModel, List<dynamic>>>()),
      );
    },
  );

  test(
    'emits Left when the repository stream errors',
    () async {
      const tAppError = AppErrorModel(
        code: 'internal',
        message: 'server error',
        type: AppErrorType.server,
        isRetryable: true,
      );

      when(
        () => repository.streamGrades(
          activeOnly: any(named: 'activeOnly'),
        ),
      ).thenAnswer(
        (_) => Stream.error(
          FirebaseRemoteException(errorModel: tAppError),
        ),
      );

      final stream = useCase.call();

      await expectLater(
        stream,
        emitsError(isA<FirebaseRemoteException>()),
      );
    },
  );
}

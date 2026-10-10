import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/live_session/domain/entities/live_session_entity.dart';
import 'package:al_mobdea_admin/features/live_session/domain/use_cases/get_live_session_use_case.dart';
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

  late MockLiveSessionsRepository repository;
  late GetLiveSessionUseCase useCase;

  setUp(() {
    repository = MockLiveSessionsRepository();
    useCase = GetLiveSessionUseCase(repository: repository);
  });

  test('returns Right(entity) from the repository', () async {
    when(() => repository.getLiveSession())
        .thenAnswer((_) async => Right(tLiveSessionEntity));

    final result = await useCase();

    expect(
      result.fold((_) => null, (entity) => entity),
      tLiveSessionEntity,
    );
    verify(() => repository.getLiveSession()).called(1);
  });

  test(
    'returns Right(null) when there is no live session',
    () async {
      when(() => repository.getLiveSession())
          .thenAnswer((_) async => const Right(null));

      final result = await useCase();

      expect(result.isRight(), isTrue);
      expect(
        result.fold((_) => 'failure', (entity) => entity),
        isNull,
      );
    },
  );

  test('returns Left when the repository fails', () async {
    when(() => repository.getLiveSession())
        .thenAnswer((_) async => const Left(tAppError));

    final result = await useCase();

    expect(
      result,
      equals(
        const Left<AppErrorModel, LiveSessionEntity?>(tAppError),
      ),
    );
  });
}

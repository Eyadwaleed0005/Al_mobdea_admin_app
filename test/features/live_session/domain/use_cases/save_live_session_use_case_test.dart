import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/live_session/domain/use_cases/save_live_session_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockLiveSessionsRepository repository;
  late SaveLiveSessionUseCase useCase;

  setUpAll(() {
    registerFallbackValue(tLiveSessionEntity);
  });

  setUp(() {
    repository = MockLiveSessionsRepository();
    useCase = SaveLiveSessionUseCase(repository: repository);
  });

  test(
    'forwards the live session entity to the repository',
    () async {
      when(
        () => repository.saveLiveSession(
          liveSession: any(named: 'liveSession'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      final result = await useCase(
        liveSession: tLiveSessionEntity,
      );

      expect(
        result,
        equals(const Right<AppErrorModel, Unit>(unit)),
      );
      verify(
        () => repository.saveLiveSession(
          liveSession: tLiveSessionEntity,
        ),
      ).called(1);
    },
  );

  test('returns Left when the repository fails', () async {
    const tError = AppErrorModel(
      code: 'no-internet',
      message: 'offline',
      type: AppErrorType.network,
      isRetryable: true,
    );

    when(
      () => repository.saveLiveSession(
        liveSession: any(named: 'liveSession'),
      ),
    ).thenAnswer((_) async => const Left(tError));

    final result = await useCase(
      liveSession: tLiveSessionEntity,
    );

    expect(result.isLeft(), isTrue);
  });
}

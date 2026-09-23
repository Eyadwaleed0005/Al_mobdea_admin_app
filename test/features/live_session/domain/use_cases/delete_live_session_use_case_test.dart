import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/live_session/domain/use_cases/delete_live_session_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockLiveSessionsRepository repository;
  late DeleteLiveSessionUseCase useCase;

  setUp(() {
    repository = MockLiveSessionsRepository();
    useCase = DeleteLiveSessionUseCase(repository: repository);
  });

  test('forwards the gradeId to the repository', () async {
    when(
      () => repository.deleteLiveSession(
        gradeId: any(named: 'gradeId'),
      ),
    ).thenAnswer((_) async => const Right(unit));

    final result = await useCase(gradeId: tLiveSessionGradeId);

    expect(
      result,
      equals(const Right<AppErrorModel, Unit>(unit)),
    );
    verify(
      () => repository.deleteLiveSession(
        gradeId: tLiveSessionGradeId,
      ),
    ).called(1);
  });

  test('returns Left when the repository fails', () async {
    const tError = AppErrorModel(
      code: 'permission-denied',
      message: 'not allowed',
      type: AppErrorType.authorization,
      isRetryable: false,
    );

    when(
      () => repository.deleteLiveSession(
        gradeId: any(named: 'gradeId'),
      ),
    ).thenAnswer((_) async => const Left(tError));

    final result = await useCase(gradeId: tLiveSessionGradeId);

    expect(result.isLeft(), isTrue);
  });
}

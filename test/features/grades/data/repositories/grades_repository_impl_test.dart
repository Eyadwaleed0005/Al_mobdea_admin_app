import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/features/grades/data/models/grade_model.dart';
import 'package:al_mobdea_admin/features/grades/data/repositories/grades_repository_impl.dart';
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockGradesRemoteDataSource remoteDataSource;
  late GradesRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(tGradeModel);
  });

  setUp(() {
    remoteDataSource = MockGradesRemoteDataSource();
    repository = GradesRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );
  });

  const tAppError = AppErrorModel(
    code: 'internal',
    message: 'server error',
    type: AppErrorType.server,
    isRetryable: true,
  );

  final tRemoteException = FirebaseRemoteException(
    errorModel: tAppError,
  );

  group('getGrades', () {
    test(
      'returns Right(list of grade entities) on success',
      () async {
        when(
          () => remoteDataSource.getGrades(
            activeOnly: any(named: 'activeOnly'),
          ),
        ).thenAnswer(
          (_) async => [tGradeModel, tSecondGradeModel],
        );

        final result = await repository.getGrades();

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('expected Right'), (grades) {
          expect(grades, isA<List<GradeEntity>>());
          expect(grades, hasLength(2));
          expect(grades.first.gradeId, tGradeId);
          expect(grades.first.name, tGradeName);
          expect(grades.first.displayOrder, tGradeDisplayOrder);
          expect(grades.first.isActive, isTrue);
          expect(grades.last.gradeId, 'grade-2');
        });
        verify(
          () => remoteDataSource.getGrades(
            activeOnly: any(named: 'activeOnly'),
          ),
        ).called(1);
      },
    );

    test(
      'forwards activeOnly=false to the data source',
      () async {
        when(
          () => remoteDataSource.getGrades(
            activeOnly: any(named: 'activeOnly'),
          ),
        ).thenAnswer((_) async => <GradeModel>[]);

        await repository.getGrades(activeOnly: false);

        verify(
          () => remoteDataSource.getGrades(activeOnly: false),
        ).called(1);
      },
    );

    test('defaults activeOnly to true', () async {
      when(
        () => remoteDataSource.getGrades(
          activeOnly: any(named: 'activeOnly'),
        ),
      ).thenAnswer((_) async => <GradeModel>[]);

      await repository.getGrades();

      final captured = verify(
        () => remoteDataSource.getGrades(
          activeOnly: captureAny(named: 'activeOnly'),
        ),
      ).captured;

      expect(captured.single, isTrue);
    });

    test(
      'returns an empty Right list when there are no grades',
      () async {
        when(
          () => remoteDataSource.getGrades(
            activeOnly: any(named: 'activeOnly'),
          ),
        ).thenAnswer((_) async => <GradeModel>[]);

        final result = await repository.getGrades();

        expect(
          result.fold(
            (_) => fail('expected Right'),
            (grades) => grades,
          ),
          isEmpty,
        );
      },
    );

    test(
      'returns Left(AppErrorModel) when the datasource throws',
      () async {
        when(
          () => remoteDataSource.getGrades(
            activeOnly: any(named: 'activeOnly'),
          ),
        ).thenThrow(tRemoteException);

        final result = await repository.getGrades();

        expect(result.isLeft(), isTrue);
        expect(result.fold((l) => l, (_) => null), tAppError);
      },
    );

    test('returns Left(AppErrorModel) when the datasource future fails', () async {
      when(
        () => remoteDataSource.getGrades(
          activeOnly: any(named: 'activeOnly'),
        ),
      ).thenAnswer((_) => Future.error(tRemoteException));

      final result = await repository.getGrades();

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (_) => null), tAppError);
    });
  });

  group('streamGrades', () {
    test(
      'emits Right(list of grade entities) on success',
      () async {
        when(
          () => remoteDataSource.streamGrades(
            activeOnly: any(named: 'activeOnly'),
          ),
        ).thenAnswer(
          (_) => Stream.value([tGradeModel, tSecondGradeModel]),
        );

        final stream = repository.streamGrades();

        await expectLater(
          stream,
          emits(
            isA<Right<AppErrorModel, List<GradeEntity>>>()
                .having(
                  (either) =>
                      either.getOrElse(() => <GradeEntity>[]),
                  'grades',
                  hasLength(2),
                ),
          ),
        );
      },
    );

    test(
      'emits Left(AppErrorModel) when the stream throws',
      () async {
        when(
          () => remoteDataSource.streamGrades(
            activeOnly: any(named: 'activeOnly'),
          ),
        ).thenAnswer((_) => Stream.error(tRemoteException));

        final stream = repository.streamGrades();

        await expectLater(
          stream,
          emits(
            isA<Left<AppErrorModel, List<GradeEntity>>>().having(
              (either) =>
                  either.swap().getOrElse(() => fail('left')),
              'error',
              tAppError,
            ),
          ),
        );
      },
    );

    test(
      'forwards activeOnly=false to the data source stream',
      () async {
        when(
          () => remoteDataSource.streamGrades(
            activeOnly: any(named: 'activeOnly'),
          ),
        ).thenAnswer((_) => const Stream.empty());

        await repository.streamGrades(activeOnly: false).toList();

        verify(
          () => remoteDataSource.streamGrades(activeOnly: false),
        ).called(1);
      },
    );
  });
}

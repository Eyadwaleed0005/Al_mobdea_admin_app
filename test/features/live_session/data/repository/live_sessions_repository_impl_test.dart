import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/features/live_session/data/models/live_session_model.dart';
import 'package:al_mobdea_admin/features/live_session/data/repository/live_sessions_repository_impl.dart';
import 'package:al_mobdea_admin/features/live_session/domain/entities/meeting_type.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockLiveSessionsRemoteDataSource remoteDataSource;
  late LiveSessionsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(tLiveSessionModel);
  });

  setUp(() {
    remoteDataSource = MockLiveSessionsRemoteDataSource();
    repository = LiveSessionsRepositoryImpl(
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

  group('getLiveSession', () {
    test(
      'returns Right(entity) when a live session exists',
      () async {
        when(() => remoteDataSource.getLiveSession())
            .thenAnswer((_) async => tLiveSessionModel);

        final result = await repository.getLiveSession();

        final entity = result.fold(
          (AppErrorModel failure) => throw StateError('left'),
          (entity) => entity,
        );

        expect(entity!.gradeId, tLiveSessionGradeId);
        expect(entity.platformType, MeetingType.zoom);
        expect(entity.meetingUrl, tMeetingUrl);
      },
    );

    test(
      'returns Right(null) when no live session exists',
      () async {
        when(() => remoteDataSource.getLiveSession())
            .thenAnswer((_) async => null);

        final result = await repository.getLiveSession();

        expect(result.isRight(), isTrue);
        expect(
          result.fold(
            (AppErrorModel failure) => throw StateError('left'),
            (entity) => entity,
          ),
          isNull,
        );
      },
    );

    test('returns Left when the datasource throws', () async {
      when(() => remoteDataSource.getLiveSession())
          .thenThrow(tRemoteException);

      final result = await repository.getLiveSession();

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (_) => null), tAppError);
    });

    test(
      'returns Left when the datasource future fails',
      () async {
        when(() => remoteDataSource.getLiveSession())
            .thenAnswer((_) => Future.error(tRemoteException));

        final result = await repository.getLiveSession();

        expect(result.isLeft(), isTrue);
      },
    );
  });

  group('saveLiveSession', () {
    test('converts the entity into a model and returns Right(unit) on success', () async {
      when(
        () => remoteDataSource.saveLiveSession(
          liveSession: any(named: 'liveSession'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.saveLiveSession(
        liveSession: tLiveSessionEntity,
      );

      expect(
        result,
        equals(const Right<AppErrorModel, Unit>(unit)),
      );

      final capturedModel =
          verify(
                () => remoteDataSource.saveLiveSession(
                  liveSession: captureAny(named: 'liveSession'),
                ),
              ).captured.single
              as LiveSessionModel;

      expect(capturedModel.gradeId, tLiveSessionGradeId);
      expect(capturedModel.platformType, MeetingType.zoom.value);
      expect(capturedModel.meetingUrl, tMeetingUrl);
    });

    test('returns Left when the datasource throws', () async {
      when(
        () => remoteDataSource.saveLiveSession(
          liveSession: any(named: 'liveSession'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.saveLiveSession(
        liveSession: tLiveSessionEntity,
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('deleteLiveSession', () {
    test('returns Right(unit) on success', () async {
      when(
        () => remoteDataSource.deleteLiveSession(
          gradeId: any(named: 'gradeId'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.deleteLiveSession(
        gradeId: tLiveSessionGradeId,
      );

      expect(
        result,
        equals(const Right<AppErrorModel, Unit>(unit)),
      );
      verify(
        () => remoteDataSource.deleteLiveSession(
          gradeId: tLiveSessionGradeId,
        ),
      ).called(1);
    });

    test('returns Left when the datasource throws', () async {
      when(
        () => remoteDataSource.deleteLiveSession(
          gradeId: any(named: 'gradeId'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.deleteLiveSession(
        gradeId: tLiveSessionGradeId,
      );

      expect(result.isLeft(), isTrue);
    });
  });
}

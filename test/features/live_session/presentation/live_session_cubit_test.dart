import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:al_mobdea_admin/features/live_session/domain/entities/live_session_entity.dart';
import 'package:al_mobdea_admin/features/live_session/domain/entities/meeting_type.dart';
import 'package:al_mobdea_admin/features/live_session/presentation/cubit/live_session_cubit.dart';
import 'package:al_mobdea_admin/features/live_session/presentation/cubit/live_session_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/dummy_data.dart';
import '../../../helpers/test_helper.dart';

void main() {
  late MockStreamGradesUseCase mockStreamGradesUseCase;
  late MockGetLiveSessionUseCase mockGetLiveSessionUseCase;
  late MockSaveLiveSessionUseCase mockSaveLiveSessionUseCase;
  late MockDeleteLiveSessionUseCase mockDeleteLiveSessionUseCase;
  late MockNetworkStatusCubit mockNetworkStatusCubit;

  const tError = AppErrorModel(
    code: 'live-session-error',
    message: 'live session failed',
    type: AppErrorType.unknown,
    isRetryable: true,
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(tLiveSessionEntity);
  });

  setUp(() {
    mockStreamGradesUseCase = MockStreamGradesUseCase();
    mockGetLiveSessionUseCase = MockGetLiveSessionUseCase();
    mockSaveLiveSessionUseCase = MockSaveLiveSessionUseCase();
    mockDeleteLiveSessionUseCase = MockDeleteLiveSessionUseCase();
    mockNetworkStatusCubit = MockNetworkStatusCubit();

    when(
      () => mockNetworkStatusCubit.checkConnection(
        forceShowOfflineBanner: any(named: 'forceShowOfflineBanner'),
      ),
    ).thenAnswer((_) async {});
  });

  LiveSessionCubit buildCubit() {
    return LiveSessionCubit(
      streamGradesUseCase: mockStreamGradesUseCase,
      getLiveSessionUseCase: mockGetLiveSessionUseCase,
      saveLiveSessionUseCase: mockSaveLiveSessionUseCase,
      deleteLiveSessionUseCase: mockDeleteLiveSessionUseCase,
      networkStatusCubit: mockNetworkStatusCubit,
    );
  }

  void stubGradesSuccess({List<GradeEntity>? grades}) {
    final effectiveGrades = grades ?? [tGradeEntity];

    when(
      () => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly')),
    ).thenAnswer(
      (_) => Stream<Either<AppErrorModel, List<GradeEntity>>>.value(
        Right(effectiveGrades),
      ),
    );
  }

  void stubGradesError() {
    when(
      () => mockStreamGradesUseCase(activeOnly: any(named: 'activeOnly')),
    ).thenAnswer(
      (_) => Stream<Either<AppErrorModel, List<GradeEntity>>>.value(
        const Left(tError),
      ),
    );
  }

  void stubLiveSession({LiveSessionEntity? liveSession}) {
    when(
      () => mockGetLiveSessionUseCase(),
    ).thenAnswer((_) async => Right(liveSession));
  }

  void stubLiveSessionFailure() {
    when(
      () => mockGetLiveSessionUseCase(),
    ).thenAnswer((_) async => const Left(tError));
  }

  void stubSaveSuccess() {
    when(
      () => mockSaveLiveSessionUseCase(
        liveSession: any(named: 'liveSession'),
      ),
    ).thenAnswer((_) async => Right(unit));
  }

  void stubSaveFailure() {
    when(
      () => mockSaveLiveSessionUseCase(
        liveSession: any(named: 'liveSession'),
      ),
    ).thenAnswer((_) async => const Left(tError));
  }

  void stubDeleteSuccess() {
    when(
      () => mockDeleteLiveSessionUseCase(gradeId: any(named: 'gradeId')),
    ).thenAnswer((_) async => Right(unit));
  }

  void stubDeleteFailure() {
    when(
      () => mockDeleteLiveSessionUseCase(gradeId: any(named: 'gradeId')),
    ).thenAnswer((_) async => const Left(tError));
  }

  LiveSessionState seededFormState() {
    return LiveSessionState(
      status: LiveSessionStatus.empty,
      grades: [tGradeEntity],
      selectedGradeId: tGradeId,
      selectedMeetingType: MeetingType.zoom,
      meetingUrl: tMeetingUrl,
    );
  }

  LiveSessionState seededLoadedState() {
    return LiveSessionState(
      status: LiveSessionStatus.loaded,
      grades: [tGradeEntity],
      liveSession: tLiveSessionEntity,
    );
  }

  group('initial state', () {
    test('is idle with no grades and no live session', () async {
      final cubit = buildCubit();

      expect(cubit.state.status, LiveSessionStatus.initial);
      expect(cubit.state.grades, isEmpty);
      expect(cubit.state.isGradesLoading, isFalse);
      expect(cubit.state.hasLiveSession, isFalse);
      expect(cubit.state.errorModel, isNull);

      await cubit.close();
    });
  });

  group('initialize', () {
    test('streams grades and loads the live session', () async {
      stubGradesSuccess();
      stubLiveSession(liveSession: tLiveSessionEntity);

      final cubit = buildCubit();

      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(cubit.state.grades.map((grade) => grade.gradeId), [tGradeId]);
      expect(cubit.state.isGradesLoading, isFalse);
      expect(cubit.state.status, LiveSessionStatus.loaded);
      expect(cubit.state.liveSession, isNotNull);
      expect(cubit.state.liveSession!.meetingUrl, tMeetingUrl);
      expect(cubit.state.liveSession!.platformType, MeetingType.zoom);

      verify(
        () => mockStreamGradesUseCase(activeOnly: true),
      ).called(1);
      verify(() => mockGetLiveSessionUseCase()).called(1);

      await cubit.close();
    });

    test('emits empty status when no live session exists', () async {
      stubGradesSuccess();
      stubLiveSession();

      final cubit = buildCubit();

      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(cubit.state.status, LiveSessionStatus.empty);
      expect(cubit.state.hasLiveSession, isFalse);

      await cubit.close();
    });

    test('emits failure when the live session request fails', () async {
      stubGradesSuccess();
      stubLiveSessionFailure();

      final cubit = buildCubit();

      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(cubit.state.status, LiveSessionStatus.failure);
      expect(cubit.state.errorModel, tError);

      await cubit.close();
    });

    test('reports grade stream errors without crashing', () async {
      stubGradesError();

      final cubit = buildCubit();

      await cubit.watchGrades();

      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(cubit.state.isGradesLoading, isFalse);
      expect(cubit.state.errorModel, tError);

      await cubit.close();
    });

    test('initialize is idempotent', () async {
      stubGradesSuccess();
      stubLiveSession(liveSession: tLiveSessionEntity);

      final cubit = buildCubit();

      await cubit.initialize();
      await cubit.initialize();

      await Future<void>.delayed(const Duration(milliseconds: 30));

      verify(
        () => mockStreamGradesUseCase(activeOnly: true),
      ).called(1);
      verify(() => mockGetLiveSessionUseCase()).called(1);

      await cubit.close();
    });
  });

  group('selectGrade', () {
    blocTest<LiveSessionCubit, LiveSessionState>(
      'updates the grade and resets platform and link',
      build: buildCubit,
      seed: () => const LiveSessionState(
        selectedGradeId: 'grade-2',
        selectedMeetingType: MeetingType.zoom,
        meetingUrl: 'https://zoom.us/j/999',
      ),
      act: (cubit) => cubit.selectGrade(tGradeId),
      expect: () => [
        isA<LiveSessionState>()
            .having((state) => state.selectedGradeId, 'selectedGradeId', tGradeId)
            .having((state) => state.selectedMeetingType, 'selectedMeetingType', isNull)
            .having((state) => state.meetingUrl, 'meetingUrl', ''),
      ],
    );

    blocTest<LiveSessionCubit, LiveSessionState>(
      'ignores the same grade selection',
      build: buildCubit,
      seed: () => const LiveSessionState(selectedGradeId: tGradeId),
      act: (cubit) => cubit.selectGrade(tGradeId),
      expect: () => [],
    );
  });

  group('selectMeetingType', () {
    blocTest<LiveSessionCubit, LiveSessionState>(
      'updates the selected platform',
      build: buildCubit,
      act: (cubit) => cubit.selectMeetingType(MeetingType.googleMeet),
      expect: () => [
        isA<LiveSessionState>().having(
          (state) => state.selectedMeetingType,
          'selectedMeetingType',
          MeetingType.googleMeet,
        ),
      ],
    );

    blocTest<LiveSessionCubit, LiveSessionState>(
      'ignores the same platform selection',
      build: buildCubit,
      seed: () => const LiveSessionState(selectedMeetingType: MeetingType.zoom),
      act: (cubit) => cubit.selectMeetingType(MeetingType.zoom),
      expect: () => [],
    );
  });

  group('form validation', () {
    test('validates the meeting url', () {
      expect(
        const LiveSessionState(meetingUrl: '').hasValidMeetingUrl,
        isFalse,
      );
      expect(
        const LiveSessionState(meetingUrl: 'not-a-url').hasValidMeetingUrl,
        isFalse,
      );
      expect(
        const LiveSessionState(meetingUrl: tMeetingUrl).hasValidMeetingUrl,
        isTrue,
      );
    });

    test('canSave requires a grade, platform and url', () {
      final validState = LiveSessionState(
        grades: [tGradeEntity],
        selectedGradeId: tGradeId,
        selectedMeetingType: MeetingType.zoom,
        meetingUrl: tMeetingUrl,
      );

      expect(validState.hasValidForm, isTrue);
      expect(validState.canSave, isTrue);

      final missingPlatform = validState.copyWith(
        clearSelectedMeetingType: true,
      );

      expect(missingPlatform.canSave, isFalse);

      final missingGrade = validState.copyWith(clearSelectedGrade: true);

      expect(missingGrade.canSave, isFalse);

      final invalidUrl = validState.copyWith(meetingUrl: 'zoom');

      expect(invalidUrl.canSave, isFalse);

      final withLiveSession = validState.copyWith(
        liveSession: tLiveSessionEntity,
      );

      expect(withLiveSession.canSave, isFalse);
    });

    test('selectedGrade resolves the grade entity', () {
      final state = LiveSessionState(
        grades: [tGradeEntity, tSecondGradeEntity],
        selectedGradeId: tSecondGradeEntity.gradeId,
      );

      expect(state.selectedGrade, tSecondGradeEntity);
      expect(state.hasValidGrade, isTrue);

      final unknownGrade = state.copyWith(selectedGradeId: 'grade-9');

      expect(unknownGrade.selectedGrade, isNull);
      expect(unknownGrade.hasValidGrade, isFalse);
    });
  });

  group('saveLiveSession', () {
    blocTest<LiveSessionCubit, LiveSessionState>(
      'emits saving then saveSuccess with the saved session',
      setUp: stubSaveSuccess,
      build: buildCubit,
      seed: seededFormState,
      act: (cubit) => cubit.saveLiveSession(),
      expect: () => [
        isA<LiveSessionState>().having(
          (state) => state.status,
          'status',
          LiveSessionStatus.saving,
        ),
        isA<LiveSessionState>()
            .having(
              (state) => state.status,
              'status',
              LiveSessionStatus.saveSuccess,
            )
            .having(
              (state) => state.liveSession?.meetingUrl,
              'meetingUrl',
              tMeetingUrl,
            ),
      ],
      verify: (_) {
        verify(
          () => mockSaveLiveSessionUseCase(
            liveSession: any(named: 'liveSession'),
          ),
        ).called(1);
      },
    );

    blocTest<LiveSessionCubit, LiveSessionState>(
      'emits saving then failure when the save request fails',
      setUp: stubSaveFailure,
      build: buildCubit,
      seed: seededFormState,
      act: (cubit) => cubit.saveLiveSession(),
      expect: () => [
        isA<LiveSessionState>().having(
          (state) => state.status,
          'status',
          LiveSessionStatus.saving,
        ),
        isA<LiveSessionState>()
            .having((state) => state.status, 'status', LiveSessionStatus.failure)
            .having((state) => state.errorModel, 'errorModel', tError),
      ],
    );

    blocTest<LiveSessionCubit, LiveSessionState>(
      'does nothing when the form is invalid',
      build: buildCubit,
      seed: () => const LiveSessionState(meetingUrl: 'zoom'),
      act: (cubit) => cubit.saveLiveSession(),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => mockSaveLiveSessionUseCase(
            liveSession: any(named: 'liveSession'),
          ),
        );
      },
    );
  });

  group('deleteLiveSession', () {
    blocTest<LiveSessionCubit, LiveSessionState>(
      'emits deleting then deleteSuccess and clears the session',
      setUp: stubDeleteSuccess,
      build: buildCubit,
      seed: seededLoadedState,
      act: (cubit) => cubit.deleteLiveSession(),
      expect: () => [
        isA<LiveSessionState>().having(
          (state) => state.status,
          'status',
          LiveSessionStatus.deleting,
        ),
        isA<LiveSessionState>()
            .having(
              (state) => state.status,
              'status',
              LiveSessionStatus.deleteSuccess,
            )
            .having((state) => state.liveSession, 'liveSession', isNull)
            .having((state) => state.selectedGradeId, 'selectedGradeId', isNull)
            .having(
              (state) => state.selectedMeetingType,
              'selectedMeetingType',
              isNull,
            )
            .having((state) => state.meetingUrl, 'meetingUrl', ''),
      ],
      verify: (_) {
        verify(
          () => mockDeleteLiveSessionUseCase(gradeId: tLiveSessionGradeId),
        ).called(1);
      },
    );

    blocTest<LiveSessionCubit, LiveSessionState>(
      'emits deleting then failure and keeps the session for feedback',
      setUp: stubDeleteFailure,
      build: buildCubit,
      seed: seededLoadedState,
      act: (cubit) => cubit.deleteLiveSession(),
      expect: () => [
        isA<LiveSessionState>().having(
          (state) => state.status,
          'status',
          LiveSessionStatus.deleting,
        ),
        isA<LiveSessionState>()
            .having(
              (state) => state.status,
              'status',
              LiveSessionStatus.failure,
            )
            .having(
              (state) => state.liveSession?.gradeId,
              'liveSession',
              tLiveSessionGradeId,
            )
            .having((state) => state.errorModel, 'errorModel', tError),
      ],
    );

    blocTest<LiveSessionCubit, LiveSessionState>(
      'does nothing when there is no session to delete',
      build: buildCubit,
      seed: () => const LiveSessionState(status: LiveSessionStatus.empty),
      act: (cubit) => cubit.deleteLiveSession(),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => mockDeleteLiveSessionUseCase(gradeId: any(named: 'gradeId')),
        );
      },
    );
  });

  group('refreshLiveSession', () {
    blocTest<LiveSessionCubit, LiveSessionState>(
      'checks the connection and reloads the session',
      setUp: () {
        stubLiveSession(
          liveSession: tGoogleMeetLiveSessionEntity,
        );
      },
      build: buildCubit,
      seed: seededLoadedState,
      act: (cubit) => cubit.refreshLiveSession(),
      expect: () => [
        isA<LiveSessionState>()
            .having((state) => state.status, 'status', LiveSessionStatus.loaded)
            .having(
              (state) => state.liveSession?.platformType,
              'platformType',
              MeetingType.googleMeet,
            ),
      ],
      verify: (_) {
        verify(
          () => mockNetworkStatusCubit.checkConnection(
            forceShowOfflineBanner: true,
          ),
        ).called(1);
        verify(() => mockGetLiveSessionUseCase()).called(1);
      },
    );

    blocTest<LiveSessionCubit, LiveSessionState>(
      'keeps the current state when a refresh fails',
      setUp: stubLiveSessionFailure,
      build: buildCubit,
      seed: seededLoadedState,
      act: (cubit) => cubit.refreshLiveSession(),
      expect: () => [],
      verify: (_) {
        verify(() => mockGetLiveSessionUseCase()).called(1);
      },
    );

    blocTest<LiveSessionCubit, LiveSessionState>(
      'continues when the network check throws',
      setUp: () {
        when(
          () => mockNetworkStatusCubit.checkConnection(
            forceShowOfflineBanner: any(named: 'forceShowOfflineBanner'),
          ),
        ).thenThrow(Exception('network check failed'));

        stubLiveSession(liveSession: tLiveSessionEntity);
      },
      build: buildCubit,
      seed: seededLoadedState,
      act: (cubit) => cubit.refreshLiveSession(),
      expect: () => [
        isA<LiveSessionState>().having(
          (state) => state.status,
          'status',
          LiveSessionStatus.loaded,
        ),
      ],
    );
  });

  group('clearError', () {
    blocTest<LiveSessionCubit, LiveSessionState>(
      'clears the stored error model',
      build: buildCubit,
      seed: () => const LiveSessionState(
        status: LiveSessionStatus.failure,
        errorModel: tError,
      ),
      act: (cubit) => cubit.clearError(),
      expect: () => [
        isA<LiveSessionState>().having(
          (state) => state.errorModel,
          'errorModel',
          isNull,
        ),
      ],
    );

    blocTest<LiveSessionCubit, LiveSessionState>(
      'does nothing when there is no error',
      build: buildCubit,
      act: (cubit) => cubit.clearError(),
      expect: () => [],
    );
  });

  test('close does not throw after initialize', () async {
    stubGradesSuccess();
    stubLiveSession(liveSession: tLiveSessionEntity);

    final cubit = buildCubit();

    await cubit.initialize();

    await Future<void>.delayed(const Duration(milliseconds: 30));

    await expectLater(cubit.close(), completes);
  });
}

import 'package:al_mobdea_admin/core/connection/network/network_info.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firebase_firestore_service.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_collections.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/core/firebase/firestore/firestore_service.dart';
import 'package:al_mobdea_admin/features/live_session/data/data_sources/firebase_live_sessions_remote_data_source.dart';
import 'package:al_mobdea_admin/features/live_session/data/data_sources/live_sessions_remote_data_source.dart';
import 'package:al_mobdea_admin/features/live_session/data/models/live_session_model.dart';
import 'package:al_mobdea_admin/features/live_session/domain/entities/meeting_type.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

class _AlwaysOnlineNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;

  @override
  Stream<bool> get onConnectionChanged =>
      const Stream<bool>.empty();

  @override
  Future<void> dispose() async {}
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreService firestoreService;
  late MockNetworkInfo networkInfo;
  late FirebaseLiveSessionsRemoteDataSource dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    firestoreService = FirebaseFirestoreService(
      networkInfo: _AlwaysOnlineNetworkInfo(),
      firestore: fakeFirestore,
      enableLogging: false,
    );
    networkInfo = MockNetworkInfo();

    dataSource = FirebaseLiveSessionsRemoteDataSource(
      firestoreService: firestoreService,
      networkInfo: networkInfo,
    );
  });

  Future<void> seedLiveSession({String? gradeId}) {
    return fakeFirestore
        .collection(FirestoreCollections.liveSessions)
        .doc(tLiveSessionGradeId)
        .set(
          tLiveSessionJson(
            gradeId: gradeId ?? tLiveSessionGradeId,
          ),
        );
  }

  test('implements LiveSessionsRemoteDataSource', () {
    expect(dataSource, isA<LiveSessionsRemoteDataSource>());
  });

  group('getLiveSession (online)', () {
    setUp(() {
      when(() => networkInfo.isConnected)
          .thenAnswer((_) async => true);
    });

    test('returns null when no live session exists', () async {
      final result = await dataSource.getLiveSession();

      expect(result, isNull);
    });

    test('returns the stored live session model', () async {
      await seedLiveSession();

      final result = await dataSource.getLiveSession();

      expect(result, isNotNull);
      expect(result!.gradeId, tLiveSessionGradeId);
      expect(result.platformType, MeetingType.zoom.value);
      expect(result.meetingUrl, tMeetingUrl);
    });

    test('reads the document id as the gradeId', () async {
      await fakeFirestore
          .collection(FirestoreCollections.liveSessions)
          .doc('grade-77')
          .set(tLiveSessionJson());

      final result = await dataSource.getLiveSession();

      expect(result!.gradeId, 'grade-77');
    });
  });

  group('getLiveSession (offline)', () {
    setUp(() {
      when(() => networkInfo.isConnected)
          .thenAnswer((_) async => false);
    });

    test(
      'returns the cached live session while offline',
      () async {
        await seedLiveSession();

        final result = await dataSource.getLiveSession();

        expect(result, isNotNull);
        expect(result!.gradeId, tLiveSessionGradeId);
        expect(result.meetingUrl, tMeetingUrl);
      },
    );

    test(
      'returns null while offline when the cache is empty',
      () async {
        final result = await dataSource.getLiveSession();

        expect(result, isNull);
      },
    );
  });

  group('saveLiveSession', () {
    setUp(() {
      when(() => networkInfo.isConnected)
          .thenAnswer((_) async => true);
    });

    test(
      'writes the model using the gradeId as the document id',
      () async {
        await dataSource.saveLiveSession(
          liveSession: tLiveSessionModel,
        );

        final snapshot = await fakeFirestore
            .collection(FirestoreCollections.liveSessions)
            .doc(tLiveSessionGradeId)
            .get();

        expect(snapshot.exists, isTrue);

        final data = snapshot.data()!;

        expect(
          data[FirestoreFields.gradeId],
          tLiveSessionGradeId,
        );
        expect(
          data[FirestoreFields.platformType],
          MeetingType.zoom.value,
        );
        expect(data[FirestoreFields.meetingUrl], tMeetingUrl);
      },
    );

    test('overwrites a previously saved live session', () async {
      await dataSource.saveLiveSession(
        liveSession: tLiveSessionModel,
      );
      await dataSource.saveLiveSession(
        liveSession: LiveSessionModel.fromEntity(
          tGoogleMeetLiveSessionEntity,
        ),
      );

      final snapshot = await fakeFirestore
          .collection(FirestoreCollections.liveSessions)
          .doc(tLiveSessionGradeId)
          .get()
          .then((document) => document.data()!);

      expect(
        snapshot[FirestoreFields.platformType],
        MeetingType.googleMeet.value,
      );
      expect(
        snapshot[FirestoreFields.meetingUrl],
        tGoogleMeetUrl,
      );
    });
  });

  group('deleteLiveSession', () {
    setUp(() {
      when(() => networkInfo.isConnected)
          .thenAnswer((_) async => true);
    });

    test('removes the live session document', () async {
      await seedLiveSession();

      await dataSource.deleteLiveSession(
        gradeId: tLiveSessionGradeId,
      );

      final snapshot = await fakeFirestore
          .collection(FirestoreCollections.liveSessions)
          .doc(tLiveSessionGradeId)
          .get();

      expect(snapshot.exists, isFalse);
    });

    test('completes silently when nothing is stored', () async {
      await expectLater(
        dataSource.deleteLiveSession(
          gradeId: tLiveSessionGradeId,
        ),
        completes,
      );
    });
  });
}

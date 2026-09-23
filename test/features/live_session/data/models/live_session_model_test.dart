import 'package:al_mobdea_admin/core/firebase/firestore/firestore_fields.dart';
import 'package:al_mobdea_admin/features/live_session/data/models/live_session_model.dart';
import 'package:al_mobdea_admin/features/live_session/domain/entities/meeting_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dummy_data.dart';

void main() {
  group('LiveSessionModel', () {
    group('fromMap', () {
      test('maps all fields from a firestore document map', () {
        final model = LiveSessionModel.fromMap(tLiveSessionJson());

        expect(model.gradeId, tLiveSessionGradeId);
        expect(model.platformType, MeetingType.zoom.value);
        expect(model.meetingUrl, tMeetingUrl);
      });
    });

    group('toMap', () {
      test('serializes all fields', () {
        final map = tLiveSessionModel.toMap();

        expect(map[FirestoreFields.gradeId], tLiveSessionGradeId);
        expect(map[FirestoreFields.platformType], MeetingType.zoom.value);
        expect(map[FirestoreFields.meetingUrl], tMeetingUrl);
      });

      test('round-trips through fromMap', () {
        final parsed = LiveSessionModel.fromMap(tLiveSessionModel.toMap());

        expect(parsed.gradeId, tLiveSessionModel.gradeId);
        expect(parsed.platformType, tLiveSessionModel.platformType);
        expect(parsed.meetingUrl, tLiveSessionModel.meetingUrl);
      });
    });

    group('fromEntity', () {
      test('converts the meeting type enum into its string value', () {
        final model = LiveSessionModel.fromEntity(tLiveSessionEntity);

        expect(model.gradeId, tLiveSessionGradeId);
        expect(model.platformType, MeetingType.zoom.value);
        expect(model.meetingUrl, tMeetingUrl);
      });

      test('supports the google meet platform', () {
        final model = LiveSessionModel.fromEntity(
          tGoogleMeetLiveSessionEntity,
        );

        expect(model.platformType, MeetingType.googleMeet.value);
        expect(model.meetingUrl, tGoogleMeetUrl);
      });
    });

    group('toEntity', () {
      test('converts the platform string back into the meeting type', () {
        final entity = tLiveSessionModel.toEntity();

        expect(entity.gradeId, tLiveSessionGradeId);
        expect(entity.platformType, MeetingType.zoom);
        expect(entity.meetingUrl, tMeetingUrl);
      });

      test('parses googleMeet platform', () {
        final entity = LiveSessionModel(
          gradeId: tLiveSessionGradeId,
          platformType: MeetingType.googleMeet.value,
          meetingUrl: tGoogleMeetUrl,
        ).toEntity();

        expect(entity.platformType, MeetingType.googleMeet);
      });

      test('throws for an unknown platform value', () {
        final model = LiveSessionModel(
          gradeId: tLiveSessionGradeId,
          platformType: 'teams',
          meetingUrl: tMeetingUrl,
        );

        expect(() => model.toEntity(), throwsArgumentError);
      });
    });
  });
}

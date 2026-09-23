import 'package:al_mobdea_admin/features/live_session/domain/entities/meeting_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MeetingType', () {
    test('exposes the expected platform values', () {
      expect(MeetingType.values, hasLength(2));
      expect(MeetingType.zoom.value, 'zoom');
      expect(MeetingType.googleMeet.value, 'googleMeet');
    });

    group('fromValue', () {
      test('parses zoom', () {
        expect(MeetingType.fromValue('zoom'), MeetingType.zoom);
      });

      test('parses googleMeet', () {
        expect(MeetingType.fromValue('googleMeet'), MeetingType.googleMeet);
      });

      test('is case sensitive', () {
        expect(
          () => MeetingType.fromValue('Zoom'),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError for an unknown value', () {
        expect(
          () => MeetingType.fromValue('teams'),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError for an empty value', () {
        expect(
          () => MeetingType.fromValue(''),
          throwsArgumentError,
        );
      });
    });
  });
}

import 'meeting_type.dart';

class LiveSessionEntity {
  const LiveSessionEntity({
    required this.gradeId,
    required this.platformType,
    required this.meetingUrl,
  });

  final String gradeId;
  final MeetingType platformType;
  final String meetingUrl;

  LiveSessionEntity copyWith({
    String? gradeId,
    MeetingType? platformType,
    String? meetingUrl,
  }) {
    return LiveSessionEntity(
      gradeId: gradeId ?? this.gradeId,
      platformType: platformType ?? this.platformType,
      meetingUrl: meetingUrl ?? this.meetingUrl,
    );
  }
}

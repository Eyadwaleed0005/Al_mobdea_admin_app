import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/features/live_session/domain/entities/meeting_type.dart';
import 'package:al_mobdea_admin/features/live_session/presentation/widgets/live_session_screen_widgets/meeting_type_item.dart';
import 'package:flutter/material.dart';

class MeetingTypeSelector extends StatelessWidget {
  const MeetingTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  final MeetingType? selectedType;
  final ValueChanged<MeetingType> onChanged;

  String _subtitleFor(MeetingType meetingType) {
    return selectedType == meetingType ? 'محدد' : 'متاح';
  }

  @override
  Widget build(BuildContext context) {
    final isGoogleMeetSelected = selectedType == MeetingType.googleMeet;
    final isZoomSelected = selectedType == MeetingType.zoom;

    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: MeetingTypeItem(
            title: 'Google Meet',
            subtitle: _subtitleFor(MeetingType.googleMeet),
            isSelected: isGoogleMeetSelected,
            onTap: () {
              onChanged(MeetingType.googleMeet);
            },
          ),
        ),
        horizontalSpace(12),
        Expanded(
          child: MeetingTypeItem(
            title: 'Zoom',
            subtitle: _subtitleFor(MeetingType.zoom),
            isSelected: isZoomSelected,
            onTap: () {
              onChanged(MeetingType.zoom);
            },
          ),
        ),
      ],
    );
  }
}

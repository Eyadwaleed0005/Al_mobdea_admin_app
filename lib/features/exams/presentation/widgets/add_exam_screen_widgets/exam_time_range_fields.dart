import 'package:al_mobdea_admin/core/helper/app_date_time_formatter.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExamTimeRangeFields extends StatelessWidget {
  const ExamTimeRangeFields({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onStartTimePressed,
    required this.onEndTimePressed,
    this.errorText,
    this.isEnabled = true,
  });

  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  final VoidCallback onStartTimePressed;
  final VoidCallback onEndTimePressed;

  final String? errorText;

  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ExamTimeField(
                labelText: 'وقت البداية',
                selectedTime: startTime,
                isEnabled: isEnabled,
                onPressed: onStartTimePressed,
              ),
            ),
            horizontalSpace(16),
            Expanded(
              child: ExamTimeField(
                labelText: 'وقت النهاية',
                selectedTime: endTime,
                isEnabled: isEnabled,
                onPressed: onEndTimePressed,
              ),
            ),
          ],
        ),

        if (errorText != null && errorText!.trim().isNotEmpty) ...[
          verticalSpace(8),
          Text(
            errorText!,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTextStyle.font12ErrorRegularTajawal(),
          ),
        ],
      ],
    );
  }
}

class ExamTimeField extends StatelessWidget {
  const ExamTimeField({
    super.key,
    required this.labelText,
    required this.selectedTime,
    required this.onPressed,
    this.isEnabled = true,
  });

  final String labelText;
  final TimeOfDay? selectedTime;
  final VoidCallback onPressed;
  final bool isEnabled;

  String get _timeText {
    final TimeOfDay? time = selectedTime;

    if (time == null) {
      return 'اختر الوقت';
    }

    return AppDateTimeFormatter.formatTime(
      DateTime(2026, 1, 1, time.hour, time.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          labelText,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: AppTextStyle.font15TextPrimaryMediumTajawal(),
        ),
        verticalSpace(8),
        SizedBox(
          height: 56.h,
          child: Material(
            color: isEnabled ? ColorPalette.surface : ColorPalette.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.r),
              side: BorderSide(color: ColorPalette.border, width: 1.w),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: isEnabled ? onPressed : null,
              splashColor: ColorPalette.primarySoftBackground,
              highlightColor: ColorPalette.primarySoftBackground,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _timeText,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: selectedTime == null
                        ? AppTextStyle.font15TextMutedRegularTajawal()
                        : AppTextStyle.font15TextPrimaryMediumTajawal(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

abstract final class ExamTimePickerHelper {
  const ExamTimePickerHelper._();

  static Future<TimeOfDay?> show(
    BuildContext context, {
    required TimeOfDay initialTime,
    required String helpText,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: helpText,
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
      hourLabelText: 'الساعة',
      minuteLabelText: 'الدقيقة',
      barrierColor: ColorPalette.deepSurface.withValues(alpha: 0.45),
      builder: (BuildContext context, Widget? child) {
        final ThemeData currentTheme = Theme.of(context);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Theme(
            data: currentTheme.copyWith(
              colorScheme: currentTheme.colorScheme.copyWith(
                primary: ColorPalette.primary,
                onPrimary: ColorPalette.surface,
                secondary: ColorPalette.accent,
                onSecondary: ColorPalette.textPrimary,
                surface: ColorPalette.surface,
                onSurface: ColorPalette.textPrimary,
                error: ColorPalette.error,
                outline: ColorPalette.border,
              ),
              timePickerTheme: TimePickerThemeData(
                backgroundColor: ColorPalette.surface,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  side: BorderSide(color: ColorPalette.border, width: 1.w),
                ),
                hourMinuteColor: ColorPalette.primarySoftBackground,
                hourMinuteTextColor: ColorPalette.primary,
                dayPeriodColor: ColorPalette.primarySoftBackground,
                dayPeriodTextColor: ColorPalette.primary,
                dayPeriodBorderSide: BorderSide(
                  color: ColorPalette.border,
                  width: 1.w,
                ),
                dialBackgroundColor: ColorPalette.primarySoftBackground,
                dialHandColor: ColorPalette.primary,
                dialTextColor: ColorPalette.textPrimary,
                entryModeIconColor: ColorPalette.primary,
                hourMinuteTextStyle:
                    AppTextStyle.font20TextPrimarySemiBoldKufam(),
                helpTextStyle: AppTextStyle.font14TextSecondaryRegularTajawal(),
                cancelButtonStyle: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(
                    ColorPalette.textSecondary,
                  ),
                ),
                confirmButtonStyle: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(
                    ColorPalette.primary,
                  ),
                ),
              ),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  static int durationMinutes({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) {
    final int startMinutes = (startTime.hour * 60) + startTime.minute;

    final int endMinutes = (endTime.hour * 60) + endTime.minute;

    return endMinutes - startMinutes;
  }
}

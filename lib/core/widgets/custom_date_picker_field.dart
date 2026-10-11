import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:al_mobdea_admin/core/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDatePickerField extends StatelessWidget {
  const CustomDatePickerField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onDateSelected,
    this.labelText,
    this.selectedDate,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.validator,
    this.isRequired = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hintText;
  final String? labelText;

  final DateTime? selectedDate;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  final ValueChanged<DateTime> onDateSelected;
  final FormFieldValidator<String>? validator;

  final bool isRequired;
  final bool enabled;

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _getInitialDate({required DateTime first, required DateTime last}) {
    final date = _normalizeDate(selectedDate ?? initialDate ?? DateTime.now());

    if (date.isBefore(first)) return first;
    if (date.isAfter(last)) return last;

    return date;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Color? _selectionBackground(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) return null;

    if (states.contains(WidgetState.selected)) {
      return ColorPalette.primary;
    }

    return null;
  }

  Color _selectionForeground(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return ColorPalette.disabled;
    }

    if (states.contains(WidgetState.selected)) {
      return ColorPalette.surface;
    }

    return ColorPalette.textPrimary;
  }

  Color? _interactionOverlay(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) return null;

    if (states.contains(WidgetState.pressed) ||
        states.contains(WidgetState.hovered) ||
        states.contains(WidgetState.focused)) {
      return ColorPalette.primary.withValues(alpha: 0.10);
    }

    return null;
  }

  OutlineInputBorder _inputBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  ThemeData _pickerTheme(ThemeData theme) {
    // Use logical pixel sizes inside the dialog.
    final bodyStyle = AppTextStyle.font15TextPrimaryMediumTajawal().copyWith(
      fontSize: 15,
    );

    return theme.copyWith(
      disabledColor: ColorPalette.disabled,
      dividerColor: ColorPalette.divider,
      colorScheme: theme.colorScheme.copyWith(
        primary: ColorPalette.primary,
        onPrimary: ColorPalette.surface,
        secondary: ColorPalette.accent,
        onSecondary: ColorPalette.textPrimary,
        surface: ColorPalette.surface,
        onSurface: ColorPalette.textPrimary,
        error: ColorPalette.error,
        outline: ColorPalette.border,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: ColorPalette.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: ColorPalette.primaryPressed.withValues(alpha: 0.14),
        elevation: 8,
        dividerColor: ColorPalette.divider,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: ColorPalette.border, width: 1),
        ),
        headerBackgroundColor: ColorPalette.primary,
        headerForegroundColor: ColorPalette.surface,
        headerHeadlineStyle: AppTextStyle.font18PrimarySemiBoldKufam().copyWith(
          color: ColorPalette.surface,
          fontSize: 22,
        ),
        headerHelpStyle: AppTextStyle.font14TextPrimaryRegularTajawal()
            .copyWith(color: ColorPalette.surface, fontSize: 14),
        weekdayStyle: AppTextStyle.font15TextMutedRegularTajawal().copyWith(
          color: ColorPalette.textSecondary,
          fontSize: 14,
        ),
        dayStyle: bodyStyle,
        dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>(
          _selectionBackground,
        ),
        dayForegroundColor: WidgetStateProperty.resolveWith<Color>(
          _selectionForeground,
        ),
        dayOverlayColor: WidgetStateProperty.resolveWith<Color?>(
          _interactionOverlay,
        ),
        dayShape: WidgetStateProperty.all<OutlinedBorder>(const CircleBorder()),
        todayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.disabled)) return null;

          return states.contains(WidgetState.selected)
              ? ColorPalette.primary
              : ColorPalette.primarySoftBackground;
        }),
        todayForegroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return ColorPalette.disabled;
          }

          return states.contains(WidgetState.selected)
              ? ColorPalette.surface
              : ColorPalette.primary;
        }),
        todayBorder: const BorderSide(color: ColorPalette.primary, width: 1.2),
        yearStyle: bodyStyle,
        yearBackgroundColor: WidgetStateProperty.resolveWith<Color?>(
          _selectionBackground,
        ),
        yearForegroundColor: WidgetStateProperty.resolveWith<Color>(
          _selectionForeground,
        ),
        yearOverlayColor: WidgetStateProperty.resolveWith<Color?>(
          _interactionOverlay,
        ),
        yearShape: WidgetStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: ColorPalette.textSecondary,
          textStyle: bodyStyle,
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: ColorPalette.primary,
          textStyle: bodyStyle,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ColorPalette.primarySoftBackground,
          hintStyle: AppTextStyle.font15TextMutedRegularTajawal().copyWith(
            fontSize: 15,
          ),
          labelStyle: bodyStyle,
          enabledBorder: _inputBorder(ColorPalette.border, 1),
          focusedBorder: _inputBorder(ColorPalette.primary, 1.3),
          errorBorder: _inputBorder(ColorPalette.error, 1),
          focusedErrorBorder: _inputBorder(ColorPalette.error, 1.3),
        ),
      ),
    );
  }

  Future<void> _openDatePicker(BuildContext context) async {
    if (!enabled) return;

    FocusScope.of(context).unfocus();

    final first = _normalizeDate(firstDate ?? DateTime(2000));
    final last = _normalizeDate(lastDate ?? DateTime(2100));

    // Keep a valid range even if the supplied bounds are reversed.
    final rangeStart = first.isAfter(last) ? last : first;
    final rangeEnd = first.isAfter(last) ? first : last;

    final media = MediaQuery.of(context);
    final availableWidth =
        media.size.width - media.padding.left - media.padding.right;
    final availableHeight =
        media.size.height - media.padding.top - media.padding.bottom;

    final useInputMode =
        availableWidth < 360 ||
        availableHeight < 500 ||
        media.textScaler.scale(16) > 20.8;

    final selected = await showDatePicker(
      context: context,
      initialDate: _getInitialDate(first: rangeStart, last: rangeEnd),
      firstDate: rangeStart,
      lastDate: rangeEnd,
      initialEntryMode: useInputMode
          ? DatePickerEntryMode.inputOnly
          : DatePickerEntryMode.calendar,
      helpText: labelText ?? 'اختر التاريخ',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
      barrierColor: ColorPalette.deepSurface.withValues(alpha: 0.45),
      builder: (dialogContext, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Theme(
            data: _pickerTheme(Theme.of(dialogContext)),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );

    if (!context.mounted || selected == null) return;

    final normalizedDate = _normalizeDate(selected);

    controller.text = _formatDate(normalizedDate);
    onDateSelected(normalizedDate);
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      isRequired: isRequired,
      enabled: enabled,
      readOnly: true,
      validator: validator,
      onTap: () => _openDatePicker(context),
      suffixIcon: Icon(
        Icons.calendar_month_outlined,
        color: enabled ? ColorPalette.primary : ColorPalette.disabled,
        size: 24.sp,
      ),
      onSuffixTap: () => _openDatePicker(context),
    );
  }
}

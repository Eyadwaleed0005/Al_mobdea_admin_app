import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StudentStatCard extends StatelessWidget {
  const StudentStatCard({
    super.key,
    required this.count,
    required this.label,
    this.showEyeToggle = false,
    this.isCountVisible = true,
    this.onToggleVisibility,
    this.cardColor,
    this.labelColor,
    this.countColor,
  });

  final int count;
  final String label;
  final bool showEyeToggle;
  final bool isCountVisible;
  final VoidCallback? onToggleVisibility;
  final Color? cardColor;
  final Color? labelColor;
  final Color? countColor;

  @override
  Widget build(BuildContext context) {
    final bgColor = cardColor ?? ColorPalette.surface;
    final txtColor = countColor ?? ColorPalette.primary;
    final lblColor = labelColor ?? ColorPalette.textSecondary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ColorPalette.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row: label + optional eye toggle
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTextStyle.tajawal,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: lblColor,
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                ),
              ),
              if (showEyeToggle) ...[
                horizontalSpace(6),
                GestureDetector(
                  onTap: onToggleVisibility,
                  child: Icon(
                    isCountVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18.sp,
                    color: ColorPalette.textMuted,
                  ),
                ),
              ],
            ],
          ),
          verticalSpace(10),
          // Count or obscured dots
          Directionality(
            textDirection: TextDirection.rtl,
            child: isCountVisible
                ? Text(
                    _toArabicNumerals(count),
                    style: TextStyle(
                      fontFamily: AppTextStyle.kufam,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: txtColor,
                    ),
                  )
                : Text(
                    '•••',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: txtColor,
                      letterSpacing: 3,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _toArabicNumerals(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((d) {
      final digit = int.tryParse(d);
      return digit != null ? arabicDigits[digit] : d;
    }).join();
  }
}

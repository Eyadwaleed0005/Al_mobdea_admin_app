import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LessonExamQuestionHintCard extends StatelessWidget {
  const LessonExamQuestionHintCard({
    super.key,
    required this.message,
    this.bulletColor = ColorPalette.gold400,
    this.icon,
  });

  final String message;

  final Color bulletColor;

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: ColorPalette.gold50,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: ColorPalette.cream200, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.black.withValues(alpha: 0.05),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTextStyle.font13TextPrimaryMediumTajawal(),
            ),
          ),

          horizontalSpace(14),

          if (icon == null)
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: bulletColor,
                shape: BoxShape.circle,
              ),
            )
          else
            Icon(icon, size: 18.sp, color: bulletColor),
        ],
      ),
    );
  }
}

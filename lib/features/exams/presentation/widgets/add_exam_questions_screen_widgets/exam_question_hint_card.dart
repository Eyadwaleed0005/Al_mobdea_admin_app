import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExamQuestionHintCard extends StatelessWidget {
  const ExamQuestionHintCard({
    super.key,
    required this.message,
    this.bulletColor = ColorPalette.gold400,
    this.bulletSize = 10,
  });

  final String message;

  final Color bulletColor;

  final double bulletSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: ColorPalette.gold50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: ColorPalette.cream200, width: 1.w),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTextStyle.font13TextPrimaryRegularTajawal().copyWith(
                height: 1.6,
              ),
            ),
          ),
          horizontalSpace(16),
          Container(
            width: bulletSize.w,
            height: bulletSize.w,
            decoration: BoxDecoration(
              color: bulletColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

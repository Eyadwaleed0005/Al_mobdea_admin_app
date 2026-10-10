import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExamResultsWelcomeCard extends StatelessWidget {
  const ExamResultsWelcomeCard({
    super.key,
    required this.examName,
    required this.examDetailsText,
  });

  final String examName;
  final String examDetailsText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: ColorPalette.primary,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primary.withValues(alpha: 0.25),
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            examName,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.font20TextLightBoldKufam().copyWith(
              color: ColorPalette.gold200,
            ),
          ),
          verticalSpace(10),
          Text(
            examDetailsText,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.font13TextLightSemiBoldTajawal().copyWith(
              color: ColorPalette.cream200,
            ),
          ),
        ],
      ),
    );
  }
}

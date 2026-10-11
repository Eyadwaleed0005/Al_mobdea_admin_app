import 'package:al_mobdea_admin/core/helper/arabic_numbers_helper.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExamCountersRow extends StatelessWidget {
  const ExamCountersRow({
    super.key,
    required this.questionsCount,
    required this.totalDegrees,
  });

  final int questionsCount;
  final int totalDegrees;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ExamCounterCard(
              labelText: 'الدرجة النهائية',
              valueText: toArabicNumbers(totalDegrees),
              accentColor: ColorPalette.gold400,
            ),
          ),
          horizontalSpace(16),
          Expanded(
            child: ExamCounterCard(
              labelText: 'الأسئلة',
              valueText: toArabicNumbers(questionsCount),
              accentColor: ColorPalette.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class ExamCounterCard extends StatelessWidget {
  const ExamCounterCard({
    super.key,
    required this.labelText,
    required this.valueText,
    required this.accentColor,
  });

  final String labelText;
  final String valueText;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 88.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: ColorPalette.cardFill,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: ColorPalette.cream200, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryShadow,
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          verticalSpace(10),
          Text(
            valueText,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.font18PrimarySemiBoldKufam(),
          ),
          verticalSpace(4),
          Text(
            labelText,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.font13TextSecondaryRegularTajawal(),
          ),
        ],
      ),
    );
  }
}

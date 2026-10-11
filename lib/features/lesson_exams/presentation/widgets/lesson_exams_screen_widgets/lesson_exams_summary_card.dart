import 'package:al_mobdea_admin/core/helper/arabic_numbers_helper.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LessonExamsSummaryCard extends StatelessWidget {
  const LessonExamsSummaryCard({
    super.key,
    required this.questionsCount,
    required this.totalDegrees,
  });

  final int questionsCount;
  final int totalDegrees;

  String get _questionsLabel {
    if (questionsCount <= 0) {
      return 'لا توجد أسئلة بعد';
    }

    if (questionsCount == 1) {
      return 'سؤال واحد';
    }

    if (questionsCount == 2) {
      return 'سؤالان';
    }

    if (questionsCount <= 10) {
      return '${toArabicNumbers(questionsCount)} أسئلة';
    }

    return '${toArabicNumbers(questionsCount)} سؤالًا';
  }

  String get _summaryText {
    return '$_questionsLabel · مجموع الدرجات '
        '${toArabicNumbers(totalDegrees)} درجات';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 84.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: ColorPalette.gold50,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: ColorPalette.cream200, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.black.withValues(alpha: 0.06),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              _summaryText,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTextStyle.font14TextPrimaryRegularTajawal(),
            ),
          ),

          horizontalSpace(18),

          Container(
            width: 10.w,
            height: 10.w,
            decoration: const BoxDecoration(
              color: ColorPalette.secondary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:al_mobdea_admin/core/helper/arabic_numbers_helper.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:al_mobdea_admin/features/exams/presentation/widgets/view_exams_screen_widgets/exam_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditExamQuestionsCard extends StatelessWidget {
  const EditExamQuestionsCard({
    super.key,
    required this.questionsCount,
    required this.totalDegrees,
    required this.onOpenQuestionsPressed,
    this.isEnabled = true,
  });

  final int questionsCount;
  final int totalDegrees;

  final VoidCallback onOpenQuestionsPressed;

  final bool isEnabled;

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
    return '$_questionsLabel · ${toArabicNumbers(totalDegrees)} درجة';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.font16TextPrimarySemiBoldKufam(),
            ),
          ),
          horizontalSpace(14),
          CustomOutlinedActionButton(
            text: 'تعديل الأسئلة',
            onPressed: isEnabled ? onOpenQuestionsPressed : null,
          ),
        ],
      ),
    );
  }
}

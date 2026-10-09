import 'package:al_mobdea_admin/core/helper/arabic_numbers_helper.dart';
import 'package:al_mobdea_admin/core/helper/app_validator.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:al_mobdea_admin/core/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LessonExamChoicesSection extends StatelessWidget {
  const LessonExamChoicesSection({
    super.key,
    required this.choiceControllers,
    this.enabled = true,
  }) : assert(
         choiceControllers.length == 4,
         'يجب تمرير أربعة Controllers للاختيارات',
       );

  final List<TextEditingController> choiceControllers;

  final bool enabled;

  static const List<String> _choiceLabels = [
    'الاختيار الأول',
    'الاختيار الثاني',
    'الاختيار الثالث',
    'الاختيار الرابع',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: ColorPalette.surface,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'اختيارات الإجابة',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTextStyle.font16TextPrimarySemiBoldKufam().copyWith(
              fontSize: 16.sp,
              color: ColorPalette.primary,
            ),
          ),

          verticalSpace(6),

          Text(
            'أربعة اختيارات لكل سؤال، وحدد الإجابة الصحيحة من شاشة الاختبار',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTextStyle.font12TextSecondaryRegularTajawal(),
          ),

          verticalSpace(16),

          for (var index = 0; index < choiceControllers.length; index += 2) ...[
            if (index > 0) verticalSpace(14),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _ChoiceField(
                      index: index,
                      label: _choiceLabels[index],
                      controller: choiceControllers[index],
                      enabled: enabled,
                    ),
                  ),

                  horizontalSpace(12),

                  Expanded(
                    child: _ChoiceField(
                      index: index + 1,
                      label: _choiceLabels[index + 1],
                      controller: choiceControllers[index + 1],
                      enabled: enabled,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChoiceField extends StatelessWidget {
  const _ChoiceField({
    required this.index,
    required this.label,
    required this.controller,
    required this.enabled,
  });

  final int index;

  final String label;

  final TextEditingController controller;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: ColorPalette.gold100,
                shape: BoxShape.circle,
              ),
              child: Text(
                toArabicNumbers(index + 1),
                textAlign: TextAlign.center,
                style: AppTextStyle.font12TextPrimaryMediumTajawal().copyWith(
                  color: ColorPalette.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            horizontalSpace(6),

            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: AppTextStyle.font13TextPrimaryMediumTajawal(),
              ),
            ),
          ],
        ),

        verticalSpace(6),

        CustomTextFormField(
          controller: controller,
          hintText: 'اكتب $label',
          keyboardType: TextInputType.text,
          textInputAction: index == 3
              ? TextInputAction.done
              : TextInputAction.next,
          maxLength: 200,
          enabled: enabled,
          validator: AppValidator.lessonExamQuestionChoice,
        ),
      ],
    );
  }
}

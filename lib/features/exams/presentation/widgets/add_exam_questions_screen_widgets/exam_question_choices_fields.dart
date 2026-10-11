import 'package:al_mobdea_admin/core/helper/app_validator.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:al_mobdea_admin/core/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExamQuestionChoicesFields extends StatelessWidget {
  const ExamQuestionChoicesFields({
    super.key,
    required this.choiceControllers,
    this.enabled = true,
  }) : assert(
         choiceControllers.length == 4,
         'يجب تمرير أربعة Controllers للاختيارات',
       );

  final List<TextEditingController> choiceControllers;

  final bool enabled;

  static const List<String> _choiceHints = [
    'اكتب الاختيار الأول',
    'اكتب الاختيار الثاني',
    'اكتب الاختيار الثالث',
    'اكتب الاختيار الرابع',
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
            style: AppTextStyle.font16TextPrimarySemiBoldKufam(),
          ),
          verticalSpace(16),
          _buildChoicesGrid(),
        ],
      ),
    );
  }

  Widget _buildChoicesGrid() {
    final List<Widget> rows = <Widget>[];

    for (int index = 0; index < choiceControllers.length; index += 2) {
      final int firstIndex = index;

      final int secondIndex = index + 1;

      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildChoiceField(firstIndex)),
              horizontalSpace(12),
              Expanded(child: _buildChoiceField(secondIndex)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int index = 0; index < rows.length; index++) ...[
          if (index > 0) verticalSpace(12),
          rows[index],
        ],
      ],
    );
  }

  Widget _buildChoiceField(int index) {
    return CustomTextFormField(
      controller: choiceControllers[index],
      hintText: _choiceHints[index],
      keyboardType: TextInputType.text,
      textInputAction: index == choiceControllers.length - 1
          ? TextInputAction.done
          : TextInputAction.next,
      maxLength: 200,
      enabled: enabled,
      validator: AppValidator.lessonExamQuestionChoice,
    );
  }
}

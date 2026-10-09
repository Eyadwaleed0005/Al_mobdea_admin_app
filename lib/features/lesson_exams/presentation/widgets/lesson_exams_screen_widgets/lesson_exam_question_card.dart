import 'package:al_mobdea_admin/core/helper/arabic_numbers_helper.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/entities/lesson_exam_question_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LessonExamQuestionCard extends StatelessWidget {
  const LessonExamQuestionCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.selectedChoiceIndex,
    required this.onChoiceSelected,
    required this.onEditPressed,
    required this.onDeletePressed,
    this.isEnabled = true,
    this.isDeleting = false,
  });

  final LessonExamQuestionEntity question;

  final int questionNumber;

  final int? selectedChoiceIndex;

  final ValueChanged<int> onChoiceSelected;

  final VoidCallback onEditPressed;

  final VoidCallback onDeletePressed;

  final bool isEnabled;

  final bool isDeleting;

  static const int _maximumGridChoiceLength = 18;

  List<String> get _questionTextLines {
    return question.questionText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
  }

  bool get _usesTwoColumnChoices {
    final choices = question.choices;

    if (choices.length < 2 || choices.length.isOdd) {
      return false;
    }

    return choices.every((choice) {
      return choice.trim().length <= _maximumGridChoiceLength;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = question.imageUrl?.trim();

    final textLines = _questionTextLines;

    final prompt = textLines.isEmpty ? question.questionText.trim() : textLines.first;

    final highlightedText = textLines.length > 1 ? textLines.sublist(1).join(' ') : null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDeleting ? 0.65 : 1,
      child: IgnorePointer(
        ignoring: !isEnabled || isDeleting,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: ColorPalette.surface,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: ColorPalette.cream200, width: 1.w),
            boxShadow: [
              BoxShadow(
                color: ColorPalette.primaryShadow,
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _QuestionCardHeader(
                questionNumber: questionNumber,
                degree: question.degree,
                isDeleting: isDeleting,
                onEditPressed: onEditPressed,
                onDeletePressed: onDeletePressed,
              ),

              verticalSpace(16),

              Text(
                prompt,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: AppTextStyle.font14TextPrimaryMediumKufam().copyWith(height: 1.7),
              ),

              if (highlightedText != null) ...[
                verticalSpace(14),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: ColorPalette.cream100,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: ColorPalette.cream300, width: 1.w),
                  ),
                  child: Text(
                    highlightedText,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: AppTextStyle.font16TextPrimaryBoldTajawal().copyWith(
                      color: ColorPalette.primary,
                    ),
                  ),
                ),
              ],

              if (imageUrl != null && imageUrl.isNotEmpty) ...[
                verticalSpace(16),

                Container(
                  width: double.infinity,
                  height: 150.h,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: ColorPalette.primarySoftBackground,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: ColorPalette.primary.withValues(alpha: 0.08),
                      width: 1.w,
                    ),
                  ),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return Center(
                        child: SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4.w,
                            color: ColorPalette.primary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 38.sp,
                          color: ColorPalette.disabled,
                        ),
                      );
                    },
                  ),
                ),
              ],

              verticalSpace(16),

              if (_usesTwoColumnChoices)
                _TwoColumnChoices(
                  choices: question.choices,
                  selectedChoiceIndex: selectedChoiceIndex,
                  onChoiceSelected: onChoiceSelected,
                )
              else
                _SingleColumnChoices(
                  choices: question.choices,
                  selectedChoiceIndex: selectedChoiceIndex,
                  onChoiceSelected: onChoiceSelected,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TwoColumnChoices extends StatelessWidget {
  const _TwoColumnChoices({
    required this.choices,
    required this.selectedChoiceIndex,
    required this.onChoiceSelected,
  });

  final List<String> choices;
  final int? selectedChoiceIndex;
  final ValueChanged<int> onChoiceSelected;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (var index = 0; index < choices.length; index += 2) {
      final firstIndex = index;

      final secondIndex = index + 1 < choices.length ? index + 1 : null;

      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _LessonExamChoiceTile(
                  choice: choices[firstIndex],
                  isSelected: firstIndex == selectedChoiceIndex,
                  onPressed: () {
                    onChoiceSelected(firstIndex);
                  },
                ),
              ),

              horizontalSpace(12),

              if (secondIndex != null)
                Expanded(
                  child: _LessonExamChoiceTile(
                    choice: choices[secondIndex],
                    isSelected: secondIndex == selectedChoiceIndex,
                    onPressed: () {
                      onChoiceSelected(secondIndex);
                    },
                  ),
                )
              else
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < rows.length; index++) ...[
          if (index > 0) verticalSpace(10),
          rows[index],
        ],
      ],
    );
  }
}

class _SingleColumnChoices extends StatelessWidget {
  const _SingleColumnChoices({
    required this.choices,
    required this.selectedChoiceIndex,
    required this.onChoiceSelected,
  });

  final List<String> choices;
  final int? selectedChoiceIndex;
  final ValueChanged<int> onChoiceSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < choices.length; index++) ...[
          if (index > 0) verticalSpace(8),
          _LessonExamChoiceTile(
            choice: choices[index],
            isSelected: index == selectedChoiceIndex,
            onPressed: () {
              onChoiceSelected(index);
            },
          ),
        ],
      ],
    );
  }
}

class _QuestionCardHeader extends StatelessWidget {
  const _QuestionCardHeader({
    required this.questionNumber,
    required this.degree,
    required this.isDeleting,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  final int questionNumber;

  final int degree;

  final bool isDeleting;

  final VoidCallback onEditPressed;

  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'السؤال ${toArabicNumbers(questionNumber)}',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTextStyle.font18TextPrimaryBoldKufam().copyWith(fontSize: 17.sp),
            ),
          ),

          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: ColorPalette.gold100,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${toArabicNumbers(degree)} درجة',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: AppTextStyle.font12TextPrimaryMediumTajawal().copyWith(
                  color: ColorPalette.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isDeleting)
                  SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: CircularProgressIndicator(strokeWidth: 2.w, color: ColorPalette.error),
                  )
                else
                  _QuestionActionText(
                    text: 'حذف',
                    color: ColorPalette.error,
                    onPressed: onDeletePressed,
                  ),

                horizontalSpace(14),

                _QuestionActionText(
                  text: 'تعديل',
                  color: ColorPalette.primary,
                  onPressed: onEditPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionActionText extends StatelessWidget {
  const _QuestionActionText({required this.text, required this.color, required this.onPressed});

  final String text;

  final Color color;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 6.h),
          child: Text(
            text,
            style: AppTextStyle.font14PrimaryMediumTajawal().copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonExamChoiceTile extends StatelessWidget {
  const _LessonExamChoiceTile({
    required this.choice,
    required this.isSelected,
    required this.onPressed,
  });

  final String choice;

  final bool isSelected;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? ColorPalette.cream100 : Colors.transparent,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 52.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Text(
                  choice,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyle.font14TextPrimaryRegularTajawal().copyWith(
                    color: isSelected ? ColorPalette.textPrimary : ColorPalette.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),

              horizontalSpace(12),

              _AnswerIndicator(isSelected: isSelected),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerIndicator extends StatelessWidget {
  const _AnswerIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18.w,
      height: 18.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? ColorPalette.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? ColorPalette.primary : ColorPalette.cream300,
          width: 2.w,
        ),
      ),
      child: isSelected
          ? Container(
              width: 6.w,
              height: 6.w,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            )
          : null,
    );
  }
}

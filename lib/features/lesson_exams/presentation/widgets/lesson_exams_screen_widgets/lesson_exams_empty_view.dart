import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:al_mobdea_admin/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LessonExamsEmptyView extends StatelessWidget {
  const LessonExamsEmptyView({
    super.key,
    required this.onAddQuestionPressed,
    this.title = 'لا توجد أسئلة بعد',
    this.message = 'لم تتم إضافة أي أسئلة لاختبار هذا الدرس حتى الآن.',
    this.hint = 'أضف أول سؤال ليظهر هنا مع درجة واختيارات الإجابة',
    this.actionText = 'إضافة سؤال',
    this.icon = Icons.quiz_outlined,
  });

  final VoidCallback onAddQuestionPressed;

  final String title;
  final String message;
  final String hint;
  final String actionText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double minimumHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : 0;

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minimumHeight),
            child: Center(
              child: AppAnimations.emptyStateEntrance(
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: 340.h),
                  padding: EdgeInsets.fromLTRB(16.w, 34.h, 16.w, 20.h),
                  decoration: BoxDecoration(
                    color: ColorPalette.surface,
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24.r,
                        spreadRadius: 0,
                        offset: Offset(0, 8.h),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 84.w,
                        height: 84.h,
                        decoration: const BoxDecoration(
                          color: ColorPalette.gold50,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          icon,
                          size: 42.sp,
                          color: ColorPalette.primary,
                        ),
                      ),
                      verticalSpace(22),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.font18PrimarySemiBoldKufam(),
                      ),
                      verticalSpace(10),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.font13TextPrimaryRegularTajawal(),
                        ),
                      ),
                      verticalSpace(10),
                      Text(
                        hint,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.font13TextMutedRegularTajawal(),
                      ),
                      verticalSpace(24),
                      CustomButton(
                        text: actionText,
                        icon: Icons.add_rounded,
                        onPressed: onAddQuestionPressed,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

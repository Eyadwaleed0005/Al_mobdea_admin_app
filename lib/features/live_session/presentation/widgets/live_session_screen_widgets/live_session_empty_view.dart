import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:al_mobdea_admin/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LiveSessionEmptyView extends StatelessWidget {
  const LiveSessionEmptyView({super.key, required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 34.h),
              decoration: BoxDecoration(
                color: ColorPalette.surface,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: ColorPalette.border, width: 1.w),
                boxShadow: [
                  BoxShadow(
                    color: ColorPalette.textPrimary.withValues(alpha: 0.06),
                    blurRadius: 18.r,
                    offset: Offset(0, 6.h),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: const BoxDecoration(
                      color: ColorPalette.gold50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.videocam_outlined,
                      color: ColorPalette.gold500,
                      size: 31.sp,
                    ),
                  ),
                  verticalSpace(18),
                  Text(
                    'لا يوجد رابط للحصة',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: AppTextStyle.font18PrimarySemiBoldKufam(),
                  ),
                  verticalSpace(10),
                  Text(
                    'أضف رابط Google Meet أو Zoom لمشاركته مع الطلاب قبل موعد الحصة.',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: AppTextStyle.font13TextSecondaryRegularTajawal()
                        .copyWith(height: 1.7),
                  ),
                ],
              ),
            ),
            verticalSpace(28),
            CustomButton(text: 'إضافة رابط', onPressed: onAddPressed),
          ],
        ),
      ),
    );
  }
}

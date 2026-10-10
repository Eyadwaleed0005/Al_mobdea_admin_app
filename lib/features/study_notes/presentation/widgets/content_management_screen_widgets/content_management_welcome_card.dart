import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContentManagementWelcomeCard extends StatelessWidget {
  const ContentManagementWelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: ColorPalette.primary,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryShadow,
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'محتوى اللغة العربية',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTextStyle.font24PrimaryBoldKufam().copyWith(
              color: ColorPalette.highlight,
            ),
          ),
          verticalSpace(12),
          Text(
            '٢٤ درسًا • ١٢ ملزمة • ٦ وحدات دراسية',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTextStyle.font13TextPrimaryRegularTajawal().copyWith(
              color: ColorPalette.cream50.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MeetingTypeItem extends StatelessWidget {
  const MeetingTypeItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 72.h,
      decoration: BoxDecoration(
        color: isSelected
            ? ColorPalette.semanticSuccessSoftBg
            : ColorPalette.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected ? ColorPalette.primary : ColorPalette.border,
          width: isSelected ? 1.5.w : 1.w,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: ColorPalette.primarySoftBackground,
          highlightColor: ColorPalette.primarySoftBackground,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.font16TextPrimaryBoldTajawal(),
                ),
                verticalSpace(6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.font12TextSecondaryMediumTajawal()
                      .copyWith(color: ColorPalette.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

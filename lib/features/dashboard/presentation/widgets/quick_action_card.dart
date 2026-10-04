import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.title,
    this.icon,
    this.customIcon,
    Color? cardColor,
    Color? badgeColor,
    this.iconColor = Colors.white,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE5DFDC),
    required this.onTap,
  }) : badgeColor = badgeColor ?? cardColor ?? ColorPalette.primary;

  final String title;
  final IconData? icon;
  final Widget? customIcon;
  final Color badgeColor;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 1.1),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: badgeColor.withValues(alpha: 0.12),
          highlightColor: badgeColor.withValues(alpha: 0.06),
          child: Container(
            height: 74.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Row(
              textDirection: TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44.w,
                  height: 44.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child:
                      customIcon ??
                      (icon != null
                          ? Icon(icon, color: iconColor, size: 22.sp)
                          : const SizedBox.shrink()),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      title,
                      maxLines: 1,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: AppTextStyle.kufam,
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: ColorPalette.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ThreeLinesIcon extends StatelessWidget {
  const ThreeLinesIcon({super.key, this.color = Colors.white});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 15.w,
          height: 2.4.h,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2.r)),
        ),
        SizedBox(height: 3.5.h),
        Container(
          width: 15.w,
          height: 2.4.h,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2.r)),
        ),
        SizedBox(height: 3.5.h),
        Container(
          width: 15.w,
          height: 2.4.h,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2.r)),
        ),
      ],
    );
  }
}

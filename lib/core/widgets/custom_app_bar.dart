import 'package:al_mobdea_admin/app/routes/app_images_routes.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton,
    this.showProfileIcon = false,
    this.onBack,
    this.onProfileTap,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.titleColor,
    this.titleStyle,
    this.toolbarHeight,
  });

  final String title;
  final bool? showBackButton;
  final bool showProfileIcon;
  final VoidCallback? onBack;
  final VoidCallback? onProfileTap;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? titleColor;
  final TextStyle? titleStyle;
  final double? toolbarHeight;

  static const double defaultToolbarHeight = 74.0;

  @override
  Size get preferredSize => Size.fromHeight((toolbarHeight ?? defaultToolbarHeight).h);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final totalHeight = preferredSize.height + topPadding;
    final canPop = Navigator.of(context).canPop();
    final bool shouldShowBack = showBackButton ?? (canPop && !showProfileIcon);

    final barColor = backgroundColor ?? ColorPalette.primary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: SizedBox(
        height: totalHeight,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _CurvedAppBarPainter(color: barColor, topPadding: topPadding),
              ),
            ),

            Positioned(
              top: topPadding,
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    _buildLeading(context, shouldShowBack: shouldShowBack),

                    const Spacer(),
                    ...?actions,

                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(right: 8.w, left: 12.w),
                        child: Text(
                          title,
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: titleStyle ?? AppTextStyle.font18TextLightSemiBoldKufam(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context, {required bool shouldShowBack}) {
    if (leading != null) {
      return leading!;
    }

    if (showProfileIcon) {
      return Padding(
        padding: EdgeInsets.only(left: 14.w, top: 16.h),
        child: SvgPicture.asset(AppImage().profile, height: 48.h, width: 48.w),
      );
    }

    if (shouldShowBack) {
      return Padding(
        padding: EdgeInsets.only(left: 14.w),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
            customBorder: const CircleBorder(),
            child: Padding(
              padding: EdgeInsets.all(8.r),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ColorPalette.textPrimary,
                size: 22.sp,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(width: 48.w);
  }
}

class _CurvedAppBarPainter extends CustomPainter {
  const _CurvedAppBarPainter({required this.color, required this.topPadding});

  final Color color;
  final double topPadding;

  @override
  void paint(Canvas canvas, Size size) {
    final double baseline = size.height;
    final double apexY = topPadding > 0 ? (topPadding * 0.58) : 18.0;
    final double leftY = topPadding + (baseline - topPadding) * 0.62;
    final double apexX = size.width * 0.19;
    final double startX = size.width * 0.40;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, baseline)
      ..lineTo(startX, baseline)
      ..cubicTo(
        startX - (startX - apexX) * 0.50,
        baseline,
        apexX + (startX - apexX) * 0.40,
        apexY,
        apexX,
        apexY,
      )
      ..cubicTo(apexX - apexX * 0.45, apexY, apexX * 0.16, leftY - (leftY - apexY) * 0.22, 0, leftY)
      ..lineTo(0, 0)
      ..close();

    canvas.drawShadow(path, color.withValues(alpha: 0.35), 8.0, false);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvedAppBarPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.topPadding != topPadding;
  }
}

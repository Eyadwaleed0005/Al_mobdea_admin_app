import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/fontweighthelper.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavItemData {
  const BottomNavItemData({
    required this.index,
    required this.label,
    required this.iconPath,
  });

  final int index;
  final String label;
  final String iconPath;
}

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  final BottomNavItemData data;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isSelected
        ? Colors.white
        : ColorPalette.textSecondary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: data.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
            margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
            padding: EdgeInsets.symmetric(horizontal: isSelected ? 10.w : 0),
            decoration: BoxDecoration(
              color: isSelected ? ColorPalette.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: isSelected
                  ? Row(
                      key: const ValueKey<String>('selected'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _NavIcon(path: data.iconPath, color: foregroundColor),
                        horizontalSpace(7),
                        Flexible(
                          child: Text(
                            data.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                AppTextStyle.font12TextSecondaryRegularTajawal()
                                    .copyWith(
                                      color: foregroundColor,
                                      fontWeight: FontWeightHelper.bold,
                                    ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      key: const ValueKey<String>('unselected'),
                      child: _NavIcon(
                        path: data.iconPath,
                        color: foregroundColor,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.path, required this.color});

  final String path;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      width: 22.w,
      height: 22.w,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

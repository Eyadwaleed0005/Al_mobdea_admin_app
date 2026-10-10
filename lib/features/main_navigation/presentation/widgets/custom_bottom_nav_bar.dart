import 'package:al_mobdea_admin/app/routes/app_images_routes.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/features/main_navigation/presentation/cubit/bottom_navigation_cubit.dart';
import 'package:al_mobdea_admin/features/main_navigation/presentation/widgets/nav_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    this.currentIndex,
    this.onItemSelected,
    this.onTap,
  });

  final int? currentIndex;
  final ValueChanged<int>? onItemSelected;
  final ValueChanged<int>? onTap;

  static List<BottomNavItemData> get items => [
    BottomNavItemData(index: 0, label: 'الرئيسية', iconPath: AppImage().home),
    BottomNavItemData(index: 1, label: 'الطلاب', iconPath: AppImage().students),
    BottomNavItemData(
      index: 2,
      label: 'المحتوى',
      iconPath: AppImage().bookOpen,
    ),
    BottomNavItemData(
      index: 3,
      label: 'الامتحانات',
      iconPath: AppImage().exams,
    ),
    BottomNavItemData(
      index: 4,
      label: 'الحصة',
      iconPath: AppImage().liveSession,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex =
        currentIndex ?? context.watch<BottomNavigationCubit>().state;

    void handleTap(int index) {
      if (onTap != null) {
        onTap!(index);
      } else if (onItemSelected != null) {
        onItemSelected!(index);
      } else {
        context.read<BottomNavigationCubit>().changeIndex(index);
      }
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
        child: SizedBox(
          height: 62.h,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: ColorPalette.surface,
              borderRadius: BorderRadius.circular(50.r),
              boxShadow: [
                BoxShadow(
                  color: ColorPalette.cardShadow.withValues(alpha: 0.12),
                  blurRadius: 18.r,
                  offset: Offset(0, 5.h),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(5.w),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final unitWidth = constraints.maxWidth / 6;
                    var rightOffset = 0.0;
                    final positionedItems = <Widget>[];

                    for (final item in items) {
                      positionedItems.add(
                        _buildPositionedItem(
                          item: item,
                          selectedIndex: selectedIndex,
                          unitWidth: unitWidth,
                          rightOffset: rightOffset,
                          onTap: () => handleTap(item.index),
                        ),
                      );
                      rightOffset +=
                          unitWidth * (item.index == selectedIndex ? 2 : 1);
                    }

                    return Stack(
                      clipBehavior: Clip.none,
                      children: positionedItems,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPositionedItem({
    required BottomNavItemData item,
    required int selectedIndex,
    required double unitWidth,
    required double rightOffset,
    required VoidCallback onTap,
  }) {
    final isSelected = item.index == selectedIndex;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      right: rightOffset,
      top: 0,
      bottom: 0,
      width: unitWidth * (isSelected ? 2 : 1),
      child: NavItem(data: item, isSelected: isSelected, onTap: onTap),
    );
  }
}

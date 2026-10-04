import 'package:al_mobdea_admin/app/routes/app_images_routes.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:al_mobdea_admin/features/dashboard/presentation/widgets/quick_action_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({
    super.key,
    required this.onStudentsTap,
    required this.onContentTap,
    required this.onExamsTap,
    required this.onNotesTap,
  });

  final VoidCallback onStudentsTap;
  final VoidCallback onContentTap;
  final VoidCallback onExamsTap;
  final VoidCallback onNotesTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'إجراءات سريعة',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: AppTextStyle.kufam,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: ColorPalette.textPrimary,
          ),
        ),
        verticalSpace(14),

        Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: QuickActionCard(
                title: 'إضافة درس',
                customIcon: const ThreeLinesIcon(color: Colors.white),
                badgeColor: ColorPalette.gold500,
                backgroundColor: const Color(0xFFFFF9EE),
                borderColor: const Color(0xFFEDE2CF),
                onTap: onContentTap,
              ),
            ),
            horizontalSpace(12),
            Expanded(
              child: QuickActionCard(
                title: 'إضافة طالب',
                icon: Icons.add_rounded,
                badgeColor: ColorPalette.primary,
                backgroundColor: Colors.white,
                borderColor: const Color(0xFFE5DFDC),
                onTap: onStudentsTap,
              ),
            ),
          ],
        ),
        verticalSpace(12),

        Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: QuickActionCard(
                title: 'رابط البث',
                badgeColor: ColorPalette.primary,
                backgroundColor: Colors.white,
                customIcon: SvgPicture.asset(AppImage().liveSession, color: ColorPalette.accent),
                borderColor: const Color(0xFFE5DFDC),
                onTap: onNotesTap,
              ),
            ),
            horizontalSpace(12),
            Expanded(
              child: QuickActionCard(
                title: 'إنشاء اختبار',
                icon: Icons.check_rounded,
                badgeColor: ColorPalette.gold500,
                backgroundColor: const Color(0xFFFFF9EE),
                borderColor: const Color(0xFFEDE2CF),
                onTap: onExamsTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

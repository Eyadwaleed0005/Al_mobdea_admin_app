import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardLoadingSkeleton extends StatefulWidget {
  const DashboardLoadingSkeleton({super.key});

  @override
  State<DashboardLoadingSkeleton> createState() => _DashboardLoadingSkeletonState();
}

class _DashboardLoadingSkeletonState extends State<DashboardLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmerOpacity = 0.4 + 0.3 * _shimmerController.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonBox(height: 130.h, borderRadius: 20.r, opacity: shimmerOpacity),
            verticalSpace(20),
            Row(
              children: [
                Expanded(
                  child: _SkeletonBox(height: 90.h, borderRadius: 16.r, opacity: shimmerOpacity),
                ),
                horizontalSpace(12),
                Expanded(
                  child: _SkeletonBox(height: 90.h, borderRadius: 16.r, opacity: shimmerOpacity),
                ),
              ],
            ),
            verticalSpace(24),
            _SkeletonBox(height: 18.h, width: 120.w, borderRadius: 6.r, opacity: shimmerOpacity),
            verticalSpace(14),
            Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i < 3 ? 8.w : 0),
                    child: _SkeletonBox(height: 80.h, borderRadius: 16.r, opacity: shimmerOpacity),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.height,
    required this.borderRadius,
    required this.opacity,
    this.width,
  });

  final double height;
  final double borderRadius;
  final double opacity;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: ColorPalette.border.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

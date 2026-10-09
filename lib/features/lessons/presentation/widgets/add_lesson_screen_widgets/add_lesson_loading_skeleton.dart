import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddLessonLoadingSkeleton extends StatefulWidget {
  const AddLessonLoadingSkeleton({super.key});

  @override
  State<AddLessonLoadingSkeleton> createState() {
    return _AddLessonLoadingSkeletonState();
  }
}

class _AddLessonLoadingSkeletonState extends State<AddLessonLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(bottom: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLabelSkeleton(width: 90.w),

                    verticalSpace(8),

                    _buildSkeletonBox(
                      height: 56.h,
                      borderRadius: BorderRadius.circular(18.r),
                    ),

                    verticalSpace(18),

                    _buildLabelSkeleton(width: 82.w),

                    verticalSpace(8),

                    _buildSkeletonBox(
                      height: 56.h,
                      borderRadius: BorderRadius.circular(18.r),
                    ),

                    verticalSpace(20),

                    _buildOptionsSkeleton(),

                    verticalSpace(20),

                    _buildLabelSkeleton(width: 145.w),

                    verticalSpace(8),

                    _buildSkeletonBox(
                      height: 56.h,
                      borderRadius: BorderRadius.circular(18.r),
                    ),

                    verticalSpace(20),

                    _buildSkeletonBox(
                      height: 116.h,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ],
                ),
              ),
            ),

            verticalSpace(16),

            SafeArea(
              top: false,
              minimum: EdgeInsets.only(bottom: 4.h),
              child: _buildSkeletonBox(
                height: 56.h,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLabelSkeleton({required double width}) {
    return Align(
      alignment: Alignment.centerRight,
      child: _buildSkeletonBox(
        width: width,
        height: 14.h,
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }

  Widget _buildOptionsSkeleton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 300.w) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSkeletonBox(
                height: 56.h,
                borderRadius: BorderRadius.circular(18.r),
              ),

              verticalSpace(12),

              _buildSkeletonBox(
                height: 56.h,
                borderRadius: BorderRadius.circular(18.r),
              ),
            ],
          );
        }

        return Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              flex: 5,
              child: _buildSkeletonBox(
                height: 56.h,
                borderRadius: BorderRadius.circular(18.r),
              ),
            ),

            horizontalSpace(12),

            Expanded(
              flex: 4,
              child: _buildSkeletonBox(
                height: 56.h,
                borderRadius: BorderRadius.circular(18.r),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSkeletonBox({
    double? width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    final movement = _animationController.value * 3;

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8.r),
        gradient: LinearGradient(
          begin: Alignment(-1.5 + movement, 0),
          end: Alignment(-0.5 + movement, 0),
          colors: const [
            Color(0xFFEFE1E3),
            Color(0xFFFAF3F1),
            Color(0xFFEFE1E3),
          ],
          stops: const [0.2, 0.5, 0.8],
        ),
      ),
    );
  }
}

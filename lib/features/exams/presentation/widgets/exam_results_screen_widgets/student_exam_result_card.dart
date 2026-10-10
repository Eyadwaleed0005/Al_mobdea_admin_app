import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum StudentExamResultStatus { passed, failed }

class StudentExamResultViewData {
  const StudentExamResultViewData({
    required this.studentId,
    required this.studentName,
    required this.gradeName,
    required this.studentScoreText,
    required this.totalScoreText,
    required this.status,
  });

  final String studentId;
  final String studentName;
  final String gradeName;
  final String studentScoreText;
  final String totalScoreText;
  final StudentExamResultStatus status;
}

class StudentExamResultCard extends StatelessWidget {
  const StudentExamResultCard({super.key, required this.studentResult});

  final StudentExamResultViewData studentResult;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: ColorPalette.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: ColorPalette.cream200, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryShadow,
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(child: _buildStudentInformation()),
          horizontalSpace(16),
          _buildStudentScore(),
        ],
      ),
    );
  }

  Widget _buildStudentInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          studentResult.studentName,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.font16TextPrimarySemiBoldKufam(),
        ),
        verticalSpace(6),
        Text(
          studentResult.gradeName,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.font12TextSecondaryRegularTajawal(),
        ),
      ],
    );
  }

  Widget _buildStudentScore() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: _scoreBackgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        '${studentResult.totalScoreText} / '
        '${studentResult.studentScoreText}',
        textDirection: TextDirection.rtl,
        style: AppTextStyle.font15TextPrimaryBoldTajawal().copyWith(
          color: _scoreTextColor,
        ),
      ),
    );
  }

  Color get _scoreBackgroundColor {
    return switch (studentResult.status) {
      StudentExamResultStatus.passed => ColorPalette.primarySoftBackground,
      StudentExamResultStatus.failed => ColorPalette.error.withValues(
        alpha: 0.10,
      ),
    };
  }

  Color get _scoreTextColor {
    return switch (studentResult.status) {
      StudentExamResultStatus.passed => ColorPalette.primary,
      StudentExamResultStatus.failed => ColorPalette.error,
    };
  }
}

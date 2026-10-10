import 'package:al_mobdea_admin/core/helper/arabic_numbers_helper.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExamCardViewData {
  const ExamCardViewData({
    required this.examId,
    required this.examName,
    required this.gradeName,
    required this.questionCount,
    required this.totalScore,
    required this.durationMinutes,
    required this.participantsCount,
    required this.status,
    this.closedDateText,
  });

  final String examId;
  final String examName;
  final String gradeName;

  final int questionCount;
  final int totalScore;
  final int durationMinutes;
  final int participantsCount;

  final ExamStatus status;

  final String? closedDateText;
}

class ExamCard extends StatelessWidget {
  const ExamCard({
    super.key,
    required this.exam,
    this.onExamPressed,
    this.onViewResultsPressed,
  });

  final ExamCardViewData exam;

  final VoidCallback? onExamPressed;
  final VoidCallback? onViewResultsPressed;

  bool get _isExamEnded {
    return exam.status == ExamStatus.ended;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.cardBackground,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: ColorPalette.cream200, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryShadow,
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onExamPressed,
          borderRadius: BorderRadius.circular(22.r),
          splashColor: ColorPalette.primarySoftBackground,
          highlightColor: ColorPalette.primarySoftBackground,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildExamHeader(),
                verticalSpace(12),
                Text(
                  _examDetailsText,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.font13TextSecondaryRegularTajawal(),
                ),
                if (_isExamEnded) ...[
                  verticalSpace(18),
                  _buildViewResultsButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExamHeader() {
    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            exam.examName,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.font16TextPrimarySemiBoldKufam(),
          ),
        ),
        horizontalSpace(12),
        _ExamStatusBadge(status: exam.status),
      ],
    );
  }

  Widget _buildViewResultsButton() {
    return CustomOutlinedActionButton(
      text: 'عرض النتائج',
      onPressed: onViewResultsPressed,
    );
  }

  String get _examDetailsText {
    return switch (exam.status) {
      ExamStatus.ended => _endedExamDetails,
      ExamStatus.published => _publishedExamDetails,
      ExamStatus.unpublished => _unpublishedExamDetails,
    };
  }

  String get _endedExamDetails {
    final List<String> examDetails = <String>[];

    final String? closedDateText = exam.closedDateText;

    if (closedDateText != null && closedDateText.trim().isNotEmpty) {
      examDetails.add('انتهى $closedDateText');
    }

    if (exam.participantsCount > 0) {
      examDetails.add('${toArabicNumbers(exam.participantsCount)} طالبًا');
    }

    examDetails.add('${toArabicNumbers(exam.totalScore)} درجة');

    return examDetails.join(' • ');
  }

  String get _publishedExamDetails {
    return [
      exam.gradeName,
      '${toArabicNumbers(exam.questionCount)} سؤال',
      '${toArabicNumbers(exam.durationMinutes)} دقيقة',
    ].join(' • ');
  }

  String get _unpublishedExamDetails {
    return [
      exam.gradeName,
      '${toArabicNumbers(exam.questionCount)} أسئلة',
      'لم يُنشر',
    ].join(' • ');
  }
}

class _ExamStatusBadge extends StatelessWidget {
  const _ExamStatusBadge({required this.status});

  final ExamStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        _statusText,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: AppTextStyle.font12TextSecondaryMediumTajawal().copyWith(
          color: _textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String get _statusText {
    return switch (status) {
      ExamStatus.ended => 'منتهي',
      ExamStatus.published => 'منشور',
      ExamStatus.unpublished => 'غير منشور',
    };
  }

  Color get _backgroundColor {
    return switch (status) {
      ExamStatus.ended => const Color(0xFFB3261E),
      ExamStatus.published => ColorPalette.primary,
      ExamStatus.unpublished => ColorPalette.gold50,
    };
  }

  Color get _textColor {
    return switch (status) {
      ExamStatus.ended => ColorPalette.surface,
      ExamStatus.published => ColorPalette.surface,
      ExamStatus.unpublished => ColorPalette.gold500,
    };
  }
}

class CustomOutlinedActionButton extends StatelessWidget {
  const CustomOutlinedActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: ColorPalette.surface,
          foregroundColor: ColorPalette.primary,
          elevation: 0,
          side: const BorderSide(color: ColorPalette.primary, width: 1.5),
          padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 11.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.font15PrimaryBoldTajawal(),
        ),
      ),
    );
  }
}

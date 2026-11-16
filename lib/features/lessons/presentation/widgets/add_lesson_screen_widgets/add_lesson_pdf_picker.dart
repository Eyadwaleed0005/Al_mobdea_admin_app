import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:al_mobdea_admin/core/widgets/app_loading_indicator.dart';
import 'package:al_mobdea_admin/core/widgets/app_toast.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/cubit/add_lesson_pdf_picker_cubit.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/cubit/add_lesson_pdf_picker_state.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddLessonPdfPicker extends StatelessWidget {
  const AddLessonPdfPicker({
    super.key,
    required this.onFileSelected,
    required this.onFileRemoved,
  });

  final ValueChanged<PlatformFile> onFileSelected;
  final VoidCallback onFileRemoved;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddLessonPdfPickerCubit, AddLessonPdfPickerState>(
      listenWhen: (previous, current) {
        return previous.selectedFile != current.selectedFile ||
            previous.errorMessage != current.errorMessage;
      },
      listener: (context, state) {
        final cubit = context.read<AddLessonPdfPickerCubit>();

        if (state.hasFailure) {
          showAppToast(
            context,
            message: state.errorMessage!,
            icon: Icons.error_outline_rounded,
          );

          cubit.consumeFailure();
          return;
        }

        final file = state.selectedFile;

        if (file != null) {
          onFileSelected(file);
        } else {
          onFileRemoved();
        }
      },
      builder: (context, state) {
        final cubit = context.read<AddLessonPdfPickerCubit>();

        final Widget child;

        if (state.isPicking) {
          child = const _AddLessonPdfPickerLoading();
        } else if (state.selectedFile == null) {
          child = _EmptyAddLessonPdfPicker(onTap: cubit.pickPdfFile);
        } else {
          final selectedFile = state.selectedFile!;

          child = _AddLessonSelectedPdfPicker(
            key: ValueKey<String>('selected-${selectedFile.name}'),
            fileName: selectedFile.name,
            fileSize: _formatFileSize(selectedFile.size),
            onTap: cubit.pickPdfFile,
            onRemove: cubit.removeSelectedFile,
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: child,
        );
      },
    );
  }

  String _formatFileSize(int sizeInBytes) {
    final sizeInKilobytes = sizeInBytes / 1024;
    final sizeInMegabytes = sizeInKilobytes / 1024;

    if (sizeInMegabytes >= 1) {
      return '${sizeInMegabytes.toStringAsFixed(1)} MB';
    }

    return '${sizeInKilobytes.toStringAsFixed(0)} KB';
  }
}

class _EmptyAddLessonPdfPicker extends StatelessWidget {
  const _EmptyAddLessonPdfPicker({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey<String>('empty-add-lesson-pdf-picker'),
      button: true,
      label: 'اختيار ملف PDF للدرس',
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: ColorPalette.black.withValues(alpha: 0.05),
              blurRadius: 8.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            radius: Radius.circular(16.r),
            color: ColorPalette.border,
            strokeWidth: 1.5.w,
            dashPattern: [7.w, 5.w],
            padding: EdgeInsets.zero,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 116.h,
            child: Material(
              color: ColorPalette.surface,
              borderRadius: BorderRadius.circular(16.r),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16.r),
                splashColor: ColorPalette.primarySoftBackground,
                highlightColor: ColorPalette.primarySoftBackground,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 18.h,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'اسحب الملف هنا أو اختر من الجهاز',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: AppTextStyle.font14TextPrimaryRegularTajawal(),
                      ),
                      verticalSpace(12),
                      Text(
                        'ملف شرح الدرس · PDF فقط',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: AppTextStyle.font12TextSecondaryRegularTajawal(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddLessonSelectedPdfPicker extends StatelessWidget {
  const _AddLessonSelectedPdfPicker({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.onTap,
    required this.onRemove,
  });

  final String fileName;
  final String fileSize;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'ملف PDF للدرس محدد، اضغط لاستبداله',
      child: Container(
        width: double.infinity,
        height: 116.h,
        decoration: BoxDecoration(
          color: ColorPalette.primarySoftBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: ColorPalette.border, width: 1.2.w),
          boxShadow: [
            BoxShadow(
              color: ColorPalette.black.withValues(alpha: 0.06),
              blurRadius: 8.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16.r),
                  splashColor: ColorPalette.gold50,
                  highlightColor: ColorPalette.gold50,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(48.w, 18.h, 48.w, 18.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: AppTextStyle.font14TextPrimaryRegularTajawal(),
                        ),
                        verticalSpace(14),
                        Text(
                          'الملف الحالي · اضغط للاستبدال',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style:
                              AppTextStyle.font12TextSecondaryRegularTajawal(),
                        ),
                        verticalSpace(4),
                        Text(
                          fileSize,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style:
                              AppTextStyle.font12TextSecondaryRegularTajawal(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8.h,
                left: 8.w,
                child: Tooltip(
                  message: 'إزالة الملف',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(20.r),
                      splashColor: ColorPalette.error.withValues(alpha: 0.10),
                      highlightColor: ColorPalette.error.withValues(
                        alpha: 0.08,
                      ),
                      child: SizedBox(
                        width: 32.w,
                        height: 32.w,
                        child: Icon(
                          Icons.close_rounded,
                          size: 20.sp,
                          color: ColorPalette.error,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddLessonPdfPickerLoading extends StatelessWidget {
  const _AddLessonPdfPickerLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('add-lesson-pdf-picker-loading'),
      width: double.infinity,
      height: 116.h,
      decoration: BoxDecoration(
        color: ColorPalette.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ColorPalette.border, width: 1.w),
      ),
      alignment: Alignment.center,
      child: AppLoadingIndicator(
        color: ColorPalette.primary,
        size: 28.sp,
        strokeWidth: 2.w,
      ),
    );
  }
}

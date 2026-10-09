import 'package:al_mobdea_admin/core/helper/app_image_compression_helper.dart';
import 'package:al_mobdea_admin/core/helper/app_image_validator.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:al_mobdea_admin/core/widgets/app_loading_indicator.dart';
import 'package:al_mobdea_admin/core/widgets/app_toast.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/lesson_exam_question_image_file.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LessonExamImagePicker extends StatefulWidget {
  const LessonExamImagePicker({
    super.key,
    required this.selectedImage,
    required this.onImageSelected,
    required this.onImageRemoved,
    this.isEnabled = true,
  });

  final LessonExamQuestionImageFile? selectedImage;

  final ValueChanged<LessonExamQuestionImageFile> onImageSelected;

  final VoidCallback onImageRemoved;

  final bool isEnabled;

  @override
  State<LessonExamImagePicker> createState() {
    return _LessonExamImagePickerState();
  }
}

class _LessonExamImagePickerState extends State<LessonExamImagePicker> {
  bool _isPickingImage = false;

  Future<void> _pickImage() async {
    if (_isPickingImage || !widget.isEnabled) {
      return;
    }

    setState(() {
      _isPickingImage = true;
    });

    try {
      final PlatformFile? selectedFile = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: AppImageValidator.allowedExtensions,
      );

      if (!mounted || selectedFile == null) {
        return;
      }

      final originalBytes = await selectedFile.readAsBytes();

      if (!mounted) {
        return;
      }

      final validationMessage = AppImageValidator.validatePickedImage(
        fileName: selectedFile.name,
        extension: selectedFile.extension,
        sizeInBytes: selectedFile.size,
        bytes: originalBytes,
      );

      if (validationMessage != null) {
        showAppToast(
          context,
          message: validationMessage,
          icon: Icons.error_outline_rounded,
        );

        return;
      }

      final compressionResult =
          await AppImageCompressionHelper.compressForFirebase(
            bytes: originalBytes,
            originalFileName: selectedFile.name,
          );

      if (!mounted) {
        return;
      }

      final compressedValidationMessage =
          AppImageValidator.validateCompressedImage(compressionResult.bytes);

      if (compressedValidationMessage != null) {
        showAppToast(
          context,
          message: compressedValidationMessage,
          icon: Icons.error_outline_rounded,
        );

        return;
      }

      final originalPath = selectedFile.path?.trim();

      widget.onImageSelected(
        LessonExamQuestionImageFile(
          name: compressionResult.fileName,
          sizeInBytes: compressionResult.sizeInBytes,
          bytes: compressionResult.bytes,
          path: compressionResult.wasCompressed
              ? null
              : originalPath == null || originalPath.isEmpty
              ? null
              : originalPath,
        ),
      );
    } on AppImageCompressionException catch (error) {
      if (!mounted) {
        return;
      }

      showAppToast(
        context,
        message: error.message,
        icon: Icons.error_outline_rounded,
      );
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }

      showAppToast(
        context,
        message: 'تعذر اختيار أو ضغط الصورة، حاول مرة أخرى',
        icon: Icons.error_outline_rounded,
      );

      debugPrint('Add lesson exam question image picker error: $error');

      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  String _formatFileSize(int sizeInBytes) {
    final sizeInKilobytes = sizeInBytes / 1024;

    final sizeInMegabytes = sizeInKilobytes / 1024;

    if (sizeInMegabytes >= 1) {
      return '${sizeInMegabytes.toStringAsFixed(1)} MB';
    }

    return '${sizeInKilobytes.toStringAsFixed(0)} KB';
  }

  @override
  Widget build(BuildContext context) {
    final selectedImage = widget.selectedImage;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _isPickingImage
          ? const _LessonExamImagePickerLoading()
          : selectedImage == null
          ? _EmptyLessonExamImagePicker(
              isEnabled: widget.isEnabled,
              onTap: _pickImage,
            )
          : _SelectedLessonExamImagePicker(
              key: ValueKey<String>('selected-${selectedImage.name}'),
              image: selectedImage,
              formattedFileSize: _formatFileSize(selectedImage.sizeInBytes),
              isEnabled: widget.isEnabled,
              onTap: _pickImage,
              onRemove: widget.onImageRemoved,
            ),
    );
  }
}

class _LessonExamImagePickerFrame extends StatelessWidget {
  const _LessonExamImagePickerFrame({
    required this.child,
    required this.isEnabled,
    required this.onTap,
  });

  final Widget child;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      width: double.infinity,
      child: Material(
        color: ColorPalette.surface,
        borderRadius: BorderRadius.circular(18.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(18.r),
          splashColor: ColorPalette.gold50,
          highlightColor: ColorPalette.gold50,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
            child: child,
          ),
        ),
      ),
    );

    return Opacity(
      opacity: isEnabled ? 1 : 0.55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
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
            radius: Radius.circular(18.r),
            color: ColorPalette.gold300,
            strokeWidth: 1.5.w,
            dashPattern: [8.w, 6.w],
            padding: EdgeInsets.zero,
          ),
          child: content,
        ),
      ),
    );
  }
}

class _LessonExamImagePickerTitle extends StatelessWidget {
  const _LessonExamImagePickerTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      style: AppTextStyle.font16TextPrimarySemiBoldKufam().copyWith(
        fontSize: 15.sp,
        color: ColorPalette.primary,
      ),
    );
  }
}

class _LessonExamImagePickerButton extends StatelessWidget {
  const _LessonExamImagePickerButton({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: ColorPalette.primary, width: 2.w),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textDirection: TextDirection.rtl,
            style: AppTextStyle.font15PrimaryBoldTajawal(),
          ),

          horizontalSpace(8),

          Icon(Icons.add_rounded, size: 20.sp, color: ColorPalette.primary),
        ],
      ),
    );
  }
}

class _EmptyLessonExamImagePicker extends StatelessWidget {
  const _EmptyLessonExamImagePicker({
    required this.isEnabled,
    required this.onTap,
  });

  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey<String>('empty-lesson-exam-image-picker'),
      button: true,
      enabled: isEnabled,
      label: 'اختيار صورة للسؤال من الجهاز',
      child: _LessonExamImagePickerFrame(
        isEnabled: isEnabled,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _LessonExamImagePickerTitle(text: 'صورة السؤال — اختياري'),

            verticalSpace(8),

            Text(
              'الحد الأقصى '
              '${AppImageValidator.maximumPickedImageSizeInMegabytes}MB · '
              'JPG أو PNG',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: AppTextStyle.font12TextSecondaryRegularTajawal(),
            ),

            verticalSpace(16),

            const _LessonExamImagePickerButton(text: 'إضافة صورة'),
          ],
        ),
      ),
    );
  }
}

class _SelectedLessonExamImagePicker extends StatelessWidget {
  const _SelectedLessonExamImagePicker({
    super.key,
    required this.image,
    required this.formattedFileSize,
    required this.isEnabled,
    required this.onTap,
    required this.onRemove,
  });

  final LessonExamQuestionImageFile image;

  final String formattedFileSize;

  final bool isEnabled;

  final VoidCallback onTap;

  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: isEnabled,
      label: 'تم اختيار صورة للسؤال، اضغط لاستبدالها',
      child: Stack(
        children: [
          _LessonExamImagePickerFrame(
            isEnabled: isEnabled,
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: Image.memory(
                    image.bytes,
                    width: double.infinity,
                    height: 132.h,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                ),

                verticalSpace(14),

                Text(
                  image.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyle.font13TextPrimaryMediumTajawal(),
                ),

                verticalSpace(6),

                Text(
                  'الصورة جاهزة · $formattedFileSize',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyle.font12TextSecondaryRegularTajawal(),
                ),

                verticalSpace(14),

                const _LessonExamImagePickerButton(text: 'تغيير الصورة'),
              ],
            ),
          ),

          Positioned(
            top: 8.h,
            left: 8.w,
            child: Tooltip(
              message: 'حذف الصورة',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? onRemove : null,
                  borderRadius: BorderRadius.circular(20.r),
                  splashColor: ColorPalette.error.withValues(alpha: 0.10),
                  highlightColor: ColorPalette.error.withValues(alpha: 0.08),
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
    );
  }
}

class _LessonExamImagePickerLoading extends StatelessWidget {
  const _LessonExamImagePickerLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('lesson-exam-image-picker-loading'),
      width: double.infinity,
      height: 168.h,
      decoration: BoxDecoration(
        color: ColorPalette.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: ColorPalette.cream200, width: 1.w),
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

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

class EditLessonExamImagePicker extends StatefulWidget {
  const EditLessonExamImagePicker({
    super.key,
    required this.selectedImage,
    required this.onImageSelected,
    required this.onImageRemoved,
    this.currentImageUrl,
    this.isCurrentImageRemoved = false,
    this.isEnabled = true,
  });

  final LessonExamQuestionImageFile? selectedImage;

  final String? currentImageUrl;

  final bool isCurrentImageRemoved;

  final ValueChanged<LessonExamQuestionImageFile> onImageSelected;

  final VoidCallback onImageRemoved;

  final bool isEnabled;

  @override
  State<EditLessonExamImagePicker> createState() {
    return _EditLessonExamImagePickerState();
  }
}

class _EditLessonExamImagePickerState extends State<EditLessonExamImagePicker> {
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

      debugPrint('Edit lesson exam question image picker error: $error');

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

    final normalizedCurrentImageUrl = widget.currentImageUrl?.trim();

    final hasCurrentImage =
        normalizedCurrentImageUrl != null &&
        normalizedCurrentImageUrl.isNotEmpty &&
        !widget.isCurrentImageRemoved;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _isPickingImage
          ? const _EditLessonExamImagePickerLoading()
          : selectedImage != null
          ? _EditSelectedLessonExamImagePicker(
              key: ValueKey<String>('selected-${selectedImage.name}'),
              image: selectedImage,
              formattedFileSize: _formatFileSize(selectedImage.sizeInBytes),
              isEnabled: widget.isEnabled,
              onTap: _pickImage,
              onRemove: widget.onImageRemoved,
            )
          : hasCurrentImage
          ? _CurrentLessonExamImagePicker(
              key: ValueKey<String>('current-$normalizedCurrentImageUrl'),
              imageUrl: normalizedCurrentImageUrl,
              isEnabled: widget.isEnabled,
              onTap: _pickImage,
              onRemove: widget.onImageRemoved,
            )
          : _EmptyEditLessonExamImagePicker(
              isEnabled: widget.isEnabled,
              onTap: _pickImage,
            ),
    );
  }
}

class _EditLessonExamImagePickerFrame extends StatelessWidget {
  const _EditLessonExamImagePickerFrame({
    required this.child,
    required this.isEnabled,
    required this.onTap,
  });

  final Widget child;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          child: SizedBox(
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 18.h,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditLessonExamImagePickerButton extends StatelessWidget {
  const _EditLessonExamImagePickerButton({required this.text});

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

class _EditLessonExamImagePickerTitle extends StatelessWidget {
  const _EditLessonExamImagePickerTitle({required this.text});

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

class _EditLessonExamImagePickerHint extends StatelessWidget {
  const _EditLessonExamImagePickerHint();

  @override
  Widget build(BuildContext context) {
    return Text(
      'الحد الأقصى '
      '${AppImageValidator.maximumPickedImageSizeInMegabytes}MB · '
      'JPG أو PNG',
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      style: AppTextStyle.font12TextSecondaryRegularTajawal(),
    );
  }
}

class _EmptyEditLessonExamImagePicker extends StatelessWidget {
  const _EmptyEditLessonExamImagePicker({
    required this.isEnabled,
    required this.onTap,
  });

  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey<String>('empty-edit-lesson-exam-image-picker'),
      button: true,
      enabled: isEnabled,
      label: 'اختيار صورة للسؤال من الجهاز',
      child: _EditLessonExamImagePickerFrame(
        isEnabled: isEnabled,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _EditLessonExamImagePickerTitle(
              text: 'صورة السؤال — اختياري',
            ),

            verticalSpace(8),

            const _EditLessonExamImagePickerHint(),

            verticalSpace(16),

            const _EditLessonExamImagePickerButton(text: 'إضافة صورة'),
          ],
        ),
      ),
    );
  }
}

class _EditSelectedLessonExamImagePicker extends StatelessWidget {
  const _EditSelectedLessonExamImagePicker({
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
    return Stack(
      children: [
        _EditLessonExamImagePickerFrame(
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
                'الصورة الجديدة جاهزة · $formattedFileSize',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: AppTextStyle.font12TextSecondaryRegularTajawal(),
              ),

              verticalSpace(14),

              const _EditLessonExamImagePickerButton(text: 'تغيير الصورة'),
            ],
          ),
        ),

        _RemoveImageButton(isEnabled: isEnabled, onRemove: onRemove),
      ],
    );
  }
}

class _CurrentLessonExamImagePicker extends StatelessWidget {
  const _CurrentLessonExamImagePicker({
    super.key,
    required this.imageUrl,
    required this.isEnabled,
    required this.onTap,
    required this.onRemove,
  });

  final String imageUrl;

  final bool isEnabled;

  final VoidCallback onTap;

  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _EditLessonExamImagePickerFrame(
          isEnabled: isEnabled,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 132.h,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return Container(
                      width: double.infinity,
                      height: 132.h,
                      color: ColorPalette.gold50,
                      alignment: Alignment.center,
                      child: AppLoadingIndicator(
                        color: ColorPalette.primary,
                        size: 26.sp,
                        strokeWidth: 2.w,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 132.h,
                      color: ColorPalette.gold50,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 34.sp,
                        color: ColorPalette.textSecondary,
                      ),
                    );
                  },
                ),
              ),

              verticalSpace(14),

              const _EditLessonExamImagePickerTitle(
                text: 'صورة السؤال الحالية — يمكنك تغييرها',
              ),

              verticalSpace(8),

              const _EditLessonExamImagePickerHint(),

              verticalSpace(14),

              const _EditLessonExamImagePickerButton(text: 'تغيير الصورة'),
            ],
          ),
        ),

        _RemoveImageButton(isEnabled: isEnabled, onRemove: onRemove),
      ],
    );
  }
}

class _RemoveImageButton extends StatelessWidget {
  const _RemoveImageButton({required this.isEnabled, required this.onRemove});

  final bool isEnabled;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
    );
  }
}

class _EditLessonExamImagePickerLoading extends StatelessWidget {
  const _EditLessonExamImagePickerLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('edit-lesson-exam-image-picker-loading'),
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

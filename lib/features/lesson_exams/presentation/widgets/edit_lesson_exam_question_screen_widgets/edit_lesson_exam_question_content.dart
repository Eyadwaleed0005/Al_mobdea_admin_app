import 'package:al_mobdea_admin/core/helper/app_validator.dart';
import 'package:al_mobdea_admin/core/helper/arabic_numbers_helper.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:al_mobdea_admin/core/widgets/custom_button.dart';
import 'package:al_mobdea_admin/core/widgets/custom_secondary_button.dart';
import 'package:al_mobdea_admin/core/widgets/custom_text_form_field.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/entities/lesson_exam_question_entity.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/lesson_exam_question_image_file.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/widgets/add_lesson_exam_question_screen_widgets/lesson_exam_choices_section.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/widgets/edit_lesson_exam_question_screen_widgets/edit_lesson_exam_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef EditLessonExamQuestionSubmit = Future<void> Function({
  required String questionText,
  required int degree,
  required List<String> choices,
  LessonExamQuestionImageFile? newImage,
  required bool removeCurrentImage,
});

class EditLessonExamQuestionContent extends StatefulWidget {
  const EditLessonExamQuestionContent({
    super.key,
    required this.question,
    required this.onUpdateQuestionPressed,
    this.questionNumber,
    this.isUpdatingQuestion = false,
  });

  final LessonExamQuestionEntity question;

  final EditLessonExamQuestionSubmit onUpdateQuestionPressed;

  final int? questionNumber;

  final bool isUpdatingQuestion;

  @override
  State<EditLessonExamQuestionContent> createState() {
    return _EditLessonExamQuestionContentState();
  }
}

class _EditLessonExamQuestionContentState
    extends State<EditLessonExamQuestionContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _questionController;
  late final TextEditingController _degreeController;

  late final List<TextEditingController> _choiceControllers;

  LessonExamQuestionImageFile? _selectedImage;

  bool _removeCurrentImage = false;

  String get _hintMessage {
    final questionNumber = widget.questionNumber;

    final questionLabel = questionNumber == null
        ? 'تعديل السؤال'
        : 'تعديل السؤال ${toArabicNumbers(questionNumber)}';

    return '$questionLabel · راجع البيانات ثم احفظ التعديلات';
  }

  bool get _hasChanges {
    if (_questionController.text.trim() !=
        widget.question.questionText.trim()) {
      return true;
    }

    final currentDegree = int.tryParse(_degreeController.text.trim());

    if (currentDegree != widget.question.degree) {
      return true;
    }

    for (var index = 0; index < _choiceControllers.length; index++) {
      final currentChoice = _choiceControllers[index].text.trim();

      final originalChoice = index < widget.question.choices.length
          ? widget.question.choices[index].trim()
          : '';

      if (currentChoice != originalChoice) {
        return true;
      }
    }

    if (_selectedImage != null) {
      return true;
    }

    return _removeCurrentImage;
  }

  @override
  void initState() {
    super.initState();

    _questionController = TextEditingController(
      text: widget.question.questionText,
    );

    _degreeController = TextEditingController(
      text: widget.question.degree.toString(),
    );

    _choiceControllers = List.generate(4, (index) {
      final choice = index < widget.question.choices.length
          ? widget.question.choices[index]
          : '';

      return TextEditingController(text: choice);
    });

    _questionController.addListener(_onFormValueChanged);
    _degreeController.addListener(_onFormValueChanged);

    for (final controller in _choiceControllers) {
      controller.addListener(_onFormValueChanged);
    }
  }

  void _onFormValueChanged() {
    if (!mounted || widget.isUpdatingQuestion) {
      return;
    }

    setState(() {});
  }

  void _selectImage(LessonExamQuestionImageFile image) {
    if (widget.isUpdatingQuestion) {
      return;
    }

    setState(() {
      _selectedImage = image;
      _removeCurrentImage = false;
    });
  }

  void _removeImage() {
    if (widget.isUpdatingQuestion) {
      return;
    }

    setState(() {
      if (_selectedImage != null) {
        _selectedImage = null;
        _removeCurrentImage = false;
        return;
      }

      final currentImageUrl = widget.question.imageUrl?.trim();

      if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
        _removeCurrentImage = true;
      }
    });
  }

  Future<void> _updateQuestion() async {
    if (widget.isUpdatingQuestion || !_hasChanges) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      return;
    }

    final degree = int.tryParse(_degreeController.text.trim());

    if (degree == null) {
      return;
    }

    final choices = _choiceControllers
        .map((controller) => controller.text.trim())
        .toList(growable: false);

    await widget.onUpdateQuestionPressed(
      questionText: _questionController.text.trim(),
      degree: degree,
      choices: choices,
      newImage: _selectedImage,
      removeCurrentImage: _removeCurrentImage,
    );
  }

  void _cancel() {
    if (widget.isUpdatingQuestion) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _degreeController.dispose();

    for (final controller in _choiceControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fieldsEnabled = !widget.isUpdatingQuestion;

    final canSave = _hasChanges && fieldsEnabled;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppAnimations.screenSection(
              delay: 0,
              child: _EditLessonExamQuestionHintCard(message: _hintMessage),
            ),

            verticalSpace(20),

            AppAnimations.formFieldEntrance(
              order: 0,
              child: CustomTextFormField(
                controller: _questionController,
                labelText: 'نص السؤال',
                hintText: 'اكتب السؤال هنا',
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 2,
                maxLines: 4,
                maxLength: 500,
                enabled: fieldsEnabled,
                validator: AppValidator.lessonExamQuestionText,
              ),
            ),

            verticalSpace(20),

            AppAnimations.formFieldEntrance(
              order: 1,
              child: EditLessonExamImagePicker(
                selectedImage: _selectedImage,
                currentImageUrl: widget.question.imageUrl,
                isCurrentImageRemoved: _removeCurrentImage,
                isEnabled: fieldsEnabled,
                onImageSelected: _selectImage,
                onImageRemoved: _removeImage,
              ),
            ),

            verticalSpace(20),

            AppAnimations.formFieldEntrance(
              order: 2,
              child: CustomTextFormField(
                controller: _degreeController,
                labelText: 'درجة السؤال',
                hintText: 'مثال: ٢',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: fieldsEnabled,
                validator: AppValidator.lessonExamQuestionDegree,
              ),
            ),

            verticalSpace(20),

            AppAnimations.formFieldEntrance(
              order: 3,
              child: LessonExamChoicesSection(
                choiceControllers: _choiceControllers,
                enabled: fieldsEnabled,
              ),
            ),

            verticalSpace(24),

            AppAnimations.screenSection(
              delay: 420,
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'حفظ التعديلات',
                      isLoading: widget.isUpdatingQuestion,
                      isEnabled: canSave,
                      onPressed: _updateQuestion,
                    ),
                  ),

                  horizontalSpace(12),

                  Expanded(
                    child: CustomSecondaryButton(
                      text: 'إلغاء',
                      isEnabled: fieldsEnabled,
                      onPressed: _cancel,
                    ),
                  ),
                ],
              ),
            ),

            verticalSpace(8),
          ],
        ),
      ),
    );
  }
}

class _EditLessonExamQuestionHintCard extends StatelessWidget {
  const _EditLessonExamQuestionHintCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: ColorPalette.gold50,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: ColorPalette.cream200, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.black.withValues(alpha: 0.05),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTextStyle.font13TextPrimaryMediumTajawal(),
            ),
          ),

          horizontalSpace(14),

          Container(
            width: 10.w,
            height: 10.w,
            decoration: const BoxDecoration(
              color: ColorPalette.gold400,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:al_mobdea_admin/core/helper/app_validator.dart';
import 'package:al_mobdea_admin/core/helper/arabic_numbers_helper.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/widgets/custom_button.dart';
import 'package:al_mobdea_admin/core/widgets/custom_secondary_button.dart';
import 'package:al_mobdea_admin/core/widgets/custom_text_form_field.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/lesson_exam_question_image_file.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/widgets/add_lesson_exam_question_screen_widgets/lesson_exam_choices_section.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/widgets/add_lesson_exam_question_screen_widgets/lesson_exam_image_picker.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/widgets/add_lesson_exam_question_screen_widgets/lesson_exam_question_hint_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef AddLessonExamQuestionSubmit = Future<void> Function({
  required String questionText,
  required int degree,
  required List<String> choices,
  LessonExamQuestionImageFile? image,
});

class AddLessonExamQuestionContent extends StatefulWidget {
  const AddLessonExamQuestionContent({
    super.key,
    required this.onAddQuestionPressed,
    this.questionNumber,
    this.isAddingQuestion = false,
  });

  final AddLessonExamQuestionSubmit onAddQuestionPressed;

  final int? questionNumber;

  final bool isAddingQuestion;

  @override
  State<AddLessonExamQuestionContent> createState() {
    return _AddLessonExamQuestionContentState();
  }
}

class _AddLessonExamQuestionContentState
    extends State<AddLessonExamQuestionContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _questionController;

  late final TextEditingController _degreeController;

  late final List<TextEditingController> _choiceControllers;

  LessonExamQuestionImageFile? _selectedImage;

  String get _hintMessage {
    final questionNumber = widget.questionNumber;

    final questionLabel = questionNumber == null
        ? 'سؤال جديد'
        : 'السؤال ${toArabicNumbers(questionNumber)}';

    return '$questionLabel · الصورة اختيارية · حدد درجة السؤال';
  }

  @override
  void initState() {
    super.initState();

    _questionController = TextEditingController();

    _degreeController = TextEditingController();

    _choiceControllers = List.generate(4, (_) => TextEditingController());
  }

  void _selectImage(LessonExamQuestionImageFile image) {
    if (widget.isAddingQuestion) {
      return;
    }

    setState(() {
      _selectedImage = image;
    });
  }

  void _removeImage() {
    if (widget.isAddingQuestion) {
      return;
    }

    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _addQuestion() async {
    if (widget.isAddingQuestion) {
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

    await widget.onAddQuestionPressed(
      questionText: _questionController.text.trim(),
      degree: degree,
      choices: choices,
      image: _selectedImage,
    );
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
    final fieldsEnabled = !widget.isAddingQuestion;

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
              child: LessonExamQuestionHintCard(message: _hintMessage),
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
              child: LessonExamImagePicker(
                selectedImage: _selectedImage,
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
                      text: 'إضافة السؤال',
                      isLoading: widget.isAddingQuestion,
                      isEnabled: fieldsEnabled,
                      onPressed: _addQuestion,
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

  void _cancel() {
    if (widget.isAddingQuestion) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context).maybePop();
  }
}

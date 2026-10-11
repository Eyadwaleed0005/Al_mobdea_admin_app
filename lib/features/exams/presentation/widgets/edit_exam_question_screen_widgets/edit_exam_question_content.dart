import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_network_aware_content.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:al_mobdea_admin/core/widgets/custom_operation_result_dialog.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_question_draft_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_question_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/exam_question_image_file.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/edit_exam_question_cubit.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/edit_exam_question_state.dart';
import 'package:al_mobdea_admin/features/exams/presentation/widgets/edit_exam_question_screen_widgets/edit_exam_question_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditExamQuestionContent extends StatefulWidget {
  const EditExamQuestionContent({super.key, required this.questionDraft});

  final ExamQuestionDraftEntity questionDraft;

  @override
  State<EditExamQuestionContent> createState() {
    return _EditExamQuestionContentState();
  }
}

class _EditExamQuestionContentState extends State<EditExamQuestionContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _questionController;
  late final TextEditingController _degreeController;
  late final List<TextEditingController> _choiceControllers;

  ExamQuestionImageFile? _selectedImage;

  bool _removeCurrentImage = false;
  bool _imageChanged = false;
  bool _isErrorDialogOpen = false;

  ExamQuestionEntity get _question => widget.questionDraft.question;

  bool get _hasChanges {
    if (_questionController.text.trim() != _question.questionText.trim()) {
      return true;
    }

    final currentDegree = int.tryParse(_degreeController.text.trim());

    if (currentDegree != _question.degree) {
      return true;
    }

    for (var index = 0; index < _choiceControllers.length; index++) {
      final currentChoice = _choiceControllers[index].text.trim();

      final originalChoice = index < _question.choices.length
          ? _question.choices[index].trim()
          : '';

      if (currentChoice != originalChoice) {
        return true;
      }
    }

    return _imageChanged;
  }

  @override
  void initState() {
    super.initState();

    _questionController = TextEditingController(text: _question.questionText);

    _degreeController = TextEditingController(
      text: _question.degree.toString(),
    );

    _choiceControllers = List<TextEditingController>.generate(4, (index) {
      final choice = index < _question.choices.length
          ? _question.choices[index]
          : '';

      return TextEditingController(text: choice);
    });

    _selectedImage = widget.questionDraft.image;

    _questionController.addListener(_onFormValueChanged);
    _degreeController.addListener(_onFormValueChanged);

    for (final controller in _choiceControllers) {
      controller.addListener(_onFormValueChanged);
    }
  }

  @override
  void dispose() {
    _questionController.removeListener(_onFormValueChanged);
    _degreeController.removeListener(_onFormValueChanged);

    _questionController.dispose();
    _degreeController.dispose();

    for (final controller in _choiceControllers) {
      controller.removeListener(_onFormValueChanged);
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditExamQuestionCubit, EditExamQuestionState>(
      listenWhen: (previous, current) {
        return current is EditExamQuestionSuccess ||
            current is EditExamQuestionFailure;
      },
      listener: _handleState,
      builder: (context, state) {
        final isUpdating = state is EditExamQuestionLoading;

        return PopScope(
          canPop: !isUpdating,
          child: AbsorbPointer(
            absorbing: isUpdating,
            child: _buildScaffold(isUpdatingQuestion: isUpdating),
          ),
        );
      },
    );
  }

  Future<void> _handleState(
    BuildContext context,
    EditExamQuestionState state,
  ) async {
    if (state is EditExamQuestionSuccess) {
      Navigator.of(context).pop(state.questionDraft);
      return;
    }

    if (state is! EditExamQuestionFailure || _isErrorDialogOpen) {
      return;
    }

    _isErrorDialogOpen = true;

    try {
      await showDialog<void>(
        context: context,
        useRootNavigator: false,
        barrierDismissible: false,
        builder: (dialogContext) {
          return PopScope(
            canPop: false,
            child: CustomOperationResultDialog(
              type: CustomOperationResultType.failure,
              title: 'تعذر تعديل السؤال',
              message: state.error.message,
              actionText: 'العودة للتعديل',
              failureIcon: Icons.error_outline_rounded,
              onActionPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          );
        },
      );
    } finally {
      _isErrorDialogOpen = false;
    }
  }

  Widget _buildScaffold({required bool isUpdatingQuestion}) {
    return Scaffold(
      appBar: const CustomHeaderBar(
        title: 'تعديل سؤال الاختبار العام',
        showBackButton: true,
      ),
      backgroundColor: ColorPalette.background,
      body: BackgroundStudentLayout(
        child: SafeArea(
          top: false,
          child: AppNetworkAwareContent(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: AppAnimations.screenSection(
                      delay: 120,
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: EditExamQuestionForm(
                            questionController: _questionController,
                            degreeController: _degreeController,
                            choiceControllers: _choiceControllers,
                            selectedImage: _selectedImage,
                            currentImageUrl: _question.imageUrl,
                            isCurrentImageRemoved: _removeCurrentImage,
                            hasChanges: _hasChanges,
                            isUpdatingQuestion: isUpdatingQuestion,
                            onImageSelected: _selectImage,
                            onImageRemoved: _removeImage,
                            onUpdateQuestionPressed: _updateQuestion,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onFormValueChanged() {
    if (!mounted) {
      return;
    }

    final state = context.read<EditExamQuestionCubit>().state;

    if (state is EditExamQuestionLoading) {
      return;
    }

    setState(() {});
  }

  void _selectImage(ExamQuestionImageFile selectedImage) {
    final state = context.read<EditExamQuestionCubit>().state;

    if (state is EditExamQuestionLoading) {
      return;
    }

    setState(() {
      _selectedImage = selectedImage;
      _removeCurrentImage = false;
      _imageChanged = true;
    });
  }

  void _removeImage() {
    final state = context.read<EditExamQuestionCubit>().state;

    if (state is EditExamQuestionLoading) {
      return;
    }

    final hasLocalImage = _selectedImage != null;
    final hasOriginalLocalImage = widget.questionDraft.image != null;
    final hasRemoteImage = _question.hasImage;

    if (!hasLocalImage && !hasOriginalLocalImage && !hasRemoteImage) {
      return;
    }

    setState(() {
      _selectedImage = null;
      _removeCurrentImage = hasOriginalLocalImage || hasRemoteImage;
      _imageChanged = true;
    });
  }

  Future<void> _updateQuestion() async {
    final state = context.read<EditExamQuestionCubit>().state;

    if (state is EditExamQuestionLoading || !_hasChanges) {
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

    final newImage = _imageChanged && !_removeCurrentImage
        ? _selectedImage
        : null;

    await context.read<EditExamQuestionCubit>().updateQuestion(
      questionText: _questionController.text.trim(),
      degree: degree,
      choices: choices,
      newImage: newImage,
      removeCurrentImage: _removeCurrentImage,
    );
  }
}

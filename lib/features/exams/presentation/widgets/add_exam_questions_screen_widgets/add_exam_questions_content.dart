import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_network_aware_content.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_draft_entity.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/add_exam_question_cubit.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/add_exam_question_state.dart';
import 'package:al_mobdea_admin/features/exams/presentation/widgets/add_exam_questions_screen_widgets/add_exam_question_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddExamQuestionsContent extends StatelessWidget {
  const AddExamQuestionsContent({super.key, required this.examDraft});

  final ExamDraftEntity examDraft;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeaderBar(
        title: 'إضافة سؤال للاختبار العام',
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
                    child:
                        BlocConsumer<
                          AddExamQuestionCubit,
                          AddExamQuestionState
                        >(
                          listenWhen: (previous, current) {
                            return current is AddExamQuestionSuccess;
                          },
                          listener: (context, state) {
                            if (state is AddExamQuestionSuccess) {
                              Navigator.of(context).pop(state.questionDraft);
                            }
                          },
                          builder: (context, state) {
                            return _buildContent(
                              context: context,
                              state: state,
                            );
                          },
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

  Widget _buildContent({
    required BuildContext context,
    required AddExamQuestionState state,
  }) {
    final isLoading = state is AddExamQuestionLoading;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: AddExamQuestionForm(
        isAddingQuestion: isLoading,
        onAddQuestionPressed:
            ({
              required String questionText,
              required int questionDegree,
              required List<String> choices,
              image,
            }) {
              context.read<AddExamQuestionCubit>().addQuestion(
                questionText: questionText,
                questionDegree: questionDegree,
                choices: choices,
                image: image,
              );
            },
      ),
    );
  }
}

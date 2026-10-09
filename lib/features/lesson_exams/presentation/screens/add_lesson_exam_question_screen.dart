import 'package:al_mobdea_admin/core/helper/app_system_ui.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_network_aware_content.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/cubit/add_lesson_exam_question_cubit.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/cubit/add_lesson_exam_question_state.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/widgets/add_lesson_exam_question_screen_widgets/add_lesson_exam_question_content.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/widgets/add_lesson_exam_question_screen_widgets/add_lesson_exam_question_feedback_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddLessonExamQuestionScreen extends StatelessWidget {
  const AddLessonExamQuestionScreen({
    super.key,
    required this.lessonId,
    this.questionNumber,
  });

  final String lessonId;

  final int? questionNumber;

  @override
  Widget build(BuildContext context) {
    return AddLessonExamQuestionFeedbackListener(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppSystemUi.light(),
        child: SafeArea(
          bottom: false,
          child: Scaffold(
            appBar: const CustomHeaderBar(title: 'إضافة سؤال لاختبار الدرس'),
            backgroundColor: ColorPalette.background,
            body: BackgroundStudentLayout(
              child: SafeArea(
                child: AppNetworkAwareContent(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child:
                              BlocBuilder<
                                AddLessonExamQuestionCubit,
                                AddLessonExamQuestionState
                              >(
                                builder: (context, state) {
                                  final isAddingQuestion =
                                      state is AddLessonExamQuestionLoading;

                                  return AddLessonExamQuestionContent(
                                    questionNumber: questionNumber,
                                    isAddingQuestion: isAddingQuestion,
                                    onAddQuestionPressed:
                                        ({
                                          required questionText,
                                          required degree,
                                          required choices,
                                          image,
                                        }) {
                                          return context
                                              .read<
                                                AddLessonExamQuestionCubit
                                              >()
                                              .addQuestion(
                                                lessonId: lessonId,
                                                questionText: questionText,
                                                degree: degree,
                                                choices: choices,
                                                image: image,
                                              );
                                        },
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
          ),
        ),
      ),
    );
  }
}

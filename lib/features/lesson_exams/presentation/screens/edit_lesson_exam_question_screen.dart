import 'package:al_mobdea_admin/core/helper/app_system_ui.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_network_aware_content.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/entities/lesson_exam_question_entity.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/cubit/edit_lesson_exam_question_cubit.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/cubit/edit_lesson_exam_question_state.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/widgets/edit_lesson_exam_question_screen_widgets/edit_lesson_exam_question_content.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/widgets/edit_lesson_exam_question_screen_widgets/edit_lesson_exam_question_feedback_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditLessonExamQuestionScreen extends StatelessWidget {
  const EditLessonExamQuestionScreen({
    super.key,
    required this.question,
    this.questionNumber,
  });

  final LessonExamQuestionEntity question;

  final int? questionNumber;

  @override
  Widget build(BuildContext context) {
    return EditLessonExamQuestionFeedbackListener(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppSystemUi.light(),
        child: SafeArea(
          bottom: false,
          child: Scaffold(
            appBar: const CustomHeaderBar(title: 'تعديل سؤال اختبار الدرس'),
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
                                EditLessonExamQuestionCubit,
                                EditLessonExamQuestionState
                              >(
                                builder: (context, state) {
                                  final isUpdatingQuestion =
                                      state is EditLessonExamQuestionLoading;

                                  return EditLessonExamQuestionContent(
                                    question: question,
                                    questionNumber: questionNumber,
                                    isUpdatingQuestion: isUpdatingQuestion,
                                    onUpdateQuestionPressed:
                                        ({
                                          required questionText,
                                          required degree,
                                          required choices,
                                          newImage,
                                          required removeCurrentImage,
                                        }) {
                                          return context
                                              .read<
                                                EditLessonExamQuestionCubit
                                              >()
                                              .updateQuestion(
                                                lessonId: question.lessonId,
                                                questionId: question.questionId,
                                                questionText: questionText,
                                                degree: degree,
                                                choices: choices,
                                                newImage: newImage,
                                                removeCurrentImage:
                                                    removeCurrentImage,
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

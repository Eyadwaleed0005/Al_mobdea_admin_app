import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/widgets/custom_button.dart';
import 'package:al_mobdea_admin/core/widgets/custom_secondary_button.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/entities/lesson_exam_question_entity.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/cubit/lesson_exams_state.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/widgets/lesson_exams_screen_widgets/lesson_exam_question_card.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/widgets/lesson_exams_screen_widgets/lesson_exams_summary_card.dart';
import 'package:flutter/material.dart';

typedef LessonExamChoiceSelected = void Function(
  LessonExamQuestionEntity question,
  int choiceIndex,
);

class LessonExamsContent extends StatelessWidget {
  const LessonExamsContent({
    super.key,
    required this.state,
    required this.onChoiceSelected,
    required this.onDeleteQuestion,
    required this.onEditQuestion,
    required this.onSaveExamPressed,
    required this.onAddQuestionPressed,
  });

  final LessonExamsState state;

  final LessonExamChoiceSelected onChoiceSelected;

  final ValueChanged<LessonExamQuestionEntity> onDeleteQuestion;

  final ValueChanged<LessonExamQuestionEntity> onEditQuestion;

  final VoidCallback onSaveExamPressed;

  final VoidCallback onAddQuestionPressed;

  String get _primaryButtonText {
    if (state.persistedCorrectChoiceIndexes.isEmpty) {
      return 'حفظ الاختبار';
    }

    return 'حفظ التعديلات';
  }

  @override
  Widget build(BuildContext context) {
    final questions = state.exam.questions;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppAnimations.screenSection(
            delay: 0,
            child: LessonExamsSummaryCard(
              questionsCount: state.questionsCount,
              totalDegrees: state.totalDegrees,
            ),
          ),

          verticalSpace(20),
          for (var index = 0; index < questions.length; index++) ...[
            AppAnimations.formFieldEntrance(
              order: index,
              child: LessonExamQuestionCard(
                question: questions[index],
                questionNumber: index + 1,
                selectedChoiceIndex:
                    state.selectedCorrectChoiceIndexes[questions[index].questionId],
                isEnabled: !state.isActionInProgress,
                isDeleting: state.isQuestionDeleting(questions[index].questionId),
                onChoiceSelected: (choiceIndex) {
                  onChoiceSelected(questions[index], choiceIndex);
                },
                onEditPressed: () {
                  onEditQuestion(questions[index]);
                },
                onDeletePressed: () {
                  onDeleteQuestion(questions[index]);
                },
              ),
            ),

            verticalSpace(16),
          ],

          verticalSpace(8),

          AppAnimations.screenSection(
            delay: 360,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: CustomButton(
                    text: _primaryButtonText,
                    isLoading: state.isSavingAnswers,
                    isEnabled: state.canSaveAnswers,
                    onPressed: onSaveExamPressed,
                  ),
                ),

                horizontalSpace(12),

                Expanded(
                  child: CustomSecondaryButton(
                    text: 'إضافة سؤال',
                    isEnabled: !state.isActionInProgress,
                    onPressed: onAddQuestionPressed,
                  ),
                ),
              ],
            ),
          ),

          verticalSpace(20),
        ],
      ),
    );
  }
}

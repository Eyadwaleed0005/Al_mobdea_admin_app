import 'package:al_mobdea_admin/app/routes/route_names.dart';
import 'package:al_mobdea_admin/core/widgets/app_error_widget.dart';
import 'package:al_mobdea_admin/core/widgets/custom_delete_confirmation_bottom_sheet.dart';
import 'package:al_mobdea_admin/core/widgets/custom_operation_result_dialog.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/entities/lesson_exam_question_entity.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/cubit/lesson_exams_cubit.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/cubit/lesson_exams_state.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/widgets/lesson_exams_screen_widgets/lesson_exams_content.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/widgets/lesson_exams_screen_widgets/lesson_exams_empty_view.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/widgets/lesson_exams_screen_widgets/lesson_exams_loading_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LessonExamsScreenContent extends StatelessWidget {
  const LessonExamsScreenContent({super.key, required this.lessonId});

  final String lessonId;

  void _openAddQuestionScreen(BuildContext context) {
    if (context.read<LessonExamsCubit>().state.isActionInProgress) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context)
        .pushNamed(RouteNames.addLessonExamQuestionScreen, arguments: lessonId);
  }

  void _openEditQuestionScreen({
    required BuildContext context,
    required LessonExamQuestionEntity question,
  }) {
    if (context.read<LessonExamsCubit>().state.isActionInProgress) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(
      context,
    ).pushNamed(RouteNames.editLessonExamQuestionScreen, arguments: question);
  }

  Future<void> _confirmDeleteQuestion({
    required BuildContext context,
    required LessonExamQuestionEntity question,
  }) async {
    final cubit = context.read<LessonExamsCubit>();

    if (cubit.state.isActionInProgress) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    final questionText = question.questionText.trim();

    final message = questionText.isNotEmpty
        ? 'هل أنت متأكد من حذف السؤال "$questionText"؟ '
              'سيتم حذف السؤال وصورته إن وجدت، '
              'ولا يمكن التراجع عن هذه العملية.'
        : 'هل أنت متأكد من حذف هذا السؤال؟ '
              'سيتم حذف السؤال وصورته إن وجدت، '
              'ولا يمكن التراجع عن هذه العملية.';

    final confirmed = await showCustomDeleteConfirmationBottomSheet(
      context,
      title: 'حذف السؤال',
      message: message,
      confirmText: 'حذف السؤال',
      cancelText: 'إلغاء',
    );

    if (!context.mounted || !confirmed || cubit.isClosed) {
      return;
    }

    if (cubit.state.isActionInProgress) {
      return;
    }

    cubit.deleteQuestion(questionId: question.questionId);
  }

  Future<void> _handleActionState(
    BuildContext context,
    LessonExamsState state,
  ) async {
    if (!state.hasActionSuccess && !state.hasActionFailure) {
      return;
    }

    final cubit = context.read<LessonExamsCubit>();
    final isDeleting = state.actionType == LessonExamsActionType.deleteQuestion;

    if (state.hasActionSuccess) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return CustomOperationResultDialog(
            type: CustomOperationResultType.success,
            title: isDeleting ? 'تم حذف السؤال' : 'تم حفظ التعديلات',
            message: isDeleting
                ? 'تم حذف السؤال من اختبار الدرس بنجاح.'
                : 'تم حفظ الإجابات الصحيحة بنجاح.',
            actionText: 'حسنًا',
            onActionPressed: () {
              Navigator.of(dialogContext).pop();
            },
          );
        },
      );
    } else {
      final error = state.actionError;

      if (error == null) {
        return;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return CustomOperationResultDialog(
            type: CustomOperationResultType.failure,
            title: isDeleting ? 'تعذر حذف السؤال' : 'تعذر حفظ التعديلات',
            message: error.message,
            actionText: 'حسنًا',
            onActionPressed: () {
              Navigator.of(dialogContext).pop();
            },
          );
        },
      );
    }

    if (!context.mounted || cubit.isClosed) {
      return;
    }

    cubit.clearActionFeedback();
  }

  Widget _buildBody(BuildContext context, LessonExamsState state) {
    if (state.isInitial || state.isPageLoading) {
      return const LessonExamsLoadingSkeleton();
    }

    if (state.hasPageFailure) {
      return AppErrorWidget(
        message: state.pageError?.message ?? 'تعذر تحميل بيانات اختبار الدرس.',
        onRetry: () {
          context.read<LessonExamsCubit>().retry();
        },
      );
    }

    if (state.isPageReady && !state.hasQuestions) {
      return LessonExamsEmptyView(
        onAddQuestionPressed: () {
          _openAddQuestionScreen(context);
        },
      );
    }

    if (state.isPageReady) {
      return LessonExamsContent(
        state: state,
        onChoiceSelected: (question, choiceIndex) {
          context.read<LessonExamsCubit>().selectCorrectChoice(
            questionId: question.questionId,
            choiceIndex: choiceIndex,
          );
        },
        onEditQuestion: (question) {
          _openEditQuestionScreen(context: context, question: question);
        },
        onDeleteQuestion: (question) {
          _confirmDeleteQuestion(context: context, question: question);
        },
        onSaveExamPressed: () {
          context.read<LessonExamsCubit>().saveAnswers();
        },
        onAddQuestionPressed: () {
          _openAddQuestionScreen(context);
        },
      );
    }

    return const LessonExamsLoadingSkeleton();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LessonExamsCubit, LessonExamsState>(
      listenWhen: (previous, current) {
        final actionChanged = previous.actionStatus != current.actionStatus;

        final hasResult = current.hasActionSuccess || current.hasActionFailure;

        return actionChanged && hasResult;
      },
      listener: _handleActionState,
      builder: _buildBody,
    );
  }
}

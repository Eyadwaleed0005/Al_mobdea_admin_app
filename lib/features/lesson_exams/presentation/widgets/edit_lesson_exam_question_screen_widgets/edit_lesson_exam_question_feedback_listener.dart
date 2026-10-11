import 'package:al_mobdea_admin/core/widgets/custom_operation_result_dialog.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/cubit/edit_lesson_exam_question_cubit.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/cubit/edit_lesson_exam_question_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditLessonExamQuestionFeedbackListener extends StatelessWidget {
  const EditLessonExamQuestionFeedbackListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      EditLessonExamQuestionCubit,
      EditLessonExamQuestionState
    >(
      listenWhen: (previous, current) {
        final hasResult =
            current is EditLessonExamQuestionSuccess ||
            current is EditLessonExamQuestionFailure;

        if (!hasResult) {
          return false;
        }

        return previous.runtimeType != current.runtimeType;
      },
      listener: (context, state) async {
        final cubit = context.read<EditLessonExamQuestionCubit>();

        if (state is EditLessonExamQuestionSuccess) {
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return CustomOperationResultDialog(
                type: CustomOperationResultType.success,
                title: 'تم تعديل السؤال',
                message: 'تم حفظ تعديلات السؤال بنجاح.',
                actionText: 'العودة إلى الاختبار',
                onActionPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              );
            },
          );

          if (!context.mounted) {
            return;
          }

          Navigator.of(context).pop(true);
          return;
        }

        if (state is! EditLessonExamQuestionFailure) {
          return;
        }

        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return CustomOperationResultDialog(
              type: CustomOperationResultType.failure,
              title: 'تعذر تعديل السؤال',
              message: state.error.message,
              actionText: 'حاول مرة أخرى',
              onActionPressed: () {
                Navigator.of(dialogContext).pop();
              },
            );
          },
        );

        if (!context.mounted) {
          return;
        }

        cubit.clearFeedback();
      },
      child: child,
    );
  }
}

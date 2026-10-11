import 'package:al_mobdea_admin/core/widgets/custom_operation_result_dialog.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/cubit/add_lesson_exam_question_cubit.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/cubit/add_lesson_exam_question_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddLessonExamQuestionFeedbackListener extends StatelessWidget {
  const AddLessonExamQuestionFeedbackListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddLessonExamQuestionCubit, AddLessonExamQuestionState>(
      listenWhen: (previous, current) {
        final hasResult =
            current is AddLessonExamQuestionSuccess ||
            current is AddLessonExamQuestionFailure;

        if (!hasResult) {
          return false;
        }

        return previous.runtimeType != current.runtimeType;
      },
      listener: (context, state) async {
        final cubit = context.read<AddLessonExamQuestionCubit>();

        if (state is AddLessonExamQuestionSuccess) {
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return CustomOperationResultDialog(
                type: CustomOperationResultType.success,
                title: 'تمت إضافة السؤال',
                message: 'تمت إضافة السؤال إلى اختبار الدرس بنجاح.',
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

        if (state is! AddLessonExamQuestionFailure) {
          return;
        }

        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return CustomOperationResultDialog(
              type: CustomOperationResultType.failure,
              title: 'تعذر إضافة السؤال',
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

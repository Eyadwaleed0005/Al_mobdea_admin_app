import 'package:al_mobdea_admin/core/helper/app_system_ui.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_error_widget.dart';
import 'package:al_mobdea_admin/core/widgets/app_network_aware_content.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/core/widgets/custom_delete_confirmation_bottom_sheet.dart';
import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/cubit/edit_lesson_cubit.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/cubit/edit_lesson_state.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/widgets/edit_lesson_screen_widgets/edit_lesson_content.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/widgets/edit_lesson_screen_widgets/edit_lesson_feedback_listener.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/widgets/edit_lesson_screen_widgets/edit_lesson_loading_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditLessonScreen extends StatelessWidget {
  const EditLessonScreen({super.key});

  Future<void> _showDeleteConfirmation({
    required BuildContext context,
    required EditLessonState state,
  }) async {
    if (state.isDeleting || !state.canDelete) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    final lessonTitle = state.lesson?.title.trim() ?? '';

    final message = lessonTitle.isNotEmpty
        ? 'هل أنت متأكد من حذف درس "$lessonTitle"؟ '
              'سيتم حذف الدرس وملف PDF الخاص به نهائيًا، '
              'ولا يمكن التراجع عن هذه العملية.'
        : 'هل أنت متأكد من حذف هذا الدرس؟ '
              'سيتم حذف الدرس وملف PDF الخاص به نهائيًا، '
              'ولا يمكن التراجع عن هذه العملية.';

    final confirmed = await showCustomDeleteConfirmationBottomSheet(
      context,
      title: 'حذف الدرس',
      message: message,
      confirmText: 'حذف الدرس',
      cancelText: 'إلغاء',
    );

    if (!context.mounted || !confirmed) {
      return;
    }

    final cubit = context.read<EditLessonCubit>();
    final currentState = cubit.state;

    if (currentState.isDeleting || !currentState.canDelete) {
      return;
    }

    cubit.deleteLesson();
  }

  @override
  Widget build(BuildContext context) {
    return EditLessonFeedbackListener(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppSystemUi.dark(),
        child: Scaffold(
          appBar: const CustomHeaderBar(
            title: 'تعديل الدرس',
            showBackButton: true,
          ),
          backgroundColor: ColorPalette.background,
          body: BackgroundStudentLayout(
            child: SafeArea(
              top: false,
              child: AppNetworkAwareContent(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 20.h,
                  ),
                  child: BlocBuilder<EditLessonCubit, EditLessonState>(
                    builder: (context, state) {
                      if (state.isInitial || state.isPageLoading) {
                        return const EditLessonLoadingSkeleton();
                      }

                      if (state.hasPageFailure) {
                        return AppErrorWidget(
                          message:
                              state.pageError?.message ??
                              'تعذر تحميل بيانات الدرس.',
                          onRetry: () {
                            context.read<EditLessonCubit>().retry();
                          },
                        );
                      }

                      if (state.isPageReady) {
                        return EditLessonContent(
                          state: state,
                          onDeletePressed: () {
                            _showDeleteConfirmation(
                              context: context,
                              state: state,
                            );
                          },
                        );
                      }
                      return const EditLessonLoadingSkeleton();
                    },
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

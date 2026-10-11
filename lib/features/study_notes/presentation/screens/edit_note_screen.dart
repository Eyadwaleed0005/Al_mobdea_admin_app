import 'package:al_mobdea_admin/core/helper/app_system_ui.dart';
import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_error_widget.dart';
import 'package:al_mobdea_admin/core/widgets/app_network_aware_content.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/core/widgets/custom_delete_confirmation_bottom_sheet.dart';
import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/cubit/edit_note_cubit.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/cubit/edit_note_state.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/widgets/edit_note_screen_widgets/edit_note_content.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/widgets/edit_note_screen_widgets/edit_note_feedback_listener.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/widgets/edit_note_screen_widgets/edit_note_loading_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditNoteScreen extends StatelessWidget {
  const EditNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EditNoteFeedbackListener(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppSystemUi.dark(),
        child: Scaffold(
          appBar: CustomHeaderBar(title: 'تعديل المذكرة'),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: AppAnimations.screenSection(
                          delay: 0,
                          child: BlocBuilder<EditNoteCubit, EditNoteState>(
                            builder: (context, state) {
                              if (state.isInitial || state.isPageLoading) {
                                return const EditNoteLoadingSkeleton();
                              }

                              if (state.hasPageFailure) {
                                return AppErrorWidget(
                                  message:
                                      state.pageError?.message ??
                                      'تعذر تحميل بيانات المذكرة.',
                                  onRetry: () {
                                    context.read<EditNoteCubit>().retry();
                                  },
                                );
                              }

                              if (state.isPageReady) {
                                return EditNoteContent(
                                  state: state,
                                  onDeletePressed: () async {
                                    if (state.isDeleting || !state.canDelete) {
                                      return;
                                    }

                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();

                                    final noteName = state.note?.name.trim();

                                    final confirmed =
                                        await showCustomDeleteConfirmationBottomSheet(
                                          context,
                                          title: 'حذف المذكرة',
                                          message:
                                              noteName != null &&
                                                  noteName.isNotEmpty
                                              ? 'هل أنت متأكد من حذف مذكرة "$noteName"؟ سيتم حذف المذكرة وملف PDF الخاص بها نهائيًا، ولا يمكن التراجع عن هذه العملية.'
                                              : 'هل أنت متأكد من حذف هذه المذكرة؟ سيتم حذف المذكرة وملف PDF الخاص بها نهائيًا، ولا يمكن التراجع عن هذه العملية.',
                                          confirmText: 'حذف المذكرة',
                                          cancelText: 'إلغاء',
                                        );

                                    if (!context.mounted || !confirmed) {
                                      return;
                                    }

                                    context.read<EditNoteCubit>().deleteNote();
                                  },
                                );
                              }

                              return const EditNoteLoadingSkeleton();
                            },
                          ),
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
    );
  }
}

import 'package:al_mobdea_admin/app/routes/route_names.dart';
import 'package:al_mobdea_admin/core/helper/app_system_ui.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_empty_widget.dart';
import 'package:al_mobdea_admin/core/widgets/app_error_widget.dart';
import 'package:al_mobdea_admin/core/widgets/app_network_aware_content.dart';
import 'package:al_mobdea_admin/core/widgets/app_no_search_results_widget.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/core/widgets/custom_button.dart';
import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/cubit/view_notes_cubit.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/cubit/view_notes_state.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/widgets/view_notes_screen_widgets/note_search_filter_section.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/widgets/view_notes_screen_widgets/study_notes_list.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/widgets/view_notes_screen_widgets/view_notes_loading_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ViewNotesScreen extends StatelessWidget {
  const ViewNotesScreen({super.key, this.onAddNotePressed, this.onNoteTap});

  final VoidCallback? onAddNotePressed;
  final ValueChanged<StudyNoteEntity>? onNoteTap;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.dark(),
      child: Scaffold(
        appBar: CustomHeaderBar(title: 'مذكرات المذاكرة', showBackButton: true),
        backgroundColor: ColorPalette.background,
        body: BackgroundStudentLayout(
          child: SafeArea(
            top: false,
            child: AppNetworkAwareContent(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                child: AppAnimations.screenSection(
                  delay: 0,
                  child: BlocBuilder<ViewNotesCubit, ViewNotesState>(
                    builder: (context, state) {
                      if (state is ViewNotesInitial ||
                          state is ViewNotesLoading) {
                        return const ViewNotesLoadingSkeleton();
                      }

                      if (state is ViewNotesFailure) {
                        return AppErrorWidget(
                          message: 'تعذر تحميل بيانات المذكرات، تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
                          onRetry: () {
                            context.read<ViewNotesCubit>().retry();
                          },
                        );
                      }

                      if (state is ViewNotesDataSuccess) {
                        return _buildSuccessContent(context, state);
                      }

                      return const ViewNotesLoadingSkeleton();
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

  Widget _buildSuccessContent(
    BuildContext context,
    ViewNotesDataSuccess state,
  ) {
    final cubit = context.read<ViewNotesCubit>();

    if (state.hasNoNotes) {
      return AppAnimations.emptyStateEntrance(
        child: AppEmptyWidget(
          title: 'لا توجد مذكرات',
          message: 'لم تتم إضافة أي مذكرات حتى الآن، يمكنك إضافة مذكرة جديدة.',
          actionText: 'إضافة مذكرة جديدة',
          icon: Icons.menu_book_outlined,
          onActionPressed: () => _handleAddNotePressed(context),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppAnimations.screenSection(
          delay: 0,
          child: NoteSearchFilterSection(
            grades: state.grades,
            selectedGradeId: state.selectedGradeId,
            selectedPublicationFilter: state.selectedPublicationFilter,
            onSearchChanged: cubit.searchNotes,
            onSearchSubmitted: cubit.searchNotes,
            onGradeSelected: cubit.selectGrade,
            onPublicationStatusSelected: cubit.selectPublicationFilter,
          ),
        ),
        verticalSpace(24),
        Expanded(
          child: state.hasNoSearchResults
              ? AppAnimations.emptyStateEntrance(
                  child: const AppNoSearchResultsWidget(
                    message: 'لا توجد مذكرات مطابقة للبحث أو الفلاتر المحددة.',
                  ),
                )
              : AppAnimations.screenSection(
                  delay: 120,
                  child: StudyNotesList(
                    notes: state.filteredNotes,
                    onNoteTap: (note) => _handleNoteTap(context, note),
                  ),
                ),
        ),
        verticalSpace(16),
        AppAnimations.screenSection(
          delay: 240,
          child: CustomButton(
            text: 'إضافة مذكرة جديدة',
            onPressed: () => _handleAddNotePressed(context),
          ),
        ),
      ],
    );
  }

  void _handleAddNotePressed(BuildContext context) {
    final callback = onAddNotePressed;

    if (callback != null) {
      callback();
      return;
    }

    Navigator.of(context).pushNamed(RouteNames.addNoteScreen);
  }

  void _handleNoteTap(BuildContext context, StudyNoteEntity note) {
    final callback = onNoteTap;

    if (callback != null) {
      callback(note);
      return;
    }

    final noteId = note.noteId.trim();

    if (noteId.isEmpty) {
      return;
    }

    Navigator.of(context)
        .pushNamed(RouteNames.editNoteScreen, arguments: noteId);
  }
}

import 'package:al_mobdea_admin/app/routes/route_names.dart';
import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_error_widget.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/cubit/content_management_cubit.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/cubit/content_management_state.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/widgets/content_management_screen_widgets/content_management_welcome_card.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/widgets/content_management_screen_widgets/content_section_card.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/widgets/content_management_screen_widgets/content_sections_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContentManagementContent extends StatelessWidget {
  const ContentManagementContent({super.key});

  String _notesSubtitle(ContentManagementState state) {
    return switch (state) {
      ContentManagementInitial() ||
      ContentManagementLoading() => 'جارٍ تحميل عدد المذكرات...',
      ContentManagementLoaded(:final notes) => StudyNoteEntity.summarySubtitle(
        notes,
      ),
      ContentManagementFailure() => 'تعذر تحميل عدد المذكرات',
    };
  }

  String _errorMessage(Object error) {
    if (error is AppErrorModel) {
      return error.message;
    }
    return 'تعذر تحميل بيانات المذكرات، حاول مرة أخرى.';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppAnimations.screenSection(
            delay: 0,
            child: BlocBuilder<ContentManagementCubit, ContentManagementState>(
              builder: (context, state) {
                final subtitle = switch (state) {
                  ContentManagementInitial() ||
                  ContentManagementLoading() => 'جارٍ تحميل ملخص المحتوى...',
                  ContentManagementLoaded() => state.welcomeSubtitle,
                  ContentManagementFailure() => 'تعذر تحميل ملخص المحتوى',
                };

                return ContentManagementWelcomeCard(subtitle: subtitle);
              },
            ),
          ),
          verticalSpace(28),
          AppAnimations.screenSection(
            delay: 120,
            child: const ContentSectionsTitle(),
          ),
          verticalSpace(14),
          AppAnimations.screenSection(
            delay: 220,
            child: ContentSectionCard(
              title: 'الدروس',
              subtitle: '٢٤ درسًا • ٢ مسودة',
              icon: Icons.menu_rounded,
              iconBackgroundColor: ColorPalette.primary,
              onTap: () {
                Navigator.of(context).pushNamed(RouteNames.viewLessonsScreen);
              },
            ),
          ),
          verticalSpace(14),
          AppAnimations.screenSection(
            delay: 320,
            child: BlocBuilder<ContentManagementCubit, ContentManagementState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ContentSectionCard(
                      title: 'المذكرات',
                      subtitle: _notesSubtitle(state),
                      icon: Icons.article_outlined,
                      iconBackgroundColor: ColorPalette.gold500,
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(RouteNames.viewNotesScreen);
                      },
                    ),
                    if (state is ContentManagementFailure) ...[
                      verticalSpace(16),
                      AppErrorWidget(
                        message: _errorMessage(state.error),
                        onRetry: () {
                          context.read<ContentManagementCubit>().retry();
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          verticalSpace(24),
        ],
      ),
    );
  }
}

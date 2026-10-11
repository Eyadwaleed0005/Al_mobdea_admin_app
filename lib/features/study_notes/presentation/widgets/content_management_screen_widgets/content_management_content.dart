import 'package:al_mobdea_admin/app/routes/route_names.dart';
import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_error_widget.dart';
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

  String _welcomeSubtitle(ContentManagementState state) {
    return switch (state) {
      ContentManagementInitial() ||
      ContentManagementLoading() => 'جارٍ تحميل ملخص المحتوى...',
      ContentManagementLoaded() => state.welcomeSubtitle,
      ContentManagementFailure() => 'تعذر تحميل ملخص المحتوى',
    };
  }

  String _lessonsSubtitle(ContentManagementState state) {
    return switch (state) {
      ContentManagementInitial() ||
      ContentManagementLoading() => 'جارٍ تحميل عدد الدروس...',
      ContentManagementLoaded() => state.lessonsSubtitle,
      ContentManagementFailure() => 'تعذر تحميل ملخص المحتوى',
    };
  }

  String _notesSubtitle(ContentManagementState state) {
    return switch (state) {
      ContentManagementInitial() ||
      ContentManagementLoading() => 'جارٍ تحميل عدد المذكرات...',
      ContentManagementLoaded() => state.notesSubtitle,
      ContentManagementFailure() => 'تعذر تحميل ملخص المحتوى',
    };
  }

  String _errorMessage(Object error) {
    if (error is AppErrorModel) {
      return error.message;
    }

    return 'تعذر تحميل بيانات المحتوى، حاول مرة أخرى.';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContentManagementCubit, ContentManagementState>(
      builder: (context, state) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppAnimations.screenSection(
                delay: 0,
                child: ContentManagementWelcomeCard(
                  subtitle: _welcomeSubtitle(state),
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
                  subtitle: _lessonsSubtitle(state),
                  icon: Icons.menu_rounded,
                  iconBackgroundColor: ColorPalette.primary,
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(RouteNames.viewLessonsScreen);
                  },
                ),
              ),
              verticalSpace(14),
              AppAnimations.screenSection(
                delay: 320,
                child: ContentSectionCard(
                  title: 'المذكرات',
                  subtitle: _notesSubtitle(state),
                  icon: Icons.article_outlined,
                  iconBackgroundColor: ColorPalette.gold500,
                  onTap: () {
                    Navigator.of(context).pushNamed(RouteNames.viewNotesScreen);
                  },
                ),
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
              verticalSpace(24),
            ],
          ),
        );
      },
    );
  }
}

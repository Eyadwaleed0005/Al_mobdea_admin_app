import 'package:al_mobdea_admin/app/routes/route_names.dart';
import 'package:al_mobdea_admin/core/helper/app_system_ui.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_network_aware_content.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/widgets/content_management_screen_widgets/content_management_welcome_card.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/widgets/content_management_screen_widgets/content_section_card.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/widgets/content_management_screen_widgets/content_sections_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContentManagementScreen extends StatelessWidget {
  const ContentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.light(),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          appBar: CustomHeaderBar(title: 'إدارة المحتوى', showProfileIcon: true),
          backgroundColor: ColorPalette.background,
          body: BackgroundStudentLayout(
            child: SafeArea(
              child: AppNetworkAwareContent(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppAnimations.screenSection(
                        delay: 0,
                        child: const ContentManagementWelcomeCard(),
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
                            Navigator.of(
                              context,
                            ).pushNamed(RouteNames.viewLessonsScreen);
                          },
                        ),
                      ),
                      verticalSpace(14),
                      AppAnimations.screenSection(
                        delay: 320,
                        child: ContentSectionCard(
                          title: 'المذكرات',
                          subtitle: '١٢ ملف PDF • جميعها منشورة',
                          icon: Icons.article_outlined,
                          iconBackgroundColor: ColorPalette.gold500,
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(RouteNames.viewNotesScreen);
                          },
                        ),
                      ),
                      const Expanded(child: SizedBox()),
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

import 'package:al_mobdea_admin/app/dependency_injection/service_locator.dart';
import 'package:al_mobdea_admin/core/helper/app_system_ui.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/widgets/app_network_aware_content.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/stream_study_notes_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/cubit/content_management_cubit.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/widgets/content_management_screen_widgets/content_management_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContentManagementScreen extends StatelessWidget {
  const ContentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContentManagementCubit>(
      create: (_) => ContentManagementCubit(
        streamStudyNotesUseCase: getIt<StreamStudyNotesUseCase>(),
      )..initialize(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppSystemUi.dark(),
        child: Scaffold(
          appBar: CustomHeaderBar(
            title: 'إدارة المحتوى',
            showProfileIcon: true,
          ),
          backgroundColor: ColorPalette.background,
          body: BackgroundStudentLayout(
            child: SafeArea(
              top: false,
              child: AppNetworkAwareContent(
                child: const ContentManagementContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

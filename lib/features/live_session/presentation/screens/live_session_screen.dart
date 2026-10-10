import 'package:al_mobdea_admin/core/helper/app_system_ui.dart';
import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:al_mobdea_admin/core/widgets/app_network_aware_content.dart';
import 'package:al_mobdea_admin/core/widgets/app_refresh_indicator.dart';
import 'package:al_mobdea_admin/core/widgets/background/background_student_layout.dart';
import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:al_mobdea_admin/features/live_session/presentation/cubit/live_session_cubit.dart';
import 'package:al_mobdea_admin/features/live_session/presentation/widgets/live_session_screen_widgets/live_session_body.dart';
import 'package:al_mobdea_admin/features/live_session/presentation/widgets/live_session_screen_widgets/live_session_feedback_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LiveSessionScreen extends StatelessWidget {
  const LiveSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LiveSessionCubit>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.light(),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          appBar: CustomHeaderBar(
            title: 'رابط الحصة المباشرة',
            showProfileIcon: true,
            titleStyle: AppTextStyle.font22TextLightBoldKufam(),
          ),
          backgroundColor: ColorPalette.background,
          body: BackgroundStudentLayout(
            child: SafeArea(
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
                          child: LiveSessionFeedbackListener(
                            child: AppRefreshIndicator(
                              onRefresh: cubit.refreshLiveSession,
                              child: const LiveSessionBody(),
                            ),
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

import 'package:al_mobdea_admin/app/routes/app_images_routes.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:al_mobdea_admin/features/app_startup/presentation/cubit/app_startup_cubit.dart';
import 'package:al_mobdea_admin/features/app_startup/presentation/widgets/splash_loading_bar.dart';
import 'package:al_mobdea_admin/features/app_startup/presentation/widgets/splash_title_text.dart';
import 'package:al_mobdea_admin/features/app_startup/presentation/widgets/typewriter_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashLoadingView extends StatelessWidget {
  const SplashLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          children: [
            const Spacer(flex: 3),

            AppAnimations.logoZoomInEntrance(
              child: Image.asset(
                AppImage().splashLogo,
                width: 260.w,
                fit: BoxFit.contain,
              ),
            ),

            verticalSpace(20),
            TypewriterImage(
              imagePath: AppImage().alMobdea,
              width: 230.w,
              delay: const Duration(milliseconds: 1450),
              duration: const Duration(milliseconds: 1100),
            ),

            verticalSpace(14),

            AppAnimations.splashSubtitle(
              child: SplashTitleText(
                text: 'معلم أول لغة عربية',
                style: AppTextStyle.font16TextLightMediumTajawal(),
              ),
            ),

            const Spacer(flex: 4),

            AppAnimations.splashLoadingBar(
              child: SplashLoadingBar(
                onCompleted: () {
                  context.read<AppStartupCubit>().completeStartup();
                },
              ),
            ),
            verticalSpace(14),
            AppAnimations.splashLoadingText(
              child: SplashTitleText(
                text: 'طريقك إلى اللغة العربية',
                style: AppTextStyle.font14TextSecondaryRegularTajawal().copyWith(
                  color: ColorPalette.cream300,
                ),
              ),
            ),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

import 'package:al_mobdea_admin/app/routes/app_images_routes.dart';
import 'package:al_mobdea_admin/app/routes/route_names.dart';
import 'package:al_mobdea_admin/core/helper/app_system_ui.dart';
import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:al_mobdea_admin/features/app_startup/presentation/cubit/app_startup_cubit.dart';
import 'package:al_mobdea_admin/features/app_startup/presentation/cubit/app_startup_state.dart';
import 'package:al_mobdea_admin/features/app_startup/presentation/widgets/splash_loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppStartupCubit, AppStartupState>(
      listenWhen: (previous, current) => current is AppStartupCompleted,
      listener: (context, state) {
        if (state is AppStartupCompleted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            RouteNames.mainNavigationScreen,
            (route) => false,
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppSystemUi.dark(),
        child: Scaffold(
          backgroundColor: ColorPalette.deepSurface,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(AppImage().splashBackground, fit: BoxFit.cover),
              const SplashLoadingView(),
            ],
          ),
        ),
      ),
    );
  }
}

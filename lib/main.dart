import 'dart:async';

import 'package:al_mobdea_admin/app/dependency_injection/service_locator.dart';
import 'package:al_mobdea_admin/app/routes/app_route_observer.dart';
import 'package:al_mobdea_admin/app/routes/app_routes.dart';
import 'package:al_mobdea_admin/app/routes/route_names.dart';
import 'package:al_mobdea_admin/core/connection/cubit/network_status_cubit.dart';
import 'package:al_mobdea_admin/core/widgets/app_network_status_listener.dart';
import 'package:al_mobdea_admin/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  setupServiceLocator();
  await ScreenUtil.ensureScreenSize();
  unawaited(getIt<NetworkStatusCubit>().startMonitoring());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final routeObserver = getIt<AppRouteObserver>();
    return BlocProvider<NetworkStatusCubit>.value(
      value: getIt<NetworkStatusCubit>(),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'المبدع - لوحة التحكم',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'Tajawal', useMaterial3: true),
            initialRoute: RouteNames.splashScreen,
            onGenerateRoute: AppRoutes.generateRoute,
            navigatorObservers: [routeObserver],
            builder: (context, child) {
              return AppNetworkStatusListener(
                routeObserver: routeObserver,
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}

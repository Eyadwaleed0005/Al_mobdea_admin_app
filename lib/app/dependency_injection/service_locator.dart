import 'package:al_mobdea_admin/app/dependency_injection/app_dependencies/app_dependencies.dart';
import 'package:al_mobdea_admin/app/dependency_injection/app_dependencies/core_dependencies.dart';
import 'package:al_mobdea_admin/app/dependency_injection/features/students_dependencies.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  registerCoreDependencies(getIt);

  registerAppDependencies(getIt);
  registerStudentsDependencies(getIt);
}

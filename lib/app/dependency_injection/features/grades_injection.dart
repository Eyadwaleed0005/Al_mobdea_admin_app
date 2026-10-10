import 'package:al_mobdea_admin/core/firebase/firestore/firestore_service.dart';
import 'package:al_mobdea_admin/features/grades/data/data_sources/firebase_grades_remote_data_source.dart';
import 'package:al_mobdea_admin/features/grades/data/data_sources/grades_remote_data_source.dart';
import 'package:al_mobdea_admin/features/grades/data/repositories/grades_repository_impl.dart';
import 'package:al_mobdea_admin/features/grades/domain/repositories/grades_repository.dart';
import 'package:al_mobdea_admin/features/grades/domain/use_cases/stream_grades_use_case.dart';
import 'package:get_it/get_it.dart';

void registerGradesDependencies(GetIt getIt) {
  // Data Source
  getIt.registerLazySingleton<GradesRemoteDataSource>(
    () => FirebaseGradesRemoteDataSource(
      firestoreService: getIt<FirestoreService>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<GradesRepository>(
    () => GradesRepositoryImpl(
      remoteDataSource: getIt<GradesRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<StreamGradesUseCase>(
    () => StreamGradesUseCase(
      gradesRepository: getIt<GradesRepository>(),
    ),
  );
}

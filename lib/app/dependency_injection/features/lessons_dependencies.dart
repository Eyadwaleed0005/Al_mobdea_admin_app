import 'package:al_mobdea_admin/core/firebase/firestore/firestore_service.dart';
import 'package:al_mobdea_admin/core/firebase/storage/storage_service.dart';
import 'package:al_mobdea_admin/features/lessons/data/data_sources/firebase_lessons_remote_data_source.dart';
import 'package:al_mobdea_admin/features/lessons/data/data_sources/lessons_remote_data_source.dart';
import 'package:al_mobdea_admin/features/lessons/data/repositories/lessons_repository_impl.dart';
import 'package:al_mobdea_admin/features/lessons/domain/repositories/lessons_repository.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/create_lesson_use_case.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/delete_lesson_use_case.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/get_lesson_by_id_use_case.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/get_lessons_use_case.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/stream_lessons_use_case.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/update_lesson_use_case.dart';
import 'package:get_it/get_it.dart';

void registerLessonsDependencies(GetIt getIt) {
  // Data Sources
  getIt.registerLazySingleton<LessonsRemoteDataSource>(
    () => FirebaseLessonsRemoteDataSource(
      firestoreService: getIt<FirestoreService>(),
      storageService: getIt<StorageService>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<LessonsRepository>(
    () => LessonsRepositoryImpl(
      remoteDataSource: getIt<LessonsRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<GetLessonsUseCase>(
    () => GetLessonsUseCase(
      repository: getIt<LessonsRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetLessonByIdUseCase>(
    () => GetLessonByIdUseCase(
      repository: getIt<LessonsRepository>(),
    ),
  );

  getIt.registerLazySingleton<StreamLessonsUseCase>(
    () => StreamLessonsUseCase(
      repository: getIt<LessonsRepository>(),
    ),
  );

  getIt.registerLazySingleton<CreateLessonUseCase>(
    () => CreateLessonUseCase(
      repository: getIt<LessonsRepository>(),
    ),
  );

  getIt.registerLazySingleton<UpdateLessonUseCase>(
    () => UpdateLessonUseCase(
      repository: getIt<LessonsRepository>(),
    ),
  );

  getIt.registerLazySingleton<DeleteLessonUseCase>(
    () => DeleteLessonUseCase(
      repository: getIt<LessonsRepository>(),
    ),
  );
}

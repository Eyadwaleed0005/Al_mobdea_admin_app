import 'package:al_mobdea_admin/core/firebase/firestore/firestore_service.dart';
import 'package:al_mobdea_admin/core/firebase/storage/storage_service.dart';
import 'package:al_mobdea_admin/features/study_notes/data/data_sources/firebase_study_notes_remote_data_source.dart';
import 'package:al_mobdea_admin/features/study_notes/data/data_sources/study_notes_remote_data_source.dart';
import 'package:al_mobdea_admin/features/study_notes/data/repositories/study_notes_repository_impl.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/repositories/study_notes_repository.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/create_study_note_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/delete_study_note_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/get_study_note_by_id_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/get_study_notes_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/stream_study_notes_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/update_study_note_use_case.dart';
import 'package:get_it/get_it.dart';

void registerStudyNotesDependencies(GetIt getIt) {
  // Data Sources
  getIt.registerLazySingleton<StudyNotesRemoteDataSource>(
    () => FirebaseStudyNotesRemoteDataSource(
      firestoreService: getIt<FirestoreService>(),
      storageService: getIt<StorageService>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<StudyNotesRepository>(
    () => StudyNotesRepositoryImpl(
      remoteDataSource: getIt<StudyNotesRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<GetStudyNotesUseCase>(
    () => GetStudyNotesUseCase(
      repository: getIt<StudyNotesRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetStudyNoteByIdUseCase>(
    () => GetStudyNoteByIdUseCase(
      repository: getIt<StudyNotesRepository>(),
    ),
  );

  getIt.registerLazySingleton<StreamStudyNotesUseCase>(
    () => StreamStudyNotesUseCase(
      repository: getIt<StudyNotesRepository>(),
    ),
  );

  getIt.registerLazySingleton<CreateStudyNoteUseCase>(
    () => CreateStudyNoteUseCase(
      repository: getIt<StudyNotesRepository>(),
    ),
  );

  getIt.registerLazySingleton<UpdateStudyNoteUseCase>(
    () => UpdateStudyNoteUseCase(
      repository: getIt<StudyNotesRepository>(),
    ),
  );

  getIt.registerLazySingleton<DeleteStudyNoteUseCase>(
    () => DeleteStudyNoteUseCase(
      repository: getIt<StudyNotesRepository>(),
    ),
  );
}

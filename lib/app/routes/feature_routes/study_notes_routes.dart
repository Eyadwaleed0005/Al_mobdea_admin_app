import 'package:al_mobdea_admin/app/routes/route_names.dart';
import 'package:al_mobdea_admin/features/grades/domain/use_cases/stream_grades_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/create_study_note_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/delete_study_note_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/get_study_note_by_id_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/stream_study_notes_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/update_study_note_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/cubit/add_note_cubit.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/cubit/edit_note_cubit.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/cubit/view_notes_cubit.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/screens/add_note_screen.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/screens/content_management_screen.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/screens/edit_note_screen.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/screens/view_notes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

abstract final class StudyNotesRoutes {
  const StudyNotesRoutes._();

  static final GetIt _getIt = GetIt.instance;

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.contentManagementScreen:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const ContentManagementScreen(),
        );

      case RouteNames.viewNotesScreen:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<ViewNotesCubit>(
            create: (_) => ViewNotesCubit(
              streamGradesUseCase: _get<StreamGradesUseCase>(),
              streamStudyNotesUseCase: _get<StreamStudyNotesUseCase>(),
            )..initialize(),
            child: const ViewNotesScreen(),
          ),
        );

      case RouteNames.addNoteScreen:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<AddNoteCubit>(
            create: (_) => AddNoteCubit(
              streamGradesUseCase: _get<StreamGradesUseCase>(),
              createStudyNoteUseCase: _get<CreateStudyNoteUseCase>(),
            )..initialize(),
            child: const AddNoteScreen(),
          ),
        );

      case RouteNames.editNoteScreen:
        final noteId = settings.arguments as String? ?? '';
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<EditNoteCubit>(
            create: (_) => EditNoteCubit(
              noteId: noteId,
              getStudyNoteByIdUseCase: _get<GetStudyNoteByIdUseCase>(),
              streamGradesUseCase: _get<StreamGradesUseCase>(),
              updateStudyNoteUseCase: _get<UpdateStudyNoteUseCase>(),
              deleteStudyNoteUseCase: _get<DeleteStudyNoteUseCase>(),
            )..initialize(),
            child: const EditNoteScreen(),
          ),
        );

      default:
        return null;
    }
  }

  static T _get<T extends Object>() {
    return _getIt.get<T>();
  }
}

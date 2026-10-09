import 'dart:async';

import 'package:al_mobdea_admin/app/routes/route_names.dart';
import 'package:al_mobdea_admin/features/grades/domain/use_cases/stream_grades_use_case.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/use_cases/delete_lesson_exam_question_use_case.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/use_cases/save_lesson_exam_answers_use_case.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/use_cases/stream_lesson_exam_use_case.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/cubit/lesson_exams_cubit.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/create_lesson_use_case.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/delete_lesson_use_case.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/get_lesson_by_id_use_case.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/stream_lessons_use_case.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/update_lesson_use_case.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/cubit/add_lesson_cubit.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/cubit/edit_lesson_cubit.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/cubit/view_lessons_cubit.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/screens/add_lesson_screen.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/screens/edit_lesson_screen.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/screens/view_lessons_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

abstract final class LessonsRoutes {
  const LessonsRoutes._();

  static final GetIt _getIt = GetIt.instance;

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.viewLessonsScreen:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<ViewLessonsCubit>(
            create: (_) => _createViewLessonsCubit(),
            child: const ViewLessonsScreen(),
          ),
        );

      case RouteNames.addLessonScreen:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<AddLessonCubit>(
            create: (_) => _createAddLessonCubit(),
            child: const AddLessonScreen(),
          ),
        );

      case RouteNames.editLessonScreen:
        return _generateEditLessonRoute(settings);

      default:
        return null;
    }
  }

  static Route<dynamic>? _generateEditLessonRoute(RouteSettings settings) {
    final Object? argument = settings.arguments;

    if (argument is! String || argument.trim().isEmpty) {
      return null;
    }

    final String lessonId = argument.trim();

    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<EditLessonCubit>(
            create: (_) => _createEditLessonCubit(lessonId: lessonId),
          ),
          BlocProvider<LessonExamsCubit>(
            create: (_) => _createLessonExamsCubit(lessonId: lessonId),
          ),
        ],
        child: const EditLessonScreen(),
      ),
    );
  }

  static ViewLessonsCubit _createViewLessonsCubit() {
    return ViewLessonsCubit(
      streamGradesUseCase: _get<StreamGradesUseCase>(),
      streamLessonsUseCase: _get<StreamLessonsUseCase>(),
    )..initialize();
  }

  static AddLessonCubit _createAddLessonCubit() {
    return AddLessonCubit(
      streamGradesUseCase: _get<StreamGradesUseCase>(),
      createLessonUseCase: _get<CreateLessonUseCase>(),
    )..initialize();
  }

  static EditLessonCubit _createEditLessonCubit({required String lessonId}) {
    return EditLessonCubit(
      lessonId: lessonId,
      getLessonByIdUseCase: _get<GetLessonByIdUseCase>(),
      streamGradesUseCase: _get<StreamGradesUseCase>(),
      updateLessonUseCase: _get<UpdateLessonUseCase>(),
      deleteLessonUseCase: _get<DeleteLessonUseCase>(),
    )..initialize();
  }

  static LessonExamsCubit _createLessonExamsCubit({required String lessonId}) {
    final LessonExamsCubit lessonExamsCubit = LessonExamsCubit(
      lessonId: lessonId,
      streamLessonExamUseCase: _get<StreamLessonExamUseCase>(),
      deleteLessonExamQuestionUseCase: _get<DeleteLessonExamQuestionUseCase>(),
      saveLessonExamAnswersUseCase: _get<SaveLessonExamAnswersUseCase>(),
    );

    unawaited(lessonExamsCubit.initialize());

    return lessonExamsCubit;
  }

  static T _get<T extends Object>() {
    return _getIt.get<T>();
  }
}

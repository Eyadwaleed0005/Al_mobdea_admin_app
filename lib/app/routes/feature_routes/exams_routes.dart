import 'package:al_mobdea_admin/app/routes/route_names.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_draft_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_question_draft_entity.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/add_exam_cubit.dart';
import 'package:al_mobdea_admin/features/exams/presentation/screens/add_exam_questions_screen.dart';
import 'package:al_mobdea_admin/features/exams/presentation/screens/add_exam_screen.dart';
import 'package:al_mobdea_admin/features/exams/presentation/screens/edit_exam_question_screen.dart';
import 'package:al_mobdea_admin/features/exams/presentation/screens/edit_exam_screen.dart';
import 'package:al_mobdea_admin/features/exams/presentation/screens/exam_questions_screen.dart';
import 'package:al_mobdea_admin/features/exams/presentation/screens/exam_results_screen.dart';
import 'package:al_mobdea_admin/features/exams/presentation/screens/view_exams_screen.dart';
import 'package:al_mobdea_admin/features/grades/domain/use_cases/stream_grades_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

abstract final class ExamsRoutes {
  const ExamsRoutes._();

  static final GetIt _getIt = GetIt.instance;

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.viewExamsScreen:
        return _generateViewExamsRoute(settings);

      case RouteNames.addExamScreen:
        return _generateAddExamRoute(settings);

      case RouteNames.editExamScreen:
        return _generateEditExamRoute(settings);

      case RouteNames.examQuestionsScreen:
        return _generateExamQuestionsRoute(settings);

      case RouteNames.addExamQuestionsScreen:
        return _generateAddExamQuestionsRoute(settings);

      case RouteNames.editExamQuestionScreen:
        return _generateEditExamQuestionRoute(settings);

      case RouteNames.examResultsScreen:
        return _generateExamResultsRoute(settings);

      default:
        return null;
    }
  }

  static Route<dynamic> _generateViewExamsRoute(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => const ViewExamsScreen(),
    );
  }

  static Route<dynamic> _generateAddExamRoute(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => BlocProvider<AddExamCubit>(
        create: (_) =>
            AddExamCubit(streamGradesUseCase: _get<StreamGradesUseCase>())
              ..loadGrades(),
        child: const AddExamScreen(),
      ),
    );
  }

  static Route<dynamic>? _generateEditExamRoute(RouteSettings settings) {
    final argument = settings.arguments;

    if (argument is! ExamEntity) {
      return null;
    }

    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => EditExamScreen(exam: argument),
    );
  }

  static Route<dynamic>? _generateExamQuestionsRoute(RouteSettings settings) {
    final argument = settings.arguments;

    if (argument is ExamDraftEntity) {
      return MaterialPageRoute<dynamic>(
        settings: settings,
        builder: (_) => ExamQuestionsScreen(examDraft: argument),
      );
    }

    if (argument is String && argument.trim().isNotEmpty) {
      return MaterialPageRoute<dynamic>(
        settings: settings,
        builder: (_) => ExamQuestionsScreen(examId: argument.trim()),
      );
    }

    return null;
  }

  static Route<dynamic>? _generateAddExamQuestionsRoute(
    RouteSettings settings,
  ) {
    final argument = settings.arguments;

    if (argument is! ExamDraftEntity) {
      return null;
    }

    return MaterialPageRoute<ExamQuestionDraftEntity>(
      settings: settings,
      builder: (_) => AddExamQuestionsScreen(examDraft: argument),
    );
  }

  static Route<dynamic>? _generateEditExamQuestionRoute(
    RouteSettings settings,
  ) {
    final argument = settings.arguments;

    if (argument is! ExamQuestionDraftEntity) {
      return null;
    }

    return MaterialPageRoute<ExamQuestionDraftEntity>(
      settings: settings,
      builder: (_) => EditExamQuestionScreen(questionDraft: argument),
    );
  }

  static Route<dynamic>? _generateExamResultsRoute(RouteSettings settings) {
    final argument = settings.arguments;

    if (argument is! String || argument.trim().isEmpty) {
      return null;
    }

    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => ExamResultsScreen(examId: argument.trim()),
    );
  }

  static T _get<T extends Object>() {
    return _getIt.get<T>();
  }
}

import 'dart:async';

import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/lessons/domain/entities/lesson_entity.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/stream_lessons_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/stream_study_notes_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/cubit/content_management_state.dart';
import 'package:dartz/dartz.dart' show Either;
import 'package:flutter_bloc/flutter_bloc.dart';

class ContentManagementCubit extends Cubit<ContentManagementState> {
  ContentManagementCubit({
    required StreamLessonsUseCase streamLessonsUseCase,
    required StreamStudyNotesUseCase streamStudyNotesUseCase,
  }) : _streamLessonsUseCase = streamLessonsUseCase,
       _streamStudyNotesUseCase = streamStudyNotesUseCase,
       super(const ContentManagementInitial());

  final StreamLessonsUseCase _streamLessonsUseCase;
  final StreamStudyNotesUseCase _streamStudyNotesUseCase;

  StreamSubscription<Either<AppErrorModel, List<LessonEntity>>>?
  _lessonsSubscription;

  StreamSubscription<Either<AppErrorModel, List<StudyNoteEntity>>>?
  _notesSubscription;

  List<LessonEntity>? _lessons;
  List<StudyNoteEntity>? _notes;

  Object? _lessonsError;
  Object? _notesError;

  int _requestId = 0;

  bool _isCurrentRequest(int requestId) {
    return !isClosed && requestId == _requestId;
  }

  Future<void> initialize() async {
    if (isClosed) return;

    final requestId = ++_requestId;

    emit(const ContentManagementLoading());

    final previousLessonsSubscription = _lessonsSubscription;
    final previousNotesSubscription = _notesSubscription;

    _lessonsSubscription = null;
    _notesSubscription = null;

    _lessons = null;
    _notes = null;

    _lessonsError = null;
    _notesError = null;

    try {
      await Future.wait<void>([
        if (previousLessonsSubscription != null)
          previousLessonsSubscription.cancel(),
        if (previousNotesSubscription != null)
          previousNotesSubscription.cancel(),
      ]);
    } catch (error) {
      if (!_isCurrentRequest(requestId)) return;

      emit(ContentManagementFailure(error: error));
      return;
    }

    if (!_isCurrentRequest(requestId)) return;

    _watchLessons(requestId);
    _watchNotes(requestId);
  }

  void _watchLessons(int requestId) {
    try {
      _lessonsSubscription = _streamLessonsUseCase().listen(
        (result) {
          if (!_isCurrentRequest(requestId)) return;

          result.fold(
            (error) {
              _lessonsError = error;
            },
            (lessons) {
              _lessons = lessons;
              _lessonsError = null;
            },
          );

          _emitCurrentState();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!_isCurrentRequest(requestId)) return;

          _lessonsError = error;
          _emitCurrentState();
        },
      );
    } catch (error) {
      if (!_isCurrentRequest(requestId)) return;

      _lessonsError = error;
      _emitCurrentState();
    }
  }

  void _watchNotes(int requestId) {
    try {
      _notesSubscription = _streamStudyNotesUseCase().listen(
        (result) {
          if (!_isCurrentRequest(requestId)) return;

          result.fold(
            (error) {
              _notesError = error;
            },
            (notes) {
              _notes = notes;
              _notesError = null;
            },
          );

          _emitCurrentState();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!_isCurrentRequest(requestId)) return;

          _notesError = error;
          _emitCurrentState();
        },
      );
    } catch (error) {
      if (!_isCurrentRequest(requestId)) return;

      _notesError = error;
      _emitCurrentState();
    }
  }

  void _emitCurrentState() {
    if (isClosed) return;

    final error = _lessonsError ?? _notesError;

    if (error != null) {
      emit(ContentManagementFailure(error: error));
      return;
    }

    final lessons = _lessons;
    final notes = _notes;

    if (lessons == null || notes == null) {
      if (state is! ContentManagementLoading) {
        emit(const ContentManagementLoading());
      }
      return;
    }

    emit(ContentManagementLoaded(lessons: lessons, notes: notes));
  }

  Future<void> retry() => initialize();

  @override
  Future<void> close() async {
    ++_requestId;

    try {
      await Future.wait<void>([
        if (_lessonsSubscription != null) _lessonsSubscription!.cancel(),
        if (_notesSubscription != null) _notesSubscription!.cancel(),
      ]);
    } finally {
      await super.close();
    }
  }
}

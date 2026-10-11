import 'dart:async';

import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/stream_study_notes_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/presentation/cubit/content_management_state.dart';
import 'package:dartz/dartz.dart' show Either;
import 'package:flutter_bloc/flutter_bloc.dart';

class ContentManagementCubit extends Cubit<ContentManagementState> {
  ContentManagementCubit({
    required StreamStudyNotesUseCase streamStudyNotesUseCase,
  }) : _streamStudyNotesUseCase = streamStudyNotesUseCase,
       super(const ContentManagementInitial());

  final StreamStudyNotesUseCase _streamStudyNotesUseCase;

  StreamSubscription<Either<AppErrorModel, List<StudyNoteEntity>>>?
  _notesSubscription;

  int _requestId = 0;

  Future<void> initialize() async {
    if (isClosed) return;

    final requestId = ++_requestId;

    emit(const ContentManagementLoading());

    final previousSubscription = _notesSubscription;
    _notesSubscription = null;

    await previousSubscription?.cancel();

    if (isClosed || requestId != _requestId) return;

    try {
      _notesSubscription = _streamStudyNotesUseCase().listen(
        (result) {
          if (isClosed || requestId != _requestId) return;

          result.fold(
            (error) {
              emit(ContentManagementFailure(error: error));
            },
            (notes) {
              emit(ContentManagementLoaded(notes: notes));
            },
          );
        },
        onError: (Object error, StackTrace stackTrace) {
          if (isClosed || requestId != _requestId) return;

          emit(ContentManagementFailure(error: error));
        },
      );
    } catch (error) {
      if (isClosed || requestId != _requestId) return;

      emit(ContentManagementFailure(error: error));
    }
  }

  Future<void> retry() => initialize();

  @override
  Future<void> close() async {
    ++_requestId;
    await _notesSubscription?.cancel();
    return super.close();
  }
}

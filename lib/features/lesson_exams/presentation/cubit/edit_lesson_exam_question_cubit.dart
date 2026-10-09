import 'package:al_mobdea_admin/features/lesson_exams/domain/lesson_exam_question_image_file.dart';
import 'package:al_mobdea_admin/features/lesson_exams/domain/use_cases/update_lesson_exam_question_use_case.dart';
import 'package:al_mobdea_admin/features/lesson_exams/presentation/cubit/edit_lesson_exam_question_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditLessonExamQuestionCubit extends Cubit<EditLessonExamQuestionState> {
  EditLessonExamQuestionCubit(this._updateLessonExamQuestionUseCase)
    : super(const EditLessonExamQuestionInitial());

  final UpdateLessonExamQuestionUseCase _updateLessonExamQuestionUseCase;

  bool get isSubmitting {
    return state is EditLessonExamQuestionLoading;
  }

  void clearFeedback() {
    if (state is EditLessonExamQuestionLoading || isClosed) {
      return;
    }

    if (state is EditLessonExamQuestionInitial) {
      return;
    }

    emit(const EditLessonExamQuestionInitial());
  }

  Future<void> updateQuestion({
    required String lessonId,
    required String questionId,
    required String questionText,
    required int degree,
    required List<String> choices,
    LessonExamQuestionImageFile? newImage,
    bool removeCurrentImage = false,
  }) async {
    if (isSubmitting || isClosed) {
      return;
    }

    emit(const EditLessonExamQuestionLoading());

    final result = await _updateLessonExamQuestionUseCase(
      lessonId: lessonId,
      questionId: questionId,
      questionText: questionText,
      degree: degree,
      choices: choices,
      newImage: newImage,
      removeCurrentImage: removeCurrentImage,
    );

    if (isClosed) {
      return;
    }

    result.fold(
      (error) {
        emit(EditLessonExamQuestionFailure(error: error));
      },
      (_) {
        emit(const EditLessonExamQuestionSuccess());
      },
    );
  }
}

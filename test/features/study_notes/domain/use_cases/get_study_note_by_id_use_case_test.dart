import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/get_study_note_by_id_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStudyNotesRepository repository;
  late GetStudyNoteByIdUseCase useCase;

  setUp(() {
    repository = MockStudyNotesRepository();
    useCase = GetStudyNoteByIdUseCase(repository: repository);
  });

  test('returns the note on success', () async {
    when(
      () => repository.getStudyNoteById(noteId: any(named: 'noteId')),
    ).thenAnswer((_) async => Right(tStudyNoteEntity));

    final result = await useCase.call(noteId: tStudyNoteId);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (note) => expect(note.noteId, tStudyNoteId),
    );
    verify(() => repository.getStudyNoteById(noteId: tStudyNoteId)).called(1);
  });

  test('returns Left when the note does not exist', () async {
    const tAppError = AppErrorModel(
      code: 'not-found',
      message: 'not found',
      type: AppErrorType.notFound,
      isRetryable: false,
    );

    when(
      () => repository.getStudyNoteById(noteId: any(named: 'noteId')),
    ).thenAnswer(
      (_) async => const Left<AppErrorModel, StudyNoteEntity>(tAppError),
    );

    final result = await useCase.call(noteId: tStudyNoteId);

    expect(result.isLeft(), isTrue);
    result.fold(
      (error) => expect(error.type, AppErrorType.notFound),
      (_) => fail('expected Left'),
    );
  });
}

import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/get_study_notes_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStudyNotesRepository repository;
  late GetStudyNotesUseCase useCase;

  setUp(() {
    repository = MockStudyNotesRepository();
    useCase = GetStudyNotesUseCase(repository: repository);
  });

  test('returns the study notes list on success', () async {
    when(
      () => repository.getStudyNotes(
        gradeId: any(named: 'gradeId'),
        isPublished: any(named: 'isPublished'),
      ),
    ).thenAnswer((_) async => Right([tStudyNoteEntity]));

    final result = await useCase.call();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (notes) => expect(notes.single.noteId, tStudyNoteId),
    );
    verify(() => repository.getStudyNotes()).called(1);
  });

  test('forwards the grade and publication filters', () async {
    when(
      () => repository.getStudyNotes(
        gradeId: any(named: 'gradeId'),
        isPublished: any(named: 'isPublished'),
      ),
    ).thenAnswer((_) async => const Right([]));

    await useCase.call(gradeId: tGradeId, isPublished: true);

    verify(
      () => repository.getStudyNotes(gradeId: tGradeId, isPublished: true),
    ).called(1);
  });

  test('returns Left when the repository fails', () async {
    const tAppError = AppErrorModel(
      code: 'unavailable',
      message: 'offline',
      type: AppErrorType.network,
      isRetryable: true,
    );

    when(
      () => repository.getStudyNotes(
        gradeId: any(named: 'gradeId'),
        isPublished: any(named: 'isPublished'),
      ),
    ).thenAnswer(
      (_) async => const Left<AppErrorModel, List<StudyNoteEntity>>(tAppError),
    );

    final result = await useCase.call();

    expect(result.isLeft(), isTrue);
    result.fold(
      (error) => expect(error.code, 'unavailable'),
      (_) => fail('expected Left'),
    );
  });
}

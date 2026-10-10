import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/stream_study_notes_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStudyNotesRepository repository;
  late StreamStudyNotesUseCase useCase;

  setUp(() {
    repository = MockStudyNotesRepository();
    useCase = StreamStudyNotesUseCase(repository: repository);
  });

  test('returns the repository stream on success', () async {
    when(
      () => repository.streamStudyNotes(
        gradeId: any(named: 'gradeId'),
        isPublished: any(named: 'isPublished'),
      ),
    ).thenAnswer((_) => Stream.value(Right([tStudyNoteEntity])));

    final stream = useCase.call();

    await expectLater(
      stream,
      emits(
        isA<Right<AppErrorModel, List<dynamic>>>().having(
          (either) => either.getOrElse(() => <StudyNoteEntity>[]).single.noteId,
          'noteId',
          tStudyNoteId,
        ),
      ),
    );
    verify(() => repository.streamStudyNotes()).called(1);
  });

  test('forwards the grade and publication filters', () async {
    when(
      () => repository.streamStudyNotes(
        gradeId: any(named: 'gradeId'),
        isPublished: any(named: 'isPublished'),
      ),
    ).thenAnswer((_) => const Stream.empty());

    useCase.call(gradeId: tGradeId, isPublished: false);

    verify(
      () => repository.streamStudyNotes(gradeId: tGradeId, isPublished: false),
    ).called(1);
  });

  test('emits Left when the repository stream errors', () async {
    const tAppError = AppErrorModel(
      code: 'unavailable',
      message: 'offline',
      type: AppErrorType.network,
      isRetryable: true,
    );

    when(
      () => repository.streamStudyNotes(
        gradeId: any(named: 'gradeId'),
        isPublished: any(named: 'isPublished'),
      ),
    ).thenAnswer(
      (_) =>
          Stream.value(Left<AppErrorModel, List<StudyNoteEntity>>(tAppError)),
    );

    final stream = useCase.call();

    await expectLater(stream, emits(isA<Left<AppErrorModel, List<dynamic>>>()));
  });
}

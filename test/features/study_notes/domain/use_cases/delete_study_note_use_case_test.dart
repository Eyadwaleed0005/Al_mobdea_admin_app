import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/delete_study_note_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStudyNotesRepository repository;
  late DeleteStudyNoteUseCase useCase;

  setUp(() {
    repository = MockStudyNotesRepository();
    useCase = DeleteStudyNoteUseCase(repository: repository);
  });

  test(
    'calls deleteStudyNote on the repository with the given note id',
    () async {
      when(
        () => repository.deleteStudyNote(noteId: any(named: 'noteId')),
      ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));

      final result = await useCase.call(noteId: tStudyNoteId);

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
      verify(() => repository.deleteStudyNote(noteId: tStudyNoteId)).called(1);
    },
  );

  test('returns Left when the repository fails', () async {
    const tAppError = AppErrorModel(
      code: 'permission-denied',
      message: 'not allowed',
      type: AppErrorType.authorization,
      isRetryable: false,
    );

    when(
      () => repository.deleteStudyNote(noteId: any(named: 'noteId')),
    ).thenAnswer((_) async => const Left<AppErrorModel, Unit>(tAppError));

    final result = await useCase.call(noteId: tStudyNoteId);

    expect(result.isLeft(), isTrue);
    result.fold(
      (error) => expect(error.code, 'permission-denied'),
      (_) => fail('expected Left'),
    );
  });
}

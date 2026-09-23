import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/update_study_note_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStudyNotesRepository repository;
  late UpdateStudyNoteUseCase useCase;

  setUpAll(() {
    registerFallbackValue(tStudyNoteEntity);
  });

  setUp(() {
    repository = MockStudyNotesRepository();
    useCase = UpdateStudyNoteUseCase(repository: repository);
  });

  test('calls updateStudyNote on the repository with the given note', () async {
    when(
      () => repository.updateStudyNote(
        note: any(named: 'note'),
        replacementPdfFilePath: any(named: 'replacementPdfFilePath'),
        removeExistingPdf: any(named: 'removeExistingPdf'),
      ),
    ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));

    final result = await useCase.call(note: tStudyNoteEntity);

    expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
    verify(
      () => repository.updateStudyNote(
        note: tStudyNoteEntity,
        replacementPdfFilePath: null,
        removeExistingPdf: false,
      ),
    ).called(1);
  });

  test('supports editing a note without a pdf', () async {
    when(
      () => repository.updateStudyNote(
        note: any(named: 'note'),
        replacementPdfFilePath: any(named: 'replacementPdfFilePath'),
        removeExistingPdf: any(named: 'removeExistingPdf'),
      ),
    ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));

    final result = await useCase.call(note: tStudyNoteEntityWithoutPdf);

    expect(result.isRight(), isTrue);
    verify(
      () => repository.updateStudyNote(
        note: tStudyNoteEntityWithoutPdf,
        replacementPdfFilePath: null,
        removeExistingPdf: false,
      ),
    ).called(1);
  });

  test('forwards the replacement pdf file path', () async {
    when(
      () => repository.updateStudyNote(
        note: any(named: 'note'),
        replacementPdfFilePath: any(named: 'replacementPdfFilePath'),
        removeExistingPdf: any(named: 'removeExistingPdf'),
      ),
    ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));

    await useCase.call(
      note: tStudyNoteEntity,
      replacementPdfFilePath: tStudyNoteLocalPdfFilePath,
    );

    verify(
      () => repository.updateStudyNote(
        note: tStudyNoteEntity,
        replacementPdfFilePath: tStudyNoteLocalPdfFilePath,
        removeExistingPdf: false,
      ),
    ).called(1);
  });

  test('forwards removeExistingPdf to remove the attached pdf', () async {
    when(
      () => repository.updateStudyNote(
        note: any(named: 'note'),
        replacementPdfFilePath: any(named: 'replacementPdfFilePath'),
        removeExistingPdf: any(named: 'removeExistingPdf'),
      ),
    ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));

    await useCase.call(note: tStudyNoteEntity, removeExistingPdf: true);

    verify(
      () => repository.updateStudyNote(
        note: tStudyNoteEntity,
        replacementPdfFilePath: null,
        removeExistingPdf: true,
      ),
    ).called(1);
  });

  test('returns Left when the repository fails', () async {
    const tAppError = AppErrorModel(
      code: 'internal',
      message: 'server error',
      type: AppErrorType.server,
      isRetryable: true,
    );

    when(
      () => repository.updateStudyNote(
        note: any(named: 'note'),
        replacementPdfFilePath: any(named: 'replacementPdfFilePath'),
        removeExistingPdf: any(named: 'removeExistingPdf'),
      ),
    ).thenAnswer((_) async => const Left<AppErrorModel, Unit>(tAppError));

    final result = await useCase.call(note: tStudyNoteEntity);

    expect(result.isLeft(), isTrue);
  });
}

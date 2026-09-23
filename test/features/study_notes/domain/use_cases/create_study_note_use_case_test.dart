import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/create_study_note_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockStudyNotesRepository repository;
  late CreateStudyNoteUseCase useCase;

  setUpAll(() {
    registerFallbackValue(tStudyNoteEntity);
  });

  setUp(() {
    repository = MockStudyNotesRepository();
    useCase = CreateStudyNoteUseCase(repository: repository);
  });

  test('calls createStudyNote on the repository with the given note', () async {
    when(
      () => repository.createStudyNote(
        note: any(named: 'note'),
        localPdfFilePath: any(named: 'localPdfFilePath'),
      ),
    ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));

    final result = await useCase.call(note: tStudyNoteEntity);

    expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
    verify(() => repository.createStudyNote(note: tStudyNoteEntity)).called(1);
  });

  test('supports creating a note without a pdf', () async {
    when(
      () => repository.createStudyNote(
        note: any(named: 'note'),
        localPdfFilePath: any(named: 'localPdfFilePath'),
      ),
    ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));

    final result = await useCase.call(note: tStudyNoteEntityWithoutPdf);

    expect(result.isRight(), isTrue);
    verify(
      () => repository.createStudyNote(
        note: tStudyNoteEntityWithoutPdf,
        localPdfFilePath: null,
      ),
    ).called(1);
  });

  test('forwards the local pdf file path when a pdf is attached', () async {
    when(
      () => repository.createStudyNote(
        note: any(named: 'note'),
        localPdfFilePath: any(named: 'localPdfFilePath'),
      ),
    ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));

    await useCase.call(
      note: tStudyNoteEntity,
      localPdfFilePath: tStudyNoteLocalPdfFilePath,
    );

    verify(
      () => repository.createStudyNote(
        note: tStudyNoteEntity,
        localPdfFilePath: tStudyNoteLocalPdfFilePath,
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
      () => repository.createStudyNote(
        note: any(named: 'note'),
        localPdfFilePath: any(named: 'localPdfFilePath'),
      ),
    ).thenAnswer((_) async => const Left<AppErrorModel, Unit>(tAppError));

    final result = await useCase.call(note: tStudyNoteEntity);

    expect(result.isLeft(), isTrue);
    result.fold(
      (error) => expect(error.code, 'internal'),
      (_) => fail('expected Left'),
    );
  });
}

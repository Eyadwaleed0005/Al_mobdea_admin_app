import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/entities/study_note_entity.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/repositories/study_notes_repository.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/create_study_note_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/delete_study_note_use_case.dart';
import 'package:al_mobdea_admin/features/study_notes/domain/use_cases/get_study_notes_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/dummy_data.dart';

class MockStudyNotesRepository extends Mock implements StudyNotesRepository {}

void main() {
  late MockStudyNotesRepository repository;
  late GetStudyNotesUseCase getStudyNotesUseCase;
  late CreateStudyNoteUseCase uploadStudyNoteUseCase;
  late DeleteStudyNoteUseCase deleteStudyNoteUseCase;

  setUpAll(() {
    registerFallbackValue(tStudyNoteEntity);
    registerFallbackValue(tStudyNoteId);
  });

  setUp(() {
    repository = MockStudyNotesRepository();
    getStudyNotesUseCase = GetStudyNotesUseCase(repository: repository);
    uploadStudyNoteUseCase = CreateStudyNoteUseCase(repository: repository);
    deleteStudyNoteUseCase = DeleteStudyNoteUseCase(repository: repository);
  });

  group('GetStudyNotesUseCase', () {
    test('returns Right(List<StudyNoteEntity>) on success', () async {
      when(
        () => repository.getStudyNotes(
          gradeId: any(named: 'gradeId'),
          isPublished: any(named: 'isPublished'),
        ),
      ).thenAnswer((_) async => Right(<StudyNoteEntity>[tStudyNoteEntity]));

      final result = await getStudyNotesUseCase.call(
        gradeId: tGradeId,
        isPublished: true,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right(List<StudyNoteEntity>)'),
        (notes) => expect(notes, equals(<StudyNoteEntity>[tStudyNoteEntity])),
      );
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
        (_) async =>
            const Left<AppErrorModel, List<StudyNoteEntity>>(tAppError),
      );

      final result = await getStudyNotesUseCase.call(
        gradeId: tGradeId,
        isPublished: true,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (error) => expect(error.code, 'unavailable'),
        (_) => fail('Expected Left(AppErrorModel)'),
      );
      verify(
        () => repository.getStudyNotes(gradeId: tGradeId, isPublished: true),
      ).called(1);
    });
  });

  group('CreateStudyNoteUseCase (admin upload flow)', () {
    test('returns Right(Unit) on success', () async {
      when(
        () => repository.createStudyNote(
          note: any(named: 'note'),
          localPdfFilePath: any(named: 'localPdfFilePath'),
        ),
      ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));

      final result = await uploadStudyNoteUseCase.call(
        note: tStudyNoteEntity,
        localPdfFilePath: tStudyNoteLocalPdfFilePath,
      );

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
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

      final result = await uploadStudyNoteUseCase.call(
        note: tStudyNoteEntity,
        localPdfFilePath: tStudyNoteLocalPdfFilePath,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (error) => expect(error.code, 'internal'),
        (_) => fail('Expected Left(AppErrorModel)'),
      );
      verify(
        () => repository.createStudyNote(
          note: tStudyNoteEntity,
          localPdfFilePath: tStudyNoteLocalPdfFilePath,
        ),
      ).called(1);
    });
  });

  group('DeleteStudyNoteUseCase', () {
    test('returns Right(Unit) on success', () async {
      when(() => repository.deleteStudyNote(noteId: any(named: 'noteId')))
          .thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));

      final result = await deleteStudyNoteUseCase.call(noteId: tStudyNoteId);

      expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
      verify(() => repository.deleteStudyNote(noteId: tStudyNoteId)).called(1);
    });

    test('returns Left when the repository fails', () async {
      const tAppError = AppErrorModel(
        code: 'permission-denied',
        message: 'not allowed',
        type: AppErrorType.authorization,
        isRetryable: false,
      );

      when(() => repository.deleteStudyNote(noteId: any(named: 'noteId')))
          .thenAnswer((_) async => const Left<AppErrorModel, Unit>(tAppError));

      final result = await deleteStudyNoteUseCase.call(noteId: tStudyNoteId);

      expect(result.isLeft(), isTrue);
      result.fold(
        (error) => expect(error.code, 'permission-denied'),
        (_) => fail('Expected Left(AppErrorModel)'),
      );
      verify(() => repository.deleteStudyNote(noteId: tStudyNoteId)).called(1);
    });
  });
}

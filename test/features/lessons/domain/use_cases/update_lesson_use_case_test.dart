import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/update_lesson_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockLessonsRepository repository;
  late UpdateLessonUseCase useCase;

  setUpAll(() {
    registerFallbackValue(tLessonEntity);
  });

  setUp(() {
    repository = MockLessonsRepository();
    useCase = UpdateLessonUseCase(repository: repository);
  });

  test('calls updateLesson on the repository with the given lesson', () async {
    when(
      () => repository.updateLesson(
        lesson: any(named: 'lesson'),
        replacementPdfFilePath: any(named: 'replacementPdfFilePath'),
        removeExistingPdf: any(named: 'removeExistingPdf'),
      ),
    ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));

    final result = await useCase.call(lesson: tLessonEntity);

    expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
    verify(
      () => repository.updateLesson(
        lesson: tLessonEntity,
        replacementPdfFilePath: null,
        removeExistingPdf: false,
      ),
    ).called(1);
  });

  test('supports editing a lesson without a pdf (pdf-optional)', () async {
    when(
      () => repository.updateLesson(
        lesson: any(named: 'lesson'),
        replacementPdfFilePath: any(named: 'replacementPdfFilePath'),
        removeExistingPdf: any(named: 'removeExistingPdf'),
      ),
    ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));

    final result = await useCase.call(lesson: tLessonEntityWithoutPdf);

    expect(result.isRight(), isTrue);
    verify(
      () => repository.updateLesson(
        lesson: tLessonEntityWithoutPdf,
        replacementPdfFilePath: null,
        removeExistingPdf: false,
      ),
    ).called(1);
  });

  test('forwards the replacement pdf file path', () async {
    when(
      () => repository.updateLesson(
        lesson: any(named: 'lesson'),
        replacementPdfFilePath: any(named: 'replacementPdfFilePath'),
        removeExistingPdf: any(named: 'removeExistingPdf'),
      ),
    ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));

    await useCase.call(
      lesson: tLessonEntity,
      replacementPdfFilePath: tLocalPdfFilePath,
    );

    verify(
      () => repository.updateLesson(
        lesson: tLessonEntity,
        replacementPdfFilePath: tLocalPdfFilePath,
        removeExistingPdf: false,
      ),
    ).called(1);
  });

  test('forwards removeExistingPdf to remove the attached pdf', () async {
    when(
      () => repository.updateLesson(
        lesson: any(named: 'lesson'),
        replacementPdfFilePath: any(named: 'replacementPdfFilePath'),
        removeExistingPdf: any(named: 'removeExistingPdf'),
      ),
    ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));

    await useCase.call(
      lesson: tLessonEntity,
      removeExistingPdf: true,
    );

    verify(
      () => repository.updateLesson(
        lesson: tLessonEntity,
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
      () => repository.updateLesson(
        lesson: any(named: 'lesson'),
        replacementPdfFilePath: any(named: 'replacementPdfFilePath'),
        removeExistingPdf: any(named: 'removeExistingPdf'),
      ),
    ).thenAnswer((_) async => const Left<AppErrorModel, Unit>(tAppError));

    final result = await useCase.call(lesson: tLessonEntity);

    expect(result.isLeft(), isTrue);
  });
}

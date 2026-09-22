import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/features/lessons/domain/use_cases/create_lesson_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockLessonsRepository repository;
  late CreateLessonUseCase useCase;

  setUpAll(() {
    registerFallbackValue(tLessonEntity);
  });

  setUp(() {
    repository = MockLessonsRepository();
    useCase = CreateLessonUseCase(repository: repository);
  });

  test('calls createLesson on the repository with the given lesson', () async {
    when(
      () => repository.createLesson(
        lesson: any(named: 'lesson'),
        localPdfFilePath: any(named: 'localPdfFilePath'),
      ),
    ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));

    final result = await useCase.call(lesson: tLessonEntity);

    expect(result, equals(const Right<AppErrorModel, Unit>(unit)));
    verify(
      () => repository.createLesson(lesson: tLessonEntity),
    ).called(1);
  });

  test('supports creating a lesson without a pdf (pdf-optional)', () async {
    when(
      () => repository.createLesson(
        lesson: any(named: 'lesson'),
        localPdfFilePath: any(named: 'localPdfFilePath'),
      ),
    ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));

    final result = await useCase.call(lesson: tLessonEntityWithoutPdf);

    expect(result.isRight(), isTrue);
    verify(
      () => repository.createLesson(
        lesson: tLessonEntityWithoutPdf,
        localPdfFilePath: null,
      ),
    ).called(1);
  });

  test('forwards the local pdf file path when a pdf is attached', () async {
    when(
      () => repository.createLesson(
        lesson: any(named: 'lesson'),
        localPdfFilePath: any(named: 'localPdfFilePath'),
      ),
    ).thenAnswer((_) async => const Right<AppErrorModel, Unit>(unit));

    await useCase.call(
      lesson: tLessonEntity,
      localPdfFilePath: tLocalPdfFilePath,
    );

    verify(
      () => repository.createLesson(
        lesson: tLessonEntity,
        localPdfFilePath: tLocalPdfFilePath,
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
      () => repository.createLesson(
        lesson: any(named: 'lesson'),
        localPdfFilePath: any(named: 'localPdfFilePath'),
      ),
    ).thenAnswer((_) async => const Left<AppErrorModel, Unit>(tAppError));

    final result = await useCase.call(lesson: tLessonEntity);

    expect(result.isLeft(), isTrue);
    result.fold(
      (error) => expect(error.code, 'internal'),
      (_) => fail('expected Left'),
    );
  });
}

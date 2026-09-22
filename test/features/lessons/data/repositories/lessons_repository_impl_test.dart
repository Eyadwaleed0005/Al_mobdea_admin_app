import 'package:al_mobdea_admin/core/errors/error_model/app_error_model.dart';
import 'package:al_mobdea_admin/core/errors/exceptions/firebase_remote_exception.dart';
import 'package:al_mobdea_admin/features/lessons/data/models/lesson_model.dart';
import 'package:al_mobdea_admin/features/lessons/data/repositories/lessons_repository_impl.dart';
import 'package:al_mobdea_admin/features/lessons/domain/entities/lesson_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockLessonsRemoteDataSource remoteDataSource;
  late LessonsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(tLessonModel);
    registerFallbackValue(tLessonEntity);
  });

  setUp(() {
    remoteDataSource = MockLessonsRemoteDataSource();
    repository = LessonsRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );
  });

  const tAppError = AppErrorModel(
    code: 'internal',
    message: 'server error',
    type: AppErrorType.server,
    isRetryable: true,
  );

  final tRemoteException = FirebaseRemoteException(
    errorModel: tAppError,
  );

  group('getLessons', () {
    test('returns an unmodifiable list of lesson entities on success', () async {
      when(
        () => remoteDataSource.getLessons(
          gradeId: any(named: 'gradeId'),
          isPublished: any(named: 'isPublished'),
        ),
      ).thenAnswer((_) async => [tLessonModel]);

      final result = await repository.getLessons();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (lessons) {
        expect(lessons, isA<List<LessonEntity>>());
        expect(lessons.single.lessonId, tLessonId);
        expect(
          () => lessons.add(tLessonEntity),
          throwsUnsupportedError,
        );
      });
      verify(
        () => remoteDataSource.getLessons(
          gradeId: any(named: 'gradeId'),
          isPublished: any(named: 'isPublished'),
        ),
      ).called(1);
    });

    test('forwards the grade and publication filters', () async {
      when(
        () => remoteDataSource.getLessons(
          gradeId: any(named: 'gradeId'),
          isPublished: any(named: 'isPublished'),
        ),
      ).thenAnswer((_) async => <LessonModel>[]);

      await repository.getLessons(
        gradeId: tGradeId,
        isPublished: true,
      );

      final captured = verify(
        () => remoteDataSource.getLessons(
          gradeId: captureAny(named: 'gradeId'),
          isPublished: captureAny(named: 'isPublished'),
        ),
      ).captured;

      expect(captured[0], tGradeId);
      expect(captured[1], isTrue);
    });

    test(
      'returns Left(AppErrorModel) when the datasource throws',
      () async {
        when(
          () => remoteDataSource.getLessons(
            gradeId: any(named: 'gradeId'),
            isPublished: any(named: 'isPublished'),
          ),
        ).thenThrow(tRemoteException);

        final result = await repository.getLessons();

        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error.code, 'internal'),
          (_) => fail('expected Left'),
        );
      },
    );
  });

  group('getLessonById', () {
    test('returns the lesson on success', () async {
      when(
        () => remoteDataSource.getLessonById(
          lessonId: any(named: 'lessonId'),
        ),
      ).thenAnswer((_) async => tLessonModel);

      final result = await repository.getLessonById(
        lessonId: tLessonId,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (lesson) => expect(lesson.lessonId, tLessonId),
      );
    });

    test('returns Left when the datasource throws', () async {
      when(
        () => remoteDataSource.getLessonById(
          lessonId: any(named: 'lessonId'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.getLessonById(
        lessonId: tLessonId,
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('createLesson', () {
    test('returns Right(unit) on success without a pdf (pdf-optional)', () async {
      when(
        () => remoteDataSource.createLesson(
          lesson: any(named: 'lesson'),
          localPdfFilePath: any(named: 'localPdfFilePath'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.createLesson(
        lesson: tLessonEntityWithoutPdf,
      );

      expect(
        result,
        equals(const Right<AppErrorModel, Unit>(unit)),
      );
      verify(
        () => remoteDataSource.createLesson(
          lesson: any(named: 'lesson'),
          localPdfFilePath: null,
        ),
      ).called(1);
    });

    test(
      'forwards the local pdf file path when a pdf is attached',
      () async {
        when(
          () => remoteDataSource.createLesson(
            lesson: any(named: 'lesson'),
            localPdfFilePath: any(named: 'localPdfFilePath'),
          ),
        ).thenAnswer((_) async {});

        await repository.createLesson(
          lesson: tLessonEntity,
          localPdfFilePath: tLocalPdfFilePath,
        );

        final captured = verify(
          () => remoteDataSource.createLesson(
            lesson: captureAny(named: 'lesson'),
            localPdfFilePath: captureAny(
              named: 'localPdfFilePath',
            ),
          ),
        ).captured;

        final lesson = captured[0] as LessonModel;
        expect(captured[1], tLocalPdfFilePath);
        expect(lesson.pdfStoragePath, tPdfStoragePath);
        expect(lesson.createdAt, isNull);
      },
    );

    test('returns Left when the datasource throws', () async {
      when(
        () => remoteDataSource.createLesson(
          lesson: any(named: 'lesson'),
          localPdfFilePath: any(named: 'localPdfFilePath'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.createLesson(
        lesson: tLessonEntity,
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('updateLesson', () {
    test(
      'returns Right(unit) on success without pdf changes',
      () async {
        when(
          () => remoteDataSource.updateLesson(
            lesson: any(named: 'lesson'),
            replacementPdfFilePath: any(
              named: 'replacementPdfFilePath',
            ),
            removeExistingPdf: any(named: 'removeExistingPdf'),
          ),
        ).thenAnswer((_) async {});

        final result = await repository.updateLesson(
          lesson: tLessonEntityWithoutPdf,
        );

        expect(
          result,
          equals(const Right<AppErrorModel, Unit>(unit)),
        );
        verify(
          () => remoteDataSource.updateLesson(
            lesson: any(named: 'lesson'),
            replacementPdfFilePath: null,
            removeExistingPdf: false,
          ),
        ).called(1);
      },
    );

    test(
      'forwards removeExistingPdf and the replacement pdf path',
      () async {
        when(
          () => remoteDataSource.updateLesson(
            lesson: any(named: 'lesson'),
            replacementPdfFilePath: any(
              named: 'replacementPdfFilePath',
            ),
            removeExistingPdf: any(named: 'removeExistingPdf'),
          ),
        ).thenAnswer((_) async {});

        await repository.updateLesson(
          lesson: tLessonEntity,
          replacementPdfFilePath: tLocalPdfFilePath,
          removeExistingPdf: true,
        );

        final captured = verify(
          () => remoteDataSource.updateLesson(
            lesson: any(named: 'lesson'),
            replacementPdfFilePath: captureAny(
              named: 'replacementPdfFilePath',
            ),
            removeExistingPdf: captureAny(
              named: 'removeExistingPdf',
            ),
          ),
        ).captured;

        // Captured named arguments are returned in alphabetical order:
        // removeExistingPdf, then replacementPdfFilePath.
        expect(captured[0], isTrue);
        expect(captured[1], tLocalPdfFilePath);
      },
    );

    test('returns Left when the datasource throws', () async {
      when(
        () => remoteDataSource.updateLesson(
          lesson: any(named: 'lesson'),
          replacementPdfFilePath: any(
            named: 'replacementPdfFilePath',
          ),
          removeExistingPdf: any(named: 'removeExistingPdf'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.updateLesson(
        lesson: tLessonEntity,
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('deleteLesson', () {
    test('returns Right(unit) on success', () async {
      when(
        () => remoteDataSource.deleteLesson(
          lessonId: any(named: 'lessonId'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.deleteLesson(
        lessonId: tLessonId,
      );

      expect(
        result,
        equals(const Right<AppErrorModel, Unit>(unit)),
      );
    });

    test('returns Left when the datasource throws', () async {
      when(
        () => remoteDataSource.deleteLesson(
          lessonId: any(named: 'lessonId'),
        ),
      ).thenThrow(tRemoteException);

      final result = await repository.deleteLesson(
        lessonId: tLessonId,
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('streamLessons', () {
    test('emits Right(list) on success', () async {
      when(
        () => remoteDataSource.streamLessons(
          gradeId: any(named: 'gradeId'),
          isPublished: any(named: 'isPublished'),
        ),
      ).thenAnswer((_) => Stream.value([tLessonModel]));

      final stream = repository.streamLessons();

      await expectLater(
        stream,
        emits(isA<Right<AppErrorModel, List<LessonEntity>>>()),
      );
    });

    test(
      'emits Left(AppErrorModel) when the stream throws',
      () async {
        when(
          () => remoteDataSource.streamLessons(
            gradeId: any(named: 'gradeId'),
            isPublished: any(named: 'isPublished'),
          ),
        ).thenAnswer((_) => Stream.error(tRemoteException));

        final stream = repository.streamLessons();

        await expectLater(
          stream,
          emits(isA<Left<AppErrorModel, List<LessonEntity>>>()),
        );
      },
    );
  });
}

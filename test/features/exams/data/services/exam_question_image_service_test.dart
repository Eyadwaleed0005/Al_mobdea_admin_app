import 'dart:typed_data';

import 'package:al_mobdea_admin/features/exams/data/services/exam_question_image_service.dart';
import 'package:al_mobdea_admin/features/exams/domain/exam_question_image_file.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/dummy_data.dart';
import '../../../../helpers/test_helper.dart';

class _MockFullMetadata extends Mock implements FullMetadata {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockStorageService storageService;
  late ExamQuestionImageService imageService;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    storageService = MockStorageService();

    when(
      () => storageService.deleteFile(
        storagePath: any(named: 'storagePath'),
      ),
    ).thenAnswer((_) async {});

    imageService = ExamQuestionImageService(
      storageService: storageService,
      firebaseFirestore: fakeFirestore,
    );
  });

  ExamQuestionImageUploadResult stubSuccessfulUpload({
    String downloadUrl = tExamQuestionImageDownloadUrl,
  }) {
    final metadata = _MockFullMetadata();

    when(() => metadata.fullPath).thenAnswer((invocation) {
      final storagePath = invocation.namedArguments[#storagePath];

      return storagePath as String? ?? tExamQuestionImageStoragePath;
    });

    when(
      () => storageService.uploadData(
        data: any(named: 'data'),
        storagePath: any(named: 'storagePath'),
        contentType: any(named: 'contentType'),
        customMetadata: any(named: 'customMetadata'),
      ),
    ).thenAnswer((_) async => metadata);

    when(
      () => storageService.getDownloadUrl(
        storagePath: any(named: 'storagePath'),
      ),
    ).thenAnswer((_) async => downloadUrl);

    return ExamQuestionImageUploadResult(
      downloadUrl: downloadUrl,
      storagePath: tExamQuestionImageStoragePath,
    );
  }

  group('uploadImage', () {
    test(
      'uploads bytes and returns download url and storage path',
      () async {
        stubSuccessfulUpload();

        final result = await imageService.uploadImage(
          image: tExamQuestionImageFile,
          examId: tExamId,
          questionId: tExamQuestionId,
        );

        expect(
          result.downloadUrl,
          tExamQuestionImageDownloadUrl,
        );
        expect(
          result.storagePath,
          startsWith(
            'exam_question_images/$tExamId/$tExamQuestionId/',
          ),
        );
        expect(result.storagePath, endsWith('.jpg'));

        final captured = verify(
          () => storageService.uploadData(
            data: captureAny(named: 'data'),
            storagePath: captureAny(named: 'storagePath'),
            contentType: captureAny(named: 'contentType'),
            customMetadata: captureAny(named: 'customMetadata'),
          ),
        ).captured;

        final bytes = captured[0] as Uint8List;
        final storagePath = captured[1] as String;
        final contentType = captured[2] as String;
        final customMetadata =
            captured[3] as Map<String, String>;

        expect(bytes, tExamQuestionImageFile.bytes);
        expect(
          storagePath,
          startsWith(
            'exam_question_images/$tExamId/$tExamQuestionId/',
          ),
        );
        expect(storagePath, endsWith('.jpg'));
        expect(contentType, 'image/jpeg');
        expect(customMetadata['examId'], tExamId);
        expect(customMetadata['questionId'], tExamQuestionId);
        expect(
          customMetadata['originalFileName'],
          tExamQuestionImageName,
        );

        verify(
          () => storageService.getDownloadUrl(
            storagePath: storagePath,
          ),
        ).called(1);
      },
    );

    test('uploads png images with png content type', () async {
      stubSuccessfulUpload();

      await imageService.uploadImage(
        image: ExamQuestionImageFile(
          name: 'diagram.PNG',
          sizeInBytes: 4,
          bytes: Uint8List.fromList(const [1, 2, 3, 4]),
        ),
        examId: tExamId,
        questionId: tExamQuestionId,
      );

      final contentType =
          verify(
                () => storageService.uploadData(
                  data: any(named: 'data'),
                  storagePath: any(named: 'storagePath'),
                  contentType: captureAny(named: 'contentType'),
                  customMetadata: any(named: 'customMetadata'),
                ),
              ).captured.single
              as String;

      expect(contentType, 'image/png');
    });

    test(
      'rolls back the uploaded file when getting the url fails',
      () async {
        final metadata = _MockFullMetadata();

        when(() => metadata.fullPath).thenAnswer((invocation) {
          final storagePath = invocation.namedArguments[#storagePath];

          return storagePath as String? ?? tExamQuestionImageStoragePath;
        });

        when(
          () => storageService.uploadData(
            data: any(named: 'data'),
            storagePath: any(named: 'storagePath'),
            contentType: any(named: 'contentType'),
            customMetadata: any(named: 'customMetadata'),
          ),
        ).thenAnswer((_) async => metadata);

        when(
          () => storageService.getDownloadUrl(
            storagePath: any(named: 'storagePath'),
          ),
        ).thenThrow(
          FirebaseException(plugin: 'firebase_storage'),
        );

        await expectLater(
          () => imageService.uploadImage(
            image: tExamQuestionImageFile,
            examId: tExamId,
            questionId: tExamQuestionId,
          ),
          throwsA(isA<FirebaseException>()),
        );

        final uploadedStoragePath = verify(
          () => storageService.uploadData(
            data: any(named: 'data'),
            storagePath: captureAny(named: 'storagePath'),
            contentType: any(named: 'contentType'),
            customMetadata: any(named: 'customMetadata'),
          ),
        ).captured.single as String;

        verify(
          () => storageService.deleteFile(
            storagePath: uploadedStoragePath,
          ),
        ).called(1);
      },
    );
  });

  group('deleteImage', () {
    test(
      'deletes the file for the given storage path',
      () async {
        await imageService.deleteImage(
          storagePath: tExamQuestionImageStoragePath,
        );

        verify(
          () => storageService.deleteFile(
            storagePath: tExamQuestionImageStoragePath,
          ),
        ).called(1);
      },
    );

    test(
      'does nothing for an empty or null storage path',
      () async {
        await imageService.deleteImage(storagePath: null);
        await imageService.deleteImage(storagePath: '   ');

        verifyNever(
          () => storageService.deleteFile(
            storagePath: any(named: 'storagePath'),
          ),
        );
      },
    );

    test('ignores object-not-found errors', () async {
      when(
        () => storageService.deleteFile(
          storagePath: any(named: 'storagePath'),
        ),
      ).thenThrow(
        FirebaseException(
          plugin: 'firebase_storage',
          code: 'object-not-found',
        ),
      );

      await expectLater(
        imageService.deleteImage(
          storagePath: tExamQuestionImageStoragePath,
        ),
        completes,
      );
    });

    test('rethrows unexpected errors', () async {
      when(
        () => storageService.deleteFile(
          storagePath: any(named: 'storagePath'),
        ),
      ).thenThrow(
        FirebaseException(
          plugin: 'firebase_storage',
          code: 'unauthorized',
        ),
      );

      await expectLater(
        () => imageService.deleteImage(
          storagePath: tExamQuestionImageStoragePath,
        ),
        throwsA(isA<FirebaseException>()),
      );
    });
  });

  group('deleteImages / silent variants', () {
    test(
      'deleteImages deletes every unique non-empty path',
      () async {
        await imageService.deleteImages(
          storagePaths: [
            tExamQuestionImageStoragePath,
            tReplacementExamQuestionImageStoragePath,
            null,
            '  ',
            tExamQuestionImageStoragePath,
          ],
        );

        verify(
          () => storageService.deleteFile(
            storagePath: tExamQuestionImageStoragePath,
          ),
        ).called(1);
        verify(
          () => storageService.deleteFile(
            storagePath:
                tReplacementExamQuestionImageStoragePath,
          ),
        ).called(1);
      },
    );

    test('deleteImageSilently swallows errors', () async {
      when(
        () => storageService.deleteFile(
          storagePath: any(named: 'storagePath'),
        ),
      ).thenThrow(Exception('boom'));

      await expectLater(
        imageService.deleteImageSilently(
          storagePath: tExamQuestionImageStoragePath,
        ),
        completes,
      );
    });

    test('deleteImagesSilently deletes all paths without failing on errors', () async {
      when(
        () => storageService.deleteFile(
          storagePath: tExamQuestionImageStoragePath,
        ),
      ).thenThrow(Exception('boom'));

      await expectLater(
        imageService.deleteImagesSilently(
          storagePaths: [
            tExamQuestionImageStoragePath,
            tReplacementExamQuestionImageStoragePath,
          ],
        ),
        completes,
      );

      verify(
        () => storageService.deleteFile(
          storagePath: tReplacementExamQuestionImageStoragePath,
        ),
      ).called(1);
    });
  });

  group('path and content type helpers', () {
    test('createImageStoragePath builds a versioned path', () {
      final path = imageService.createImageStoragePath(
        examId: tExamId,
        questionId: tExamQuestionId,
        imageName: 'photo.jpeg',
      );

      expect(
        path,
        startsWith(
          'exam_question_images/$tExamId/$tExamQuestionId/',
        ),
      );
      expect(path, endsWith('.jpg'));
    });

    test('getFileExtension normalizes jpeg to jpg', () {
      expect(imageService.getFileExtension('photo.jpeg'), 'jpg');
      expect(imageService.getFileExtension('photo.JPG'), 'jpg');
      expect(imageService.getFileExtension('photo.png'), 'png');
      expect(
        imageService.getFileExtension('photo.webp'),
        'webp',
      );
    });

    test(
      'getFileExtension throws for unsupported extensions',
      () {
        expect(
          () => imageService.getFileExtension('photo.gif'),
          throwsArgumentError,
        );
        expect(
          () => imageService.getFileExtension('photo'),
          throwsArgumentError,
        );
        expect(
          () => imageService.getFileExtension('photo.'),
          throwsArgumentError,
        );
      },
    );

    test('getImageContentType matches the extension', () {
      expect(
        imageService.getImageContentType('a.jpg'),
        'image/jpeg',
      );
      expect(
        imageService.getImageContentType('a.png'),
        'image/png',
      );
      expect(
        imageService.getImageContentType('a.webp'),
        'image/webp',
      );
    });
  });
}

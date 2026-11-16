import 'dart:async';

import 'package:al_mobdea_admin/core/helper/app_validator.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/cubit/add_lesson_pdf_picker_cubit.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/cubit/add_lesson_pdf_picker_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFilePickerPlatform extends FilePickerPlatform {
  PlatformFile? file;
  Object? error;
  Completer<void>? gate;

  int pickFilesCalls = 0;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
    bool cancelUploadOnWindowBlur = true,
    AndroidSAFOptions? androidSafOptions,
  }) async {
    pickFilesCalls++;

    final pendingGate = gate;

    if (pendingGate != null) {
      await pendingGate.future;
    }

    final selectionError = error;

    if (selectionError != null) {
      throw selectionError;
    }

    final selectedFile = file;

    if (selectedFile == null) {
      return null;
    }

    return FilePickerResult([selectedFile]);
  }
}

void main() {
  late _FakeFilePickerPlatform fakePlatform;
  late FilePickerPlatform originalPlatform;

  final validFile = PlatformFile(
    name: 'lesson.pdf',
    size: 1024,
    path: '/tmp/lesson.pdf',
  );

  setUp(() {
    originalPlatform = FilePickerPlatform.instance;
    fakePlatform = _FakeFilePickerPlatform();
    FilePickerPlatform.instance = fakePlatform;
  });

  tearDown(() {
    FilePickerPlatform.instance = originalPlatform;
  });

  test('initial state is empty and idle', () {
    final cubit = AddLessonPdfPickerCubit();

    expect(cubit.state.isInitial, isTrue);
    expect(cubit.state.isPicking, isFalse);
    expect(cubit.state.isSelected, isFalse);
    expect(cubit.state.selectedFile, isNull);
    expect(cubit.state.hasFailure, isFalse);

    cubit.close();
  });

  blocTest<AddLessonPdfPickerCubit, AddLessonPdfPickerState>(
    'pickPdfFile emits picking then selected for a valid pdf',
    build: AddLessonPdfPickerCubit.new,
    setUp: () {
      fakePlatform.file = validFile;
    },
    act: (cubit) => cubit.pickPdfFile(),
    expect: () => [
      isA<AddLessonPdfPickerState>().having(
        (state) => state.isPicking,
        'isPicking',
        isTrue,
      ),
      isA<AddLessonPdfPickerState>()
          .having((state) => state.isSelected, 'isSelected', isTrue)
          .having((state) => state.selectedFile?.name, 'file', 'lesson.pdf')
          .having((state) => state.hasFailure, 'hasFailure', isFalse),
    ],
    verify: (_) {
      expect(fakePlatform.pickFilesCalls, 1);
    },
  );

  blocTest<AddLessonPdfPickerCubit, AddLessonPdfPickerState>(
    'pickPdfFile returns to the current status when the picker is cancelled',
    build: AddLessonPdfPickerCubit.new,
    setUp: () {
      fakePlatform.file = null;
    },
    act: (cubit) => cubit.pickPdfFile(),
    expect: () => [
      isA<AddLessonPdfPickerState>().having(
        (state) => state.isPicking,
        'isPicking',
        isTrue,
      ),
      isA<AddLessonPdfPickerState>()
          .having((state) => state.isInitial, 'isInitial', isTrue)
          .having((state) => state.selectedFile, 'selectedFile', isNull),
    ],
  );

  blocTest<AddLessonPdfPickerCubit, AddLessonPdfPickerState>(
    'pickPdfFile rejects non-pdf files',
    build: AddLessonPdfPickerCubit.new,
    setUp: () {
      fakePlatform.file = PlatformFile(
        name: 'lesson.docx',
        size: 1024,
        path: '/tmp/lesson.docx',
      );
    },
    act: (cubit) => cubit.pickPdfFile(),
    expect: () => [
      isA<AddLessonPdfPickerState>(),
      isA<AddLessonPdfPickerState>()
          .having((state) => state.hasFailure, 'hasFailure', isTrue)
          .having(
            (state) => state.errorMessage,
            'errorMessage',
            'يجب اختيار ملف PDF فقط',
          )
          .having((state) => state.selectedFile, 'selectedFile', isNull),
    ],
  );

  blocTest<AddLessonPdfPickerCubit, AddLessonPdfPickerState>(
    'pickPdfFile rejects files larger than the maximum lesson pdf size',
    build: AddLessonPdfPickerCubit.new,
    setUp: () {
      fakePlatform.file = PlatformFile(
        name: 'lesson.pdf',
        size: AppValidator.maximumLessonPdfSizeInBytes + 1,
        path: '/tmp/lesson.pdf',
      );
    },
    act: (cubit) => cubit.pickPdfFile(),
    expect: () => [
      isA<AddLessonPdfPickerState>(),
      isA<AddLessonPdfPickerState>()
          .having((state) => state.hasFailure, 'hasFailure', isTrue)
          .having(
            (state) => state.errorMessage,
            'errorMessage',
            contains('15MB'),
          ),
    ],
  );

  blocTest<AddLessonPdfPickerCubit, AddLessonPdfPickerState>(
    'pickPdfFile rejects files without an accessible path',
    build: AddLessonPdfPickerCubit.new,
    setUp: () {
      fakePlatform.file = PlatformFile(name: 'lesson.pdf', size: 1024);
    },
    act: (cubit) => cubit.pickPdfFile(),
    expect: () => [
      isA<AddLessonPdfPickerState>(),
      isA<AddLessonPdfPickerState>()
          .having((state) => state.hasFailure, 'hasFailure', isTrue)
          .having(
            (state) => state.errorMessage,
            'errorMessage',
            'تعذر الوصول إلى مسار الملف المحدد',
          ),
    ],
  );

  blocTest<AddLessonPdfPickerCubit, AddLessonPdfPickerState>(
    'pickPdfFile emits a failure when the picker throws',
    build: AddLessonPdfPickerCubit.new,
    setUp: () {
      fakePlatform.error = Exception('picker crashed');
    },
    act: (cubit) => cubit.pickPdfFile(),
    expect: () => [
      isA<AddLessonPdfPickerState>(),
      isA<AddLessonPdfPickerState>()
          .having((state) => state.hasFailure, 'hasFailure', isTrue)
          .having(
            (state) => state.errorMessage,
            'errorMessage',
            AppValidator.lessonPdfPickingFailureMessage,
          ),
    ],
  );

  blocTest<AddLessonPdfPickerCubit, AddLessonPdfPickerState>(
    'removeSelectedFile clears the selected file',
    build: AddLessonPdfPickerCubit.new,
    setUp: () {
      fakePlatform.file = validFile;
    },
    act: (cubit) async {
      await cubit.pickPdfFile();

      cubit.removeSelectedFile();
    },
    skip: 2,
    expect: () => [
      isA<AddLessonPdfPickerState>()
          .having((state) => state.isInitial, 'isInitial', isTrue)
          .having((state) => state.selectedFile, 'selectedFile', isNull),
    ],
  );

  blocTest<AddLessonPdfPickerCubit, AddLessonPdfPickerState>(
    'consumeFailure restores selected status and keeps the previous file',
    build: AddLessonPdfPickerCubit.new,
    act: (cubit) async {
      fakePlatform.file = validFile;

      await cubit.pickPdfFile();

      fakePlatform.file = PlatformFile(
        name: 'lesson.docx',
        size: 1024,
        path: '/tmp/lesson.docx',
      );

      await cubit.pickPdfFile();

      cubit.consumeFailure();
    },
    skip: 4,
    expect: () => [
      isA<AddLessonPdfPickerState>()
          .having((state) => state.isSelected, 'isSelected', isTrue)
          .having((state) => state.hasFailure, 'hasFailure', isFalse)
          .having((state) => state.selectedFile?.name, 'file', 'lesson.pdf'),
    ],
  );

  test('pickPdfFile ignores calls while a pick is already in progress', () async {
    final gate = Completer<void>();
    fakePlatform
      ..file = validFile
      ..gate = gate;

    final cubit = AddLessonPdfPickerCubit();

    final firstPick = cubit.pickPdfFile();

    await cubit.pickPdfFile();

    expect(fakePlatform.pickFilesCalls, 1);

    gate.complete();

    await firstPick;

    expect(cubit.state.isSelected, isTrue);

    await cubit.close();
  });
}

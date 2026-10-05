class AppImage {
  static AppImage? _instance;

  factory AppImage() {
    _instance ??= AppImage._internal();
    return _instance!;
  }

  AppImage._internal();

  // Base paths
  final String baseImages = 'assets/images/';
  final String baseAnimation = 'assets/animation/';
  final String baseIcons = 'assets/icons/';

  // ===== images =====
  late final String alMobdea = '${baseImages}al_mobdea.png';
  late final String splashLogo = '${baseImages}splash_logo.png';
  late final String splashBackground = '${baseImages}splash_background.png';
  late final String alwaleedImg = '${baseImages}al_mobdea.png';

  // ===== icons =====
  late final String search = '${baseIcons}Search.svg';
  late final String exam = '${baseIcons}exam.svg';
  late final String lessons = '${baseIcons}lessons.svg';
  late final String studyNotes = '${baseIcons}study_notes.svg';
  late final String profile = '${baseIcons}profile.svg';
  late final String home = '${baseIcons}home.svg';
  late final String liveSession = '${baseIcons}live.svg';
  late final String students = '${baseIcons}students.svg';
  late final String bookOpen = '${baseIcons}lessons.svg';
  late final String exams = '${baseIcons}exam.svg';

  // ===== animations =====
}

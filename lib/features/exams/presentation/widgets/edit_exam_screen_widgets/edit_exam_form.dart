import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/app_animations.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:al_mobdea_admin/core/widgets/custom_popup_menu_field.dart';
import 'package:al_mobdea_admin/core/widgets/custom_text_form_field.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_entity.dart';
import 'package:al_mobdea_admin/features/exams/presentation/validation/add_exam_validation.dart';
import 'package:al_mobdea_admin/features/exams/presentation/widgets/add_exam_screen_widgets/exam_publication_switch.dart';
import 'package:al_mobdea_admin/features/exams/presentation/widgets/add_exam_screen_widgets/exam_time_range_fields.dart';
import 'package:al_mobdea_admin/features/exams/presentation/widgets/edit_exam_screen_widgets/edit_exam_actions.dart';
import 'package:al_mobdea_admin/features/exams/presentation/widgets/edit_exam_screen_widgets/edit_exam_questions_card.dart';
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef EditExamSubmit = void Function({
  required String examName,
  required String gradeId,
  required int durationMinutes,
  required bool isPublished,
});

class EditExamForm extends StatefulWidget {
  const EditExamForm({
    super.key,
    required this.exam,
    required this.grades,
    required this.onSaveChangesPressed,
    required this.onOpenQuestionsPressed,
    required this.onCloseExamPressed,
    required this.onDeleteExamPressed,
    this.canCloseExam = true,
    this.isSavingChanges = false,
    this.isClosingExam = false,
    this.isDeletingExam = false,
  });

  final ExamEntity exam;
  final List<GradeEntity> grades;

  final EditExamSubmit onSaveChangesPressed;
  final VoidCallback onOpenQuestionsPressed;
  final VoidCallback onCloseExamPressed;
  final VoidCallback onDeleteExamPressed;

  final bool canCloseExam;

  final bool isSavingChanges;
  final bool isClosingExam;
  final bool isDeletingExam;

  @override
  State<EditExamForm> createState() {
    return _EditExamFormState();
  }
}

class _EditExamFormState extends State<EditExamForm> {
  static const TimeOfDay _defaultStartTime = TimeOfDay(hour: 19, minute: 0);

  static const int _defaultDurationMinutes = 120;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _examNameController;
  late final AddExamValidation _editExamValidation;

  late String _selectedGradeId;
  late bool _isPublished;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String? _timeRangeError;

  bool _isSyncingForm = false;

  bool get _isActionInProgress {
    return widget.isSavingChanges ||
        widget.isClosingExam ||
        widget.isDeletingExam;
  }

  bool get _isExamEnded {
    return widget.exam.isEnded;
  }

  bool get _fieldsEnabled {
    return !_isExamEnded && !_isActionInProgress;
  }

  bool get _hasChanges {
    return _hasChangesComparedTo(widget.exam);
  }

  bool _hasChangesComparedTo(ExamEntity exam) {
    return _examNameController.text.trim() != exam.examName.trim() ||
        _currentDurationMinutes != exam.durationMinutes ||
        _selectedGradeId != exam.gradeId ||
        _isPublished != exam.isPublished;
  }

  int? get _currentDurationMinutes {
    return _durationFor(startTime: _startTime, endTime: _endTime);
  }

  int? _durationFor({
    required TimeOfDay? startTime,
    required TimeOfDay? endTime,
  }) {
    if (startTime == null || endTime == null) {
      return null;
    }

    return ExamTimePickerHelper.durationMinutes(
      startTime: startTime,
      endTime: endTime,
    );
  }

  @override
  void initState() {
    super.initState();

    _editExamValidation = AddExamValidation();

    _examNameController = TextEditingController(text: widget.exam.examName);

    _selectedGradeId = widget.exam.gradeId;
    _isPublished = widget.exam.isPublished;

    _syncTimesFromDuration(widget.exam.durationMinutes);

    _examNameController.addListener(_onFormValueChanged);
  }

  @override
  void didUpdateWidget(covariant EditExamForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool isDifferentExam = oldWidget.exam.examId != widget.exam.examId;

    final bool settingsChanged =
        oldWidget.exam.examName != widget.exam.examName ||
        oldWidget.exam.gradeId != widget.exam.gradeId ||
        oldWidget.exam.durationMinutes != widget.exam.durationMinutes ||
        oldWidget.exam.status != widget.exam.status;

    final bool hadLocalChanges = _hasChangesComparedTo(oldWidget.exam);

    if (isDifferentExam || (settingsChanged && !hadLocalChanges)) {
      _syncFormFromExam();
    }
  }

  void _syncTimesFromDuration(int durationMinutes) {
    final int safeDurationMinutes = durationMinutes > 0
        ? durationMinutes
        : _defaultDurationMinutes;

    final int endMinutes =
        (_defaultStartTime.hour * 60) +
        _defaultStartTime.minute +
        safeDurationMinutes;

    _startTime = _defaultStartTime;

    _endTime = TimeOfDay(
      hour: (endMinutes ~/ 60) % 24,
      minute: endMinutes % 60,
    );
  }

  void _syncFormFromExam() {
    _isSyncingForm = true;

    try {
      _examNameController.text = widget.exam.examName;

      _selectedGradeId = widget.exam.gradeId;
      _isPublished = widget.exam.isPublished;

      _syncTimesFromDuration(widget.exam.durationMinutes);
    } finally {
      _isSyncingForm = false;
    }
  }

  @override
  void dispose() {
    _examNameController.removeListener(_onFormValueChanged);

    _examNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<PopupSelectionItem<String>> gradeItems = widget.grades
        .map((GradeEntity grade) {
          return PopupSelectionItem<String>(
            value: grade.gradeId,
            label: grade.name,
          );
        })
        .toList(growable: false);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppAnimations.formFieldEntrance(
              order: 0,
              child: CustomTextFormField(
                controller: _examNameController,
                labelText: 'اسم الاختبار',
                hintText: 'أدخل اسم الاختبار',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                maxLength: 100,
                enabled: _fieldsEnabled,
                validator: _editExamValidation.validateExamName,
              ),
            ),
            verticalSpace(20),
            AppAnimations.formFieldEntrance(
              order: 1,
              child: _buildGradeField(gradeItems),
            ),
            verticalSpace(24),
            AppAnimations.formFieldEntrance(
              order: 2,
              child: ExcludeFocus(
                excluding: !_fieldsEnabled,
                child: AbsorbPointer(
                  absorbing: !_fieldsEnabled,
                  child: ExamPublicationSwitch(
                    isPublished: _isPublished,
                    onChanged: _changePublicationStatus,
                  ),
                ),
              ),
            ),
            verticalSpace(24),
            AppAnimations.formFieldEntrance(
              order: 3,
              child: ExamTimeRangeFields(
                startTime: _startTime,
                endTime: _endTime,
                isEnabled: _fieldsEnabled,
                errorText: _timeRangeError,
                onStartTimePressed: () {
                  _pickTime(isStartTime: true);
                },
                onEndTimePressed: () {
                  _pickTime(isStartTime: false);
                },
              ),
            ),
            verticalSpace(24),
            AppAnimations.formFieldEntrance(
              order: 4,
              child: EditExamQuestionsCard(
                questionsCount: widget.exam.questionCount,
                totalDegrees: widget.exam.totalScore,
                isEnabled: !_isActionInProgress,
                onOpenQuestionsPressed: _openQuestions,
              ),
            ),
            verticalSpace(28),
            AppAnimations.screenSection(
              delay: 360,
              child: EditExamActions(
                isExamEnded: _isExamEnded,
                isSavingChanges: widget.isSavingChanges,
                isClosingExam: widget.isClosingExam,
                isDeletingExam: widget.isDeletingExam,
                isSaveChangesEnabled: _fieldsEnabled && _hasChanges,
                isCloseExamEnabled: widget.canCloseExam,
                isDeleteExamEnabled: true,
                onSaveChangesPressed: _saveChanges,
                onCloseExamPressed: _closeExam,
                onDeleteExamPressed: _deleteExam,
              ),
            ),
            verticalSpace(20),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeField(List<PopupSelectionItem<String>> gradeItems) {
    return FormField<String>(
      key: ValueKey<String>('${widget.exam.examId}:$_selectedGradeId'),
      initialValue: _selectedGradeId,
      enabled: _fieldsEnabled,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: _validateGrade,
      builder: (gradeField) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: SizedBox(
                width: 220.w,
                child: CustomPopupMenuField<String>(
                  items: gradeItems,
                  value: _selectedGradeId.isEmpty ? null : _selectedGradeId,
                  selectedText: _selectedGradeText,
                  filterValue: _selectedGradeId.isEmpty
                      ? null
                      : _selectedGradeId,
                  tooltip: 'اختر الصف الدراسي',
                  emptyTooltip: 'لا توجد صفوف متاحة',
                  enabled: widget.grades.isNotEmpty && _fieldsEnabled,
                  onSelected: (String gradeId) {
                    if (!_fieldsEnabled) {
                      return;
                    }

                    gradeField.didChange(gradeId);

                    setState(() {
                      _selectedGradeId = gradeId;
                    });
                  },
                ),
              ),
            ),
            if (gradeField.hasError) ...[
              verticalSpace(8),
              Text(
                gradeField.errorText ?? '',
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: AppTextStyle.font12ErrorRegularTajawal(),
              ),
            ],
          ],
        );
      },
    );
  }

  String? _validateGrade(String? value) {
    final String? validationError = _editExamValidation.validateGrade(value);

    if (validationError != null) {
      return validationError;
    }

    final bool exists = widget.grades.any((GradeEntity grade) {
      return grade.gradeId == value;
    });

    if (!exists) {
      return 'الصف المحدد غير متاح. اختر صفًا دراسيًا آخر.';
    }

    return null;
  }

  String get _selectedGradeText {
    for (final GradeEntity grade in widget.grades) {
      if (grade.gradeId == _selectedGradeId) {
        return grade.name;
      }
    }

    return _selectedGradeId.isEmpty ? 'الصف الدراسي' : 'الصف المحدد غير متاح';
  }

  void _onFormValueChanged() {
    if (!mounted || _isSyncingForm || _isActionInProgress) {
      return;
    }

    setState(() {});
  }

  void _changePublicationStatus(bool isPublished) {
    if (!_fieldsEnabled) {
      return;
    }

    setState(() {
      _isPublished = isPublished;
    });
  }

  Future<void> _pickTime({required bool isStartTime}) async {
    if (!_fieldsEnabled) {
      return;
    }

    final TimeOfDay? currentTime = isStartTime ? _startTime : _endTime;

    final TimeOfDay? selectedTime = await ExamTimePickerHelper.show(
      context,
      initialTime: currentTime ?? _defaultStartTime,
      helpText: isStartTime ? 'اختر وقت البداية' : 'اختر وقت النهاية',
    );

    if (!mounted || selectedTime == null) {
      return;
    }

    setState(() {
      if (isStartTime) {
        _startTime = selectedTime;
      } else {
        _endTime = selectedTime;
      }

      _timeRangeError = _validateTimeRange();
    });
  }

  String? _validateTimeRange() {
    final int? durationMinutes = _currentDurationMinutes;

    if (durationMinutes == null) {
      return 'يرجى تحديد وقت البداية ووقت النهاية';
    }

    if (durationMinutes <= 0) {
      return 'وقت النهاية يجب أن يكون بعد وقت البداية';
    }

    return _editExamValidation.validateDuration(durationMinutes.toString());
  }

  void _openQuestions() {
    if (_isActionInProgress) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    widget.onOpenQuestionsPressed();
  }

  void _closeExam() {
    if (_isActionInProgress || !widget.canCloseExam) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    widget.onCloseExamPressed();
  }

  void _deleteExam() {
    if (_isActionInProgress) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    widget.onDeleteExamPressed();
  }

  void _saveChanges() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_fieldsEnabled || !_hasChanges) {
      return;
    }

    final String? timeRangeError = _validateTimeRange();

    setState(() {
      _timeRangeError = timeRangeError;
    });

    final bool isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid || timeRangeError != null) {
      return;
    }

    final int? durationMinutes = _currentDurationMinutes;

    if (durationMinutes == null) {
      return;
    }

    widget.onSaveChangesPressed(
      examName: _examNameController.text.trim(),
      gradeId: _selectedGradeId,
      durationMinutes: durationMinutes,
      isPublished: _isPublished,
    );
  }
}

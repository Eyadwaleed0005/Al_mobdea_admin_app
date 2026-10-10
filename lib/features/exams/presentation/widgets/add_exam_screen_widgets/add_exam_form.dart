import 'package:al_mobdea_admin/app/routes/route_names.dart';
import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/core/style/textstyles.dart';
import 'package:al_mobdea_admin/core/widgets/custom_button.dart';
import 'package:al_mobdea_admin/core/widgets/custom_popup_menu_field.dart';
import 'package:al_mobdea_admin/core/widgets/custom_text_form_field.dart';
import 'package:al_mobdea_admin/features/exams/domain/entities/exam_draft_entity.dart';
import 'package:al_mobdea_admin/features/exams/presentation/cubit/add_exam_cubit.dart';
import 'package:al_mobdea_admin/features/exams/presentation/validation/add_exam_validation.dart';
import 'package:al_mobdea_admin/features/exams/presentation/widgets/add_exam_screen_widgets/exam_publication_switch.dart';
import 'package:al_mobdea_admin/features/exams/presentation/widgets/add_exam_screen_widgets/exam_time_range_fields.dart';
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddExamForm extends StatefulWidget {
  const AddExamForm({super.key, required this.grades});

  final List<GradeEntity> grades;

  @override
  State<AddExamForm> createState() {
    return _AddExamFormState();
  }
}

class _AddExamFormState extends State<AddExamForm> {
  static const TimeOfDay _defaultStartTime = TimeOfDay(hour: 19, minute: 0);

  static const TimeOfDay _defaultEndTime = TimeOfDay(hour: 21, minute: 0);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _examNameController = TextEditingController();

  late final AddExamValidation _addExamValidation;

  String _selectedGradeId = '';

  bool _isPublished = false;

  TimeOfDay? _startTime = _defaultStartTime;

  TimeOfDay? _endTime = _defaultEndTime;

  String? _timeRangeError;

  int? get _durationMinutes {
    final TimeOfDay? startTime = _startTime;
    final TimeOfDay? endTime = _endTime;

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

    _addExamValidation = AddExamValidation();
  }

  @override
  void dispose() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextFormField(
            controller: _examNameController,
            labelText: 'اسم الاختبار',
            hintText: 'مثال: اختبار الباب الأول',
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            maxLength: 100,
            validator: _addExamValidation.validateExamName,
          ),
          verticalSpace(24),
          _buildGradeField(gradeItems),
          verticalSpace(24),
          ExamPublicationSwitch(
            isPublished: _isPublished,
            onChanged: _changePublicationStatus,
          ),
          verticalSpace(24),
          ExamTimeRangeFields(
            startTime: _startTime,
            endTime: _endTime,
            errorText: _timeRangeError,
            onStartTimePressed: () {
              _pickTime(isStartTime: true);
            },
            onEndTimePressed: () {
              _pickTime(isStartTime: false);
            },
          ),
          verticalSpace(32),
          CustomButton(
            text: 'التالي: إضافة الأسئلة',
            onPressed: _handleNextPressed,
          ),
          verticalSpace(24),
        ],
      ),
    );
  }

  Widget _buildGradeField(List<PopupSelectionItem<String>> gradeItems) {
    return FormField<String>(
      key: ValueKey<String>(_selectedGradeId),
      initialValue: _selectedGradeId,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: _addExamValidation.validateGrade,
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
                  enabled: widget.grades.isNotEmpty,
                  onSelected: (String gradeId) {
                    _selectGrade(gradeId);

                    gradeField.didChange(gradeId);
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

  String get _selectedGradeText {
    if (_selectedGradeId.isEmpty) {
      return 'الصف الدراسي';
    }

    for (final GradeEntity grade in widget.grades) {
      if (grade.gradeId == _selectedGradeId) {
        return grade.name;
      }
    }

    return 'الصف الدراسي';
  }

  void _selectGrade(String gradeId) {
    setState(() {
      _selectedGradeId = gradeId;
    });
  }

  void _changePublicationStatus(bool isPublished) {
    setState(() {
      _isPublished = isPublished;
    });
  }

  Future<void> _pickTime({required bool isStartTime}) async {
    final TimeOfDay? currentTime = isStartTime ? _startTime : _endTime;

    final TimeOfDay? selectedTime = await ExamTimePickerHelper.show(
      context,
      initialTime:
          currentTime ?? (isStartTime ? _defaultStartTime : _defaultEndTime),
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

      _timeRangeError = _validateTimeRange(showErrors: false);
    });
  }

  String? _validateTimeRange({required bool showErrors}) {
    final TimeOfDay? startTime = _startTime;
    final TimeOfDay? endTime = _endTime;

    if (startTime == null) {
      return showErrors ? 'يرجى تحديد وقت البداية' : null;
    }

    if (endTime == null) {
      return showErrors ? 'يرجى تحديد وقت النهاية' : null;
    }

    final int durationMinutes = ExamTimePickerHelper.durationMinutes(
      startTime: startTime,
      endTime: endTime,
    );

    if (durationMinutes <= 0) {
      return 'وقت النهاية يجب أن يكون بعد وقت البداية';
    }

    return _addExamValidation.validateDuration(durationMinutes.toString());
  }

  void _handleNextPressed() {
    FocusScope.of(context).unfocus();

    final String? timeRangeError = _validateTimeRange(showErrors: true);

    setState(() {
      _timeRangeError = timeRangeError;
    });

    final bool isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid || timeRangeError != null) {
      return;
    }

    final int? durationMinutes = _durationMinutes;

    if (durationMinutes == null) {
      return;
    }

    final ExamDraftEntity examDraft = context.read<AddExamCubit>().createDraft(
      examName: _examNameController.text.trim(),
      gradeId: _selectedGradeId,
      durationMinutes: durationMinutes,
      isPublished: _isPublished,
    );

    Navigator.of(context)
        .pushNamed(RouteNames.examQuestionsScreen, arguments: examDraft);
  }
}

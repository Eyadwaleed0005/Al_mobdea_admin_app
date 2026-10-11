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
import 'package:al_mobdea_admin/features/grades/domain/entities/grade_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddExamForm extends StatefulWidget {
  const AddExamForm({super.key, required this.grades});

  final List<GradeEntity> grades;

  @override
  State<AddExamForm> createState() => _AddExamFormState();
}

class _AddExamFormState extends State<AddExamForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _examNameController = TextEditingController();

  final TextEditingController _durationController = TextEditingController();

  late final AddExamValidation _addExamValidation;

  String _selectedGradeId = '';
  bool _isPublished = false;

  @override
  void initState() {
    super.initState();
    _addExamValidation = AddExamValidation();
  }

  @override
  void dispose() {
    _examNameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradeItems = widget.grades
        .map((grade) {
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
          CustomTextFormField(
            controller: _durationController,
            labelText: 'مدة الامتحان بالدقائق',
            hintText: 'مثال: ٦٠',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹]')),
            ],
            validator: _validateDuration,
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
                  onSelected: (gradeId) {
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

    for (final grade in widget.grades) {
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

  String _normalizeDigits(String value) {
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    const persianDigits = '۰۱۲۳۴۵۶۷۸۹';

    return value.trim().split('').map((character) {
      final arabicIndex = arabicDigits.indexOf(character);

      if (arabicIndex != -1) {
        return arabicIndex.toString();
      }

      final persianIndex = persianDigits.indexOf(character);

      if (persianIndex != -1) {
        return persianIndex.toString();
      }

      return character;
    }).join();
  }

  String? _validateDuration(String? value) {
    final normalizedValue = _normalizeDigits(value ?? '');

    final validationError = _addExamValidation.validateDuration(
      normalizedValue,
    );

    if (validationError != null) {
      return validationError;
    }

    final duration = int.tryParse(normalizedValue);

    if (duration == null || duration <= 0) {
      return 'أدخل مدة صحيحة أكبر من صفر';
    }

    return null;
  }

  void _handleNextPressed() {
    FocusScope.of(context).unfocus();

    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      return;
    }

    final durationMinutes = int.tryParse(
      _normalizeDigits(_durationController.text),
    );

    if (durationMinutes == null || durationMinutes <= 0) {
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

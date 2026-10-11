import 'package:al_mobdea_admin/core/helper/spacer.dart';
import 'package:al_mobdea_admin/features/lessons/domain/entities/lesson_entity.dart';
import 'package:al_mobdea_admin/features/lessons/presentation/widgets/view_lessons_screen_widgets/lesson_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LessonsList extends StatelessWidget {
  const LessonsList({
    super.key,
    required this.lessons,
    required this.onLessonTap,
  });

  final List<LessonEntity> lessons;
  final ValueChanged<LessonEntity> onLessonTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 20.h),
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: lessons.length,
      separatorBuilder: (_, _) {
        return verticalSpace(12);
      },
      itemBuilder: (context, index) {
        final lesson = lessons[index];

        return LessonCard(
          title: lesson.title,
          subtitle: lesson.subtitle,
          isPublished: lesson.isPublished,
          onTap: () {
            onLessonTap(lesson);
          },
        );
      },
    );
  }
}

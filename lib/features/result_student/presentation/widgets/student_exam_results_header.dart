import 'package:al_mobdea_admin/core/widgets/custom_header_bar.dart';
import 'package:flutter/material.dart';

class StudentExamResultsHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const StudentExamResultsHeader({super.key});

  @override
  Size get preferredSize => const CustomHeaderBar(title: '').preferredSize;

  @override
  Widget build(BuildContext context) {
    return const CustomHeaderBar(title: 'نتائج الطالب', showBackButton: true);
  }
}

import 'package:al_mobdea_admin/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class CustomHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomHeaderBar({
    super.key,
    required this.title,
    this.iconPath,
    this.showProfileIcon = true,
    this.onProfileTap,
  });

  final String title;
  final String? iconPath;
  final bool showProfileIcon;
  final VoidCallback? onProfileTap;

  @override
  Size get preferredSize => const CustomAppBar(title: '').preferredSize;

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      showProfileIcon: showProfileIcon,
      onProfileTap: onProfileTap,
    );
  }
}

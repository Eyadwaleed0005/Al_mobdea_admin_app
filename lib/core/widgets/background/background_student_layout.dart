import 'package:flutter/material.dart';

class StudentBackgroundCornerGradients extends StatelessWidget {
  const StudentBackgroundCornerGradients({
    super.key,
    this.showTopRight = true,
    this.showBottomLeft = true,
  });

  final bool showTopRight;
  final bool showBottomLeft;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (showTopRight)
          const Positioned(
            top: -140,
            right: -140,
            child: SizedBox(
              width: 300,
              height: 300,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(colors: [Color(0x24690A24), Color(0x00690A24)]),
                ),
              ),
            ),
          ),
        if (showBottomLeft)
          const Positioned(
            bottom: -140,
            left: -140,
            child: SizedBox(
              width: 300,
              height: 300,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(colors: [Color(0x1A690A24), Color(0x00690A24)]),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class BackgroundStudentLayout extends StatelessWidget {
  const BackgroundStudentLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFEF9F2), Color(0xFFFDF4E9), Color(0xFFFFFCF7)],
              stops: [0, 0.5, 1],
            ),
          ),
        ),
        const StudentBackgroundCornerGradients(),
        child,
      ],
    );
  }
}

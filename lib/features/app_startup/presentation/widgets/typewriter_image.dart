import 'dart:async';

import 'package:al_mobdea_admin/core/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TypewriterImage extends StatefulWidget {
  const TypewriterImage({
    super.key,
    required this.imagePath,
    required this.width,
    this.height,
    this.delay = const Duration(milliseconds: 850),
    this.duration = const Duration(milliseconds: 1000),
    this.fit = BoxFit.contain,
  });

  final String imagePath;
  final double width;
  final double? height;
  final Duration delay;
  final Duration duration;
  final BoxFit fit;

  @override
  State<TypewriterImage> createState() => _TypewriterImageState();
}

class _TypewriterImageState extends State<TypewriterImage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  Timer? _startTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        setState(() => _isTyping = true);
      } else if (status == AnimationStatus.completed) {
        setState(() => _isTyping = false);
      }
    });

    _startTimer = Timer(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;

        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.centerRight,
                    widthFactor: progress,
                    child: Image.asset(widget.imagePath, width: widget.width, height: widget.height, fit: widget.fit),
                  ),
                ),
              ),

              if (_isTyping && progress > 0.02 && progress < 0.98)
                Positioned(
                  right: widget.width * progress - 1.w,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2.5.w,
                    decoration: BoxDecoration(
                      color: ColorPalette.goldHighlight,
                      borderRadius: BorderRadius.circular(2.r),
                      boxShadow: [
                        BoxShadow(
                          color: ColorPalette.goldHighlight.withValues(alpha: 0.6),
                          blurRadius: 6.r,
                          spreadRadius: 1.r,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget? child;
  const AppBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0xFF0A1024),
                        Color(0xFF151D38),
                        Color(0xFF102A43),
                      ]
                    : const [
                        Color(0xFFF1F6FF),
                        Color(0xFFE3F9FF),
                        Color(0xFFF5F2FF),
                      ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -120,
          left: -80,
          child: RepaintBoundary(
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF6CA8FF).withValues(alpha: 0.18)
                    : const Color(0xFF4A8DFF).withValues(alpha: 0.12),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -160,
          right: -120,
          child: RepaintBoundary(
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF7D8BFF).withValues(alpha: 0.16)
                    : const Color(0xFF59E1FF).withValues(alpha: 0.14),
              ),
            ),
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}

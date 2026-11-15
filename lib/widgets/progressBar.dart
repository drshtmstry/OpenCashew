import 'dart:math' as math;
import 'package:budget/colors.dart';
import 'package:budget/struct/settings.dart';
import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double currentPercent;
  final Color color;
  final double height;

  const ProgressBar({
    required this.currentPercent,
    required this.color,
    this.height = 10,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (appStateSettings["linearProgressBarStyle"] == 1) {
      return LayoutBuilder(
        builder: (_, boxConstraints) {
          return CustomPaint(
            size: Size(boxConstraints.maxWidth, height),
            painter: WavyProgressBarPainter(
              progress: (currentPercent / 100),
              color: color,
              backgroundColor: getColor(context, "lightDarkAccentHeavy"),
            ),
          );
        },
      );
    }
    return LayoutBuilder(
      builder: (_, boxConstraints) {
        double x = boxConstraints.maxWidth;
        double progressWidth = (currentPercent / 100) * x;
        return Stack(
          children: [
            Container(
              width: x,
              height: height,
              decoration: BoxDecoration(
                color: getColor(context, "lightDarkAccentHeavy"),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadiusDirectional.circular(100),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 100),
              width: progressWidth,
              height: height,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadiusDirectional.circular(100),
              ),
            ),
          ],
        );
      },
    );
  }
}

class WavyProgressBarPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  WavyProgressBarPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint bgPaint = Paint()..color = backgroundColor;
    RRect bgRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(bgRRect, bgPaint);

    if (progress <= 0) return;

    double progressWidth = (progress.clamp(0.0, 1.0)) * size.width;
    Paint progressPaint = Paint()..color = color;

    Path path = Path();
    path.moveTo(0, size.height / 2);
    double waveLength = 14.0;
    double waveHeight = size.height * 0.35;
    for (double x = 0; x <= progressWidth; x += 1.0) {
      double y = size.height / 2 +
          math.sin(x / waveLength * 2 * math.pi) * waveHeight;
      path.lineTo(x, y);
    }
    path.lineTo(progressWidth, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.save();
    canvas.clipRRect(bgRRect);
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.3, progressWidth, size.height * 0.7),
        progressPaint);
    canvas.drawPath(path, progressPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WavyProgressBarPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Custom compass widget that displays compass dial with Qibla indicator
class CompassWidget extends StatelessWidget {
  final double? compassHeading;
  final double? qiblaDirection;

  const CompassWidget({super.key, this.compassHeading, this.qiblaDirection});

  @override
  Widget build(BuildContext context) {
    // Responsive size: 75% of screen width
    final size = 1.sw * 0.75;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Compass dial
          Transform.rotate(
            angle: compassHeading != null ? -compassHeading! * pi / 180 : 0,
            child: CustomPaint(
              size: Size(size, size),
              painter: CompassPainter(
                isDarkMode: Theme.of(context).brightness == Brightness.dark,
              ),
            ),
          ),

          // Qibla direction indicator (original arrow)
          if (qiblaDirection != null)
            Transform.rotate(
              angle: qiblaDirection! * pi / 180,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20.r,
                      spreadRadius: 5.r,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  size: (size * 0.15),
                  color: Colors.white,
                ),
              ),
            ),

          // Center dot
          Container(
            width: 16.r,
            height: 16.r,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 3.r,
              ),
            ),
          ),

          // Heading display
          if (compassHeading != null)
            Positioned(
              bottom: 20.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10.r,
                    ),
                  ],
                ),
                child: Text(
                  '${compassHeading!.toStringAsFixed(0)}°',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom painter for compass dial
class CompassPainter extends CustomPainter {
  final bool isDarkMode;

  CompassPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Compass circle background
    final backgroundPaint = Paint()
      ..color = isDarkMode
          ? Colors.grey[850]!.withOpacity(0.5)
          : Colors.grey[200]!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Compass circle border
    final borderPaint = Paint()
      ..color = isDarkMode ? Colors.grey[700]! : Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.r;

    canvas.drawCircle(center, radius, borderPaint);

    // Draw cardinal directions
    _drawCardinalDirections(canvas, center, radius);

    // Draw tick marks
    _drawTickMarks(canvas, center, radius);
  }

  void _drawCardinalDirections(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final directions = ['N', 'E', 'S', 'W'];
    final colors = [
      Colors.red, // North
      isDarkMode ? Colors.grey[400]! : Colors.grey[700]!,
      isDarkMode ? Colors.grey[400]! : Colors.grey[700]!,
      isDarkMode ? Colors.grey[400]! : Colors.grey[700]!,
    ];

    for (int i = 0; i < 4; i++) {
      final angle = (i * 90) * pi / 180;
      final x = center.dx + (radius - 35.r) * sin(angle);
      final y = center.dy - (radius - 35.r) * cos(angle);

      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: colors[i],
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius) {
    final tickPaint = Paint()
      ..color = isDarkMode ? Colors.grey[600]! : Colors.grey[500]!
      ..strokeWidth = 2.w;

    for (int i = 0; i < 360; i += 10) {
      final angle = i * pi / 180;
      final isMajorTick = i % 30 == 0;

      final startRadius = radius - (isMajorTick ? 15.r : 10.r);
      final endRadius = radius - 5.r;

      final x1 = center.dx + startRadius * sin(angle);
      final y1 = center.dy - startRadius * cos(angle);
      final x2 = center.dx + endRadius * sin(angle);
      final y2 = center.dy - endRadius * cos(angle);

      if (isMajorTick) {
        tickPaint.strokeWidth = 3.w;
      } else {
        tickPaint.strokeWidth = 1.w;
      }

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }
  }

  @override
  bool shouldRepaint(CompassPainter oldDelegate) => false;
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/compass_theme.dart';

/// Custom compass widget that displays compass dial with Qibla indicator
class CompassWidget extends StatelessWidget {
  final double? compassHeading;
  final double? qiblaDirection;
  final CompassDesign design;

  const CompassWidget({
    super.key,
    this.compassHeading,
    this.qiblaDirection,
    this.design = CompassDesign.classic,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive size: 80% of screen width
    final size = 1.sw * 0.8;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SizedBox(
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
                  isDarkMode: isDarkMode,
                  design: design,
                  primaryColor: Theme.of(context).colorScheme.primary,
                  surfaceColor: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),

            // Qibla direction indicator
            if (qiblaDirection != null)
              Transform.rotate(
                angle: qiblaDirection! * pi / 180,
                child: _buildQiblaIndicator(context, size),
              ),

            // Center element based on design
            _buildCenterDot(context, size),

            // Heading display
            if (compassHeading != null)
              Positioned(
                bottom: 10.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${compassHeading!.toStringAsFixed(0)}°',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQiblaIndicator(BuildContext context, double size) {
    switch (design) {
      case CompassDesign.islamic:
        return Column(
          children: [
            Icon(
              Icons.mosque_rounded,
              size: 40.r,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: size * 0.4),
          ],
        );
      case CompassDesign.glassmorphism:
        return Container(
          width: 4.w,
          height: size * 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0),
              ],
            ),
            borderRadius: BorderRadius.circular(2.r),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                blurRadius: 10.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
        );
      case CompassDesign.mechanical:
        return CustomPaint(
          size: Size(size, size),
          painter: NeedlePainter(
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      case CompassDesign.classic:
        return Column(
          children: [
            Container(
              width: size * 0.1,
              height: size * 0.1,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 15.r,
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                size: size * 0.06,
                color: Colors.white,
              ),
            ),
            SizedBox(height: size * 0.7),
          ],
        );
    }
  }

  Widget _buildCenterDot(BuildContext context, double size) {
    return Container(
      width: 12.r,
      height: 12.r,
      decoration: BoxDecoration(
        color: design == CompassDesign.mechanical 
            ? Colors.grey[400] 
            : Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: 2.r,
        ),
      ),
    );
  }
}

class CompassPainter extends CustomPainter {
  final bool isDarkMode;
  final CompassDesign design;
  final Color primaryColor;
  final Color surfaceColor;

  CompassPainter({
    required this.isDarkMode,
    required this.design,
    required this.primaryColor,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    switch (design) {
      case CompassDesign.islamic:
        _paintIslamic(canvas, center, radius);
        break;
      case CompassDesign.glassmorphism:
        _paintGlassmorphism(canvas, center, radius);
        break;
      case CompassDesign.mechanical:
        _paintMechanical(canvas, center, radius);
        break;
      case CompassDesign.classic:
        _paintClassic(canvas, center, radius);
        break;
    }
  }

  void _paintClassic(Canvas canvas, Offset center, double radius) {
    final bgPaint = Paint()
      ..color = isDarkMode ? Colors.grey[900]! : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    final borderPaint = Paint()
      ..color = primaryColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.r;
    canvas.drawCircle(center, radius, borderPaint);

    _drawTickMarks(canvas, center, radius, Colors.grey);
    _drawCardinalDirections(canvas, center, radius, isDarkMode ? Colors.white : Colors.black);
  }

  void _paintIslamic(Canvas canvas, Offset center, double radius) {
    // Background with subtle pattern
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withOpacity(0.1),
          surfaceColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, bgPaint);

    // Islamic Star Pattern Background
    final patternPaint = Paint()
      ..color = primaryColor.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.r;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * pi / 180;
      final path = Path();
      for (int j = 0; j < 8; j++) {
        final innerAngle = (j * 45) * pi / 180 + angle;
        final x = center.dx + radius * 0.8 * cos(innerAngle);
        final y = center.dy + radius * 0.8 * sin(innerAngle);
        if (j == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, patternPaint);
    }

    final borderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.r;
    canvas.drawCircle(center, radius, borderPaint);

    _drawTickMarks(canvas, center, radius, primaryColor);
    _drawCardinalDirections(canvas, center, radius, primaryColor);
  }

  void _paintGlassmorphism(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.05),
        ],
      ).createShader(rect);
    
    canvas.drawCircle(center, radius, bgPaint);

    // Glow effect
    final glowPaint = Paint()
      ..color = primaryColor.withOpacity(0.1)
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, 20.r);
    canvas.drawCircle(center, radius, glowPaint);

    final borderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.1),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.r;
    canvas.drawCircle(center, radius, borderPaint);

    _drawTickMarks(canvas, center, radius, Colors.white.withOpacity(0.5));
    _drawCardinalDirections(canvas, center, radius, Colors.white);
  }

  void _paintMechanical(Canvas canvas, Offset center, double radius) {
    // Outer metallic ring
    final outerRingPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.grey[800]!,
          Colors.grey[400]!,
          Colors.grey[800]!,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15.r;
    canvas.drawCircle(center, radius - 7.5.r, outerRingPaint);

    // Inner dial
    final dialPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 15.r, dialPaint);

    // Precision ticks
    for (int i = 0; i < 360; i += 2) {
      final angle = i * pi / 180;
      final isMain = i % 10 == 0;
      final isCardinal = i % 90 == 0;
      
      final start = radius - 15.r;
      final end = radius - (isCardinal ? 35.r : (isMain ? 25.r : 20.r));
      
      final paint = Paint()
        ..color = isCardinal ? primaryColor : (isDarkMode ? Colors.grey[600]! : Colors.grey[400]!)
        ..strokeWidth = isMain ? 2.r : 1.r;

      canvas.drawLine(
        Offset(center.dx + start * sin(angle), center.dy - start * cos(angle)),
        Offset(center.dx + end * sin(angle), center.dy - end * cos(angle)),
        paint,
      );
    }

    _drawCardinalDirections(canvas, center, radius - 45.r, isDarkMode ? Colors.white : Colors.black);
  }

  void _drawCardinalDirections(Canvas canvas, Offset center, double radius, Color color) {
    final directions = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90) * pi / 180;
      final x = center.dx + (radius - 30.r) * sin(angle);
      final y = center.dy - (radius - 30.r) * cos(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: directions[i] == 'N' ? Colors.red : color,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius, Color color) {
    for (int i = 0; i < 360; i += 10) {
      final angle = i * pi / 180;
      final isMajor = i % 30 == 0;
      
      final start = radius - (isMajor ? 15.r : 10.r);
      final end = radius - 5.r;
      
      final paint = Paint()
        ..color = color.withOpacity(0.5)
        ..strokeWidth = isMajor ? 2.r : 1.r;

      canvas.drawLine(
        Offset(center.dx + start * sin(angle), center.dy - start * cos(angle)),
        Offset(center.dx + end * sin(angle), center.dy - end * cos(angle)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class NeedlePainter extends CustomPainter {
  final Color color;
  NeedlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx, center.dy - size.width * 0.45);
    path.lineTo(center.dx - 8.r, center.dy);
    path.lineTo(center.dx + 8.r, center.dy);
    path.close();

    canvas.drawPath(path, paint);

    // Decorative circle at base of needle
    canvas.drawCircle(center, 4.r, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

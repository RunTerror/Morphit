import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shapes_morphing/models/vector3d.dart';

class MorphPainter extends CustomPainter {
  final List<Vector3D> fromPoints;
  final List<Vector3D> toPoints;
  final double t;
  final double rotation;

  MorphPainter({
    required this.fromPoints,
    required this.toPoints,
    required this.t,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.3;

    final paint = Paint()
      ..color = Colors.cyanAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    final cosR = cos(rotation);
    final sinR = sin(rotation);

    for (var i = 0; i < fromPoints.length; i++) {
      final point = Vector3D.lerp(fromPoints[i], toPoints[i], t);

      double x = point.x * cosR + point.z * sinR;
      double z = -point.x * sinR + point.z * cosR;
      double y = point.y;

      final cameraDist = 4.0;
      final scale = cameraDist / (cameraDist - z);

      final dx = x * scale * radius;
      final dy = y * scale * radius;

      final opacity = (z + 1) / 2;
      final constrainedOpacity = (0.3 + 0.7 * opacity).clamp(0.0, 1.0);

      final hue = 190 + (i / fromPoints.length) * 40;

      final lightness = 0.5 + (0.4 * opacity);

      final baseColor = HSLColor.fromAHSL(1.0, hue, 1.0, lightness).toColor();

      paint.color = baseColor.withOpacity(constrainedOpacity);
      paint.strokeWidth = 1.4 * scale;

      canvas.drawPoints(PointMode.points, [center + Offset(dx, dy)], paint);
    }
  }

  @override
  bool shouldRepaint(covariant MorphPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.t != t ||
        oldDelegate.fromPoints != fromPoints ||
        oldDelegate.toPoints != toPoints;
  }
}

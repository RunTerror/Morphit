import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shapes_morphing/models/rotation_axis.dart';
import 'package:shapes_morphing/models/vector3d.dart';
import 'package:shapes_morphing/models/view_perspective.dart';

class MorphPainter extends CustomPainter {
  final List<Vector3D> fromPoints;
  final List<Vector3D> toPoints;
  final double t;
  final double rotation;
  final RotationAxis axis;
  final ViewPerspective perspective;

  MorphPainter({
    required this.fromPoints,
    required this.toPoints,
    required this.t,
    required this.rotation,
    this.axis = RotationAxis.y,
    this.perspective = ViewPerspective.positiveZ,
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

      double x = point.x;
      double y = point.y;
      double z = point.z;

      switch (axis) {
        case RotationAxis.x:
          double tempY = y * cosR - z * sinR;
          double tempZ = y * sinR + z * cosR;
          y = tempY;
          z = tempZ;
          break;
        case RotationAxis.y:
          double tempX = x * cosR + z * sinR;
          double tempZ = -x * sinR + z * cosR;
          x = tempX;
          z = tempZ;
          break;
        case RotationAxis.z:
          double tempX = x * cosR - y * sinR;
          double tempY = x * sinR + y * cosR;
          x = tempX;
          y = tempY;
          break;
      }

      double finalX = x;
      double finalY = y;
      double finalZ = z;

      switch (perspective) {
        case ViewPerspective.positiveZ:
          break;
        case ViewPerspective.negativeZ:
          finalX = -x;
          finalZ = -z;
          break;
        case ViewPerspective.positiveX:
          finalX = z;
          finalZ = -x;
          break;
        case ViewPerspective.negativeX:
          finalX = -z;
          finalZ = x;
          break;
        case ViewPerspective.positiveY:
          finalY = z;
          finalZ = -y;
          break;
        case ViewPerspective.negativeY:
          finalY = -z;
          finalZ = y;
          break;
      }

      final cameraDist = 4.0;
      final scale = cameraDist / (cameraDist - finalZ);

      final dx = finalX * scale * radius;
      final dy = finalY * scale * radius;

      final opacity = (finalZ + 1) / 2;
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
        oldDelegate.toPoints != toPoints ||
        oldDelegate.axis != axis ||
        oldDelegate.perspective != perspective;
  }
}

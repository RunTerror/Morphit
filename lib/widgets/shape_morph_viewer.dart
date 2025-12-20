import 'package:flutter/material.dart';
import 'package:shapes_morphing/models/vector3d.dart';
import 'package:shapes_morphing/painter/morph_painter.dart';

class ShapeMorphViewer extends StatelessWidget {
  final List<Vector3D> fromPoints;
  final List<Vector3D> toPoints;
  final double t;
  final double rotation;

  const ShapeMorphViewer({
    super.key,
    required this.fromPoints,
    required this.toPoints,
    required this.t,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: MorphPainter(
        fromPoints: fromPoints,
        toPoints: toPoints,
        t: t,
        rotation: rotation,
      ),
    );
  }
}

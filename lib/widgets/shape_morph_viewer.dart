import 'package:flutter/material.dart';
import 'package:shapes_morphing/models/rotation_axis.dart';
import 'package:shapes_morphing/models/vector3d.dart';
import 'package:shapes_morphing/models/view_perspective.dart';
import 'package:shapes_morphing/painter/morph_painter.dart';

class ShapeMorphViewer extends StatelessWidget {
  final List<Vector3D> fromPoints;
  final List<Vector3D> toPoints;
  final double t;
  final double rotation;
  final RotationAxis axis;
  final ViewPerspective perspective;

  const ShapeMorphViewer({
    super.key,
    required this.fromPoints,
    required this.toPoints,
    required this.t,
    required this.rotation,
    this.axis = RotationAxis.y,
    this.perspective = ViewPerspective.positiveZ,
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
        axis: axis,
        perspective: perspective,
      ),
    );
  }
}

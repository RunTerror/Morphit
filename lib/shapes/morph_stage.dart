import 'dart:math';

import 'package:flutter/material.dart';

class MorphStage {
  final int fromIndex;
  final int toIndex;
  final double t;

  const MorphStage({
    required this.fromIndex,
    required this.toIndex,
    required this.t,
  });

  factory MorphStage.fromIndex(
    double index,
    int totalCount, {
    Curve curve = Curves.decelerate,
  }) {
    if (totalCount <= 1) {
      return MorphStage(fromIndex: 0, toIndex: 0, t: 0);
    }

    final clamped = index.clamp(0.0, (totalCount - 1).toDouble());
    final start = clamped.floor();
    final end = min(start + 1, totalCount - 1);

    final tLinear = start == end ? 0.0 : clamped - start;
    final tCurved = curve.transform(tLinear);

    return MorphStage(fromIndex: start, toIndex: end, t: tCurved);
  }
}

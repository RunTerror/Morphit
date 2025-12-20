import 'dart:math';

import 'package:shapes_morphing/models/seed.dart';
import 'package:shapes_morphing/models/vector3d.dart';

class ShapeGenerator {
  static List<Seed> generateQuasiRandomPoints(int count) {
    const goldenRatioConjugate = 0.6180339887498948;

    return List.generate(count, (i) {
      final u = (i + 0.5) / count;
      final v = (i * goldenRatioConjugate) % 1.0;
      return Seed(a: u, b: v);
    }, growable: false);
  }

  static List<Vector3D> generateSphere(List<Seed> dots) {
    return List.generate(dots.length, (i) {
      final a = dots[i].a;
      final b = dots[i].b;

      final theta = b * pi * 2;
      final y = 1 - 2 * a;
      final r = sqrt(1 - y * y);

      return Vector3D(x: r * cos(theta), y: y, z: r * sin(theta));
    }, growable: false);
  }

  static List<Vector3D> generateCubeFromSphere(List<Vector3D> dots) {
    return List.generate(dots.length, (index) {
      final dot = dots[index];
      final x = dot.x;
      final y = dot.y;
      final z = dot.z;
      final maxAbs = max(x.abs(), max(y.abs(), z.abs()));
      return Vector3D(x: x / maxAbs, y: y / maxAbs, z: z / maxAbs);
    }, growable: false);
  }

  static List<Vector3D> generateTorus(List<Seed> points) {
    final major = 0.66;
    final minor = 0.32;

    return List.generate(points.length, (index) {
      final theta = points[index].a * pi * 2;
      final phi = points[index].b * pi * 2;

      final x = (major + minor * cos(phi)) * cos(theta);
      final y = minor * sin(phi);
      final z = (major + minor * cos(phi)) * sin(theta);
      return Vector3D(x: x, y: y, z: z);
    }, growable: false);
  }

  static List<Vector3D> generateHeart(List<Seed> seeds) {
    return List.generate(seeds.length, (i) {
      final u = seeds[i].a * pi;
      final v = seeds[i].b * pi * 2;

      final sinU = sin(u);
      final radial = 16 * sinU * sinU * sinU;

      final y = 13 * cos(u) - 5 * cos(2 * u) - 2 * cos(3 * u) - cos(4 * u);

      final x = radial * sin(v);
      final z = radial * cos(v);

      return Vector3D(x: x, y: y, z: z);
    }, growable: false);
  }

  static List<Vector3D> moveToCenter(List<Vector3D> points) {
    var minX = double.infinity;
    var maxX = -double.infinity;
    var minY = double.infinity;
    var maxY = -double.infinity;
    var minZ = double.infinity;
    var maxZ = -double.infinity;

    for (final p in points) {
      minX = min(minX, p.x);
      maxX = max(maxX, p.x);
      minY = min(minY, p.y);
      maxY = max(maxY, p.y);
      minZ = min(minZ, p.z);
      maxZ = max(maxZ, p.z);
    }

    final center = Vector3D(
      x: (minX + maxX) / 2,
      y: (minY + maxY) / 2,
      z: (minZ + maxZ) / 2,
    );

    return List.generate(
      points.length,
      (i) => points[i] - center,
      growable: false,
    );
  }

  static List<Vector3D> unitNormalization(List<Vector3D> points) {
    var maxAbs = 0.0;
    for (final p in points) {
      maxAbs = max(maxAbs, max(p.x.abs(), max(p.y.abs(), p.z.abs())));
    }

    if (maxAbs == 0) {
      return points;
    }

    return List.generate(
      points.length,
      (i) => points[i] / maxAbs,
      growable: false,
    );
  }
}

extension VectorExtension on Vector3D {
  Vector3D operator -(Vector3D other) =>
      Vector3D(x: x - other.x, y: y - other.y, z: z - other.z);

  Vector3D operator /(double scalar) =>
      Vector3D(x: x / scalar, y: y / scalar, z: z / scalar);
}

class Vector3D {
  final double x;
  final double y;
  final double z;

  const Vector3D({required this.x, required this.y, required this.z});

  static Vector3D lerp(Vector3D a, Vector3D b, double t) {
    return Vector3D(
      x: a.x + (b.x - a.x) * t,
      y: a.y + (b.y - a.y) * t,
      z: a.z + (b.z - a.z) * t,
    );
  }
}

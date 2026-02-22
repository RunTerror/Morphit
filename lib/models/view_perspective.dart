enum ViewPerspective {
  positiveZ,
  negativeZ,
  positiveX,
  negativeX,
  positiveY,
  negativeY,
}

extension ViewPerspectiveLabels on ViewPerspective {
  String get label {
    switch (this) {
      case ViewPerspective.positiveZ:
        return '+Z (Front)';
      case ViewPerspective.negativeZ:
        return '-Z (Back)';
      case ViewPerspective.positiveX:
        return '+X (Right)';
      case ViewPerspective.negativeX:
        return '-X (Left)';
      case ViewPerspective.positiveY:
        return '+Y (Top)';
      case ViewPerspective.negativeY:
        return '-Y (Bottom)';
    }
  }
}

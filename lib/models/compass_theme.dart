enum CompassDesign {
  classic,
  islamic,
  glassmorphism,
  mechanical,
}

class CompassThemeData {
  final CompassDesign design;
  final String name;

  const CompassThemeData({
    required this.design,
    required this.name,
  });

  static const List<CompassThemeData> themes = [
    CompassThemeData(
      design: CompassDesign.classic,
      name: 'Classic',
    ),
    CompassThemeData(
      design: CompassDesign.islamic,
      name: 'Islamic',
    ),
    CompassThemeData(
      design: CompassDesign.glassmorphism,
      name: 'Modern',
    ),
    CompassThemeData(
      design: CompassDesign.mechanical,
      name: 'Premium',
    ),
  ];
}

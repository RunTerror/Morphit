import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shapes_morphing/models/rotation_axis.dart';
import 'package:shapes_morphing/models/vector3d.dart';
import 'package:shapes_morphing/models/view_perspective.dart';
import 'package:shapes_morphing/shapes/morph_stage.dart';
import 'package:shapes_morphing/shapes/shape_generator.dart';
import 'package:shapes_morphing/widgets/shape_morph_viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shapes Morphing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: const MorphingShapesPage(),
    );
  }
}

class MorphingShapesPage extends StatefulWidget {
  const MorphingShapesPage({super.key});

  @override
  State<MorphingShapesPage> createState() => _MorphingShapesPageState();
}

class _MorphingShapesPageState extends State<MorphingShapesPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<List<Vector3D>> _shapePointsList;
  late PageController _pageController;
  RotationAxis _currentAxis = RotationAxis.y;
  ViewPerspective _currentPerspective = ViewPerspective.positiveZ;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _shapePointsList = [];
    final dots = ShapeGenerator.generateQuasiRandomPoints(2000);
    final sphereSeeds = ShapeGenerator.generateSphere(dots);
    _shapePointsList.add(sphereSeeds);
    _shapePointsList.add(ShapeGenerator.generateCubeFromSphere(sphereSeeds));
    final heart = ShapeGenerator.unitNormalization(
      ShapeGenerator.moveToCenter(ShapeGenerator.generateHeart(dots)),
    );
    _shapePointsList.add(heart);
    _shapePointsList.add(ShapeGenerator.generateTorus(dots));

    _animationController = AnimationController(
      duration: const Duration(seconds: 14),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF1a1a2e), Color(0xFF000000)],
            stops: [0.0, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _animationController,
                  _pageController,
                ]),
                builder: (context, child) {
                  final page = _pageController.hasClients
                      ? _pageController.page ?? 0.0
                      : 0.0;

                  final stage = MorphStage.fromIndex(
                    page,
                    _shapePointsList.length,
                    curve: Curves.decelerate,
                  );

                  return ShapeMorphViewer(
                    fromPoints: _shapePointsList[stage.fromIndex],
                    toPoints: _shapePointsList[stage.toIndex],
                    t: stage.t,
                    rotation: _animationController.value * 2 * pi,
                    axis: _currentAxis,
                    perspective: _currentPerspective,
                  );
                },
              ),
            ),

            PageView.builder(
              controller: _pageController,
              itemCount: _shapePointsList.length,
              itemBuilder: (context, index) {
                return ColoredBox(
                  color: Colors.transparent,
                  child: SizedBox.square(
                    dimension: MediaQuery.of(context).size.height,
                  ),
                );
              },
            ),

            Positioned(
              top: 60,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: RotationAxis.values.map((axis) {
                            final isSelected = _currentAxis == axis;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentAxis = axis;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  axis.name.toUpperCase(),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.cyanAccent
                                        : Colors.white54,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 1,
                          height: 20,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<ViewPerspective>(
                            value: _currentPerspective,
                            dropdownColor: const Color(
                              0xFF1a1a2e,
                            ).withOpacity(0.95),
                            padding: const EdgeInsets.only(right: 6),
                            icon: const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Icon(
                                Icons.visibility_outlined,
                                color: Colors.cyanAccent,
                                size: 18,
                              ),
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            items: ViewPerspective.values.map((perspective) {
                              final isSelected =
                                  _currentPerspective == perspective;
                              return DropdownMenuItem(
                                value: perspective,
                                child: Text(
                                  perspective.label,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.cyanAccent
                                        : Colors.white70,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (ViewPerspective? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _currentPerspective = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  final page = _pageController.hasClients
                      ? _pageController.page ?? 0.0
                      : 0.0;
                  final index = page.round();

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_shapePointsList.length, (i) {
                      final isActive = i == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isActive
                              ? Colors.cyanAccent
                              : Colors.white.withOpacity(0.2),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: Colors.cyanAccent.withAlpha(5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

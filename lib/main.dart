import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shapes_morphing/models/vector3d.dart';
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _shapePointsList = [];
    final dots = ShapeGenerator.generateQuasiRandomPoints(2000);
    final sphereSeeds = ShapeGenerator.generateSphere(dots);
    _shapePointsList.add(sphereSeeds);
    _shapePointsList.add(ShapeGenerator.generateCubeFromSphere(sphereSeeds));
    final heart = ShapeGenerator.normalizeToUnit(
      ShapeGenerator.center(ShapeGenerator.generateHeart(dots)),
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
                    curve: page > 1 ? Curves.easeInOut : Curves.decelerate,
                  );

                  return ShapeMorphViewer(
                    fromPoints: _shapePointsList[stage.fromIndex],
                    toPoints: _shapePointsList[stage.toIndex],
                    t: stage.t,
                    rotation: _animationController.value * 2 * pi,
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

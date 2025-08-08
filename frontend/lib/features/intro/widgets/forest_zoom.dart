import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'breath_fog_effect.dart';

class ForestZoom extends StatefulWidget {
  final VoidCallback onComplete;

  const ForestZoom({Key? key, required this.onComplete}) : super(key: key);

  @override
  _ForestZoomState createState() => _ForestZoomState();
}

class _ForestZoomState extends State<ForestZoom> with TickerProviderStateMixin {
  late final AnimationController _zoomController;
  late final Animation<double> _zoomScale;
  late final Animation<double> _forestOpacity;
  late final Animation<double> _fogIntensity;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _zoomScale = Tween<double>(
      begin: 1.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeInCubic,
    ));

    _forestOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    ));

    _fogIntensity = Tween<double>(
      begin: 1.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _zoomController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _zoomController.forward();
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _zoomController,
      builder: (context, child) {
        return Stack(
          children: [
            Stack(
              children: [
                Transform.scale(
                  scale: _zoomScale.value,
                  child: Opacity(
                    opacity: _forestOpacity.value,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/Upward Through the Forest Canopy.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
              ],
            ),
            Transform.scale(
              scale: _zoomScale.value,
              child: BreathFogEffect(
                child: Container(),
              ),
            ),
          ],
        );
      },
    );
  }
}

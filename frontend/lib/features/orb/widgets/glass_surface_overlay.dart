import 'package:flutter/material.dart';
import 'dart:ui';

class GlassSurfaceOverlay extends StatefulWidget {
  final double size;
  final double borderRadius;
  final double borderWidth;
  final double brightness;
  final double opacity;
  final double blur;
  final double backgroundOpacity;
  final double saturation;
  final Color tintColor;
  final Widget? child;

  const GlassSurfaceOverlay({
    Key? key,
    this.size = 300,
    this.borderRadius = 150, // Half of size for perfect circle
    this.borderWidth = 2.0,
    this.brightness = 1.2,
    this.opacity = 0.15,
    this.blur = 20.0,
    this.backgroundOpacity = 0.1,
    this.saturation = 1.8,
    this.tintColor = Colors.white,
    this.child,
  }) : super(key: key);

  @override
  _GlassSurfaceOverlayState createState() => _GlassSurfaceOverlayState();
}

class _GlassSurfaceOverlayState extends State<GlassSurfaceOverlay>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: widget.tintColor.withOpacity(0.3),
                width: widget.borderWidth,
              ),
              boxShadow: [
                // Outer glow
                BoxShadow(
                  color: widget.tintColor.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blur,
                  sigmaY: widget.blur,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.0,
                      colors: [
                        widget.tintColor.withOpacity(widget.backgroundOpacity * 0.8),
                        widget.tintColor.withOpacity(widget.backgroundOpacity * 0.4),
                        widget.tintColor.withOpacity(widget.backgroundOpacity * 0.1),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                    border: Border.all(
                      color: widget.tintColor.withOpacity(widget.opacity),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.tintColor.withOpacity(widget.opacity * 0.6),
                          Colors.transparent,
                          widget.tintColor.withOpacity(widget.opacity * 0.3),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Specialized circular glass overlay for the halo orb
class CircularGlassOverlay extends StatelessWidget {
  final double size;
  final Color glowColor;
  final double intensity;

  const CircularGlassOverlay({
    Key? key,
    this.size = 300,
    this.glowColor = Colors.green,
    this.intensity = 0.3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassSurfaceOverlay(
      size: size,
      borderRadius: size / 2, // Perfect circle
      borderWidth: 1.5,
      brightness: 1.3,
      opacity: intensity * 0.5,
      blur: 15.0,
      backgroundOpacity: intensity * 0.2,
      saturation: 2.0,
      tintColor: glowColor,
    );
  }
}

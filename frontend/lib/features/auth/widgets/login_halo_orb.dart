import 'package:flutter/material.dart';
import '../../../shader_orb.dart';
import 'dart:async';

class LoginHaloOrb extends StatefulWidget {
  const LoginHaloOrb({Key? key}) : super(key: key);

  @override
  _LoginHaloOrbState createState() => _LoginHaloOrbState();
}

class _LoginHaloOrbState extends State<LoginHaloOrb>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _breathingController;
  late Animation<double> _breathingScale;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _breathingScale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return Transform.scale(
          scale: _breathingScale.value,
          child: const ShaderOrb(
            size: 120,
            hue: 120.0, // Green hue in degrees
            hoverIntensity: 0.3,
            forceHoverState: false,
          ),
        );
      },
    );
  }
}

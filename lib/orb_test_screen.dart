import 'package:flutter/material.dart';
import 'react_bits_orb.dart';
import 'webgl_orb.dart';

class OrbTestScreen extends StatelessWidget {
  const OrbTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Orb Comparison'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // React Bits Orb (New)
            Column(
              children: [
                const Text(
                  'React Bits Orb (New)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const ReactBitsOrb(
                  size: 200,
                  hue: 0,
                  hoverIntensity: 0.5,
                  rotateOnHover: true,
                  forceHoverState: false,
                ),
              ],
            ),
            
            // WebGL Orb (Old)
            Column(
              children: [
                const Text(
                  'WebGL Orb (Old)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const WebGLOrb(
                  size: 200,
                  hue: 0,
                  hoverIntensity: 0.5,
                  rotateOnHover: true,
                  forceHoverState: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

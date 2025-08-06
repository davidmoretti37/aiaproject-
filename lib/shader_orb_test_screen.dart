import 'package:flutter/material.dart';
import 'shader_orb.dart';

class ShaderOrbTestScreen extends StatefulWidget {
  const ShaderOrbTestScreen({Key? key}) : super(key: key);

  @override
  _ShaderOrbTestScreenState createState() => _ShaderOrbTestScreenState();
}

class _ShaderOrbTestScreenState extends State<ShaderOrbTestScreen> {
  double _hue = 0;
  double _hoverIntensity = 0.2;
  bool _rotateOnHover = true;
  bool _forceHoverState = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('GPU Shader Orb - WebGL Quality'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Main orb display
          Expanded(
            flex: 3,
            child: Center(
              child: ShaderOrb(
                size: 340,
                hue: _hue,
                hoverIntensity: _hoverIntensity,
                rotateOnHover: _rotateOnHover,
                forceHoverState: _forceHoverState,
              ),
            ),
          ),
          
          // Controls
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'GPU Fragment Shader - Identical to WebGL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Hue control
                  Row(
                    children: [
                      const Text('Hue: ', style: TextStyle(color: Colors.white)),
                      Expanded(
                        child: Slider(
                          value: _hue,
                          min: 0,
                          max: 360,
                          divisions: 36,
                          label: _hue.round().toString(),
                          onChanged: (value) {
                            setState(() {
                              _hue = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  // Hover intensity control
                  Row(
                    children: [
                      const Text('Hover Intensity: ', style: TextStyle(color: Colors.white)),
                      Expanded(
                        child: Slider(
                          value: _hoverIntensity,
                          min: 0,
                          max: 1,
                          divisions: 20,
                          label: _hoverIntensity.toStringAsFixed(2),
                          onChanged: (value) {
                            setState(() {
                              _hoverIntensity = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  // Toggles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rotateOnHover,
                            onChanged: (value) {
                              setState(() {
                                _rotateOnHover = value ?? true;
                              });
                            },
                          ),
                          const Text('Rotate on Hover', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _forceHoverState,
                            onChanged: (value) {
                              setState(() {
                                _forceHoverState = value ?? false;
                              });
                            },
                          ),
                          const Text('Force Hover', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'hybrid_orb.dart';

class HybridOrbTestScreen extends StatefulWidget {
  const HybridOrbTestScreen({Key? key}) : super(key: key);

  @override
  _HybridOrbTestScreenState createState() => _HybridOrbTestScreenState();
}

class _HybridOrbTestScreenState extends State<HybridOrbTestScreen> {
  double _hue = 0.0;
  double _hoverIntensity = 0.2;
  int _particleCount = 200;
  bool _magnetEnabled = true;
  bool _forceHoverState = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Hybrid Orb Test'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Main orb display
          Expanded(
            flex: 3,
            child: Center(
              child: HybridOrb(
                size: 340,
                hue: _hue,
                hoverIntensity: _hoverIntensity,
                particleCount: _particleCount,
                magnetEnabled: _magnetEnabled,
                forceHoverState: _forceHoverState,
              ),
            ),
          ),
          
          // Controls
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Hybrid Orb Controls',
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
                      Text('Hue: ', style: TextStyle(color: Colors.white)),
                      Expanded(
                        child: Slider(
                          value: _hue,
                          min: 0,
                          max: 360,
                          divisions: 36,
                          label: '${_hue.round()}°',
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
                      Text('Hover Intensity: ', style: TextStyle(color: Colors.white)),
                      Expanded(
                        child: Slider(
                          value: _hoverIntensity,
                          min: 0.0,
                          max: 1.0,
                          divisions: 20,
                          label: _hoverIntensity.toStringAsFixed(1),
                          onChanged: (value) {
                            setState(() {
                              _hoverIntensity = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  // Particle count control
                  Row(
                    children: [
                      Text('Particles: ', style: TextStyle(color: Colors.white)),
                      Expanded(
                        child: Slider(
                          value: _particleCount.toDouble(),
                          min: 50,
                          max: 400,
                          divisions: 35,
                          label: _particleCount.toString(),
                          onChanged: (value) {
                            setState(() {
                              _particleCount = value.round();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  // Toggle controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text('Magnet Effect', style: TextStyle(color: Colors.white, fontSize: 12)),
                          Switch(
                            value: _magnetEnabled,
                            onChanged: (value) {
                              setState(() {
                                _magnetEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Force Hover', style: TextStyle(color: Colors.white, fontSize: 12)),
                          Switch(
                            value: _forceHoverState,
                            onChanged: (value) {
                              setState(() {
                                _forceHoverState = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Text(
                    'Drag your finger/mouse over the orb to see magnetic effects!\nThe orb combines breathing ring animations with 3D particle sphere.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
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

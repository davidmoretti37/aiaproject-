import 'package:flutter/material.dart';
import 'breath_fog_effect.dart';

class FogDemoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1a1a2e),
      appBar: AppBar(
        title: Text('Breath Fog Effect Demo'),
        backgroundColor: Color(0xFF16213e),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Demo with automatic fog effect
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF0f3460),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  Text(
                    'Automatic Fog Effect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2a2a5a),
                          Color(0xFF1a1a3a),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: BreathFogEffect(
                      isActive: true,
                      duration: Duration(seconds: 3),
                      child: Center(
                        child: Text(
                          'AIA',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                            letterSpacing: 8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 40),
            
            // Demo with tap-to-trigger fog effect
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF0f3460),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  Text(
                    'Tap to Trigger Fog Effect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2a2a5a),
                          Color(0xFF1a1a3a),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: BreathTrigger(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'AIA',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                                letterSpacing: 8,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Tap here',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 40),
            
            // Instructions
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'The fog effect simulates someone breathing on a mirror.\n'
                'It creates a misty condensation that appears, grows, and slowly fades away.\n'
                'Perfect for adding a magical, ethereal touch to your animations!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

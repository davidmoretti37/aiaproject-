import 'package:flutter/material.dart';
import '../widgets/aia_animation.dart';
import '../widgets/forest_zoom.dart';

class IntroScreen extends StatefulWidget {
  final VoidCallback onIntroComplete;

  const IntroScreen({Key? key, required this.onIntroComplete}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with TickerProviderStateMixin {
  bool _showAiaAnimation = true;

  @override
  void initState() {
    super.initState();
  }

  void _onAiaAnimationComplete() {
    setState(() {
      _showAiaAnimation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ForestZoom(onComplete: widget.onIntroComplete),
          if (_showAiaAnimation)
            AIAAnimation(onComplete: _onAiaAnimationComplete),
        ],
      ),
    );
  }
}

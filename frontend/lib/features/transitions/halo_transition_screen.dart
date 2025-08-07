import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/widgets/login_halo_orb.dart';
import '../auth/widgets/iridescence_overlay.dart';
import '../auth/widgets/aia_background.dart';
import '../../shader_orb.dart';

class HaloTransitionScreen extends StatefulWidget {
  final VoidCallback onTransitionComplete;
  final String sessionId;

  const HaloTransitionScreen({
    Key? key,
    required this.onTransitionComplete,
    required this.sessionId,
  }) : super(key: key);

  @override
  State<HaloTransitionScreen> createState() => _HaloTransitionScreenState();
}

class _HaloTransitionScreenState extends State<HaloTransitionScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _transitionController;
  late AnimationController _textFadeController;
  
  late Animation<Offset> _haloPosition;
  late Animation<double> _haloScale;
  late Animation<double> _textOpacity;
  
  bool _transitionComplete = false;
  bool _showInteractiveText = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startTransition();
  }

  void _initializeAnimations() {
    // Main transition animation (1.5 seconds)
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Text fade-in animation (350ms)
    _textFadeController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    
    // Halo position animation - from login position to center
    _haloPosition = Tween<Offset>(
      begin: const Offset(0, -0.15), // Login screen position (slightly above center)
      end: const Offset(0, 0), // Center of screen
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeOutCubic,
    ));
    
    // Halo scale animation - from login size to main orb size
    _haloScale = Tween<double>(
      begin: 0.83, // Login halo scale (250px equivalent)
      end: 1.0, // Main orb scale (300px equivalent)
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeOutCubic,
    ));
    
    // Text fade-in animation
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textFadeController,
      curve: Curves.easeOut,
    ));
    
    // Listen for transition completion
    _transitionController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_transitionComplete) {
        _transitionComplete = true;
        setState(() {
          _showInteractiveText = true;
        });
        
        // Start text fade-in after a brief pause
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _textFadeController.forward();
          }
        });
        
        // Don't complete the transition - this becomes the permanent main screen
        // The halo that moved from login is now the interactive main halo
      }
    });
  }

  void _startTransition() {
    // Start the animation immediately after the first frame is rendered for a smooth transition
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _transitionController.forward();
      }
    });
  }

  @override
  void dispose() {
    _transitionController.dispose();
    _textFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Shared iridescent background
          const AiaBackground(),

          // Transitioning halo orb
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_transitionController, _textFadeController]),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _haloPosition.value.dx * MediaQuery.of(context).size.width,
                    _haloPosition.value.dy * MediaQuery.of(context).size.height,
                  ),
                  child: Transform.scale(
                    scale: _haloScale.value,
                    child: const SizedBox(
                      width: 250,
                      height: 250,
                      child: LoginHaloOrb(),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // "Tap the orb to speak" text
          if (_transitionComplete)
            Positioned(
              bottom: 200,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _textOpacity,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacity.value,
                    child: Center(
                      child: Text(
                        'Tap the orb to speak',
                        style: GoogleFonts.inter(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

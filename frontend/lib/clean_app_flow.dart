import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ai_service.dart';
import 'clean_google_login.dart';
import 'clean_halo_orb.dart';
import 'clean_chat_interface.dart';
import 'breath_fog_effect.dart';

enum AppFlowState {
  aiaAnimation,    // AIA text animation
  googleLogin,     // Google login screen
  haloOrb,         // Interactive halo orb
  chatInterface    // Chat interface with speech toggle
}

class CleanAppFlow extends StatefulWidget {
  const CleanAppFlow({Key? key}) : super(key: key);

  @override
  _CleanAppFlowState createState() => _CleanAppFlowState();
}

class _CleanAppFlowState extends State<CleanAppFlow>
    with TickerProviderStateMixin {
  
  AppFlowState _currentState = AppFlowState.aiaAnimation;
  
  // Animation controllers for smooth transitions
  late final AnimationController _lottieController;
  late final AnimationController _zoomController;
  late final AnimationController _transitionController;
  
  // Animations
  late final Animation<double> _zoomScale;
  late final Animation<double> _forestOpacity;
  late final Animation<double> _fogIntensity;
  late final Animation<double> _backgroundTransition;
  late final Animation<double> _fadeTransition;
  
  // State tracking
  bool _startFogEffect = false;
  bool _startZoom = false;
  bool _lottieCompleted = false;
  String? _sessionId;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _startAIAAnimation();
  }

  void _initializeControllers() {
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  void _initializeAnimations() {
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
    
    _backgroundTransition = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));
    
    _fadeTransition = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));
    
    // Setup animation listeners
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_lottieCompleted) {
        _lottieCompleted = true;
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _startZoomTransition();
          }
        });
      }
    });
    
    _zoomController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _transitionToGoogleLogin();
      }
    });
  }

  void _startAIAAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _lottieController.forward();
    }
  }

  void _startZoomTransition() async {
    if (mounted) {
      setState(() {
        _startFogEffect = true;
      });
      
      await Future.delayed(const Duration(milliseconds: 400));
      
      if (mounted) {
        setState(() {
          _startZoom = true;
        });
        
        _zoomController.forward();
      }
    }
  }

  void _transitionToGoogleLogin() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _currentState = AppFlowState.googleLogin;
      });
      _transitionController.forward();
    }
  }

  void _onGoogleLoginSuccess() {
    setState(() {
      _currentState = AppFlowState.haloOrb;
    });
  }

  void _onOrbInteractionComplete() {
    setState(() {
      _currentState = AppFlowState.chatInterface;
    });
  }

  void _onReturnToOrb() {
    setState(() {
      _currentState = AppFlowState.haloOrb;
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _zoomController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  void _resetAppFlow() {
    // Stop all animations
    _lottieController.reset();
    _zoomController.reset();
    _transitionController.reset();
    
    // Reset all state variables
    setState(() {
      _currentState = AppFlowState.aiaAnimation;
      _startFogEffect = false;
      _startZoom = false;
      _lottieCompleted = false;
    });
    
    // Generate new session ID
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Restart the sequence
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _startAIAAnimation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // AIA Animation Background (only during animation)
          if (_currentState == AppFlowState.aiaAnimation)
            _buildAIAAnimationBackground(),
          
          // Main Content
          _buildMainContent(),
          
          // Reset Button (always visible)
          Positioned(
            top: 40,
            right: 20,
            child: SafeArea(
              child: IconButton(
                icon: Icon(Icons.refresh, color: Colors.white.withOpacity(0.7)),
                onPressed: _resetAppFlow,
                tooltip: 'Reset App',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAAnimationBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([_zoomController]),
      builder: (context, child) {
        return Stack(
          children: [
            // Background transition
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Color.lerp(
                Colors.transparent,
                const Color(0xFF000000),
                _backgroundTransition.value,
              ),
            ),
            
            // Forest background with zoom
            Transform.scale(
              scale: _zoomScale.value,
              child: Opacity(
                opacity: _forestOpacity.value,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/foggy_forest.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Fog effect
            if (_startFogEffect)
              Transform.scale(
                scale: _zoomScale.value,
                child: BreathFogEffect(
                  child: Container(),
                ),
              ),
            
            // Lottie animation
            if (!_startZoom)
              Positioned.fill(
                child: Transform.scale(
                  scale: 2.0,
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    child: Lottie.asset(
                      'assets/aia_text_animation.json',
                      controller: _lottieController,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      fit: BoxFit.contain,
                      onLoaded: (composition) {
                        if (!_lottieController.isAnimating) {
                          _lottieController.forward();
                        }
                      },
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMainContent() {
    switch (_currentState) {
      case AppFlowState.aiaAnimation:
        return const SizedBox.shrink(); // Background handles this
      
      case AppFlowState.googleLogin:
        return AnimatedBuilder(
          animation: _fadeTransition,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeTransition.value,
              child: CleanGoogleLogin(
                onLoginSuccess: _onGoogleLoginSuccess,
                sessionId: _sessionId!,
              ),
            );
          },
        );
      
      case AppFlowState.haloOrb:
        return CleanHaloOrb(
          onInteractionComplete: _onOrbInteractionComplete,
          sessionId: _sessionId!,
        );
      
      case AppFlowState.chatInterface:
        return CleanChatInterface(
          onReturnToOrb: _onReturnToOrb,
          sessionId: _sessionId!,
        );
    }
  }
}

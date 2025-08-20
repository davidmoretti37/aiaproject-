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
    // Automatically start the orb animation/video as soon as the orb screen is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If CleanHaloOrb exposes a static or singleton controller, trigger it here.
      // If not, you may need to pass a callback or use a state management solution.
      // Example (pseudo-code):
      // CleanHaloOrbController.of(context)?.startOrb();
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
          
          // Reset Button (visible em todas as telas, exceto na tela da AIA/orb)
          if (_currentState != AppFlowState.haloOrb)
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
      animation: Listenable.merge([_zoomController, _lottieController]),
      builder: (context, child) {
        return Stack(
          children: [
            // Animated white/grey radial gradient background
            AnimatedBuilder(
              animation: _lottieController,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        0.0 + (_lottieController.value * 0.6) - 0.3, // animate center horizontally
                        0.0 + (_lottieController.value * 0.6) - 0.3, // animate center vertically
                      ),
                      radius: 1.2,
                      colors: [
                        Color(0xFFFFFFFF), // Pure White
                        Color(0xFFF9FAFB), // Light Gray
                        Color(0xFFF5F5F5), // Cool Light Gray
                        Color(0xFFF3F4F6), // Medium Gray
                        Color(0xFFE5E7EB), // Cool Medium Gray
                        Color(0xFFF9FAFB), // Light Gray (repeat for smoothness)
                        Color(0xFFFFFFFF), // Pure White
                      ],
                      stops: [
                        0.0,
                        0.15 + (_lottieController.value * 0.2),
                        0.3 + (_lottieController.value * 0.2),
                        0.5 + (_lottieController.value * 0.2),
                        0.7 + (_lottieController.value * 0.2),
                        0.85 + (_lottieController.value * 0.2),
                        1.0,
                      ],
                    ),
                  ),
                );
              },
            ),
            
            
            // Lottie animation with colorful gradient effect
            if (!_startZoom)
              Positioned.fill(
                child: Transform.scale(
                  scale: 2.0,
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF000000), // Black
                            Color(0xFF222222), // Dark Gray
                            Color(0xFF444444), // Medium Gray
                            Color(0xFF666666), // Lighter Gray
                            Color(0xFF888888), // Even Lighter Gray
                            Color(0xFFCCCCCC), // Near White
                          ],
                          stops: [
                            0.0 + (_lottieController.value * 0.3),
                            0.2 + (_lottieController.value * 0.3),
                            0.4 + (_lottieController.value * 0.3),
                            0.6 + (_lottieController.value * 0.3),
                            0.8 + (_lottieController.value * 0.3),
                            1.0,
                          ],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: Lottie.asset(
                        'assets/aia_text_animation.json',
                        controller: _lottieController,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.contain,
                        delegates: LottieDelegates(
                          values: [
                            // This will override all fill colors in the Lottie with a neon gradient color.
                            // You can adjust the color to your desired neon/AI-inspired color.
                            ValueDelegate.color(
                              const ['**'],
                              value: Color(0xFF222222), // Dark Gray
                            ),
                          ],
                        ),
                        onLoaded: (composition) {
                          if (!_lottieController.isAnimating) {
                            _lottieController.forward();
                          }
                        },
                      ),
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
    print('🎯 APP FLOW STATE: $_currentState');
    switch (_currentState) {
      case AppFlowState.aiaAnimation:
        print('📱 Showing: AIA Animation');
        return const SizedBox.shrink(); // Background handles this
      
      case AppFlowState.googleLogin:
        print('📱 Showing: Google Login');
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
        print('📱 Showing: Halo Orb (TOUCH SHOULD WORK HERE)');
        return CleanHaloOrb(
          onInteractionComplete: _onOrbInteractionComplete,
          sessionId: _sessionId!,
        );
      
      case AppFlowState.chatInterface:
        print('📱 Showing: Chat Interface');
        return CleanChatInterface(
          onReturnToOrb: _onReturnToOrb,
          sessionId: _sessionId!,
        );
    }
  }
}

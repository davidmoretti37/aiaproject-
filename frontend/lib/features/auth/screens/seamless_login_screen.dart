import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/services/google_auth_service.dart';
import '../widgets/login_halo_orb.dart';
import '../widgets/aia_background.dart';

class SeamlessLoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const SeamlessLoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  _SeamlessLoginScreenState createState() => _SeamlessLoginScreenState();
}

class _SeamlessLoginScreenState extends State<SeamlessLoginScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _haloTransitionController;
  late AnimationController _haloGrowthController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _loginContentOpacity;
  late Animation<Offset> _haloPosition;
  late Animation<double> _haloScale;
  late Animation<double> _haloGrowthScale;
  late Animation<double> _instructionTextOpacity;
  
  bool _isLoading = false;
  bool _loginSuccessful = false;
  bool _showInteractiveHalo = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fadeController.forward();
  }

  void _initializeAnimations() {
    // Initial fade-in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Halo transition animation (triggered after login)
    _haloTransitionController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Halo growth animation (triggered after transition completes)
    _haloGrowthController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    // Start growth animation when transition completes
    _haloTransitionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Start the growth animation after a brief pause
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _haloGrowthController.forward();
          }
        });
      }
    });
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    // Login content fades out when login is successful
    _loginContentOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _haloTransitionController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));
    
    // Halo moves from login position to center
    _haloPosition = Tween<Offset>(
      begin: const Offset(0, -0.15), // Login position
      end: const Offset(0, 0), // Center
    ).animate(CurvedAnimation(
      parent: _haloTransitionController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    
    // Halo scales up slightly during transition
    _haloScale = Tween<double>(
      begin: 0.83, // Login size
      end: 1.0, // Main orb size
    ).animate(CurvedAnimation(
      parent: _haloTransitionController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    
    // Additional growth animation after transition
    _haloGrowthScale = Tween<double>(
      begin: 1.0,
      end: 2.2, // Grow to 120% larger
    ).animate(CurvedAnimation(
      parent: _haloGrowthController,
      curve: Curves.easeOutBack,
    ));
    
    // Instruction text fades in after halo settles
    _instructionTextOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _haloTransitionController,
      curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _haloTransitionController.dispose();
    _haloGrowthController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mock login for testing the seamless transition
      await Future.delayed(const Duration(milliseconds: 1000));
      
      setState(() {
        _loginSuccessful = true;
      });
      
        // Start the seamless transition
        _haloTransitionController.forward().then((_) {
          // After transition, show the interactive halo in place
          setState(() {
            _showInteractiveHalo = true;
          });
          // Optionally notify parent if needed
          widget.onLoginSuccess();
        });
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted && !_loginSuccessful) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Shared iridescent background
          const AiaBackground(),
          
          AnimatedBuilder(
            animation: Listenable.merge([_fadeController, _haloTransitionController, _haloGrowthController]),
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Stack(
                  children: [
                    // Halo orb (always present, moves and scales, becomes interactive)
                    Center(
                      child: Transform.translate(
                        offset: Offset(
                          _haloPosition.value.dx * MediaQuery.of(context).size.width,
                          _haloPosition.value.dy * MediaQuery.of(context).size.height,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Scaled halo orb
                            Transform.scale(
                              scale: _haloScale.value * _haloGrowthScale.value,
                              child: SizedBox(
                                width: 120,
                                height: 120,
                                child: LoginHaloOrb(
                                  isInteractive: _showInteractiveHalo,
                                  onInteractionComplete: () {},
                                  sessionId: "main",
                                ),
                              ),
                            ),
                            
                            // Status text that doesn't scale (only when interactive)
                            if (_showInteractiveHalo)
                              Positioned(
                                bottom: -120,
                                left: -100,
                                right: -100,
                                child: Center(
                                  child: Text(
                                    'Tap to speak',
                                    style: GoogleFonts.inter(
                                      color: Colors.green,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Login content (fades out after login)
                    Opacity(
                      opacity: _loginContentOpacity.value,
                      child: Column(
                        children: [
                          // Top section with welcome text
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Welcome text positioned lower
                                  Text(
                                    'Welcome to AIA',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Your AI Assistant',
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 60), // Space before login button section
                                ],
                              ),
                            ),
                          ),
                          
                          // Bottom section with login button
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Google Sign In Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: (_isLoading || _loginSuccessful) ? null : _handleGoogleSignIn,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black87,
                                        elevation: 8,
                                        shadowColor: Colors.green.withOpacity(0.3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(28),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.login,
                                                  size: 24,
                                                  color: Colors.green,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Continue with Google',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Privacy text
                                  Text(
                                    'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

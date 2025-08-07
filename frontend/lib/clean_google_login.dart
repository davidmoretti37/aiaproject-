import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/auth/widgets/login_halo_orb.dart';
import 'features/auth/widgets/iridescence_overlay.dart';
import 'features/auth/widgets/curved_text_loop.dart';
import 'core/services/google_auth_service.dart';
import 'features/auth/widgets/gradient_button.dart';

class CleanGoogleLogin extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final String sessionId;

  const CleanGoogleLogin({
    Key? key,
    required this.onLoginSuccess,
    required this.sessionId,
  }) : super(key: key);

  @override
  State<CleanGoogleLogin> createState() => _CleanGoogleLoginState();
}

class _CleanGoogleLoginState extends State<CleanGoogleLogin>
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  late AnimationController _haloController;
  late Animation<double> _haloAnimation;
  
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _haloController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _haloAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _haloController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start main fade animation
    _fadeController.forward();
    
    // Start halo fade animation after a delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _haloController.forward();
      }
    });
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Mock login...';
    });

    // Simulate a login process without actual authentication
    await Future.delayed(const Duration(milliseconds: 1200));
    
    setState(() {
      _statusMessage = 'Welcome!';
    });
    
    // Small delay to show success message
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      widget.onLoginSuccess();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _haloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d4f3c), // Dark green background
      body: Stack(
        children: [
          // Iridescence background
          const Positioned.fill(
            child: Stack(
              children: [
                IridescenceOverlay(
                  color: Color(0xFF0d2e1a), // Darker green iridescence
                  speed: 0.008,
                  amplitude: 0.2,
                ),
                // Gray overlay for subtlety
                IgnorePointer(
                  child: ColoredBox(
                    color: Color(0xFF444444), // fully opaque medium gray
                  ),
                ),
              ],
            ),
          ),
          
          // Main content
          SafeArea(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const SizedBox(height: 120),
                            
                            // Small halo ring with delayed fade-in
                            AnimatedBuilder(
                              animation: _haloAnimation,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _haloAnimation.value,
                                  child: const SizedBox(
                                    width: 250,
                                    height: 250,
                                    child: LoginHaloOrb(),
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 60),
                            
                            const SizedBox(height: 60),
                            
                            // Google Sign-In Button
                            if (!_isLoading)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: GradientButton(
                                  width: 320,
                                  height: 64,
                                  onPressed: _handleGoogleSignIn,
                                  disabled: _isLoading,
                                  child: Text(
                                    'Connect with Google',
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            
                            // Loading Indicator
                            if (_isLoading)
                              Column(
                                children: [
                                  const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    _statusMessage,
                                    style: GoogleFonts.inter(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            
                            const SizedBox(height: 40),
                            
                            // Status Message
                            if (_statusMessage.isNotEmpty && !_isLoading)
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(
                                  _statusMessage,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    color: _statusMessage.contains('Error') || _statusMessage.contains('failed')
                                        ? Colors.red
                                        : Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            
                            const Spacer(), // Pushes the notice to the bottom
                            
                            // Privacy Notice
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 60),
                              child: Text(
                                'Your information is secure and used only for sending emails and managing calendar events.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: Colors.white.withAlpha(102),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                          ],
                        ),
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

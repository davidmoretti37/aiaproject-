import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/simple_auth_service.dart';

class CleanGoogleLogin extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final String sessionId;

  const CleanGoogleLogin({
    Key? key,
    required this.onLoginSuccess,
    required this.sessionId,
  }) : super(key: key);

  @override
  _CleanGoogleLoginState createState() => _CleanGoogleLoginState();
}

class _CleanGoogleLoginState extends State<CleanGoogleLogin>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
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
    
    _fadeController.forward();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Connecting to Google...';
    });

    try {
      final userInfo = await SimpleAuthService.signIn();
      
      if (userInfo != null) {
        final userEmail = userInfo['email'];
        final userName = userInfo['name'];
        final userId = userInfo['user_id'];
        
        setState(() {
          _statusMessage = 'Welcome, ${userName ?? userEmail ?? 'User'}!';
        });
        
        print('✅ Login realizado com sucesso!');
        print('   Nome: $userName');
        print('   Email: $userEmail');
        print('   Supabase ID: $userId');
        print('   Google ID: ${userInfo['google_user_id']}');
        
        // Small delay to show success message
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (mounted) {
          widget.onLoginSuccess();
        }
      } else {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Login failed. Please try again.';
        });
        
        // Clear error message after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _statusMessage = '';
            });
          }
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error: ${e.toString()}';
      });
      
      print('❌ Erro no login: $e');
      
      // Clear error message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _statusMessage = '';
          });
        }
      });
    }
  }

  void _skipLogin() {
    setState(() {
      _statusMessage = 'Continuing without Google account...';
    });
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        widget.onLoginSuccess();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.3, -0.3),
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
            0.15,
            0.3,
            0.5,
            0.7,
            0.85,
            1.0,
          ],
        ),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // AIA Logo
                  Text(
                    'AIA',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 6,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'Artificial Intelligence Assistant',
                    style: GoogleFonts.inter(
                      color: Colors.black54,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 80),
                  
                  // (Removed welcome message and extra spacing)
                  const SizedBox(height: 60),
                  
                  // Google Sign-In Button
                  if (!_isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleGoogleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                            shadowColor: Colors.white.withOpacity(0.3),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Colors.white,
                                ),
                                child: const Icon(
                                  Icons.g_mobiledata,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Connect with Google',
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 40),
                  
                  // Skip Button
                  if (!_isLoading)
                    TextButton(
                      onPressed: _skipLogin,
                      child: Text(
                        'Skip for now',
                        style: GoogleFonts.inter(
                          color: Colors.black38,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  
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
                              : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 60),
                  
                  // Privacy Notice
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Text(
                      'Your information is secure and used only for sending emails and managing calendar events.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.black26,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

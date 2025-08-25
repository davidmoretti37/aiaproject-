import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/simple_auth_service.dart';
import 'activate_voice_ai_screen.dart';
import 'clean_halo_orb.dart';

// Placeholder para onboarding
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: const Center(
        child: Text(
          'Onboarding personalizado em construção...',
          style: TextStyle(color: Colors.black54, fontSize: 18),
        ),
      ),
    );
  }
}

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
  bool _isLoading = false;
  String _statusMessage = '';

  late final AnimationController _orbController;
  late final Animation<double> _orbAnimation;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _orbAnimation = Tween<double>(
      begin: 0,
      end: 16,
    ).animate(CurvedAnimation(parent: _orbController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _orbController.dispose();
    super.dispose();
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
        setState(() {
          _statusMessage = 'Welcome, ${userName ?? userEmail ?? 'User'}!';
        });
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          widget.onLoginSuccess();
        }
      } else {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Login failed. Please try again.';
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _statusMessage = '');
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error: ${e.toString()}';
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _statusMessage = '');
      });
    }
  }

  void _startOnboarding() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const OnboardingScreen()));
  }

  void _skipLogin() {
    setState(() {
      _statusMessage = 'Continuing without Google account...';
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ActivateVoiceAIScreen(
              onActivate: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CleanHaloOrb(
                      onInteractionComplete: widget.onLoginSuccess,
                      sessionId: widget.sessionId,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    });
  }

  ButtonStyle get _mainButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF7F7F7),
        foregroundColor: Colors.grey[700],
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.2),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        textStyle: GoogleFonts.inter(
          color: const Color(0xFF8B8B8B),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 28.0,
                vertical: 0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  // Orbe animado com sombra circular
                  Container(
                    width: 260,
                    height: 260,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(17, 0, 0, 0),
                          blurRadius: 12,
                          spreadRadius: 0,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: AnimatedBuilder(
                      animation: _orbAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -_orbAnimation.value),
                          child: child,
                        );
                      },
                      child: ClipOval(
                        child: Image.asset(
                          'assets/aia_icon.png',
                          width: 260,
                          height: 260,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 46),
                  // Título
                  Text(
                    'AIA',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF828282),
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Subtítulo
                  Text(
                    'Artificial Intelligence Assistant',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF828282),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Botão Start
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _startOnboarding,
                      style: _mainButtonStyle,
                      child: const Text('Start'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Botão Google
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      label: const Text('Connect With Google'),
                      style: _mainButtonStyle,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Skip for now
                  if (!_isLoading)
                    TextButton(
                      onPressed: _skipLogin,
                      child: Text(
                        'Skip for Now',
                        style: GoogleFonts.inter(
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _statusMessage,
                            style: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 38),
                  // Aviso de privacidade
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Your information is secure and used only for sending emails and managing calendar events.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFC5C5C5),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

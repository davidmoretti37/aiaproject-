import 'package:flutter/material.dart';

class GradientButton extends StatefulWidget {
  final Widget? child;
  final double width;
  final double height;
  final VoidCallback? onPressed;
  final bool disabled;

  const GradientButton({
    Key? key,
    this.child,
    this.width = 300,
    this.height = 60,
    this.onPressed,
    this.disabled = false,
  }) : super(key: key);

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(widget.height / 2);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.disabled ? null : widget.onPressed,
          child: Opacity(
            opacity: widget.disabled ? 0.5 : 1.0,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                // Shiny black border using a vertical gradient for gloss
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF222222), // shiny black (top highlight)
                    Color(0xFF111111), // deep black (bottom)
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Inner background
                  Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181818), // dead/matte black
                      borderRadius: borderRadius,
                    ),
                  ),
                  // Content
                  Center(
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: widget.disabled
                            ? Colors.grey[600]
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                      child: widget.child ?? const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math';

class MagnetWrapper extends StatefulWidget {
  final Widget child;
  final double padding;
  final double magnetStrength;
  final bool disabled;
  final Duration activeDuration;
  final Duration inactiveDuration;

  const MagnetWrapper({
    Key? key,
    required this.child,
    this.padding = 100,
    this.magnetStrength = 2,
    this.disabled = false,
    this.activeDuration = const Duration(milliseconds: 300),
    this.inactiveDuration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  State<MagnetWrapper> createState() => _MagnetWrapperState();
}

class _MagnetWrapperState extends State<MagnetWrapper>
    with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero;
  bool _isActive = false;
  final GlobalKey _key = GlobalKey();

  late final AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.inactiveDuration,
    );
    _animation =
        Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePointer(PointerEvent event) {
    if (widget.disabled) return;
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    final center = position + Offset(size.width / 2, size.height / 2);

    final distX = (center.dx - event.position.dx).abs();
    final distY = (center.dy - event.position.dy).abs();

    if (distX < size.width / 2 + widget.padding &&
        distY < size.height / 2 + widget.padding) {
      setState(() {
        _isActive = true;
        final offsetX = (event.position.dx - center.dx) / widget.magnetStrength;
        final offsetY = (event.position.dy - center.dy) / widget.magnetStrength;
        _offset = Offset(offsetX, offsetY);
      });
    } else {
      _reset();
    }
  }

  void _reset() {
    if (!_isActive) return;

    _animation = Tween<Offset>(
      begin: _offset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward(from: 0.0);
    _isActive = false;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerHover: _handlePointer,
      onPointerMove: _handlePointer,
      onPointerDown: _handlePointer,
      onPointerUp: (_) => _reset(),
      onPointerCancel: (_) => _reset(),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final transformOffset = _isActive ? _offset : _animation.value;
          return Transform(
            key: _key,
            transform: Matrix4.translationValues(
              transformOffset.dx,
              transformOffset.dy,
              0,
            ),
            child: widget.child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

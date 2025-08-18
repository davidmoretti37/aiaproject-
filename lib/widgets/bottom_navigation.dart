import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AIABottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AIABottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AIABottomNavigation> createState() => _AIABottomNavigationState();
}

class _AIABottomNavigationState extends State<AIABottomNavigation> {
  late int activeIndex;
  
  List<IconData> icons = [
    Icons.chat_bubble_outline,
    Icons.business_outlined,
    Icons.alarm_outlined,
    Icons.settings_outlined
  ];

  List<IconData> activeIcons = [
    Icons.chat_bubble,
    Icons.business,
    Icons.alarm,
    Icons.settings
  ];

  List<String> labels = [
    'Chat',
    'Partners',
    'Reminders',
    'Settings'
  ];

  Tween<double> tween = Tween<double>(begin: 1.0, end: 1.3);
  bool animationCompleted = false;

  @override
  void initState() {
    super.initState();
    activeIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(AIABottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      setState(() {
        activeIndex = widget.currentIndex;
        animationCompleted = false;
        tween = Tween(begin: 1.0, end: 1.3);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 40, left: 30, right: 30),
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Colors.grey.withOpacity(0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TweenAnimationBuilder(
        key: ValueKey(activeIndex),
        tween: tween,
        duration: Duration(milliseconds: animationCompleted ? 1500 : 300),
        curve: animationCompleted ? Curves.elasticOut : Curves.easeOutBack,
        onEnd: () {
          setState(() {
            animationCompleted = true;
            tween = Tween(begin: 1.4, end: 1.0);
          });
        },
        builder: (context, value, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(icons.length, (i) {
              bool isActive = i == activeIndex;
              return Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()
                  ..scale(isActive ? value : 1.0)
                  ..translate(
                      0.0, isActive ? -15.0 * (value - 1.0) : 0.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      animationCompleted = false;
                      tween = Tween(begin: 1.0, end: 1.3);
                      activeIndex = i;
                    });
                    widget.onTap(i);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isActive
                          ? LinearGradient(
                              colors: [
                                Color(0xFF4F8CFF),
                                Color(0xFF8F5AFF),
                                Color(0xFF6EE7B7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isActive
                          ? null
                          : Colors.transparent,
                      border: isActive
                          ? null
                          : Border.all(
                              color: Colors.grey.withOpacity(0.18),
                              width: 1.2,
                            ),
                    ),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          isActive ? activeIcons[i] : icons[i],
                          color: isActive
                              ? Color(0xFF6F42C1)
                              : Colors.grey[700],
                          size: isActive ? 26 : 22,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

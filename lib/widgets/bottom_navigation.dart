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
    return Positioned(
      bottom: 40,
      left: 30,
      right: 30,
      child: Container(
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 0),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, 
                        vertical: 12
                      ),
                      decoration: BoxDecoration(
                        color: isActive 
                            ? Colors.blue.withOpacity(0.2) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: isActive 
                            ? Border.all(
                                color: Colors.blue.withOpacity(0.4),
                                width: 1.5,
                              )
                            : null,
                        boxShadow: isActive ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ] : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive ? activeIcons[i] : icons[i],
                            color: isActive ? Colors.blue : Colors.white70,
                            size: isActive ? 26 : 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            labels[i],
                            style: GoogleFonts.inter(
                              color: isActive ? Colors.blue : Colors.white70,
                              fontSize: isActive ? 11 : 10,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

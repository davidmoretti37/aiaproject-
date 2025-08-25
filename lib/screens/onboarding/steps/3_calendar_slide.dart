import 'package:flutter/material.dart';

class CalendarSlide extends StatelessWidget {
  const CalendarSlide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60, left: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Image.asset(
          'assets/calendar.png',
          width: 400,
          height: 320,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

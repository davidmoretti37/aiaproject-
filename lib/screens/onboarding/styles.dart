import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingStyles {
  static TextStyle titleStyle = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF6B6B6B),
  );

  static TextStyle subtitleStyle = GoogleFonts.poppins(
    fontSize: 16,
    color: const Color(0xFFB0B0B0),
    fontWeight: FontWeight.w400,
  );

  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: const Color(0xFFB0B0B0),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF95C5D9),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF95C5D9),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF95C5D9),
        ),
      ),
    );
  }
}

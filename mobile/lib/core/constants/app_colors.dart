import 'package:flutter/material.dart';

/// AppColors - Constantes de cores utilizadas no aplicativo C'Alma
/// 
/// Define as cores principais e variações usadas no design system do aplicativo.
/// Baseado nas cores observadas no projeto original em React Native.
class AppColors {
  // Cores primárias
  static const calmaBlue = Color(0xFF645CBB);
  static const calmaBlueLight = Color(0xFFE5DEFF);
  static const calmaBlueDark = Color(0xFF5247A9);
  
  // Cores neutras
  static const white = Colors.white;
  static const black = Colors.black;
  static const gray700 = Color(0xFF374151);
  static const gray600 = Color(0xFF4B5563);
  static const gray500 = Color(0xFF6B7280);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray50 = Color(0xFFF9FAFB);
  
  // Gradientes
  static const gradientStart = calmaBlueLight;
  static const gradientEnd = Color(0xFFD6BCFA);
  
  // Cores de estado
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
  
  // Cores de sobreposição
  static const overlay = Color(0x80000000);
  static const whiteOverlay = Color(0x80FFFFFF);
  
  // Background
  static const background = Color(0xFFF8FAFC);
  
  // Não permitir instanciação
  const AppColors._();
}

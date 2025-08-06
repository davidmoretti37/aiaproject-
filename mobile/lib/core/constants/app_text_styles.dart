import 'package:flutter/material.dart';
import 'package:calma_flutter/core/constants/app_colors.dart';

/// AppTextStyles - Estilos de texto utilizados no aplicativo C'Alma
/// 
/// Define os estilos tipográficos consistentes para todo o aplicativo.
/// Utiliza fontes do sistema para garantir compatibilidade e performance.
class AppTextStyles {
  // Headings
  static TextStyle get heading1 => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.gray700,
    height: 1.2,
  );
  
  static TextStyle get heading2 => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.gray700,
    height: 1.2,
  );
  
  static TextStyle get heading3 => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.gray700,
    height: 1.3,
  );
  
  static TextStyle get heading4 => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.gray700,
    height: 1.3,
  );
  
  // Paragraphs
  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.gray600,
    height: 1.5,
  );
  
  static TextStyle get bodyMedium => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.gray600,
    height: 1.5,
  );
  
  static TextStyle get bodySmall => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.gray600,
    height: 1.5,
  );
  
  // Captions
  static TextStyle get caption => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.gray500,
    height: 1.4,
  );
  
  // Button texts
  static TextStyle get buttonLarge => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.4,
  );
  
  static TextStyle get buttonMedium => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.4,
  );
  
  static TextStyle get buttonSmall => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.4,
  );
  
  // Links
  static TextStyle get link => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.calmaBlue,
    height: 1.5,
    decoration: TextDecoration.underline,
  );
  
  // Não permitir instanciação
  const AppTextStyles._();
}

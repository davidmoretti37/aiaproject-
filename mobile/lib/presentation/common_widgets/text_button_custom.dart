import 'package:flutter/material.dart';
import 'package:calma_flutter/core/constants/app_colors.dart';
import 'package:calma_flutter/core/constants/app_text_styles.dart';

/// TextButtonCustom - Botão de texto personalizado para o aplicativo
///
/// Componente reutilizável que implementa o botão de texto secundário 
/// utilizado em diversas telas do aplicativo.
class TextButtonCustom extends StatelessWidget {
  /// Texto a ser exibido no botão
  final String text;
  
  /// Função a ser chamada ao pressionar o botão
  final VoidCallback? onPressed;
  
  /// Cor do texto do botão
  final Color? textColor;
  
  /// Estilo do texto do botão
  final TextStyle? textStyle;
  
  /// Padding interno do botão
  final EdgeInsetsGeometry padding;
  
  /// Ícone opcional a ser exibido após o texto
  final IconData? trailingIcon;
  
  /// Alinhamento do texto e ícone
  final MainAxisAlignment alignment;

  /// Construtor do TextButtonCustom
  const TextButtonCustom({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    this.trailingIcon,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? AppColors.gray700;
    final effectiveTextStyle = textStyle ?? 
        AppTextStyles.bodyMedium.copyWith(
          color: effectiveTextColor,
          fontWeight: FontWeight.w500,
        );
    
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: padding,
        foregroundColor: effectiveTextColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: alignment,
        children: [
          Flexible(
            child: Text(
              text,
              style: effectiveTextStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 4),
            Icon(
              trailingIcon,
              size: 16,
              color: effectiveTextColor,
            ),
          ],
        ],
      ),
    );
  }
}

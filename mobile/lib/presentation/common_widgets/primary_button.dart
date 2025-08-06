import 'package:flutter/material.dart';
import 'package:calma_flutter/core/constants/app_colors.dart';
import 'package:calma_flutter/core/constants/app_text_styles.dart';

/// PrimaryButton - Botão principal utilizado em todo o aplicativo
///
/// Componente reutilizável que implementa o botão principal da aplicação
/// com design consistente, incluindo estados de carregamento e desabilitado.
class PrimaryButton extends StatelessWidget {
  /// Texto a ser exibido no botão
  final String text;

  /// Função a ser chamada ao pressionar o botão
  final VoidCallback? onPressed;

  /// Indica se o botão está em estado de carregamento
  final bool isLoading;

  /// Ícone opcional a ser exibido antes do texto
  final IconData? icon;

  /// Largura do botão. Se null, assume a largura do container pai
  final double? width;

  /// Altura do botão
  final double height;

  /// Raio de borda do botão
  final double borderRadius;

  /// Padding interno do botão
  final EdgeInsetsGeometry padding;

  /// Estilo de texto do botão
  final TextStyle? textStyle;

  /// Cor de fundo do botão
  final Color? backgroundColor;

  /// Cor do texto do botão
  final Color? textColor;

  /// Construtor do PrimaryButton
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 56,
    this.borderRadius = 30,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    this.textStyle,
    this.backgroundColor,
    this.textColor,
  });

  // ...existing code...
  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.calmaBlue;
    final effectiveTextColor = textColor ?? AppColors.white;
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        onTap: isDisabled ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: padding,
          decoration: BoxDecoration(
            color:
                isDisabled
                    ? effectiveBackgroundColor.withOpacity(0.2)
                    : effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Center(child: _buildButtonContent(effectiveTextColor)),
        ),
      ),
    );
  }
  // ...restante do código...

  /// Constrói o conteúdo do botão (texto, ícone ou indicador de progresso)
  Widget _buildButtonContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
          strokeWidth: 2.5,
        ),
      );
    }

    final buttonText = Text(
      text,
      style: textStyle ?? AppTextStyles.buttonMedium.copyWith(color: textColor),
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          buttonText,
        ],
      );
    }

    return buttonText;
  }
}

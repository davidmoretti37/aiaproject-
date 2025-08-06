import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calma_flutter/core/constants/app_colors.dart';
import 'package:calma_flutter/core/constants/app_text_styles.dart';

/// InputField - Campo de texto customizado para uso em formulários
///
/// Widget reutilizável que implementa um campo de texto com design consistente,
/// suporte a validação, formatação e estados visuais (erro, foco, etc).
class InputField extends StatefulWidget {
  /// Controlador do campo de texto
  final TextEditingController? controller;

  /// Texto de label do campo
  final String? label;

  /// Texto de placeholder
  final String? hint;

  /// Tipo de teclado a ser exibido
  final TextInputType keyboardType;

  /// Se o texto deve ser obscurecido (ex: senha)
  final bool obscureText;

  /// Lista de formatadores de texto
  final List<TextInputFormatter>? inputFormatters;

  /// Função chamada quando o valor do campo muda
  final ValueChanged<String>? onChanged;

  /// Função de validação do campo
  final String? Function(String?)? validator;

  /// Texto de erro a ser exibido
  final String? errorText;

  /// Ícone prefixo do campo
  final Widget? prefixIcon;

  /// Ícone sufixo do campo
  final Widget? suffixIcon;

  /// Se o campo está habilitado
  final bool enabled;

  /// Número máximo de linhas (para campos multilinhas)
  final int? maxLines;

  /// Número de linhas (para campos multilinhas)
  final int? minLines;

  /// Ação do teclado
  final TextInputAction? textInputAction;

  /// Callback quando o campo recebe foco
  final VoidCallback? onTap;

  /// Tamanho máximo de texto
  final int? maxLength;

  /// Estilo do texto de input
  final TextStyle? textStyle;

  /// Autofoco quando widget é carregado
  final bool autofocus;

  /// Construtor do InputField
  const InputField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.inputFormatters,
    this.onChanged,
    this.validator,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.textInputAction,
    this.onTap,
    this.maxLength,
    this.textStyle,
    this.autofocus = false,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus != _isFocused) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.bodySmall.copyWith(
              color: hasError ? AppColors.error : AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          onTap: widget.onTap,
          style: widget.textStyle ?? AppTextStyles.bodyMedium,
          onChanged: widget.onChanged,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            errorText: widget.errorText,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray400,
            ),
            filled: true,
            fillColor:
                !widget.enabled
                    ? AppColors.gray100
                    : _isFocused
                    ? AppColors.calmaBlueLight.withOpacity(0.2)
                    : AppColors.gray50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.gray300, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.gray300, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.calmaBlue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

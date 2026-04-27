import 'package:flutter/material.dart';
import '../config/constants.dart';

/// Input personnalisé réutilisable avec options avancées
class CustomInput extends StatelessWidget {
  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autoFocus;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCounter;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? suffix;
  final VoidCallback? onSuffixIconPressed;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldSetter<String>? onSaved;
  final String? Function(String?)? validator;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final Color? focusedBorderColor;
  final Color? enabledBorderColor;
  final Color? errorBorderColor;
  final double borderRadius;
  final bool isDense;
  final bool hasBorder;
  final TextCapitalization textCapitalization;
  final List<String>? autofillHints;
  final String? restorationId;
  final bool enableInteractiveSelection;
  final TextAlign textAlign;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;

  const CustomInput({
    super.key,
    required this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autoFocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.onSuffixIconPressed,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.onSaved,
    this.validator,
    this.contentPadding,
    this.fillColor,
    this.focusedBorderColor,
    this.enabledBorderColor,
    this.errorBorderColor,
    this.borderRadius = AppConstants.borderRadius,
    this.isDense = false,
    this.hasBorder = true,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.restorationId,
    this.enableInteractiveSelection = true,
    this.textAlign = TextAlign.start,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.helperStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: labelStyle ?? const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ),

        // Champ de texte
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          autofocus: autoFocus,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onSaved: onSaved,
          onTap: onTap,
          validator: validator,
          textCapitalization: textCapitalization,
          autofillHints: autofillHints,
          restorationId: restorationId,
          enableInteractiveSelection: enableInteractiveSelection,
          textAlign: textAlign,
          style: TextStyle(
            color: enabled ? AppConstants.textPrimaryColor : AppConstants.textSecondaryColor,
            fontSize: 14,
          ),
          decoration: _buildInputDecoration(),
        ),

        // Helper text
        if (helperText != null && helperText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              helperText!,
              style: helperStyle ?? TextStyle(
                fontSize: 12,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
      ],
    );
  }

  InputDecoration _buildInputDecoration() {
    final border = hasBorder ? OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(
        color: enabledBorderColor ?? Colors.grey.shade400,
        width: 1,
      ),
    ) : InputBorder.none;

    final enabledBorder = hasBorder ? OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(
        color: enabledBorderColor ?? Colors.grey.shade400,
        width: 1,
      ),
    ) : InputBorder.none;

    final focusedBorder = hasBorder ? OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(
        color: focusedBorderColor ?? AppConstants.primaryColor,
        width: 2,
      ),
    ) : InputBorder.none;

    final errorBorder = hasBorder ? OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(
        color: errorBorderColor ?? AppConstants.errorColor,
        width: 1,
      ),
    ) : InputBorder.none;

    final focusedErrorBorder = hasBorder ? OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(
        color: errorBorderColor ?? AppConstants.errorColor,
        width: 2,
      ),
    ) : InputBorder.none;

    return InputDecoration(
      hintText: hint ?? label,
      hintStyle: hintStyle ?? TextStyle(
        color: AppConstants.textSecondaryColor,
        fontSize: 14,
      ),
      errorText: errorText,
      errorStyle: errorStyle ?? TextStyle(
        color: AppConstants.errorColor,
        fontSize: 12,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(
              prefixIcon,
              color: _getIconColor(),
              size: 20,
            )
          : null,
      suffixIcon: _buildSuffixIcon(),
      suffix: suffix,
      filled: true,
      fillColor: fillColor ?? (enabled ? Colors.white : Colors.grey.shade100),
      border: border,
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: focusedErrorBorder,
      contentPadding: contentPadding ??
          EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: maxLines > 1 ? AppConstants.paddingMedium : 14,
          ),
      isDense: isDense,
      counterText: showCounter ? null : '',
      errorMaxLines: 2,
    );
  }

  Widget? _buildSuffixIcon() {
    if (suffixIcon != null) {
      return IconButton(
        icon: Icon(
          suffixIcon,
          color: _getIconColor(),
          size: 20,
        ),
        onPressed: onSuffixIconPressed,
        splashRadius: 20,
      );
    }
    return null;
  }

  Color _getIconColor() {
    if (!enabled) {
      return AppConstants.textSecondaryColor.withOpacity(0.5);
    }
    return AppConstants.textSecondaryColor;
  }
}

/// Variantes prédéfinies de CustomInput pour un usage rapide
class CustomInputVariants {
  /// Input avec icône de recherche
  static CustomInput search({
    required String label,
    required TextEditingController controller,
    ValueChanged<String>? onChanged,
    String? hint,
  }) {
    return CustomInput(
      label: label,
      hint: hint ?? 'Rechercher...',
      controller: controller,
      prefixIcon: Icons.search_rounded,
      onChanged: onChanged,
    );
  }

  /// Input pour email
  static CustomInput email({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    String? hint,
  }) {
    return CustomInput(
      label: label,
      hint: hint ?? 'exemple@email.com',
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_rounded,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      validator: validator ?? _defaultEmailValidator,
    );
  }

  /// Input pour mot de passe
  static CustomInput password({
    required String label,
    required TextEditingController controller,
    required ValueNotifier<bool> obscureTextNotifier,
    String? Function(String?)? validator,
    String? hint,
  }) {
    return CustomInput(
      label: label,
      hint: hint ?? '••••••••',
      controller: controller,
      obscureText: obscureTextNotifier.value,
      prefixIcon: Icons.lock_rounded,
      suffixIcon: obscureTextNotifier.value 
          ? Icons.visibility_rounded 
          : Icons.visibility_off_rounded,
      onSuffixIconPressed: () => obscureTextNotifier.value = !obscureTextNotifier.value,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      validator: validator ?? _defaultPasswordValidator,
    );
  }

  /// Input pour téléphone
  static CustomInput phone({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    String? hint,
  }) {
    return CustomInput(
      label: label,
      hint: hint ?? '+229 XX XX XX XX',
      controller: controller,
      keyboardType: TextInputType.phone,
      prefixIcon: Icons.phone_rounded,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.telephoneNumber],
      validator: validator,
    );
  }

  /// Input multiligne pour descriptions
  static CustomInput multiline({
    required String label,
    required TextEditingController controller,
    String? hint,
    int minLines = 3,
    int maxLines = 5,
    String? Function(String?)? validator,
  }) {
    return CustomInput(
      label: label,
      hint: hint,
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
    );
  }

  /// Input sans bordure (pour les headers/search bars)
  static CustomInput borderless({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconPressed,
  }) {
    return CustomInput(
      label: label,
      hint: hint,
      controller: controller,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      onSuffixIconPressed: onSuffixIconPressed,
      hasBorder: false,
      fillColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
    );
  }

  /// Input désactivé (pour l'affichage en lecture seule)
  static CustomInput disabled({
    required String label,
    required String value,
    String? hint,
    IconData? prefixIcon,
  }) {
    return CustomInput(
      label: label,
      hint: hint,
      controller: TextEditingController(text: value),
      enabled: false,
      prefixIcon: prefixIcon,
    );
  }

  // Validateurs par défaut
  static String? _defaultEmailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  static String? _defaultPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }
}

/// Helper pour gérer l'état du mot de passe masqué
class PasswordObscureController extends ValueNotifier<bool> {
  PasswordObscureController({bool initialValue = true}) : super(initialValue);

  void toggle() {
    value = !value;
  }
}
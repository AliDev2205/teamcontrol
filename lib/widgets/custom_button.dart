import 'package:flutter/material.dart';
import '../config/constants.dart';

/// Bouton personnalisé réutilisable avec options avancées
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Color? loadingColor;
  final IconData? icon;
  final bool isOutlined;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool hasShadow;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final MainAxisAlignment? contentAlignment;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.loadingColor,
    this.icon,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.width,
    this.height,
    this.borderRadius = AppConstants.borderRadius,
    this.hasShadow = false,
    this.padding,
    this.textStyle,
    this.contentAlignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = _buildButtonContent();
    final buttonWidget = isOutlined ? _buildOutlinedButton(buttonContent) : _buildElevatedButton(buttonContent);

    // Conteneur pour gérer la largeur et l'ombre
    return Container(
      width: isFullWidth ? double.infinity : width,
      height: height ?? AppConstants.buttonHeight,
      decoration: hasShadow && !isOutlined ? _buildBoxShadow() : null,
      child: buttonWidget,
    );
  }

  OutlinedButton _buildOutlinedButton(Widget content) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, height ?? AppConstants.buttonHeight),
        side: BorderSide(
          color: borderColor ?? backgroundColor ?? AppConstants.primaryColor,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: textColor ?? backgroundColor ?? AppConstants.primaryColor,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
      ),
      child: content,
    );
  }

  ElevatedButton _buildElevatedButton(Widget content) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppConstants.primaryColor,
        foregroundColor: textColor ?? Colors.white,
        minimumSize: Size(double.infinity, height ?? AppConstants.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 0,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
        shadowColor: Colors.transparent,
      ),
      child: content,
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            loadingColor ?? 
            (isOutlined 
              ? (textColor ?? backgroundColor ?? AppConstants.primaryColor)
              : (textColor ?? Colors.white)
            ),
          ),
        ),
      );
    }

    final contentChildren = <Widget>[];

    // Ajouter l'icône si elle existe
    if (icon != null) {
      contentChildren.addAll([
        Icon(
          icon,
          size: 20,
          color: isOutlined 
              ? (textColor ?? backgroundColor ?? AppConstants.primaryColor)
              : (textColor ?? Colors.white),
        ),
        const SizedBox(width: 8),
      ]);
    }

    // Ajouter le texte
    contentChildren.add(
      Text(
        text,
        style: textStyle ?? TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isOutlined 
              ? (textColor ?? backgroundColor ?? AppConstants.primaryColor)
              : (textColor ?? Colors.white),
        ),
      ),
    );

    return Row(
      mainAxisAlignment: contentAlignment!,
      mainAxisSize: MainAxisSize.min,
      children: contentChildren,
    );
  }

  BoxDecoration? _buildBoxShadow() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: (backgroundColor ?? AppConstants.primaryColor).withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ],
    );
  }
}

/// Variantes prédéfinies de CustomButton pour un usage rapide
class CustomButtonVariants {
  /// Bouton principal avec la couleur primaire
  static CustomButton primary({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    bool isFullWidth = true,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      isFullWidth: isFullWidth,
      hasShadow: true,
    );
  }

  /// Bouton secondaire avec contour
  static CustomButton outlined({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    Color? color,
    bool isFullWidth = true,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      isOutlined: true,
      backgroundColor: color ?? AppConstants.primaryColor,
      textColor: color ?? AppConstants.primaryColor,
      isFullWidth: isFullWidth,
    );
  }

  /// Bouton d'accent (cyan)
  static CustomButton accent({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    bool isFullWidth = true,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: AppConstants.accentColor,
      icon: icon,
      isFullWidth: isFullWidth,
      hasShadow: true,
    );
  }

  /// Bouton de succès (vert)
  static CustomButton success({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    bool isFullWidth = true,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: AppConstants.successColor,
      icon: icon,
      isFullWidth: isFullWidth,
      hasShadow: true,
    );
  }

  /// Bouton d'erreur (rouge)
  static CustomButton error({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    bool isFullWidth = true,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: AppConstants.errorColor,
      icon: icon,
      isFullWidth: isFullWidth,
      hasShadow: true,
    );
  }

  /// Bouton petit pour les actions secondaires
  static CustomButton small({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    Color? backgroundColor,
    bool isOutlined = false,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: backgroundColor,
      isOutlined: isOutlined,
      height: 40,
      isFullWidth: false,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Bouton avec largeur automatique (s'adapte au contenu)
  static CustomButton autoWidth({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    Color? backgroundColor,
    bool isOutlined = false,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: backgroundColor,
      isOutlined: isOutlined,
      isFullWidth: false,
      padding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/Values/design_tokens.dart';

/// Modern button following Uncodixfy design principles
/// Variants: primary (blue), secondary (gray), ghost (transparent), danger (red)
enum ModernButtonVariant {
  primary,    // Blue, full background
  secondary,  // Gray, full background
  ghost,      // Transparent, border only
  danger,     // Red, for destructive actions
}

class ModernButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final ModernButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? width;
  final double? height;
  final bool isFullWidth;

  const ModernButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.variant = ModernButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height,
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.transitionDefault,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovering) {
    setState(() => _isHovered = isHovering);
    if (isHovering && !widget.isDisabled && !widget.isLoading) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabledOrLoading = widget.isDisabled || widget.isLoading;
    final effectiveHeight = widget.height ?? DesignTokens.buttonHeightDefault;

    // Get colors based on variant and state
    Color bgColor;
    Color fgColor;
    Color borderColor;

    switch (widget.variant) {
      case ModernButtonVariant.primary:
        bgColor = isDisabledOrLoading ? AppColors.gray300 : AppColors.blue;
        fgColor = Colors.white;
        borderColor = bgColor;
        break;
      case ModernButtonVariant.secondary:
        bgColor = isDisabledOrLoading ? AppColors.gray200 : AppColors.gray200;
        fgColor = isDisabledOrLoading ? AppColors.gray400 : AppColors.gray700;
        borderColor = isDisabledOrLoading ? AppColors.gray300 : AppColors.gray300;
        break;
      case ModernButtonVariant.ghost:
        bgColor = Colors.transparent;
        fgColor = isDisabledOrLoading ? AppColors.gray400 : AppColors.gray700;
        borderColor = isDisabledOrLoading ? AppColors.gray300 : AppColors.gray400;
        break;
      case ModernButtonVariant.danger:
        bgColor = isDisabledOrLoading ? AppColors.errorLight : AppColors.error;
        fgColor = Colors.white;
        borderColor = bgColor;
        break;
    }

    // Apply hover opacity
    if (_isHovered && !isDisabledOrLoading && widget.variant != ModernButtonVariant.ghost) {
      bgColor = bgColor.withOpacity(0.9);
    }

    final buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leadingIcon != null && !widget.isLoading) ...[
          Icon(widget.leadingIcon, size: DesignTokens.iconSizeSmall, color: fgColor),
          const SizedBox(width: DesignTokens.sm),
        ],
        if (widget.isLoading)
          SizedBox(
            width: DesignTokens.iconSizeSmall,
            height: DesignTokens.iconSizeSmall,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        else
          Text(
            widget.label,
            style: DesignTokens.bodyBold.copyWith(color: fgColor),
          ),
        if (widget.trailingIcon != null && !widget.isLoading) ...[
          const SizedBox(width: DesignTokens.sm),
          Icon(widget.trailingIcon, size: DesignTokens.iconSizeSmall, color: fgColor),
        ],
      ],
    );

    final button = Container(
      width: widget.isFullWidth ? double.infinity : widget.width,
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: borderColor,
          width: DesignTokens.borderWidthDefault,
        ),
        borderRadius: DesignTokens.borderRadiusSm,
        boxShadow: _isHovered && !isDisabledOrLoading
            ? DesignTokens.shadowHover
            : DesignTokens.shadowNone,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onHover: _handleHover,
          onTap: isDisabledOrLoading ? null : widget.onPressed,
          borderRadius: DesignTokens.borderRadiusSm,
          child: Center(child: buttonContent),
        ),
      ),
    );

    return Opacity(
      opacity: isDisabledOrLoading ? 0.6 : 1,
      child: button,
    );
  }
}

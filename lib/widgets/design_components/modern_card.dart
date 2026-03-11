import 'package:flutter/material.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/Values/design_tokens.dart';

/// Modern card widget following Uncodixfy design principles
/// Variants: default (light border), elevated (with shadow), flat (no border/shadow)
enum ModernCardVariant {
  default_,   // Light border, subtle shadow
  elevated,   // Elevated with shadow
  flat,       // No border, no shadow
}

class ModernCard extends StatelessWidget {
  final Widget child;
  final ModernCardVariant variant;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool hoverable;

  const ModernCard({
    Key? key,
    required this.child,
    this.variant = ModernCardVariant.default_,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.hoverable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.all(DesignTokens.lg);
    final effectiveBgColor = backgroundColor ?? AppColors.bgCardDark;

    // Determine border and shadow based on variant
    BoxBorder? border;
    List<BoxShadow> shadows = [];

    switch (variant) {
      case ModernCardVariant.default_:
        border = Border.all(
          color: borderColor ?? AppColors.gray700,
          width: DesignTokens.borderWidthDefault,
        );
        shadows = DesignTokens.shadowDefault;
        break;
      case ModernCardVariant.elevated:
        border = Border.all(
          color: borderColor ?? AppColors.gray800,
          width: DesignTokens.borderWidthDefault,
        );
        shadows = DesignTokens.shadowHover;
        break;
      case ModernCardVariant.flat:
        border = null;
        shadows = [];
        break;
    }

    Widget card = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        border: border,
        borderRadius: DesignTokens.borderRadiusMd,
        boxShadow: shadows,
      ),
      child: child,
    );

    // Wrap with InkWell if onTap provided
    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: DesignTokens.borderRadiusMd,
          child: card,
        ),
      );
    }

    // Add hover animation if hoverable
    if (hoverable && onTap != null) {
      return _HoverableCard(child: card);
    }

    return card;
  }
}

/// Helper widget for card hover animation
class _HoverableCard extends StatefulWidget {
  final Widget child;

  const _HoverableCard({required this.child});

  @override
  State<_HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<_HoverableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.transitionDefault,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: DesignTokens.easingCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovering) {
    setState(() => _isHovered = isHovering);
    isHovering ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

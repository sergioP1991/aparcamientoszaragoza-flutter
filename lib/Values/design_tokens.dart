import 'package:flutter/material.dart';

/// Design tokens for Uncodixfy modern design system
/// Inspired by Linear, Raycast, Stripe, GitHub
class DesignTokens {
  const DesignTokens._();

  // ─── TYPOGRAPHY (Clean hierarchy, readable) ───────────────────────────────
  // H1: Page titles, main headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  // H2: Section headings
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
  );

  // H3: Subsection headings
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.2,
  );

  // Body: Main text content
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  // Body bold: Emphasized text within paragraphs
  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0,
  );

  // Small: Secondary text, captions
  static const TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.2,
  );

  // Small bold: Emphasized small text
  static const TextStyle smallBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.2,
  );

  // Tiny: Labels, badges, small tags
  static const TextStyle tiny = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.3,
  );

  // ─── SPACING SCALE (Consistent 4px base unit) ─────────────────────────────
  static const double xs = 4;      // Minimal spacing (padding within buttons)
  static const double sm = 8;      // Small spacing (between items in vertical/horizontal lists)
  static const double md = 12;     // Default spacing (between form fields, cards)
  static const double lg = 16;     // Large spacing (section margins, standard padding)
  static const double xl = 24;     // Extra large (page margins, major section gaps)
  static const double xxl = 32;    // Double extra large (hero sections, major breaks)

  // Common spacing combinations
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);

  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);

  // ─── BORDER RADIUS (NO oversized pills - max 8px) ─────────────────────────
  static const double radiusSm = 6;    // Buttons, inputs, chips
  static const double radiusMd = 8;    // Cards, modals, containers
  static const double radiusLg = 12;   // Large containers (rare use)

  // Border radius as BorderRadius objects
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));

  // ─── SHADOWS (Subtle, not dramatic) ───────────────────────────────────────
  // Default shadow: cards, elevated surfaces
  static const List<BoxShadow> shadowDefault = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // Hover shadow: interactive elements on hover
  static const List<BoxShadow> shadowHover = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.15),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // Popup shadow: modals, dropdowns, floating elements
  static const List<BoxShadow> shadowPopup = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.2),
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  // None: flat elements without elevation
  static const List<BoxShadow> shadowNone = [];

  // ─── STROKE / BORDER ──────────────────────────────────────────────────────
  static const double borderWidthThin = 0.5;  // Subtle dividers
  static const double borderWidthDefault = 1;  // Most borders
  static const double borderWidthThick = 2;   // Active/focused states

  // ─── COMPONENT SIZES ──────────────────────────────────────────────────────
  // Buttons
  static const double buttonHeightSmall = 32;
  static const double buttonHeightDefault = 36;
  static const double buttonHeightLarge = 40;

  // Input fields
  static const double inputHeight = 36;
  static const double inputHeightLarge = 40;

  // Icon sizes
  static const double iconSizeSmall = 16;
  static const double iconSizeDefault = 20;
  static const double iconSizeLarge = 24;

  // Chip / Badge sizes
  static const double chipHeight = 28;
  static const double badgeHeight = 20;

  // ─── ANIMATION / TRANSITION ───────────────────────────────────────────────
  // Duration for quick transitions (hover, focus states, toggles)
  static const Duration transitionQuick = Duration(milliseconds: 100);

  // Duration for standard transitions (page navigation, modal open)
  static const Duration transitionDefault = Duration(milliseconds: 200);

  // Duration for slow transitions (long-form animations, reveals)
  static const Duration transitionSlow = Duration(milliseconds: 300);

  // Standard easing curve (no bouncy effects - all ease-out)
  static const Curve easingCurve = Curves.easeOut;

  // ─── CONTAINER WIDTHS (Layout max-widths) ────────────────────────────────
  static const double containerMaxWidth = 1280;  // Content container
  static const double containerPadding = lg;     // Horizontal padding for containers

  // ─── SIDEBAR / NAVIGATION ──────────────────────────────────────────────────
  static const double sidebarWidth = 240;       // Standard navigation sidebar
  static const double sidebarWidthCompact = 64; // Icon-only sidebar

  // ─── MODAL / DIALOG ───────────────────────────────────────────────────────
  static const double modalMaxWidth = 480;
  static const double modalPadding = lg;

  // ─── SPACING BETWEEN ELEMENTS ─────────────────────────────────────────────
  // Between form fields
  static const double gapFormFields = md;

  // Between list items
  static const double gapListItems = sm;

  // Between buttons in a row
  static const double gapButtonRow = md;

  // Between sections on a page
  static const double gapSections = xxl;
}

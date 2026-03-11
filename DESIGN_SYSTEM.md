# Sistema de Diseño Moderno - Aparcamientos Zaragoza

**Inspiración**: Linear, Raycast, Stripe, GitHub
**Principios**: Clean, functional, honest, human-designed (NOT AI-generic)

## ✅ Lo que SÍ hacemos (Uncodixfy)
- Paleta muted (grises, azules suaves, verdes naturales)
- Componentes simples y funcionales
- Espaciado consistente (4/8/12/16/24/32px)
- Bordes simples (1px solid)
- Sombras sutiles (máx 8px blur)
- Rounded corners 6-8px max (NO pills, NO oversized)
- Typography clara (sans-serif, hierarchy simple)
- Funcionalidad antes que forma

## ❌ Lo que NO hacemos (Anti-Codex)
- Soft gradients decorativos
- Floating glassmorphism panels
- Oversized rounded corners (16px+)
- Dramatic shadows (blur 12px+)
- Transform animations (scale, rotate)
- Decorative copy / "eyebrow" labels
- Bright cyber colors (cyan, neon)
- Hero sections en dashboards
- Generic startup aesthetic

---

## 🎨 Nueva Paleta de Colores

### Base (Grays - core)
```dart
static const Color gray50 = Color(0xfffffbfa);   // Almost white
static const Color gray100 = Color(0xfff8f5f2);  // Very light
static const Color gray200 = Color(0xffede9e3);  // Light backgrounds
static const Color gray300 = Color(0xffd8d0c5);  // Borders
static const Color gray400 = Color(0xffb5a896);  // Hover
static const Color gray500 = Color(0xff8b7f6f);  // Secondary text
static const Color gray600 = Color(0xff5f554a);  // Primary text
static const Color gray700 = Color(0xff362f28);  // Dark text
static const Color gray800 = Color(0xff1a1410);  // Very dark
static const Color gray900 = Color(0xff0d0a08);  // Almost black
```

### Semantic (Functional)
```dart
// Primary (Blue - professional, not cyan)
static const Color blue = Color(0xff2563eb);    // Action, primary buttons
static const Color blueSoft = Color(0xff3b82f6); // Hover
static const Color blueLight = Color(0xffdbeafe); // Backgrounds

// Status Colors
static const Color success = Color(0xff16a34a);  // Green (natural)
static const Color warning = Color(0xffd97706);  // Amber
static const Color error = Color(0xffd32f2f);    // Red
static const Color info = Color(0xff0891b2);     // Cyan (subtle)

// Backgrounds
static const Color bgLight = Color(0xfffdfdfc);   // Main background
static const Color bgCard = Color(0xfffff9f7);    // Card background
static const Color bgAlt = Color(0xfff5f3f0);     // Alternative
static const Color bgOverlay = Color(0xff1a1410); // Modals/overlays
```

---

## 🔤 Tipografía

### Font Family: `Segoe UI`, `system-ui`, fallback sans-serif
**NO**: Serif headlines, mixed families

### Scale
- **H1**: 32px, weight 700, line-height 1.2
- **H2**: 24px, weight 600, line-height 1.25
- **H3**: 18px, weight 600, line-height 1.3
- **Body**: 14px, weight 400, line-height 1.5
- **Small**: 12px, weight 400, line-height 1.4
- **Tiny**: 11px, weight 400, line-height 1.3

---

## 📏 Espaciado y Borders

### Scale
- xs: 4px
- sm: 8px
- md: 12px
- lg: 16px
- xl: 24px
- 2xl: 32px

### Border Radius
- Buttons: 6px
- Cards: 8px
- Modals: 8px
- Inputs: 6px
- **NO**: Pill shapes (50px), oversized (16px+)

### Borders
- Default: 1px solid `gray300`
- Focus: 1px solid `blue`
- Hover: 1px solid `gray400`
- **NO**: Thick borders, gradients, shadows as borders

### Shadows
- Subtle: `0 1px 2px rgba(0,0,0,0.05)`
- Hover: `0 2px 8px rgba(0,0,0,0.1)`
- Popup: `0 4px 12px rgba(0,0,0,0.15)`
- **MAX**: 8px blur, NEVER 12px+

---

## 🎯 Componentes Core

### Button
```dart
// Primary (solid blue)
height: 36px, padding: 0 16px
border-radius: 6px
background: Color(0xff2563eb)
text: white, 14px, 600 weight

// Secondary (gray border)
height: 36px, padding: 0 16px
border-radius: 6px
border: 1px gray300
background: transparent
text: gray600, 14px, 500 weight

// Ghost (no border)
text only, text-color gray600
hover: background gray200
NO: pill shapes, oversized, shadows
```

### Card
```dart
border-radius: 8px
border: 1px gray200
background: Color(0xfffff9f7)
padding: 16px
box-shadow: 0 1px 2px rgba(0,0,0,0.05)
NO: floating effects, large shadows, gradient backgrounds
```

### Input
```dart
height: 36px, padding: 0 12px
border-radius: 6px
border: 1px gray300
background: Color(0xfffff9f7)
focus: border 1px blue, outline none
NO: underlines only, animated labels, morphing
```

### Chip
```dart
height: 28px, padding: 4px 10px
border-radius: 6px
background: gray200
text: gray700, 12px, 500 weight
NO: oversized, gradient, animated remove
```

### Badge
```dart
height: 20px, padding: 2px 8px
border-radius: 4px
background: gray200 (or color-status)
text: gray700, 11px, 600 weight
NO: glows, large sizes, decorative-only
```

---

## 📐 Layouts

### Standard Container
- max-width: 1280px (large screens)
- padding: 16px horizontal
- margin: 0 auto

### Card Grid
- Columns: auto-fit, max(280px, 1fr)
- Gap: 16px
- NO: asymmetric overlaps, creative arrangements

### Sidebar
- Width: 240px (fixed)
- background: gray900 or bgOverlay
- border-right: 1px gray800
- padding: 16px
- NO: floating, rounded outer corners

### Modal
- Centered on screen
- background: bgOverlay (dark overlay, 60% opacity)
- card size: 480px max width
- border-radius: 8px
- NO: slide-in animations, offset positions

---

## ⚡ Animations & Transitions

- Duration: 100-200ms (NO long waits)
- Easing: ease-in-out (NO bounce)
- Properties: opacity, color, border only
- NO: transform (scale, rotate, translate), dramatic effects

---

## 🎨 Dark vs Light Mode

### Dark Mode (Default for this app)
- Background: gray900
- Cards: gray800
- Text: gray50 (primary), gray200 (secondary)
- Borders: gray700

### Light Mode
- Background: bgLight
- Cards: bgCard (almost white)
- Text: gray700 (primary), gray500 (secondary)
- Borders: gray300

---

## 📋 Rediseño por Fases

### Fase 1: Foundation (ESTA FASE)
- [ ] Actualizar `AppColors` con nueva paleta
- [ ] Crear `DesignTokens` con espaciado/tipografía
- [ ] Rediseñar componentes reutilizables (Button, Card, Input, Chip)
- [ ] Crear guía de componentes (Storybook opcional)

### Fase 2: Core Screens (SIGUIENTE)
- [ ] Home Screen (más crítica)
- [ ] Garage Details
- [ ] Rent/Payment Flow

### Fase 3: Secondary Screens
- [ ] Login/Register
- [ ] Settings
- [ ] Profile/MyGarages

### Fase 4: Polish
- [ ] Animations (subtle transitions)
- [ ] Accessibility (WCAG AA)
- [ ] Dark/Light mode consistency
- [ ] Testing en múltiples dispositivos

---

**Status**: En desarrollo
**Último Update**: 11 de marzo 2026
**Responsable**: GitHub Copilot + UI Expert

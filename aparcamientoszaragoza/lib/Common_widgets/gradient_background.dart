import 'package:flutter/material.dart';

import '../Values/app_colors.dart';

class GradientBackground extends StatelessWidget {
  GradientBackground({
    required this.children,
    List<Color>? colors,
    this.urlCircleImage,
    this.imageBackground, 
    super.key,
  }) : colors = colors ?? AppColors.darkGradient;

  final List<Color> colors;
  String? urlCircleImage;
  final String? imageBackground; 
  final List<Widget> children;

@override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    
    if (imageBackground != null) {
      return Container(
        color: isDarkTheme ? const Color(0xFF070914) : AppColors.lightBackground,
        child: Stack(
          children: [
            // Imagen de fondo en el Top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.45,
              child: Image.asset(
                imageBackground!,
                fit: BoxFit.cover,
              ),
            ),
            // Overlay de degradado para desvanecimiento
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDarkTheme ? [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.2),
                      const Color(0xFF070914).withOpacity(0.8),
                      const Color(0xFF070914),
                    ] : [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.2),
                      AppColors.lightBackground.withOpacity(0.8),
                      AppColors.lightBackground,
                    ],
                    stops: const [0.0, 0.2, 0.4, 0.55],
                  ),
                ),
              ),
            ),
            // Contenido
            DecoratedBox(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                   SizedBox(height: MediaQuery.of(context).size.height * 0.28),
                   ...children,
                ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
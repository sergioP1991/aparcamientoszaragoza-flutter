import 'dart:convert';
import 'dart:math';
import 'package:firebase_ai/firebase_ai.dart';

import 'package:aparcamientoszaragoza/Screens/tutorial/tutorial_screen.dart';
import 'package:aparcamientoszaragoza/Screens/login/login_screen.dart';
import 'package:aparcamientoszaragoza/Screens/register/register_screen.dart';
import 'package:easter_egg_trigger/easter_egg_trigger.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../Common_widgets/styles.dart';

class WelcomeScreen extends StatelessWidget {
  static const routeName = '/welcome-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EasterEggTrigger(
        action: () => print("Easter Egg !!!"),
        child: ModernWelcomeBody(),
        codes: [
          EasterEggTriggers.SwipeLeft,
          EasterEggTriggers.SwipeUp,
        ],
      ),
    );
  }
}

class ModernWelcomeBody extends StatelessWidget {
  const ModernWelcomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      children: [
        // Background Color
        Container(color: const Color(0xFF070914)),
        
        // Background Image at Top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.45,
          child: Image.asset(
            'assets/garaje1.jpeg',
            fit: BoxFit.cover,
          ),
        ),
        
        // Dark Overlay Gradient for the fade out effect
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.0),
                Colors.black.withOpacity(0.2),
                const Color(0xFF070914).withOpacity(0.8),
                const Color(0xFF070914),
              ],
              stops: const [0.0, 0.2, 0.4, 0.55],
            ),
          ),
        ),
        // Content
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                // Titles
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(text: l10n.welcomeTitle1),
                      TextSpan(text: l10n.welcomeTitle2),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.welcomeSubtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                                // Feature Cards
                const SizedBox(height: 24),
                _buildFeatureCard(
                  icon: Icons.search_rounded,
                  title: l10n.featureFindTitle,
                  subtitle: l10n.featureFindSubtitle,
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  icon: Icons.directions_car_rounded,
                  title: l10n.featureRentTitle,
                  subtitle: l10n.featureRentSubtitle,
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  icon: Icons.assignment_turned_in_rounded,
                  title: l10n.featureManageTitle,
                  subtitle: l10n.featureManageSubtitle,
                ),

                const SizedBox(height: 32),

                // Actions
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed(TutorialScreen.routeName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2962FF), // Brand Blue
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.getStarted,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(LoginPage.routeName),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.white70, fontSize: 15),
                        children: [
                          TextSpan(text: l10n.alreadyHaveAccount),
                          TextSpan(
                            text: l10n.loginAction,
                            style: const TextStyle(
                              color: Color(0xFF2962FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2235).withOpacity(0.8), // Dark card bg
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF29304D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF448AFF), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

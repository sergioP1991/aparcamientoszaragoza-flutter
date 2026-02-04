import 'package:aparcamientoszaragoza/Screens/login/login_screen.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class TutorialScreen extends StatefulWidget {
  static const routeName = '/tutorial-screen';

  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingData> _getPages(AppLocalizations l10n) => [
    OnboardingData(
      title: l10n.tutorialTitle1,
      highlightedTitle: l10n.tutorialHighlight1,
      subtitle: l10n.tutorialSubtitle1,
      illustration: const OnboardingIllustration1(),
    ),
    OnboardingData(
      title: l10n.tutorialTitle2,
      highlightedTitle: l10n.tutorialHighlight2,
      subtitle: l10n.tutorialSubtitle2,
      illustration: const OnboardingIllustration2(),
      backgroundImage: 'assets/garaje1.jpeg',
    ),
    OnboardingData(
      title: l10n.tutorialTitle3,
      highlightedTitle: '', // Special case for Zaragoza in blue inside subtitle in design
      subtitle: l10n.tutorialSubtitle3,
      illustration: const OnboardingIllustration3(),
      backgroundImage: 'assets/garaje1.jpeg',
    ),
  ];

  void _onNext(int pageCount) {
    if (_currentPage < pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishTutorial();
    }
  }

  void _finishTutorial() {
    Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = _getPages(l10n);
    bool isLastPage = _currentPage == pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF070914),
      body: Stack(
        children: [
          // Background Image Layer
          if (pages[_currentPage].backgroundImage != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.4,
                child: Image.asset(
                  pages[_currentPage].backgroundImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          
          // Content Layer
          SafeArea(
            child: Column(
              children: [
                // Top Skip Button (Not on last page according to design)
                if (!isLastPage)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _finishTutorial,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              l10n.tutorialSkip,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox(height: 52), // Space for alignment
                
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return OnboardingContent(
                        data: pages[index], 
                        isLast: index == pages.length - 1
                      );
                    },
                  ),
                ),
                
                // Bottom Controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                  child: Column(
                    children: [
                      // Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => _buildIndicator(index == _currentPage),
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // Primary Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => _onNext(pages.length),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2962FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: const Color(0xFF2962FF).withOpacity(0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLastPage ? l10n.tutorialFinish : l10n.tutorialNext,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLastPage ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded, 
                                color: Colors.white
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      if (isLastPage) ...[
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: _finishTutorial,
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
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 4.0,
      width: isActive ? 32.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2962FF) : Colors.white12,
        borderRadius: BorderRadius.circular(2.0),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String highlightedTitle;
  final String subtitle;
  final Widget illustration;
  final String? backgroundImage;

  OnboardingData({
    required this.title,
    required this.highlightedTitle,
    required this.subtitle,
    required this.illustration,
    this.backgroundImage,
  });
}

class OnboardingContent extends StatelessWidget {
  final OnboardingData data;
  final bool isLast;

  const OnboardingContent({super.key, required this.data, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3),
          Center(child: data.illustration),
          const Spacer(flex: 3),
          
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          if (data.highlightedTitle.isNotEmpty)
            Text(
              data.highlightedTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2962FF),
                height: 1.2,
              ),
            ),
          const SizedBox(height: 20),
          
          if (isLast)
            _buildRichSubtitle(data.subtitle)
          else
            Text(
              data.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.6),
                height: 1.5,
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRichSubtitle(String text) {
    // Designer wants 'Zaragoza' in blue for the last step
    final parts = text.split('Zaragoza');
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 16,
          color: Colors.white.withOpacity(0.6),
          height: 1.5,
        ),
        children: [
          TextSpan(text: parts[0]),
          const TextSpan(
            text: 'Zaragoza',
            style: TextStyle(color: Color(0xFF2962FF), fontWeight: FontWeight.w600),
          ),
          TextSpan(text: parts[1]),
        ],
      ),
    );
  }
}

class OnboardingIllustration1 extends StatelessWidget {
  const OnboardingIllustration1({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildCircle(240, Colors.white.withOpacity(0.01)),
          _buildCircle(190, Colors.white.withOpacity(0.02)),
          _buildCircle(140, Colors.white.withOpacity(0.04)),
          
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2235),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2962FF).withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(Icons.travel_explore_rounded, color: Color(0xFF2962FF), size: 40),
          ),
          
          Positioned(top: 40, right: 30, child: _buildFloatingIcon(Icons.location_on, Colors.redAccent, 24)),
          Positioned(bottom: 40, left: 40, child: _buildFloatingIcon(Icons.search, Colors.tealAccent, 20)),
        ],
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
    );
  }

  Widget _buildFloatingIcon(IconData icon, Color color, double size) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFF1E2235), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: size * 0.6),
    );
  }
}

class OnboardingIllustration2 extends StatelessWidget {
  const OnboardingIllustration2({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2235).withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.vpn_key_rounded, color: Color(0xFF2962FF), size: 50),
          ),
          Positioned(
            bottom: 60,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0D101C),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context)!.tagSafeCapitalized,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingIllustration3 extends StatelessWidget {
  const OnboardingIllustration3({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Card
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2235).withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.assignment_rounded, color: Color(0xFF2962FF), size: 50),
          ),
          
          // Small Badge
          Positioned(
            top: 60,
            right: 50,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Color(0xFF0D101C), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.greenAccent, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderIllustration extends StatelessWidget {
  final IconData icon;
  const PlaceholderIllustration({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(color: const Color(0xFF1E2235).withOpacity(0.5), shape: BoxShape.circle),
      child: Icon(icon, color: const Color(0xFF2962FF).withOpacity(0.5), size: 80),
    );
  }
}

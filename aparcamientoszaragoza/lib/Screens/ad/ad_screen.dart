import 'package:flutter/material.dart';
import '../../Values/app_colors.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';

class AdScreen extends StatefulWidget {
  static const routeName = '/ad-screen';

  const AdScreen({super.key});

  @override
  State<AdScreen> createState() => _AdScreenState();
}

class _AdScreenState extends State<AdScreen> {
  int _secondsRemaining = 5;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
            _startTimer();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Stack(
        children: [
          // Background Ad Content (Mock)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.ad_units,
                  size: 100,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.adTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)!.adMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.adDiscount,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Closing Button
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: _secondsRemaining == 0 ? () => Navigator.of(context).pop() : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _secondsRemaining == 0 ? AppColors.primaryColor : Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _secondsRemaining > 0 
                        ? AppLocalizations.of(context)!.closeIn(_secondsRemaining.toString()) 
                        : AppLocalizations.of(context)!.closeAction,
                      style: TextStyle(
                        color: _secondsRemaining == 0 ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_secondsRemaining == 0) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.close, color: Colors.black, size: 18),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

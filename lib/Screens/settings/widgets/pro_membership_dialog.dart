import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:aparcamientoszaragoza/Screens/settings/providers/membership_provider.dart';
import 'package:aparcamientoszaragoza/Models/membership_subscription.dart';

/// Premium PRO subscription dialog with modern Uncodixfy design
/// Linear, Raycast, Stripe aesthetic - clean, minimal, professional
class ProMembershipDialog extends ConsumerStatefulWidget {
  final VoidCallback? onSubscribeSuccess;
  final String? initialTab; // 'monthly' o 'annual'

  const ProMembershipDialog({
    super.key,
    this.onSubscribeSuccess,
    this.initialTab = 'annual', // Annual by default for better conversion
  });

  @override
  ConsumerState<ProMembershipDialog> createState() => _ProMembershipDialogState();
}

class _ProMembershipDialogState extends ConsumerState<ProMembershipDialog> {
  late String selectedPlan; // 'monthly' o 'annual'
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedPlan = widget.initialTab ?? 'annual';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button top-right
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Unlock PRO',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Premium parking experience',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(0.4),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Features showcase (3 cols)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    _featureItem(
                      icon: Icons.ads_click,
                      label: 'Ad-free',
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _featureItem(
                      icon: Icons.priority_high,
                      label: 'Priority support',
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _featureItem(
                      icon: Icons.check_circle,
                      label: 'Full access',
                      color: AppColors.accentGreen,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Pricing cards (side by side)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _pricingCard(
                        plan: 'Monthly',
                        price: '€9.99',
                        period: '/month',
                        isSelected: selectedPlan == 'monthly',
                        onTap: () => setState(() => selectedPlan = 'monthly'),
                        highlight: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Stack(
                        children: [
                          _pricingCard(
                            plan: 'Annual',
                            price: '€99.99',
                            period: '/year',
                            isSelected: selectedPlan == 'annual',
                            onTap: () => setState(() => selectedPlan = 'annual'),
                            highlight: true,
                          ),
                          Positioned(
                            top: -12,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentGreen,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Best deal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Comparison breakdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
                  ),
                  child: Column(
                    children: [
                      _comparisonRow(
                        'Monthly',
                        '€9.99',
                        Colors.white.withOpacity(0.6),
                      ),
                      const SizedBox(height: 10),
                      _comparisonRow(
                        'Annual (monthly avg)',
                        '€8.33',
                        AppColors.accentGreen,
                      ),
                      Divider(
                        color: Colors.white.withOpacity(0.1),
                        height: 14,
                      ),
                      _comparisonRow(
                        'Save per year',
                        '€19.92',
                        AppColors.accentGreen,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Subscribe CTA
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _handleSubscribe(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Subscribe now',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Cancel button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: GestureDetector(
                        onTap: isLoading ? null : () => Navigator.pop(context),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Maybe later',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.7),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pricingCard({
    required String plan,
    required String price,
    required String period,
    required bool isSelected,
    required VoidCallback onTap,
    required bool highlight,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.12)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor.withOpacity(0.4)
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              plan,
              style: TextStyle(
                color: Colors.white.withOpacity(isSelected ? 1 : 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              period,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _comparisonRow(
    String label,
    String value,
    Color valueColor, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubscribe() async {
    setState(() => isLoading = true);

    try {
      // TODO: Integración con Stripe Payment Sheet
      // Stripe SDK will handle the subscription flow:
      // 1. Create SetupIntent on backend
      // 2. Present Stripe payment UI
      // 3. Return to app on completion

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Trigger subscription in Riverpod
        await ref
            .read(membershipNotifierProvider.notifier)
            .subscribeToProPlan(selectedPlan == 'annual' ? 'annual' : 'monthly');

        widget.onSubscribeSuccess?.call();

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Welcome to PRO! 🎉'),
              backgroundColor: AppColors.accentGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red.withOpacity(0.8),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}

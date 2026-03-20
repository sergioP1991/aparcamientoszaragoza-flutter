import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:aparcamientoszaragoza/Screens/settings/providers/membership_provider.dart';
import 'package:aparcamientoszaragoza/Models/membership_subscription.dart';

class ProMembershipDialog extends ConsumerStatefulWidget {
  final VoidCallback? onSubscribeSuccess;
  final String? initialTab; // 'monthly' o 'annual'

  const ProMembershipDialog({
    super.key,
    this.onSubscribeSuccess,
    this.initialTab = 'monthly',
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
    selectedPlan = widget.initialTab ?? 'monthly';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final membership = ref.watch(membershipProvider).value;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: Colors.amber,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upgrade a PRO',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Desbloquea funciones premium',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(0.4),
                        size: 20,
                      ),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Features
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildFeaturesList(l10n),
              ),
              const SizedBox(height: 18),

              // Plan Selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildPlanSelection(l10n),
              ),
              const SizedBox(height: 18),

              // Pricing
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildPricingInfo(l10n),
              ),
              const SizedBox(height: 20),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Subscribe Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _handleSubscribe(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.5),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Suscribirse Ahora',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isLoading ? Colors.white.withOpacity(0.6) : Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          'No ahora',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList(AppLocalizations l10n) {
    final features = [
      ('Sin anuncios', Icons.notifications_off),
      ('Soporte prioritario', Icons.support_agent),
      ('Acceso a funciones avanzadas', Icons.stars),
    ];

    return Column(
      children: features.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  entry.$2,
                  color: AppColors.primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                entry.$1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlanSelection(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildPlanCard(
            'Mensual',
            '€9.99',
            '/mes',
            selectedPlan == 'monthly',
            () => setState(() => selectedPlan = 'monthly'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPlanCard(
            'Anual',
            '€99.99',
            '/año',
            selectedPlan == 'annual',
            () => setState(() => selectedPlan = 'annual'),
            showBadge: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    String title,
    String price,
    String period,
    bool selected,
    VoidCallback onTap, {
    bool showBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryColor.withOpacity(0.12)
                  : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? AppColors.primaryColor.withOpacity(0.4)
                    : Colors.white.withOpacity(0.08),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(selected ? 1 : 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
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
          if (showBadge)
            Positioned(
              top: -6,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Ahorra 17%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPricingInfo(AppLocalizations l10n) {
    final monthlyPrice = 9.99;
    final annualPrice = 99.99;
    final monthlyFromAnnual = annualPrice / 12;
    final savings = monthlyPrice - monthlyFromAnnual;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.white.withOpacity(0.4),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'Comparación de planes',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildPricingRow(
            'Mensual',
            '€${monthlyPrice.toStringAsFixed(2)}/mes',
            AppColors.primaryColor,
          ),
          const SizedBox(height: 6),
          _buildPricingRow(
            'Anual',
            '€${monthlyFromAnnual.toStringAsFixed(2)}/mes',
            AppColors.accentGreen,
          ),
          const SizedBox(height: 6),
          _buildPricingRow(
            'Ahorro anual',
            '€${(savings * 12).toStringAsFixed(2)}',
            AppColors.accentGreen,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingRow(String label, String value, Color color, {bool isBold = false}) {
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
            color: color,
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubscribe(BuildContext context) async {
    setState(() => isLoading = true);

    try {
      // TODO: Aqui se integrará con Stripe para procesar el pago
      // Por ahora, mostramos un diálogo de éxito simulado
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Iniciando suscripción PRO!'),
          backgroundColor: Colors.green,
        ),
      );

      // Simular conexión a Stripe
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        widget.onSubscribeSuccess?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}

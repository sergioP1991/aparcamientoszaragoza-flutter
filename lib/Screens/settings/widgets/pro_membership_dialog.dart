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
      backgroundColor: Colors.black.withOpacity(0.7),
      insetPadding: const EdgeInsets.all(24),
      elevation: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor.withOpacity(0.25),
                            AppColors.primaryColor.withOpacity(0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: Colors.amber,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upgrade a PRO',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Desbloquea funciones premium',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white60),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Features
                _buildFeaturesList(l10n),
                const SizedBox(height: 24),

                // Plan Selection
                _buildPlanSelection(l10n),
                const SizedBox(height: 24),

                // Pricing
                _buildPricingInfo(l10n),
                const SizedBox(height: 24),

                // Subscribe Button
                Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isLoading ? null : () => _handleSubscribe(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Suscribirse Ahora',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Material(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Center(
                        child: Text(
                          'No ahora',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList(AppLocalizations l10n) {
    final features = {
      'Sin anuncios': Icons.notifications_off,
      'Soporte prioritario': Icons.support_agent,
      'Acceso a funciones avanzadas': Icons.stars,
    };

    return Column(
      children: features.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  entry.value,
                  color: AppColors.accentGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                entry.key,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryColor.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? AppColors.primaryColor
                    : Colors.white.withOpacity(0.1),
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  period,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (showBadge)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Ahorra 17%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white70, size: 16),
              SizedBox(width: 8),
              Text(
                'Comparación de planes',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Plan Mensual:',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              Text(
                '€${monthlyPrice.toStringAsFixed(2)}/mes',
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Plan Anual:',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              Text(
                '€${monthlyFromAnnual.toStringAsFixed(2)}/mes',
                style: const TextStyle(
                  color: AppColors.accentGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ahorro anual:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                '€${(savings * 12).toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.accentGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
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

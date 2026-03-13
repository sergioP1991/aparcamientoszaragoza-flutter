import 'package:aparcamientoszaragoza/Services/StripeService.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:flutter/material.dart';

/// Widget reutilizable para seleccionar método de pago
/// Unifica la UI y lógica en toda la aplicación
class PaymentMethodSelector extends StatefulWidget {
  final StripePaymentMethod initialMethod;
  final ValueChanged<StripePaymentMethod> onMethodChanged;
  final bool isEnabled;

  const PaymentMethodSelector({
    super.key,
    this.initialMethod = StripePaymentMethod.card,
    required this.onMethodChanged,
    this.isEnabled = true,
  });

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  late StripePaymentMethod _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.initialMethod;
  }

  @override
  Widget build(BuildContext context) {
    final availableMethods = StripeService.getAvailablePaymentMethods(country: 'ES');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Método de pago',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: availableMethods.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final method = availableMethods[index];
            return _buildPaymentMethodTile(method);
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile(StripePaymentMethod method) {
    final isSelected = _selectedMethod == method;
    final methodInfo = StripeService.getPaymentMethodDetails(method);

    return GestureDetector(
      onTap: widget.isEnabled
          ? () {
              setState(() => _selectedMethod = method);
              widget.onMethodChanged(method);
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.2) : AppColors.cardBackground,
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Icono
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  methodInfo['icon'] as IconData,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    methodInfo['label'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    methodInfo['description'] as String,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Radio button
            Radio<StripePaymentMethod>(
              value: method,
              groupValue: _selectedMethod,
              onChanged: widget.isEnabled
                  ? (value) {
                      if (value != null) {
                        setState(() => _selectedMethod = value);
                        widget.onMethodChanged(value);
                      }
                    }
                  : null,
              activeColor: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

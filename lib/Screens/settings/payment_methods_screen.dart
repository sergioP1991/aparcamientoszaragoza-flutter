import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/Models/user_settings.dart';
import 'package:aparcamientoszaragoza/Screens/settings/providers/settings_provider.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pantalla para gestionar qué métodos de pago prefiere el usuario
/// Solo los métodos seleccionados aquí aparecerán en el flujo de pago
class PaymentMethodsScreen extends ConsumerStatefulWidget {
  static const routeName = '/payment-methods';

  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  late Set<String> _selectedMethods;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _selectedMethods = Set.from(settings.availablePaymentMethods);
  }

  void _toggleMethod(String method) {
    setState(() {
      if (_selectedMethods.contains(method)) {
        // No permitir dejar sin métodos de pago
        if (_selectedMethods.length > 1) {
          _selectedMethods.remove(method);
        }
      } else {
        _selectedMethods.add(method);
      }
    });
  }

  Future<void> _savePaymentMethods() async {
    // Validar que al menos haya un método seleccionado
    if (_selectedMethods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes seleccionar al menos un método de pago'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Guardar en settings
    await ref
        .read(settingsProvider.notifier)
        .updateAvailablePaymentMethods(_selectedMethods.toList());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Métodos de pago actualizados'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDarkTheme = settings.theme == 'dark';
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDarkTheme ? AppColors.darkestBlue : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: isDarkTheme ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.paymentMethods,
          style: TextStyle(
            color: isDarkTheme ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Descripción
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkTheme
                    ? AppColors.darkCardBackground
                    : AppColors.lightCardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Selecciona los métodos de pago que deseas utilizar en la aplicación. Solo los métodos seleccionados aparecerán en el proceso de reserva.',
                style: TextStyle(
                  color: isDarkTheme ? Colors.white70 : AppColors.lightSecondaryText,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Método: Tarjeta de crédito
            _buildPaymentMethodItem(
              method: 'card',
              icon: Icons.credit_card,
              title: 'Tarjeta de Crédito/Débito',
              description: 'Visa, Mastercard, American Express',
              isSelected: _selectedMethods.contains('card'),
              isDarkTheme: isDarkTheme,
              onToggle: () => _toggleMethod('card'),
            ),
            const SizedBox(height: 12),

            // Método: Apple Pay
            _buildPaymentMethodItem(
              method: 'apple_pay',
              icon: Icons.apple,
              title: 'Apple Pay',
              description: 'Pago rápido con Apple Pay',
              isSelected: _selectedMethods.contains('apple_pay'),
              isDarkTheme: isDarkTheme,
              onToggle: () => _toggleMethod('apple_pay'),
            ),
            const SizedBox(height: 12),

            // Método: Google Pay
            _buildPaymentMethodItem(
              method: 'google_pay',
              icon: Icons.account_balance_wallet,
              title: 'Google Pay',
              description: 'Pago rápido con Google Pay',
              isSelected: _selectedMethods.contains('google_pay'),
              isDarkTheme: isDarkTheme,
              onToggle: () => _toggleMethod('google_pay'),
            ),
            const SizedBox(height: 12),

            // Método: PayPal
            _buildPaymentMethodItem(
              method: 'paypal',
              icon: Icons.payment,
              title: 'PayPal',
              description: 'Pago seguro con PayPal',
              isSelected: _selectedMethods.contains('paypal'),
              isDarkTheme: isDarkTheme,
              onToggle: () => _toggleMethod('paypal'),
            ),
            const SizedBox(height: 32),

            // Botón guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _savePaymentMethods,
                icon: const Icon(Icons.check),
                label: const Text('Guardar cambios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem({
    required String method,
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required bool isDarkTheme,
    required VoidCallback onToggle,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkTheme
              ? AppColors.darkCardBackground
              : AppColors.lightCardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : (isDarkTheme ? Colors.white10 : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icono
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor.withOpacity(0.2)
                    : (isDarkTheme ? Colors.white10 : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primaryColor : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Título y descripción
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white54 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Checkbox
            Checkbox(
              value: isSelected,
              onChanged: (_) => onToggle(),
              fillColor:
                  MaterialStateProperty.all(AppColors.primaryColor),
              checkColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

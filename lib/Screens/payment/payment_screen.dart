import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Services/StripeService.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentPage extends ConsumerStatefulWidget {
  static const routeName = '/payment';

  final Garaje plaza;
  final int rentalDays;
  final double totalAmount;

  const PaymentPage({
    super.key,
    required this.plaza,
    required this.rentalDays,
    required this.totalAmount,
  });

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  StripePaymentMethod? _selectedPaymentMethod;
  bool _isProcessing = false;
  String? _errorMessage;
  StripePaymentResult? _paymentResult;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = StripePaymentMethod.card; // Default
    // Inicializar Stripe
    StripeService.initialize();
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      setState(() => _errorMessage = 'Por favor selecciona un método de pago');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Crear Payment Intent
      final amountInCents = (widget.totalAmount * 100).toInt();
      
      final response = await StripeService.createPaymentIntent(
        amountInCents: amountInCents,
        currency: 'eur',
        plazaId: widget.plaza.idPlaza ?? 0,
        description: 'Alquiler Plaza: ${widget.plaza.direccion}',
      );

      if (!response['success']) {
        setState(() => _errorMessage = response['error'] ?? 'Error al crear el pago');
        return;
      }

      final clientSecret = response['clientSecret'] as String;
      StripePaymentResult result;

      // Procesar según el método seleccionado
      switch (_selectedPaymentMethod) {
        case StripePaymentMethod.card:
          result = await StripeService.processCardPayment(
            clientSecret: clientSecret,
            amount: widget.totalAmount,
            currency: 'eur',
          );
          break;
        case StripePaymentMethod.googlePay:
          // TODO: Implementar Google Pay cuando sea disponible
          setState(() => _errorMessage = 'Google Pay no disponible aún');
          return;
          /*
          result = await StripeService.processGooglePayment(
            clientSecret: clientSecret,
            amount: widget.totalAmount,
            currency: 'eur',
            label: 'Alquiler Plaza',
          );
          */
          break;
        case StripePaymentMethod.applePay:
          // TODO: Implementar Apple Pay cuando sea disponible
          setState(() => _errorMessage = 'Apple Pay no disponible aún');
          return;
          /*
          result = await StripeService.processApplePayment(
            clientSecret: clientSecret,
            amount: widget.totalAmount,
            currency: 'eur',
            label: 'Alquiler Plaza',
          );
          */
        default:
          // Por ahora, otros métodos solo funcionan con Cloud Function
          setState(() => _errorMessage = 'Este método requiere Cloud Function configurada');
          return;
      }

      setState(() {
        _paymentResult = result;
        if (result.isSuccessful) {
          _showPaymentSuccess();
        } else {
          _errorMessage = result.errorMessage ?? 'Error en el pago';
        }
      });
    } catch (e) {
      setState(() => _errorMessage = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showPaymentSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkestBlue,
        title: const Text('✅ Pago exitoso', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu reserva ha sido confirmada',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Plaza:', widget.plaza.direccion),
            _buildInfoRow('Días:', widget.rentalDays.toString()),
            _buildInfoRow('Total:', '${widget.totalAmount.toStringAsFixed(2)}€'),
            _buildInfoRow('ID Pago:', _paymentResult?.paymentIntentId.substring(0, 8) ?? ''),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Volver a detalles
            },
            child: const Text('Aceptar', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final availableMethods = StripeService.getAvailablePaymentMethods(country: 'ES');

    return Scaffold(
      backgroundColor: AppColors.darkestBlue,
      appBar: AppBar(
        backgroundColor: AppColors.darkestBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Método de Pago', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen de reserva
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen de Reserva',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Plaza', widget.plaza.direccion),
                    _buildSummaryRow('Ubicación', widget.plaza.direccion),
                    _buildSummaryRow('Duración', '${widget.rentalDays} días'),
                    _buildSummaryRow(
                      'Precio diario',
                      '${widget.plaza.precio.toStringAsFixed(2)}€',
                    ),
                    const Divider(color: Colors.white24),
                    _buildSummaryRow(
                      'TOTAL',
                      '${widget.totalAmount.toStringAsFixed(2)}€',
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Métodos de pago disponibles
              Text(
                'Métodos de Pago Disponibles',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Grid de métodos de pago
              for (var method in availableMethods)
                _buildPaymentMethodTile(method),

              const SizedBox(height: 30),

              // Mensaje de error
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),

              const SizedBox(height: 20),

              // Botón de pago
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isProcessing || _selectedPaymentMethod == null)
                      ? null
                      : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Pagar ${widget.totalAmount.toStringAsFixed(2)}€',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Aviso de seguridad
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.security, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tus datos de pago están protegidos con encriptación SSL',
                        style: TextStyle(color: Colors.green, fontSize: 12),
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

  Widget _buildPaymentMethodTile(StripePaymentMethod method) {
    final details = StripeService.getPaymentMethodDetails(method);
    final isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.2)
              : AppColors.cardBackground,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                details['icon'] ?? '💳',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    details['description'] ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isBold ? Colors.blue : Colors.white,
              fontSize: isBold ? 16 : 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

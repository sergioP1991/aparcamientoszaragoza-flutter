import 'package:flutter/material.dart';
import 'package:aparcamientoszaragoza/Models/multa.dart';
import 'package:aparcamientoszaragoza/Services/StripeService.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/Common_widgets/payment_method_selector.dart';

typedef PaymentSuccessCallback = Future<void> Function(Multa penalty, String paymentIntentId);

class PaymentPenaltyScreen extends StatefulWidget {
  final Multa penalty;
  final PaymentSuccessCallback onPaymentSuccess;

  const PaymentPenaltyScreen({
    required this.penalty,
    required this.onPaymentSuccess,
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentPenaltyScreen> createState() => _PaymentPenaltyScreenState();
}

class _PaymentPenaltyScreenState extends State<PaymentPenaltyScreen> {
  late StripePaymentMethod _selectedPaymentMethod;
  bool _isProcessing = false;
  String? _errorMessage;


  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = StripePaymentMethod.card;
    StripeService.initialize();
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Crear Payment Intent para la multa
      final amountInCents = (widget.penalty.monto * 100).toInt();

      final response = await StripeService.createPaymentIntent(
        amountInCents: amountInCents,
        currency: 'eur',
        plazaId: widget.penalty.idPlaza,
        description: 'Pago de Multa - Plaza #${widget.penalty.idPlaza}',
      );

      if (!response['success']) {
        setState(() => _errorMessage = response['error'] ?? 'Error al crear el pago');
        return;
      }

      final clientSecret = response['clientSecret'] as String;
      StripePaymentResult result;

      // Procesar con método seleccionado
      switch (_selectedPaymentMethod) {
        case StripePaymentMethod.card:
          result = await StripeService.processCardPayment(
            clientSecret: clientSecret,
            amount: widget.penalty.monto,
            currency: 'eur',
          );
          break;
        default:
          setState(() => _errorMessage = 'Método de pago no disponible');
          return;
      }

      setState(() {
        if (result.isSuccessful) {
          _handlePaymentSuccess(result);
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

  void _handlePaymentSuccess(StripePaymentResult result) {
    // Mostrar diálogo de éxito
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkestBlue,
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        title: const Text(
          '✅ Pago Exitoso',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              '€${widget.penalty.monto.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Multa pagada correctamente',
              style: TextStyle(color: Colors.grey[300], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Plaza #${widget.penalty.idPlaza}',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              
              // ✅ AHORA ESPERA a que el callback complete (actualización en Firestore)
              _completePaymentAndClose(result.paymentIntentId ?? 'unknown');
            },
            child: const Text('Continuar', style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  /// ✅ NUEVO: Método async para esperar a que Firestore se actualice antes de cerrar
  Future<void> _completePaymentAndClose(String paymentIntentId) async {
    debugPrint('⏳ [PAYMENT] Esperando a que se actualice Firestore...');
    
    // Esperar a que el callback complete (actualiza estado a 'pagada' en Firestore)
    await widget.onPaymentSuccess(widget.penalty, paymentIntentId);
    
    debugPrint('✅ [PAYMENT] Firestore actualizado, cerrando pantalla de pago');
    
    // Cerrar la pantalla de pago DESPUÉS de la actualización
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkestBlue,
      appBar: AppBar(
        backgroundColor: AppColors.darkestBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '💳 Pagar Multa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen de la multa
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚠️ Resumen de la Multa',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Monto:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        '€${widget.penalty.monto.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Plaza:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        '#${widget.penalty.idPlaza}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Razón:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Expanded(
                        child: Text(
                          widget.penalty.razon,
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.grey[300], fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Método de pago
            const Text(
              'Método de Pago',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            PaymentMethodSelector(
              initialMethod: _selectedPaymentMethod,
              onMethodChanged: (method) {
                setState(() => _selectedPaymentMethod = method);
              },
              isEnabled: !_isProcessing,
            ),
            const SizedBox(height: 24),

            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Botón de pago
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processPayment,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(
                  _isProcessing
                      ? 'Procesando...'
                      : 'Pagar €${widget.penalty.monto.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  disabledBackgroundColor: Colors.green.withOpacity(0.6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Info de seguridad
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                border: Border.all(color: Colors.blue, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tu transacción está protegida por Stripe',
                      style: TextStyle(color: Colors.blue[200], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

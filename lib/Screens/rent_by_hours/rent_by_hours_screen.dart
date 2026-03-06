import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Services/PlazaImageService.dart';
import 'package:aparcamientoszaragoza/Services/RentalByHoursService.dart';
import 'package:aparcamientoszaragoza/Services/StripeService.dart';
import 'package:aparcamientoszaragoza/widgets/plaza_image_loader.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/HomeProviders.dart';
import 'package:intl/intl.dart';

class RentByHoursScreen extends ConsumerStatefulWidget {
  static const routeName = '/rentByHours';

  const RentByHoursScreen({super.key});

  @override
  ConsumerState<RentByHoursScreen> createState() => _RentByHoursScreenState();
}

class _RentByHoursScreenState extends ConsumerState<RentByHoursScreen> {
  int _selectedDuration = 1; // horas
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'google_pay'; // default: Google Pay

  // Precios por hora (configurables)
  static const double pricePerHour = 2.50; // €/hora
  static const double ivaRate = 0.21;
  static const double managementFee = 0.45;

  @override
  Widget build(BuildContext context) {
    final int idPlaza = (ModalRoute.of(context)?.settings.arguments ?? 0) as int;
    final homeDataState = ref.watch(fetchHomeProvider(allGarages: true));
    final plaza = homeDataState.value?.getGarageById(idPlaza);
    final l10n = AppLocalizations.of(context)!;

    if (plaza == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Cálculos
    final durationMinutes = _selectedDuration * 60;
    final basePrice = (_selectedDuration * pricePerHour);
    final iva = basePrice * ivaRate;
    final total = basePrice + managementFee + iva;

    return Scaffold(
      backgroundColor: AppColors.darkestBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Alquiler por Horas',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen y datos de la plaza
            _buildPlazaCard(plaza),
            const SizedBox(height: 30),

            // Selector de duración
            _buildDurationSelector(context, l10n),
            const SizedBox(height: 30),

            // Desglose de precios
            _buildPriceBreakdown(context, basePrice, iva, total, l10n),
            const SizedBox(height: 30),

            // Selector de método de pago
            _buildPaymentMethodSelector(),
            const SizedBox(height: 30),

            // Información de vencimiento
            _buildExpirationInfo(durationMinutes, l10n),
            const SizedBox(height: 30),

            // Botón de confirmar
            _buildConfirmButton(context, plaza, durationMinutes, total, l10n),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPlazaCard(Garaje plaza) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen (usando imágenes reales subidas o fallback)
          PlazaImageLoader(
            imageUrl: plaza.imagenes.isNotEmpty ? plaza.imagenes.first : PlazaImageService.getLargeUrl(plaza.idPlaza ?? 0),
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            showWarningOnError: true,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre principal de la plaza
                Text(
                  plaza.direccion.split(',').first,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Dirección completa
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        plaza.direccion,
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelector(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⏱️ Selecciona la duración',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Grid de duraciones predefinidas
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildDurationOption(context, 1, '1h'),
            _buildDurationOption(context, 2, '2h'),
            _buildDurationOption(context, 4, '4h'),
            _buildDurationOption(context, 8, '8h'),
            _buildDurationOption(context, 12, '12h'),
            _buildDurationOption(context, 24, '24h'),
          ],
        ),
        const SizedBox(height: 16),
        // Duración personalizada
        Text(
          'O selecciona una duración personalizada:',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        const SizedBox(height: 12),
        Slider(
          value: _selectedDuration.toDouble(),
          min: 1,
          max: 72,
          divisions: 71,
          onChanged: (value) {
            setState(() => _selectedDuration = value.toInt());
          },
          activeColor: Colors.blue,
          inactiveColor: Colors.grey[800],
        ),
        Center(
          child: Text(
            '$_selectedDuration horas',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationOption(BuildContext context, int hours, String label) {
    final isSelected = _selectedDuration == hours;
    return GestureDetector(
      onTap: () => setState(() => _selectedDuration = hours),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : AppColors.darkCardBackground,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.white10,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '€${(hours * pricePerHour).toStringAsFixed(2)}',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown(
    BuildContext context,
    double basePrice,
    double iva,
    double total,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💳 Desglose de Precios',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkCardBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildPriceRow('Alquiler (${_selectedDuration}h × €${pricePerHour})', basePrice),
              const SizedBox(height: 8),
              _buildPriceRow('Comisión de gestión', managementFee),
              const SizedBox(height: 8),
              _buildPriceRow('IVA (21%)', iva),
              const Divider(color: Colors.white10, height: 16),
              _buildPriceRow('TOTAL', total, isBold: true, color: Colors.green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isBold = false, Color color = Colors.white}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '€${value.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildExpirationInfo(int durationMinutes, AppLocalizations l10n) {
    final expirationTime = DateTime.now().add(Duration(minutes: durationMinutes));
    final formattedTime = DateFormat('HH:mm').format(expirationTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[900]!.withOpacity(0.3),
        border: Border.all(color: Colors.blue[700]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⏰ Información de Vencimiento',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildExpirationDetail(
            'Hora de vencimiento',
            formattedTime,
            'Tu plaza se liberará automáticamente a esta hora',
          ),
          const SizedBox(height: 12),
          _buildExpirationDetail(
            'Margen de seguridad',
            '5 minutos',
            'Tendrás 5 minutos después del vencimiento para liberar manualmente',
          ),
          const SizedBox(height: 12),
          _buildExpirationDetail(
            'Multa potencial',
            'Aplica después del margen',
            'Si no liberas la plaza pasados los 5 minutos',
          ),
        ],
      ),
    );
  }

  Widget _buildExpirationDetail(String title, String value, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.blue[200], fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: Colors.blue[300], fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(
    BuildContext context,
    Garaje plaza,
    int durationMinutes,
    double total,
    AppLocalizations l10n,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          disabledBackgroundColor: Colors.grey,
        ),
        onPressed: _isProcessing ? null : () => _confirmRental(context, plaza, durationMinutes, total),
        child: _isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
              )
            : const Text(
                'Confirmar Alquiler',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }

  // ─── Widget: selector de método de pago ────────────────────────────────────
  Widget _buildPaymentMethodSelector() {
    final methods = [
      _PaymentOption(
        id: 'google_pay',
        label: 'Google Pay',
        icon: Icons.g_mobiledata_rounded,
        color: const Color(0xFF4285F4),
        subtitle: 'Paga con tu cuenta de Google',
      ),
      _PaymentOption(
        id: 'apple_pay',
        label: 'Apple Pay',
        icon: Icons.apple,
        color: Colors.white,
        subtitle: kIsWeb ? 'Disponible en Safari (iOS/macOS)' : 'Solo en dispositivos Apple',
      ),
      _PaymentOption(
        id: 'paypal',
        label: 'PayPal',
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFF003087),
        subtitle: 'Paga con tu cuenta PayPal',
      ),
      _PaymentOption(
        id: 'card',
        label: 'Tarjeta',
        icon: Icons.credit_card_rounded,
        color: Colors.orangeAccent,
        subtitle: 'Visa, Mastercard, Amex…',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💳 Método de pago',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...methods.map((option) {
          final isSelected = _selectedPaymentMethod == option.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedPaymentMethod = option.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue.withOpacity(0.15)
                    : AppColors.darkCardBackground,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[700]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: option.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(option.icon, color: option.color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          option.subtitle,
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ─── Procesar pago y crear alquiler ─────────────────────────────────────────
  Future<void> _confirmRental(
    BuildContext context,
    Garaje plaza,
    int durationMinutes,
    double total,
  ) async {
    try {
      setState(() => _isProcessing = true);

      // 1 ── Crear PaymentIntent en Stripe
      final totalInCents = (total * 100).round();
      final piResult = await StripeService.createPaymentIntent(
        amountInCents: totalInCents,
        currency: 'eur',
        plazaId: plaza.idPlaza!,
        description:
            'Alquiler Plaza #${plaza.idPlaza} — ${_selectedDuration}h ($durationMinutes min)',
      );

      if (!piResult['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error Stripe: ${piResult['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final clientSecret = piResult['clientSecret'] as String;

      // 2 ── Procesar pago según método seleccionado
      StripePaymentResult paymentResult;
      switch (_selectedPaymentMethod) {
        case 'google_pay':
          paymentResult = await StripeService.processGooglePayment(
            clientSecret: clientSecret,
            amount: total,
            currency: 'eur',
            label: 'Plaza #${plaza.idPlaza}',
          );
          break;
        case 'apple_pay':
          paymentResult = await StripeService.processApplePayment(
            clientSecret: clientSecret,
            amount: total,
            currency: 'eur',
            label: 'Plaza #${plaza.idPlaza}',
          );
          break;
        case 'paypal':
          paymentResult = await StripeService.processPaypalPayment(
            clientSecret: clientSecret,
            amount: total,
            currency: 'eur',
            label: 'Plaza #${plaza.idPlaza}',
          );
          break;
        default: // 'card'
          paymentResult = await StripeService.processCardPayment(
            clientSecret: clientSecret,
            amount: total,
            currency: 'eur',
          );
      }

      // 3 ── Evaluar resultado del pago
      if (paymentResult.status == 'canceled') {
        // Usuario canceló voluntariamente — sin error rojo
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🚫 Pago cancelado'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (paymentResult.status == 'google_pay_not_available') {
        // Google Pay no está configurado en este navegador
        if (mounted) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1E2A3A),
              title: const Row(
                children: [
                  Icon(Icons.g_mobiledata_rounded,
                      color: Color(0xFF4285F4), size: 28),
                  SizedBox(width: 8),
                  Text('Google Pay no disponible',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
              content: const Text(
                'Google Pay no está disponible en este navegador o '
                'en tu cuenta de Google.\n\n'
                '• Asegúrate de estar en Chrome y tener una tarjeta guardada en tu cuenta Google.\n'
                '• Puedes usar Tarjeta como método alternativo.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar',
                      style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent),
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(
                        () => _selectedPaymentMethod = 'card');
                  },
                  child: const Text('Usar Tarjeta',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
        return;
      }

      if (paymentResult.status != 'succeeded' &&
          paymentResult.status != 'processing') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '❌ Pago no completado: ${paymentResult.errorMessage ?? paymentResult.status}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // 4 ── Pago exitoso → crear alquiler en Firestore
      final rentalId = await RentalByHoursService.createRental(
        plazaId: plaza.idPlaza!,
        durationMinutes: durationMinutes,
        pricePerMinute: (pricePerHour / 60),
      );

      if (rentalId != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Pago confirmado y alquiler creado — Total: €${total.toStringAsFixed(2)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refrescar el proveedor de home para actualizar la lista de plazas
        await ref.refresh(fetchHomeProvider(allGarages: true, onlyMine: false));
        
        // Navegar a Home (listado de plazas)
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

// ─── Modelo interno para las opciones de pago ───────────────────────────────
class _PaymentOption {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _PaymentOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.subtitle,
  });
}

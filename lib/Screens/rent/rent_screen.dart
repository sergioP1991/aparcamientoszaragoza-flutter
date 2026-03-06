import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Models/normal.dart';
import 'package:aparcamientoszaragoza/Models/especial.dart';
import 'package:aparcamientoszaragoza/Models/alquiler_por_horas.dart';
import 'package:aparcamientoszaragoza/Services/PlazaImageService.dart';
import 'package:aparcamientoszaragoza/Services/StripeService.dart';
import 'package:aparcamientoszaragoza/Services/RentalByHoursService.dart';
import 'package:aparcamientoszaragoza/Screens/rent/providers/RentProvider.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../home/providers/HomeProviders.dart';
import '../../Values/app_colors.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';

class RentPage extends ConsumerStatefulWidget {
  static const routeName = '/rentPage';

  const RentPage({super.key});

  @override
  ConsumerState<RentPage> createState() => _RentPageState();
}

class _RentPageState extends ConsumerState<RentPage> {
  List<DateTime?> _selectedDates = [DateTime.now()];
  bool _isProcessingPayment = false;
  String _selectedPaymentMethod = 'card'; // Track selected payment method
  
  // Pricing Constants
  static const double managementFee = 0.45;
  static const double ivaRate = 0.21;

  @override
  Widget build(BuildContext context) {
    final int idPlaza = (ModalRoute.of(context)?.settings.arguments ?? 0) as int;
    final homeDataState = ref.watch(fetchHomeProvider(allGarages: true));
    final plaza = homeDataState.value?.getGarageById(idPlaza);
    final user = homeDataState.value?.user;

    if (plaza == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Validaciones defensivas
    int durationDays = _selectedDates.isNotEmpty ? _selectedDates.length : 1;
    int hours = plaza.rentIsNormal ? 720 : (durationDays * 9);
    double precioBase = plaza.precio.toDouble();
    double basePrice = (hours * precioBase);
    double iva = basePrice * ivaRate;
    double total = basePrice + managementFee + iva;

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
          AppLocalizations.of(context)!.rentConfirmationTitle,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(AppLocalizations.of(context)!.garageSummaryTitle),
            _buildPlazaSummary(plaza),
            const SizedBox(height: 30),
            
            _buildSectionTitle(AppLocalizations.of(context)!.rentalPeriodTitle),
            _buildRentalPeriod(context, plaza),
            const SizedBox(height: 30),
            
            _buildSectionTitle(AppLocalizations.of(context)!.paymentBreakdownTitle),
            _buildPriceBreakdown(plaza, hours, basePrice, iva),
            const SizedBox(height: 10),
            const Divider(color: Colors.white10),
            const SizedBox(height: 10),
            _buildTotalRow(total, AppLocalizations.of(context)!),
            const SizedBox(height: 30),
            
            _buildSectionTitle(AppLocalizations.of(context)!.paymentMethodTitle),
            _buildPaymentMethod(AppLocalizations.of(context)!),
            const SizedBox(height: 30),
            
            _buildLegalText(AppLocalizations.of(context)!),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildConfirmButton(context, plaza, user, total, AppLocalizations.of(context)!),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPlazaSummary(Garaje plaza) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified, color: Colors.blue, size: 16),
                    const SizedBox(width: 6),
                    Text(AppLocalizations.of(context)!.verifiedLabel, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "${AppLocalizations.of(context)!.navGarages} ${plaza.direccion.split(',').first}",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  plaza.direccion,
                  style: const TextStyle(color: Colors.white38, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              PlazaImageService.getMediumUrl(plaza.idPlaza ?? 0),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: Colors.grey,
                child: const Icon(Icons.image_not_supported, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRentalPeriod(BuildContext context, Garaje plaza) {
    String dateRange = "";
    final l10n = AppLocalizations.of(context)!;
    if (plaza.rentIsNormal) {
      dateRange = l10n.monthlyAutoRenewal;
    } else {
      if (_selectedDates.isEmpty) {
        dateRange = l10n.selectDatesHint;
      } else if (_selectedDates.length == 1) {
        dateRange = "${DateFormat('dd MMM').format(_selectedDates.first!)}, 09:00 - 18:00";
      } else {
        dateRange = l10n.daysSelected(_selectedDates.length);
      }
    }

    return GestureDetector(
      onTap: () async {
        if (!plaza.rentIsNormal) {
          final results = await showCalendarDatePicker2Dialog(
            context: context,
            config: CalendarDatePicker2WithActionButtonsConfig(
              calendarType: CalendarDatePicker2Type.multi,
              selectedDayHighlightColor: Colors.blue,
            ),
            dialogSize: const Size(325, 400),
            value: _selectedDates,
            borderRadius: BorderRadius.circular(15),
          );
          if (results != null) {
            setState(() => _selectedDates = results);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_today_outlined, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateRange,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plaza.rentIsNormal ? l10n.longTermContract : l10n.totalDuration(_selectedDates.length * 9),
                    style: const TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown(Garaje plaza, int hours, double base, double iva) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildPriceRow(l10n.baseRateLabel(hours, plaza.precio.toStringAsFixed(2)), base),
        _buildPriceRow(l10n.managementFeesLabel, managementFee),
        _buildPriceRow(l10n.ivaLabel, iva),
      ],
    );
  }

  Widget _buildPriceRow(String label, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          Text("${price.toStringAsFixed(2)} €", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(double total, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l10n.totalToPay, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(
          "${total.toStringAsFixed(2)} €",
          style: const TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod(AppLocalizations l10n) {
    final paymentMethods = [
      {'id': 'card', 'name': 'Tarjeta', 'description': 'Visa, Mastercard, Amex'},
      {'id': 'apple_pay', 'name': 'Apple Pay', 'description': 'Pago rápido y seguro'},
      {'id': 'google_pay', 'name': 'Google Pay', 'description': 'Pago con tu cuenta Google'},
      {'id': 'paypal', 'name': 'PayPal', 'description': 'Cuenta de PayPal'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona método de pago',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: paymentMethods.map((method) {
              final isSelected = _selectedPaymentMethod == method['id'];
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = method['id'] as String;
                  });
                  debugPrint('✅ Método seleccionado: ${method['name']}');
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.white.withOpacity(0.02),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.white12,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildPaymentIcon(method['id'] as String),
                      const SizedBox(width: 12),
                      // Nombre y descripción
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method['name'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              method['description'] as String,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Radio button mejorado
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.white30,
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentIcon(String methodId) {
    switch (methodId) {
      case 'card':
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8A00), Color(0xFFE52E71)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.credit_card_rounded, color: Colors.white, size: 26),
        );
      case 'apple_pay':
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.apple, color: Colors.white, size: 22),
              Text('Pay', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600, height: 1.0)),
            ],
          ),
        );
      case 'google_pay':
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDADCE0)),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('G', style: TextStyle(
                color: Color(0xFF4285F4),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              )),
              Text('Pay', style: TextStyle(color: Color(0xFF5F6368), fontSize: 9, fontWeight: FontWeight.w500, height: 1.0)),
            ],
          ),
        );
      case 'paypal':
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF003087), Color(0xFF009CDE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('PP', style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              letterSpacing: -1,
            )),
          ),
        );
      default:
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.payment, color: Colors.white, size: 26),
        );
    }
  }

  Future<Map<String, String>?> _showCardInputDialog() async {
    final cardCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvcCtrl = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.blue, size: 20),
            SizedBox(width: 10),
            Text('Datos de tarjeta',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cardCtrl,
                decoration: _cardInputDecoration('Número de tarjeta', '4242 4242 4242 4242', Icons.credit_card),
                style: const TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 1.5),
                keyboardType: TextInputType.number,
                maxLength: 19,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expiryCtrl,
                      decoration: _cardInputDecoration('MM/AA', '12/28', Icons.calendar_today),
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      keyboardType: TextInputType.datetime,
                      maxLength: 5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: cvcCtrl,
                      decoration: _cardInputDecoration('CVC', '123', Icons.lock_outline),
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Colors.green.shade400, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pago seguro procesado por Stripe',
                        style: TextStyle(color: Colors.green.shade300, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.lock, size: 14),
            label: const Text('Pagar', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              final num = cardCtrl.text.replaceAll(RegExp(r'\s'), '');
              final exp = expiryCtrl.text.trim();
              final cvc = cvcCtrl.text.trim();
              if (num.length < 13 || !exp.contains('/') || exp.length < 4 || cvc.length < 3) return;
              final parts = exp.split('/');
              final yr = parts[1].length == 2 ? '20${parts[1]}' : parts[1];
              Navigator.pop(ctx, {
                'number': num,
                'exp_month': parts[0],
                'exp_year': yr,
                'cvc': cvc,
              });
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _cardInputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
      prefixIcon: Icon(icon, color: Colors.white30, size: 18),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blue),
      ),
    );
  }

  Widget _buildLegalText(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(color: Colors.white38, fontSize: 12),
            children: [
              TextSpan(text: l10n.legalPrefix),
              TextSpan(
                text: l10n.termsOfService,
                style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
              TextSpan(text: l10n.andThe),
              TextSpan(
                text: l10n.cancellationPolicy,
                style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
              const TextSpan(text: "."),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, Garaje plaza, User? user, double total, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
      decoration: BoxDecoration(
        color: AppColors.darkestBlue,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton.icon(
          onPressed: _isProcessingPayment ? null : () => _handleRent(plaza, user),
          icon: _isProcessingPayment 
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
              )
            : const Icon(Icons.lock, size: 18),
          label: Text(
            _isProcessingPayment 
              ? l10n.processingPayment
              : l10n.confirmPaymentAction(total.toStringAsFixed(2)),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isProcessingPayment ? Colors.grey : Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  void _handleRent(Garaje plaza, User? user) {
    _processPaymentAndRent(plaza, user);
  }

  Future<void> _processPaymentAndRent(Garaje plaza, User? user) async {
    if (_isProcessingPayment) return;

    // En web: mostrar formulario de tarjeta SOLO si el usuario seleccionó tarjeta
    Map<String, String>? cardData;
    if (kIsWeb && _selectedPaymentMethod == 'card') {
      cardData = await _showCardInputDialog();
      if (cardData == null) return; // Usuario canceló
    }

    setState(() => _isProcessingPayment = true);

    try {
      // Calcular total usando la plaza que ya tenemos
      int hours = plaza.rentIsNormal ? 720 : (_selectedDates.length * 9);
      double basePrice = (hours * plaza.precio).toDouble();
      double iva = basePrice * ivaRate;
      double total = basePrice + managementFee + iva;

      // Mostrar método seleccionado
      debugPrint('💳 Método de pago seleccionado: $_selectedPaymentMethod');
      debugPrint('💰 Procesando pago: ${total.toStringAsFixed(2)}€ para plaza ${plaza.idPlaza}');

      // Crear pago con Stripe
      final amountInCents = (total * 100).toInt();
      
      // Mostrar diálogo de procesamiento
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.darkestBlue,
            title: const Text(
              'Procesando pago...',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
                const SizedBox(height: 16),
                Text(
                  'Conectando con Stripe...\nMétodo: $_selectedPaymentMethod',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      try {
        debugPrint('═══════════════════════════════════════════════════════════════════');
        debugPrint('✅ Método seleccionado: $_selectedPaymentMethod');
        debugPrint('💳 Método de pago seleccionado: $_selectedPaymentMethod');
        debugPrint('💰 Procesando pago: ${total.toStringAsFixed(2)}€ para plaza ${plaza.idPlaza}');
        debugPrint('═══════════════════════════════════════════════════════════════════');
        
        final response = await StripeService.createPaymentIntent(
          amountInCents: amountInCents,
          currency: 'eur',
          plazaId: plaza.idPlaza ?? 0,
          description: 'Alquiler Plaza: ${plaza.direccion}',
        );

        if (response['success']) {
          final clientSecret = response['clientSecret'] as String;
          debugPrint('🔐 ClientSecret obtenido: ${clientSecret.substring(0, 20)}...');

          late StripePaymentResult result;

          if (kIsWeb) {
            // En web: USAR el método seleccionado según tipo de pago
            debugPrint('🌐 PLATAFORMA WEB - Procesando con método: $_selectedPaymentMethod');
            
            switch (_selectedPaymentMethod) {
              case 'google_pay':
                debugPrint('▶ Llamando processGooglePayment()...');
                result = await StripeService.processGooglePayment(
                  clientSecret: clientSecret,
                  amount: total,
                  currency: 'eur',
                  label: 'Alquiler Plaza: ${plaza.direccion}',
                );
                break;
              case 'apple_pay':
                debugPrint('▶ Llamando processApplePayment()...');
                result = await StripeService.processApplePayment(
                  clientSecret: clientSecret,
                  amount: total,
                  currency: 'eur',
                  label: 'Alquiler Plaza: ${plaza.direccion}',
                );
                break;
              default: // 'card'
                debugPrint('▶ Llamando processCardPayment() para tarjeta...');
                // Para tarjeta: crear PaymentMethod desde datos del formulario
                String? paymentMethodId;
                if (cardData != null) {
                  debugPrint('💳 Creando PaymentMethod con datos de tarjeta...');
                  final pmResult = await StripeService.createPaymentMethodFromCard(
                    cardNumber: cardData['number']!,
                    expMonth: cardData['exp_month']!,
                    expYear: cardData['exp_year']!,
                    cvc: cardData['cvc']!,
                  );
                  if (pmResult['success'] == true) {
                    paymentMethodId = pmResult['paymentMethodId'] as String;
                    debugPrint('✅ PaymentMethod creado: $paymentMethodId');
                  } else {
                    if (mounted) Navigator.pop(context);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ Tarjeta inválida: ${pmResult['error']}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    setState(() => _isProcessingPayment = false);
                    return;
                  }
                }
                result = await StripeService.processCardPayment(
                  clientSecret: clientSecret,
                  amount: total,
                  currency: 'eur',
                  paymentMethodId: paymentMethodId,
                );
            }
          } else {
            // En móvil: usar SDKs nativos según método seleccionado
            debugPrint('💳 Método móvil: $_selectedPaymentMethod');
            switch (_selectedPaymentMethod) {
              case 'apple_pay':
                result = await StripeService.processApplePayment(
                  clientSecret: clientSecret,
                  amount: total,
                  currency: 'eur',
                  label: 'Alquiler Plaza: ${plaza.direccion}',
                );
                break;
              case 'google_pay':
                result = await StripeService.processGooglePayment(
                  clientSecret: clientSecret,
                  amount: total,
                  currency: 'eur',
                  label: 'Alquiler Plaza: ${plaza.direccion}',
                );
                break;
              default:
                result = await StripeService.processCardPayment(
                  clientSecret: clientSecret,
                  amount: total,
                  currency: 'eur',
                );
            }
          }

          debugPrint('💳 Resultado de pago: ${result.status}');

          if (result.status == 'canceled') {
            // Usuario canceló voluntariamente — sin error rojo
            if (mounted) Navigator.pop(context);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🚫 Pago cancelado'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            setState(() => _isProcessingPayment = false);
            return;
          }

          if (result.status == 'google_pay_not_available') {
            // Google Pay falló - mostrar error sin forzar tarjeta
            if (mounted) Navigator.pop(context);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    '⚠️ Google Pay: hubo un error al procesar el pago. Intenta de nuevo.',
                  ),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
            setState(() => _isProcessingPayment = false);
            return;
          }

          if (!result.isSuccessful) {
            if (mounted) Navigator.pop(context); // Cerrar diálogo
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Error de pago: ${result.errorMessage}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            setState(() => _isProcessingPayment = false);
            return;
          }
          
          debugPrint('✅ Pago exitoso: ${result.paymentIntentId}');
          debugPrint('📊 Estado: ${result.status}, Método: ${result.paymentMethod}');
          
          // Cerrar diálogo de procesamiento
          if (mounted) Navigator.pop(context);
          
          // Mostrar pantalla/diálogo de pago exitoso
          if (mounted) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.darkestBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                contentPadding: const EdgeInsets.all(24),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icono de éxito animado
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¡Pago Exitoso!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tu alquiler ha sido confirmado.\nPuedes ver los detalles en "Mis Alquileres".',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Botón para continuar
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx); // Cerrar diálogo
                        // Se creará el alquiler y se navegará a home después
                      },
                      child: const Text(
                        'Continuar',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // Crear el alquiler en Firestore como AlquilerPorHoras
          try {
            debugPrint('📝 Creando alquiler por horas en Firestore...');
            int durationMinutes = hours * 60; // Convertir horas a minutos
            double precioPlaza = plaza.precio;
            double pricePerMinute = precioPlaza > 0 ? (precioPlaza / 60.0) : 0.0;
            
            // Usar docId si está disponible, si no usar idPlaza
            int plazaIdentifier = plaza?.idPlaza ?? 0;
            if (plazaIdentifier == 0 && plaza?.docId != null) {
              // Si idPlaza es 0 e inválido pero tenemos docId, intentar parsear docId como int
              try {
                plazaIdentifier = int.parse(plaza!.docId!);
              } catch (e) {
                debugPrint('📌 No se pudo parsear docId como int: ${plaza?.docId}');
                plazaIdentifier = plaza?.idPlaza?.hashCode ?? 0;
              }
            }
            
            debugPrint('🔍 Duración: $durationMinutes min, Precio/min: $pricePerMinute, PlazaID: $plazaIdentifier');
            debugPrint('📍 Plaza: idPlaza=${plaza?.idPlaza}, docId=${plaza?.docId}');
            
            await RentalByHoursService.createRental(
              plazaId: plazaIdentifier,
              durationMinutes: durationMinutes,
              pricePerMinute: pricePerMinute,
            );
            debugPrint('✅ Alquiler por horas creado exitosamente');
          } catch (e) {
            debugPrint('❌ Error creando alquiler por horas: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
              );
            }
          }
          
          // Navegar a Home después de un pequeño delay
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/',
              (route) => false,
            );
          }
          return;
        } else {
          // Error al crear PaymentIntent
          if (mounted) Navigator.pop(context);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${response['error'] ?? 'Error desconocido'}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isProcessingPayment = false);
          return;
        }
      } catch (e) {
        debugPrint('⚠️ Error procesando pago: $e');
        if (mounted) Navigator.pop(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al procesar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isProcessingPayment = false);
        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }
}

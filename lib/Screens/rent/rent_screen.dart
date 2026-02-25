import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Models/normal.dart';
import 'package:aparcamientoszaragoza/Models/especial.dart';
import 'package:aparcamientoszaragoza/Services/PlazaImageService.dart';
import 'package:aparcamientoszaragoza/Services/StripeService.dart';
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

    // Calculations
    int hours = plaza.rentIsNormal ? 720 : (_selectedDates.length * 9); // Dummy 9h/day if special
    double basePrice = (hours * plaza.precio).toDouble();
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
      {
        'id': 'card',
        'icon': '💳',
        'name': 'Tarjeta',
        'description': 'Visa, Mastercard, Amex',
        'iconWidget': Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.deepOrange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.credit_card, color: Colors.deepOrange, size: 22),
        ),
      },
      {
        'id': 'apple_pay',
        'icon': '🍎',
        'name': 'Apple Pay',
        'description': 'Pago rápido y seguro',
        'iconWidget': Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black87.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.apple, color: Colors.black87, size: 24),
        ),
      },
      {
        'id': 'google_pay',
        'icon': '🔵',
        'name': 'Google Pay',
        'description': 'Pago rápido y seguro',
        'iconWidget': Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Text('G', style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
          ),
        ),
      },
      {
        'id': 'paypal',
        'icon': '📱',
        'name': 'PayPal',
        'description': 'Cuenta de PayPal',
        'iconWidget': Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF0070BA).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: Text('P', style: TextStyle(
              color: Color(0xFF0070BA),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
          ),
        ),
      },
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
                      // Icono oficial
                      method['iconWidget'] ?? Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          method['icon'] as String,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
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
                      // Radio button
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.white30,
                            width: isSelected ? 2 : 1.5,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
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
        final response = await StripeService.createPaymentIntent(
          amountInCents: amountInCents,
          currency: 'eur',
          plazaId: plaza.idPlaza ?? 0,
          description: 'Alquiler Plaza: ${plaza.direccion}',
        );

        if (response['success']) {
          final clientSecret = response['clientSecret'] as String;
          debugPrint('🔐 ClientSecret obtenido: ${clientSecret.substring(0, 20)}...');
          
          // Procesar pago con el método seleccionado
          debugPrint('💳 Método seleccionado: $_selectedPaymentMethod');
          
          late StripePaymentResult result;
          
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
            case 'paypal':
              // PayPal usa el mismo flujo que tarjeta por ahora
              result = await StripeService.processCardPayment(
                clientSecret: clientSecret,
                amount: total,
                currency: 'eur',
              );
              break;
            default: // 'card'
              result = await StripeService.processCardPayment(
                clientSecret: clientSecret,
                amount: total,
                currency: 'eur',
              );
          }

          debugPrint('💳 Resultado de pago: ${result.status}');

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
        } else {
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

      // Cerrar diálogo de procesamiento
      if (mounted) Navigator.pop(context);

      // Crear la reserva
      if (plaza.rentIsNormal) {
        ref.read(rentProvider.notifier).newRentProvider(
          AlquilerNormal(
            mesInicio: DateFormat('MMMM').format(DateTime.now()),
            mesFin: DateFormat('MMMM').format(DateTime.now().add(const Duration(days: 30))),
            anyoInicio: DateTime.now().year,
            anyoFinal: DateTime.now().year,
            idPlaza: plaza.idPlaza,
            idArrendatario: user?.uid.toString()
          )
        );
      } else {
        ref.read(rentProvider.notifier).newRentProvider(
          AlquilerEspecial(
            dias: _selectedDates,
            idPlaza: plaza.idPlaza.toString(),
            idArrendatario: user?.uid.toString()
          )
        );
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.rentSuccess),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
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

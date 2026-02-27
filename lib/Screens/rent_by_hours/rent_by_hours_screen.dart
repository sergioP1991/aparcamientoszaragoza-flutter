import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Services/PlazaImageService.dart';
import 'package:aparcamientoszaragoza/Services/RentalByHoursService.dart';
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
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          Image.network(
            PlazaImageService.getLargeUrl(plaza.idPlaza ?? 0),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              color: Colors.grey[800],
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plaza #${plaza.idPlaza}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        plaza.direccion,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
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

  Future<void> _confirmRental(
    BuildContext context,
    Garaje plaza,
    int durationMinutes,
    double total,
  ) async {
    try {
      setState(() => _isProcessing = true);

      // Crear el alquiler
      final rentalId = await RentalByHoursService.createRental(
        plazaId: plaza.idPlaza!,
        durationMinutes: durationMinutes,
        pricePerMinute: (pricePerHour / 60),
      );

      if (rentalId != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Alquiler creado exitosamente por \$$total'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar a pantalla de alquileres activos
        Navigator.of(context).pushNamed('/activeRentals');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
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

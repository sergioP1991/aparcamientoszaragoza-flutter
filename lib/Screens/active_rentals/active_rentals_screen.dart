import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aparcamientoszaragoza/Models/alquiler_por_horas.dart';
import 'package:aparcamientoszaragoza/Services/RentalByHoursService.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'dart:async';

class ActiveRentalsScreen extends ConsumerStatefulWidget {
  static const routeName = '/activeRentals';

  const ActiveRentalsScreen({super.key});

  @override
  ConsumerState<ActiveRentalsScreen> createState() => _ActiveRentalsScreenState();
}

class _ActiveRentalsScreenState extends ConsumerState<ActiveRentalsScreen> {
  late Timer _updateTimer;

  @override
  void initState() {
    super.initState();
    // Actualizar cada segundo para que el contador de tiempo sea fluido
    _updateTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        setState(() {}); // Rebuild para actualizar tiempos
      },
    );
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rentalsStream = RentalByHoursService.watchUserActiveRentals();

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
          'Alquileres Activos',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<AlquilerPorHoras>>(
        stream: rentalsStream,
        builder: (context, snapshot) {
          debugPrint('🔄 StreamBuilder estado: ${snapshot.connectionState}');
          debugPrint('📦 Datos: ${snapshot.data?.length ?? 0} alquileres');
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            debugPrint('⏳ Esperando datos...');
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint('❌ Error en stream: ${snapshot.error}');
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final rentals = snapshot.data ?? [];
          debugPrint('✅ Alquileres recibidos: ${rentals.length}');

          if (rentals.isEmpty) {
            debugPrint('📭 Sin alquileres activos');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_car, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes alquileres activos',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Busca una plaza y alquila por horas',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rentals.length,
            itemBuilder: (context, index) {
              final rental = rentals[index];
              // Generar un ID consistente basado en plazaId y arrendatario
              // En producción, el servicio debería retornar el doc ID
              final rentalId = '${rental.idPlaza}_${rental.idArrendatario}';
              return _buildRentalCard(context, rental, rentalId, l10n);
            },
          );
        },
      ),
    );
  }

  Widget _buildRentalCard(
    BuildContext context,
    AlquilerPorHoras rental,
    String rentalId,
    AppLocalizations l10n,
  ) {
    final isExpired = rental.estaVencido();
    final isInPenalty = rental.estaEnMargenMulta();
    final hasPenalty = rental.pasoMargenMulta();
    final timeRemaining = rental.tiempoRestante();
    final minutesUsed = rental.calcularTiempoUsado();
    final estimatedPrice = rental.calcularPrecioFinal();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.darkCardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Plaza ID y Estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plaza #${rental.idPlaza}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusBadge(rental.estado, isExpired, hasPenalty),
                  ],
                ),
                _buildStateIcon(rental.estado, isExpired, hasPenalty),
              ],
            ),
            const SizedBox(height: 16),

            // Tiempo restante o contador de uso
            if (!isExpired)
              _buildProgressSection(timeRemaining, rental.duracionContratada)
            else if (isInPenalty)
              _buildPenaltyWarning(l10n)
            else if (hasPenalty)
              _buildPenaltyAlert(l10n)
            else
              _buildExpiredMessage(minutesUsed, rental.duracionContratada),

            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            const SizedBox(height: 16),

            // Detalles de precio
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiempo usado',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$minutesUsed min',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Precio/min',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '€${rental.precioMinuto.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total estimado',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '€${estimatedPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Botones de acción
            _buildActionButtons(context, rental, l10n, rentalId),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    EstadoAlquilerPorHoras estado,
    bool isExpired,
    bool hasPenalty,
  ) {
    Color bgColor;
    Color textColor;
    String text;
    IconData icon;

    if (hasPenalty) {
      bgColor = Colors.red[900]!;
      textColor = Colors.red[200]!;
      text = 'Multa Pendiente';
      icon = Icons.warning;
    } else if (isExpired) {
      bgColor = Colors.orange[900]!;
      textColor = Colors.orange[200]!;
      text = 'Vencido';
      icon = Icons.timer_off;
    } else {
      bgColor = Colors.green[900]!;
      textColor = Colors.green[200]!;
      text = 'Activo';
      icon = Icons.timer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStateIcon(EstadoAlquilerPorHoras estado, bool isExpired, bool hasPenalty) {
    if (hasPenalty) {
      return const Icon(Icons.error, color: Colors.red, size: 32);
    } else if (isExpired) {
      return const Icon(Icons.info, color: Colors.orange, size: 32);
    } else {
      return const Icon(Icons.check_circle, color: Colors.green, size: 32);
    }
  }

  Widget _buildProgressSection(int timeRemaining, int totalDuration) {
    final progress = (totalDuration - timeRemaining) / totalDuration;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tiempo Restante',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              '${timeRemaining.toString().padLeft(2, '0')} min',
              style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation(
              progress > 0.75 ? Colors.green : (progress > 0.5 ? Colors.orange : Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPenaltyWarning(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[900]!.withOpacity(0.3),
        border: Border.all(color: Colors.orange[700]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Margen de 5 minutos',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Libera la plaza ahora para evitar multa',
                  style: TextStyle(color: Colors.orange[200], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPenaltyAlert(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[900]!.withOpacity(0.3),
        border: Border.all(color: Colors.red[700]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚠️ MULTA PENDIENTE',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Has pasado el margen. Se te aplicará una multa',
                  style: TextStyle(color: Colors.red[200], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredMessage(int minutesUsed, int durationContracted) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800]!.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Alquiler completado. Has usado $minutesUsed minutos de los $durationContracted contratados.',
        style: TextStyle(color: Colors.grey[300], fontSize: 12),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AlquilerPorHoras rental,
    AppLocalizations l10n,
    String rentalDocId,
  ) {
    final isExpired = rental.estaVencido();

    if (isExpired) {
      // Si ya está vencido, mostrar botón para ir a pagos o ver detalles
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ir a pagos...')),
                );
              },
              child: const Text('Proceder al Pago'),
            ),
          ),
        ],
      );
    } else {
      // Si aún está activo, mostrar botón para liberar antes
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _releaseRental(context, rental, rentalDocId),
              child: const Text(
                'Liberar Ahora',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
        ],
      );
    }
  }

  Future<void> _releaseRental(
    BuildContext context,
    AlquilerPorHoras rental,
    String rentalId,
  ) async {
    try {
      final confirmation = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkCardBackground,
          title: const Text(
            'Liberar Plaza',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            '¿Deseas liberar la plaza? Se te cobrará solo por el tiempo que has estado.',
            style: TextStyle(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Liberar', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      );

      if (confirmation == true) {
        // Mostrar loading
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Liberando plaza...')),
          );
        }

        // Liberar usando servicio local (sin Cloud Functions)
        await RentalByHoursService.releaseRental(rentalId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Plaza liberada. Total: €${rental.calcularPrecioFinal().toStringAsFixed(2)}',
              ),
              backgroundColor: Colors.green,
            ),
          );
          
          // El stream se actualiza automáticamente y la pantalla se recarga
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

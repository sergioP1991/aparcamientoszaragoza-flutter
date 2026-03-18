import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aparcamientoszaragoza/Models/alquiler_por_horas.dart';
import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Services/RentalByHoursService.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/HomeProviders.dart';
import 'package:aparcamientoszaragoza/Screens/payment/payment_screen.dart';
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
    final homeDataAsync = ref.watch(fetchHomeProvider(allGarages: true, onlyMine: false));

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
      body: homeDataAsync.when(
        data: (homeData) {
          // Crear un map de plazaId -> Garaje para acceso rápido
          final plazaMap = <int, Garaje>{};
          if (homeData != null && homeData.listGarajes.isNotEmpty) {
            for (var garajeItem in homeData.listGarajes) {
              if (garajeItem.idPlaza != null) {
                plazaMap[garajeItem.idPlaza!] = garajeItem;
              }
            }
          }

          return StreamBuilder<List<AlquilerPorHoras>>(
            stream: RentalByHoursService.watchUserActiveRentals(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              final rentals = snapshot.data ?? [];

              if (rentals.isEmpty) {
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
                  final plaza = plazaMap[rental.idPlaza];
                  final plazaAddress = plaza?.direccion ?? 'Plaza #${rental.idPlaza}';
                  return _buildRentalCard(context, rental, l10n, plazaAddress, plaza);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error al cargar plazas: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildRentalCard(
    BuildContext context,
    AlquilerPorHoras rental,
    AppLocalizations l10n,
    String plazaAddress,
    Garaje? plaza,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plazaAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(rental.estado, isExpired, hasPenalty),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
            _buildActionButtons(
              context,
              rental,
              l10n,
              rental,  // Pasar el objeto completo en lugar de solo documentId
              plaza: plaza,
            ),
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
    AlquilerPorHoras rentalForActions,
    AppLocalizations l10n,
    AlquilerPorHoras rental,  // Objeto completo
    {Garaje? plaza}
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
                if (plaza != null) {
                  // Calcular la duración en días (basada en el tiempo usado)
                  final tiempoUsadoMinutos = rental.calcularTiempoUsado().toDouble();
                  final rentalDays = (tiempoUsadoMinutos / 1440.0).ceil(); // 1440 minutos = 1 día
                  
                  // Obtener el precio total (incluye multa si aplica)
                  final totalAmount = rental.calcularPrecioFinal().toDouble();
                  
                  // Navegar a PaymentPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentPage(
                        plaza: plaza,
                        rentalDays: rentalDays,
                        totalAmount: totalAmount,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error: No se pudo obtener información de la plaza'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
              onPressed: () {
                debugPrint('🔵 [BUTTON] Botón liberar presionado. documentId=${rental.documentId}');
                _releaseRental(context, rental, rental.documentId ?? 'NULL');
              },
              child: const Text('Liberar Ahora', style: TextStyle(color: Colors.blue)),
            ),
          ),
        ],
      );
    }
  }

  Future<void> _releaseRental(
    BuildContext context,
    AlquilerPorHoras rental,
    String documentId,
  ) async {
    try {
      // Validar que el documentId no esté vacío
      debugPrint('🔵 [_RELEASE] Iniciando liberación');
      debugPrint('   documentId recibido: "$documentId"');
      debugPrint('   rental.documentId: "${rental.documentId}"');
      debugPrint('   rental.idPlaza: ${rental.idPlaza}');
      debugPrint('   rental.estado: ${rental.estado}');
      
      if (documentId.isEmpty || documentId == 'NULL') {
        debugPrint('❌ [_RELEASE] Error: documentId está vacío o es NULL');
        if (mounted) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: ID del alquiler no válido (vacío o null)'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      debugPrint('✅ [_RELEASE] documentId válido, documentId existe: ${documentId.isNotEmpty}');

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
        debugPrint('✅ [ACTIVE_RENTALS] Usuario confirmó liberación');

        if (mounted) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Liberando plaza...'),
              duration: Duration(seconds: 10),
            ),
          );
        }

        try {
          debugPrint('🔑 [ACTIVE_RENTALS] Llamando a RentalByHoursService.releaseRental($documentId)');
          
          // Llamar el servicio para liberar
          await RentalByHoursService.releaseRental(documentId);
          
          debugPrint('✅ [ACTIVE_RENTALS] Alquiler liberado en Firestore');

          // Esperar a que Firestore propague los cambios
          await Future.delayed(const Duration(milliseconds: 1200));

          if (mounted) {
            debugPrint('🔄 [ACTIVE_RENTALS] Refrescando providers');
            
            // Refrescar ambos providers para actualizar el estado en toda la app
            ref.refresh(fetchHomeProvider(allGarages: true, onlyMine: false));
            ref.refresh(fetchHomeProvider(allGarages: true, onlyMine: true));
            
            // Pequeño delay para que se procesen los refreshes
            await Future.delayed(const Duration(milliseconds: 300));
            
            if (!mounted) return;
            
            // Mostrar confirmación con el monto total
            final precioFinal = rental.calcularPrecioFinal();
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '✅ Plaza liberada. Total: €${precioFinal.toStringAsFixed(2)}',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
            
            debugPrint('📲 [ACTIVE_RENTALS] Esperando para navegar de vuelta');
            
            // Esperar a que el usuario vea la confirmación
            await Future.delayed(const Duration(milliseconds: 800));
            
            if (mounted) {
              debugPrint('🏠 [ACTIVE_RENTALS] Navegando de vuelta a Home');
              Navigator.pop(context);
            }
          }
        } catch (e) {
          debugPrint('❌ [ACTIVE_RENTALS] Error liberando: $e');
          
          if (mounted) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al liberar: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } else {
        debugPrint('⚠️ [ACTIVE_RENTALS] Usuario canceló la liberación');
      }
    } catch (e) {
      debugPrint('❌ [ACTIVE_RENTALS] Error inesperado: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

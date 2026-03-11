import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aparcamientoszaragoza/Models/favorite.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/HomeProviders.dart';
import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/Screens/detailsGarage/detailsGarage_screen.dart';
import 'package:aparcamientoszaragoza/Screens/registerGarage/registerGarage.dart';
import 'package:aparcamientoszaragoza/Screens/registerGarage/providers/RegisterGarageProviders.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:aparcamientoszaragoza/widgets/network_image_loader.dart';
import 'package:aparcamientoszaragoza/Services/PlazaImageService.dart';
import 'package:aparcamientoszaragoza/Screens/rent/rent_screen.dart';
import 'package:aparcamientoszaragoza/Screens/rent_by_hours/rent_by_hours_screen.dart';
import 'package:aparcamientoszaragoza/Services/RentalByHoursService.dart';
import 'package:aparcamientoszaragoza/Models/alquiler_por_horas.dart';

class GarageCard extends ConsumerStatefulWidget {
  final Garaje item;
  final User? user;
  final Function(int)? onTap;

  const GarageCard({
    super.key,
    required this.item,
    this.user,
    this.onTap,
  });

  @override
  ConsumerState<GarageCard> createState() => _GarageCardState();
}

class _GarageCardState extends ConsumerState<GarageCard> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final plazaId = widget.item.idPlaza ?? 0;
    
    return StreamBuilder<AlquilerPorHoras?>(
      stream: RentalByHoursService.watchPlazaRental(plazaId),
      builder: (context, snapshot) {
        final activeRental = snapshot.data;
        final hasActiveRental = activeRental != null && activeRental.estado.name == 'activo';
        final tiempoRestante = hasActiveRental ? activeRental.tiempoRestante() : 0;
        
        return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!(widget.item.idPlaza!);
        } else {
          Navigator.of(context).pushNamed(DetailsGarajePage.routeName, arguments: widget.item.idPlaza);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section - FIXED SIZE TO PREVENT OVERFLOW
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white.withOpacity(0.05),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: widget.item.imagenes.isNotEmpty
                        ? NetworkImageLoader(
                            imageUrl: widget.item.imagenes.first,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            fallbackAsset: PlazaImageService.getFallbackAsset(widget.item.idPlaza ?? 0),
                            showWarningOnError: true,
                          )
                        : Image.asset(
                            PlazaImageService.getFallbackAsset(widget.item.idPlaza ?? 0),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[800],
                                child: const Icon(Icons.image_not_supported, color: Colors.white30),
                              );
                            },
                          ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.item.propietario == widget.user?.uid 
                            ? AppColors.primaryColor 
                            : Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.item.propietario == widget.user?.uid 
                            ? l10n.ownerLabel 
                            : (widget.item.rentIsNormal ? l10n.privateLabel : l10n.normalLabel),
                        style: TextStyle(
                          color: widget.item.propietario == widget.user?.uid ? Colors.black : Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final isFavorite = widget.item.isFavorite(widget.user?.email);
                        return GestureDetector(
                          onTap: () {
                            if (widget.user != null) {
                              ref.read(homeProvider.notifier).stateFavorite(
                                    Favorite(widget.user?.email ?? "", widget.item.idPlaza.toString()),
                                    !isFavorite,
                                  );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.white,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Info Section - MUST BE EXPANDED
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.item.direccion,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildChip(
                        widget.item.vehicleType == VehicleType.moto ? Icons.motorcycle : Icons.directions_car, 
                        widget.item.vehicleType == VehicleType.moto ? l10n.motoLabel : l10n.carLabel
                      ),
                      if (widget.item.esCubierto)
                        _buildChip(Icons.roofing, l10n.coveredChip),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Status indicator with time if rental is active
                  if (hasActiveRental && tiempoRestante > 0)
                    // Banner azul para alquileres por horas
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.2),
                        border: Border.all(color: AppColors.primaryColor, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule, color: AppColors.primaryColor, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '⏱️ ${_formatRentalTime(tiempoRestante)}',
                              style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (widget.item.alquiler != null && widget.item.alquiler!.tipo == 0)
                    // Banner mejorado para alquileres mensuales
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.withOpacity(0.25),
                            Colors.orange.withOpacity(0.12),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.6),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.calendar_month,
                                  color: Colors.orange,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Alquiler Mensual Activo',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Ocupado',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 26),
                            child: Text(
                              'Alquiler de plazo fijo',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: widget.item.alquiler != null ? AppColors.accentRed : AppColors.accentGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.item.alquiler != null ? l10n.occupiedLabel : l10n.availableLabel,
                          style: TextStyle(
                            color: widget.item.alquiler != null ? AppColors.accentRed : AppColors.accentGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                             Text(
                              "${widget.item.precio.toStringAsFixed(2)} €",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.item.rentIsNormal ? '/mes' : l10n.perHourSuffix,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.item.propietario == widget.user?.uid)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterGarage(garageToEdit: widget.item),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit, color: AppColors.primaryColor, size: 20),
                            ),
                            const SizedBox(width: 8),
                            Consumer(
                              builder: (context, ref, child) => IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _confirmDelete(context, ref),
                                icon: const Icon(Icons.delete_outline, color: AppColors.accentRed, size: 20),
                              ),
                            ),
                          ],
                        )
                      else if (widget.item.alquiler == null)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              widget.item.rentIsNormal 
                                ? RentPage.routeName  // Monthly rental: calendar picker
                                : RentByHoursScreen.routeName,  // Hourly rental: duration picker
                              arguments: widget.item.idPlaza
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.reserveAction,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
        );
      },
    );
  }

  String _formatRentalTime(int minutes) {
    if (minutes <= 0) return '0m';
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBlue,
        title: Text(l10n.deleteSpotTitle, style: const TextStyle(color: Colors.white)),
        content: Text(l10n.deleteSpotConfirmation, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelAction, style: const TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (widget.item.docId != null) {
                await GarajeProvider().deleteGaraje(widget.item.docId!);
                ref.refresh(fetchHomeProvider(allGarages: true, onlyMine: false));
                ref.refresh(fetchHomeProvider(allGarages: true, onlyMine: true));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.spotDeletedSuccess)),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRed),
            child: Text(l10n.deleteAction, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2235), // Dark background matching image
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

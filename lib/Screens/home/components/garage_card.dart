import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aparcamientoszaragoza/Models/favorite.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/HomeProviders.dart';
import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/Screens/detailsGarage/detailsGarage_screen.dart';
import 'package:aparcamientoszaragoza/Screens/rent/rent_screen.dart';
import 'package:aparcamientoszaragoza/Screens/registerGarage/registerGarage.dart';
import 'package:aparcamientoszaragoza/Screens/registerGarage/providers/RegisterGarageProviders.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:aparcamientoszaragoza/widgets/network_image_loader.dart';

class GarageCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(item.idPlaza!);
        } else {
          Navigator.of(context).pushNamed(DetailsGarajePage.routeName, arguments: item.idPlaza);
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
                    child: NetworkImageLoader(
                      imageUrl: item.imagen ?? '',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      fallbackAsset: 'assets/garaje2.jpeg',
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.propietario == user?.uid 
                            ? AppColors.primaryColor 
                            : Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.propietario == user?.uid 
                            ? l10n.ownerLabel 
                            : (item.rentIsNormal ? l10n.privateLabel : l10n.normalLabel),
                        style: TextStyle(
                          color: item.propietario == user?.uid ? Colors.black : Colors.white,
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
                        final isFavorite = item.isFavorite(user?.email);
                        return GestureDetector(
                          onTap: () {
                            if (user != null) {
                              ref.read(homeProvider.notifier).stateFavorite(
                                    Favorite(user?.email ?? "", item.idPlaza.toString()),
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
                    item.direccion,
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
                        item.vehicleType == VehicleType.moto ? Icons.motorcycle : Icons.directions_car, 
                        item.vehicleType == VehicleType.moto ? l10n.motoLabel : l10n.carLabel
                      ),
                      if (item.esCubierto)
                        _buildChip(Icons.roofing, l10n.coveredChip),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: item.alquiler != null ? AppColors.accentRed : AppColors.accentGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.alquiler != null ? l10n.occupiedLabel : l10n.availableLabel,
                        style: TextStyle(
                          color: item.alquiler != null ? AppColors.accentRed : AppColors.accentGreen,
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
                              "${item.precio.toStringAsFixed(2)} €",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.perHourSuffix,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.propietario == user?.uid)
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
                                    builder: (context) => RegisterGarage(garageToEdit: item),
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
                      else if (item.alquiler == null)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(RentPage.routeName, arguments: item.idPlaza);
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
              if (item.docId != null) {
                await GarajeProvider().deleteGaraje(item.docId!);
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

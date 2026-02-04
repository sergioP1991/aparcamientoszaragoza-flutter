import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/ModelsUI/homeData.dart';
import 'package:aparcamientoszaragoza/Screens/home/components/garage_card.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/HomeProviders.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';

class FavoritesScreen extends ConsumerWidget {
  static const routeName = '/favorites';

  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataState = ref.watch(fetchHomeProvider(allGarages: true));

    return Scaffold(
      backgroundColor: AppColors.darkestBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.favoriteSpots,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: homeDataState.when(
        data: (data) {
          if (data == null) {
            return Center(
              child: Text(AppLocalizations.of(context)!.errorLoadingData, 
              style: const TextStyle(color: Colors.white)));
          }
          final HomeData d = data!;
          final favorites = d.listGarajes.where((g) => g.isFavorite(d.user?.email)).toList();

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noFavoriteGarages,
                    style: const TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              return GarageCard(
                item: favorites[index],
                user: d.user,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(AppLocalizations.of(context)!.genericError(err.toString()), style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}

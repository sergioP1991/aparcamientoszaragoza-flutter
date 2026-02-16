import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';

import 'package:aparcamientoszaragoza/Models/favorite.dart';
import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/Screens/detailsGarage/detailsGarage_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/HomeProviders.dart';

import 'package:aparcamientoszaragoza/ModelsUI/homeData.dart';
import 'garage_card.dart';

Widget bodyContainer (BuildContext context, WidgetRef ref, [HomeData? data, Function(int)? onGarageTap]) {
  if (data != null) {
    return _buildList(context, data, onGarageTap);
  }

  final homeDataState = ref.watch(fetchHomeProvider(allGarages: true));

  return homeDataState.when(
      loading: () => loadingBody(context),
      error: (err, stack) => Text(AppLocalizations.of(context)!.genericError(err.toString())),
      data: (data) => _buildList(context, data, onGarageTap)
  );
}

Widget _buildList(BuildContext context, HomeData? data, [Function(int)? onGarageTap]) {
  if (data == null) return Center(child: Text(AppLocalizations.of(context)!.noData));
  return ListView.builder(
    scrollDirection: Axis.vertical,
    padding: const EdgeInsets.only(bottom: 20),
    itemCount: data.listGarajes.length,
    itemBuilder: (BuildContext context, int index) {
      return GarageCard(
        item: data.listGarajes.elementAt(index),
        user: data.user,
        onTap: onGarageTap,
      );
    },
  );
}

Widget loadingBody (BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height / 1.3,
    child:  Center(
      child:
      CircularProgressIndicator(),
    ),
  );
}

Widget itemList (BuildContext context, WidgetRef ref, int index, Garaje item, User? user) {
  return
    GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(DetailsGarajePage.routeName, arguments: item.idPlaza);
      },
      child:
      Card(
        elevation: 8.0,
        color: AppColors.darkBlue,
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          decoration: const BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
          child: makeListTile(context, ref, item, user, item.isFavorite(user?.email ?? "")),
        ),
      ),
    );
}

Widget makeListTile(BuildContext context, WidgetRef ref, Garaje item, User? user, bool stateFavorite) {
  return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      leading: Container(
        padding: const EdgeInsets.only(right: 12.0),
        decoration: const BoxDecoration(
            border: Border(
                right: BorderSide(width: 1.0, color: Colors.white24))
        ),
        child: Icon(Icons.event_available_rounded, color: item.alquiler != null ? Colors.blueGrey : Colors.white),
      ),
      title: Text(
        item.direccion ?? "Garage",
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle:
      Column(
          children: [
            Row(
              children: <Widget>[
                const Icon(Icons.business, color: Colors.blueGrey),
                Text("${item.CodigoPostal ?? ""}" +"\t"+ "${item.Provincia ?? ""}", style: const TextStyle(color: Colors.white)),
              ],
            ),
            Row(
              children: <Widget>[
                const Icon(Icons.linear_scale, color: Colors.blueGrey),
                Text("  ${AppLocalizations.of(context)!.widthLabel} ${item.ancho}  -  ${AppLocalizations.of(context)!.lengthLabel}: ${item.largo}", style: const TextStyle(color: Colors.white))
              ],
            ),
            Row(
              children: <Widget>[
                if (item.alquiler != null) const Icon(Icons.check, color: Colors.green) else const Icon(Icons.check, color: Colors.red),
                if (item.alquiler != null) Text(AppLocalizations.of(context)!.rentedLabel, style: const TextStyle(color: Colors.green)) else Text(AppLocalizations.of(context)!.notRentedLabel, style: const TextStyle(color: Colors.red))
              ],
            ),
            Row(
              children: <Widget>[
                if (item.rentIsNormal) Text(AppLocalizations.of(context)!.normalRentLabel, style: const TextStyle(color: Colors.white12)) else Text(AppLocalizations.of(context)!.specialRentLabel, style: const TextStyle(color: Colors.white12))
              ],
            ),
            Row(
              children: <Widget>[
                IconButton(onPressed:() => {
                  ref.read(homeProvider.notifier).stateFavorite(Favorite(user?.email ?? "", (item?.idPlaza ?? 0).toString())  , ! stateFavorite)
                }, icon: item.isFavorite(user?.email) ? const Icon(Icons.heart_broken, color: Colors.red) : const Icon(Icons.heart_broken, color: Colors.white)
                )
              ],
            ),
                () {
              if (item.propietario == user?.uid) {
                return Row(
                    children: <Widget>[
                      const Icon(Icons.people, color: Colors.blueGrey),
                      Text(" ${AppLocalizations.of(context)!.ownerLabel}",
                          style: const TextStyle(color: Colors.white))
                    ]);
              } else {
                return Row();
              }
            }()
          ]
      ),
      trailing:
      const Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0));
}

import 'package:aparcamientoszaragoza/Models/alquiler.dart';
import 'package:aparcamientoszaragoza/Models/especial.dart';
import 'package:aparcamientoszaragoza/Models/favorite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:aparcamientoszaragoza/Models/history.dart';
import 'package:aparcamientoszaragoza/Services/activity_service.dart';
import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Models/normal.dart';
import 'package:aparcamientoszaragoza/ModelsUI/homeData.dart';
import 'package:aparcamientoszaragoza/Screens/login/providers/UserProviders.dart';

part 'HomeProviders.g.dart';

final homeProvider = StateNotifierProvider<
    HomeState, AsyncValue<HomeData>>((ref) {
  return HomeState(ref);
});

class HomeState extends StateNotifier<AsyncValue<HomeData>> {
  final Ref ref;

  HomeState(this.ref) : super(AsyncData(HomeData(listGarajes: List.empty(), listFavorite: List.empty())));

  Future<bool> fetchHome() async {
    return true;
  }

  Future<List<Garaje>> fetchGarajeNotOwnedByUser(String userId) async {

    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('garaje')
        .where('propietario', isNotEqualTo: userId)  // Filtra los que NO pertenecen al usuario
        .get();

    final QuerySnapshot<Map<String, dynamic>> snapshotFavorite = await FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: userId)  // Filtra los que NO pertenecen al usuario
        .get();

    List<Favorite> listFavorites = snapshotFavorite.docs.map<Favorite>((docFavorite) => Favorite.fromFirestore(docFavorite)).toList();

    List<Garaje> listResult = snapshot.docs.map<Garaje>((doc) => Garaje.fromFirestore(doc)).toList();
    return listResult;
  }

  @Riverpod(keepAlive: true)
  void stateFavorite(Favorite favorite, bool add) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('garaje')
          .where('idPlaza', isEqualTo: int.parse(favorite.idPlaza))
          .limit(1) // Por si hay varios con el mismo nombre
          .get();

      if (query.docs.isNotEmpty) {
        final garajeDoc = query.docs.first.reference;

        if (add) {
          await FirebaseFirestore.instance.collection('favorites').add(favorite.objectToMap());
          
          await ActivityService.recordEvent(History(
            fecha: DateTime.now(),
            tipo: TipoEvento.favorito_actualizado,
            descripcion: "Gareje añadido a favoritos",
            userId: query.docs.first.data()['propietario'], // Or better, the current user
            meta: "Plaza ID: ${favorite.idPlaza}",
          ));
        } else {
          // Buscar documentos donde coincidan userId e idPlaza
          final snapshot = await FirebaseFirestore.instance
              .collection('favorites')
              .where('userId', isEqualTo: favorite.userEmail)
              .where('idPlaza', isEqualTo: favorite.idPlaza)
              .get();

          for (var doc in snapshot.docs) {
            await FirebaseFirestore.instance.collection('favorites').doc(doc.id).delete();
          }

          await ActivityService.recordEvent(History(
            fecha: DateTime.now(),
            tipo: TipoEvento.favorito_actualizado,
            descripcion: "Garaje eliminado de favoritos",
            userId: favorite.userEmail,
            meta: "Plaza ID: ${favorite.idPlaza}",
          ));

          print('Favorito eliminado para ${favorite.userEmail} y plaza ${favorite.idPlaza}');

        }

        // update home
        ref.refresh(fetchHomeProvider(allGarages: true, onlyMine: false));

        print("cambiado el estado de favorito");
      } else {
        print("No se encontró el garaje");
      }
    } catch (e) {
      debugPrint("❌ No se pudo guardar como favorita: $e");
    }
  }

}

@Riverpod(keepAlive: true)
Future<HomeData?> fetchHome(Ref ref, {required bool allGarages, bool onlyMine = false}) async {
  AsyncValue<User?> user = ref.watch(loginUserProvider);

  List<Garaje> filtrada = List.empty(growable: true);
  final QuerySnapshot<Map<String, dynamic>> snapshotGarage = await FirebaseFirestore
      .instance.collection('garaje').get();

  String userId = user?.value?.email ?? "";

  // Buscar documentos donde coincidan userId e idPlaza
  final snapshotFavorite = await FirebaseFirestore.instance
      .collection('favorites')
      .where('userId', isEqualTo: userId)
      .get();

  List<Favorite> listFavorites = snapshotFavorite.docs.map<Favorite>((docFavorite) => Favorite.fromFirestore(docFavorite)).toList();
  List<Garaje> listResult = snapshotGarage.docs.map<Garaje>((doc) =>
      Garaje.fromFirestore(doc)).toList();

  listResult.forEach((c) => c.addFavorites(Favorite.filterFavorite(listFavorites, c.idPlaza.toString())));

  if (onlyMine) {
    filtrada = listResult.where((g) => g.propietario == user.value?.uid).toList();
  } else if (!allGarages) {
    for (int i = 0; i < listResult.length; i++) {
      if (listResult[i].propietario == user.value?.uid &&
          listResult[i].alquiler != null) {
        filtrada.add(listResult[i]);
      }
    }
  } else {
    // Default Home view: Include all garages
    filtrada = listResult;
  }

  final QuerySnapshot<Map<String, dynamic>> snapshotRent = await FirebaseFirestore.instance.collection('alquileres').get();
  List<Alquiler> listAlquileres = snapshotRent.docs.map<Alquiler>((doc) {
    if (doc['tipo'] == 0) {
      return AlquilerNormal.fromFirestore(doc);
    } else {
      return AlquilerEspecial.fromFirestore(doc);
    }
  }).toList();

  for (var alquiler in listAlquileres) {
    Garaje? garage = searchGarageId(filtrada, alquiler?.idPlaza ?? -1);
    if (garage != null) {
      garage.alquiler = alquiler;
    }
  }

  return HomeData(  listGarajes: filtrada,
                    listFavorite: listFavorites,
                    user: user.value);
}

Garaje? searchGarageId (List<Garaje> listGarage, int? idPlaza) {
  for (Garaje garage in listGarage){
    if (garage.idPlaza == idPlaza){
      return garage;
    }
  }
  return null;
}


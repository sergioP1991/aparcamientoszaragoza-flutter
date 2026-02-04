import 'package:aparcamientoszaragoza/Models/favorite.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/garaje.dart';

class HomeData {

  List<Garaje> listGarajes;
  List<Favorite> listFavorite;
  User? user;

  HomeData({
    required this.listGarajes,
    required this.listFavorite,
    this.user
  });

  String infoHomePlaza () {
    int rentParking = 0;
    int allParking = 0;

    for (Garaje garaje in listGarajes) {
      if(garaje.alquiler != null) {
        rentParking = rentParking + 1;
      }
    }
    allParking = listGarajes.length;

    String lastUpdate = DateTime.now().toString();

    return "${rentParking.toString()} de ${allParking.toString()} totales,\ny última vez modificado:\n${lastUpdate}";
  }

  Garaje? getGarageById(int idPlaza) {
    for (Garaje garaje in listGarajes)
      if (garaje.idPlaza == idPlaza) {
        return garaje;
      }
  }

}
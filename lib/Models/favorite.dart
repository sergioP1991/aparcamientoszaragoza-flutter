import 'package:cloud_firestore/cloud_firestore.dart';

class Favorite {

  String userEmail;
  String idPlaza;

  Favorite( this.userEmail, this.idPlaza);

  @override
  String toString() {
    return 'Comentario:{usuario: $userEmail, idPlaza: $idPlaza}';
  }

  @override
  Map <String, dynamic> objectToMap() {
    return {
      'userId': userEmail,
      'idPlaza': idPlaza,
    };
  }

  factory Favorite.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Favorite(
        snapshot!['userId'],
        snapshot!['idPlaza']
    );
  }

  static List<Favorite> filterFavorite(List<Favorite> listFavorite, String idPlaza) {
    List<Favorite> listFavoriteFilter = listFavorite.where((c) => c.idPlaza == idPlaza)
                                      .toList();

    return listFavoriteFilter;
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class Promocion{

  String codigo;
  String idUser;
  bool usada;
  String tipo;
  int valor;
  Timestamp valided;

  Promocion( this.codigo, this.idUser, this.usada, this.tipo, this.valor, this.valided);

  factory Promocion.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Promocion(
        snapshot.data()!['codigo'],
        snapshot.data()!['idUser'],
        snapshot.data()!['usada'],
        snapshot.data()!['tipoDescuento'],
        snapshot.data()!['cantidad'],
        snapshot.data()!['validate'],
    );
  }
}
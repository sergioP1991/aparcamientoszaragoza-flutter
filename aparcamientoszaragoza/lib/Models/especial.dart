import 'package:aparcamientoszaragoza/Models/alquiler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlquilerEspecial extends Alquiler {
  List<DateTime?> dias;

  AlquilerEspecial(
    { required this.dias,
      required idPlaza,
      required idArrendatario}
      ) : super (idPlaza, idArrendatario, 1);

  @override
  String toString() {
        return 'Alquiler las siguientes fechas: '+dias.toString();
  }

  // Especial
  // 8 - 10 de Agosto
  // 8 - 18:00h - 00:00h
  // 9 - 00:00h - 23:59h
  // 10 - 00:00h - 14:00h

  @override
  int tiempoTotal () {
    int tiempoTotal = 0;
    for (DateTime? dia in dias){
      tiempoTotal = tiempoTotal + (dia?.hour ?? 0);
    }
    return tiempoTotal;
  }

  @override
  Map <String, dynamic> objectToMap() {
    return {
      'dias' : dias,
      'idPlaza': idPlaza,
      'idArrendatario': idArrendatario,
      'tipo': tipo,
    };
  }

  @override
  factory AlquilerEspecial.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {

    dynamic jsArray = snapshot.data()!['dias'];
    List <DateTime> lista = List<Timestamp>.from(jsArray)
          .map((e) => e.toDate())
          .toList();

    return AlquilerEspecial(
      dias: lista,
      idArrendatario: snapshot.data()!['idArrendatario'],
      idPlaza: snapshot.data()!['idPlaza'],
    );
  }

}

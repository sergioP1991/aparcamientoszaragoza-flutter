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
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Documento de alquiler especial está vacío');
    }

    List<DateTime> lista = [];
    final jsArray = data['dias'];
    if (jsArray != null && jsArray is Iterable) {
      try {
        lista = List<Timestamp>.from(jsArray)
              .map((e) => e.toDate())
              .toList();
      } catch (e) {
        print('Error parsing dias: $e');
        lista = [];
      }
    }

    return AlquilerEspecial(
      dias: lista,
      idArrendatario: data['idArrendatario'] as String? ?? 'unknown',
      idPlaza: data['idPlaza'] as int? ?? 0,
    );
  }

}

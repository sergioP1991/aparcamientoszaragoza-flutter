import 'package:aparcamientoszaragoza/Models/alquiler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlquilerNormal extends Alquiler {

  String mesInicio;
  String mesFin;
  int anyoInicio;
  int anyoFinal;

  AlquilerNormal(
      {
        required this.mesInicio,
        required this.mesFin,
        required this.anyoInicio,
        required this.anyoFinal,
        required idPlaza,
        required idArrendatario}
      ) : super (idPlaza, idArrendatario, 0);

  @override
  String toString() {
    return 'Alquiler normal:{mes inicio: ' + mesInicio+', mes fin: ' + mesFin + '}';
  }

  @override
  void alquilar() {

  }

  int cantidad(int inicio, int fin){
    return fin - inicio;
  }

  int tiempoTotalMeses(int cantidadMeses, int cantidadAnyos){
    return cantidadMeses + cantidadAnyos*12;
  }

  int mesSelecionado(String mes){
    int mesIndicado = 0;
    if(mes =="Enero") mesIndicado = 01;
    if(mes =="Febreo") mesIndicado = 02;
    if(mes =="Marzo") mesIndicado = 03;
    if(mes =="Abril") mesIndicado = 04;
    if(mes =="Mayo") mesIndicado = 05;
    if(mes =="Junio") mesIndicado = 06;
    if(mes =="Julio") mesIndicado = 07;
    if(mes =="Agosto") mesIndicado = 08;
    if(mes =="Septiembre") mesIndicado = 09;
    if(mes =="Octubre") mesIndicado = 10;
    if(mes =="Noviembre") mesIndicado = 11;
    if(mes =="Diciembre") mesIndicado = 12;
    return mesIndicado;
  }

  @override
  Map <String, dynamic> objectToMap() {
    return {
      'mesInicio': mesInicio,
      'mesFin': mesFin,
      'AnyoInicio': anyoInicio,
      'AnyoFin': anyoFinal,
      'idPlaza': idPlaza,
      'idArrendatario': idArrendatario,
      'tipo': tipo
    };
  }

  @override
  int tiempoTotal(){
    return tiempoTotalMeses(cantidad(mesSelecionado(mesInicio), mesSelecionado(mesFin)), cantidad(anyoInicio, anyoFinal) * 12);
  }

  @override
  factory AlquilerNormal.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return AlquilerNormal(
      idPlaza: snapshot.data()!['idPlaza'],
      idArrendatario: snapshot.data()!['idArrendatario'],
      mesInicio: snapshot.data()!['mesInicio'],
      mesFin: snapshot.data()!['mesFin'],
      anyoInicio: snapshot.data()!['AnyoInicio'],
      anyoFinal: snapshot.data()!['AnyoFin'],
    );
  }

}

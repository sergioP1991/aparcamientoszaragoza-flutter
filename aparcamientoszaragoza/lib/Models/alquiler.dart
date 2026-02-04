abstract class Alquiler{

  int? idPlaza;
  String? idArrendatario;
  // 0 - Normal
  // 1 - Especial
  int tipo;

  Alquiler(this.idPlaza, this.idArrendatario, this.tipo);

  @override
  String toString() {
    return 'Alquiler:{palza: $idPlaza, arrendatario: $idArrendatario}';
  }

  int precioTotal(int precioMinuto){
    return precioMinuto * tiempoTotal();
  }

  int tiempoTotal();

  Map <String, dynamic> objectToMap() ;
  
}
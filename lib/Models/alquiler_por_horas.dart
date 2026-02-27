import 'package:aparcamientoszaragoza/Models/alquiler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoAlquilerPorHoras {
  activo,        // Alquiler en curso
  completado,    // Alquiler completado normalmente
  vencido,       // Pasó el tiempo de vencimiento
  multa_pendiente, // 5 minutos después de vencimiento
  liberado       // Liberado por el usuario
}

class AlquilerPorHoras extends Alquiler {
  // Información temporal
  DateTime fechaInicio;
  DateTime fechaVencimiento;
  DateTime? fechaLiberacion; // Cuando se libera (puede ser null si aún está activo)
  
  // Duración contratada (en minutos)
  int duracionContratada;
  
  // Tiempo real usado (en minutos)
  int? tiempoUsado;
  
  // Estado del alquiler
  EstadoAlquilerPorHoras estado;
  
  // Precio
  double precioMinuto;
  double? precioCalculado; // Precio final calculado al liberar
  
  // Margen de tiempo (5 minutos por defecto)
  final int margenMinutos = 5;
  
  // Notificaciones enviadas
  bool notificacionVencimientoEnviada = false;
  bool notificacionMultaEnviada = false;

  AlquilerPorHoras({
    required this.fechaInicio,
    required this.fechaVencimiento,
    required this.duracionContratada,
    required this.precioMinuto,
    required int idPlaza,
    required String idArrendatario,
    this.fechaLiberacion,
    this.tiempoUsado,
    this.precioCalculado,
    this.estado = EstadoAlquilerPorHoras.activo,
    this.notificacionVencimientoEnviada = false,
    this.notificacionMultaEnviada = false,
  }) : super(idPlaza, idArrendatario, 2); // tipo 2 para alquiler por horas

  @override
  String toString() {
    return 'AlquilerPorHoras:{plaza: $idPlaza, arrendatario: $idArrendatario, inicio: $fechaInicio, vencimiento: $fechaVencimiento}';
  }

  @override
  int tiempoTotal() {
    // Retorna el tiempo usado o la duración contratada
    return tiempoUsado ?? duracionContratada;
  }

  /// Calcula el tiempo usado (en minutos) hasta el momento actual o hasta la liberación
  int calcularTiempoUsado() {
    DateTime ahora = fechaLiberacion ?? DateTime.now();
    return ahora.difference(fechaInicio).inMinutes;
  }

  /// Calcula el precio final basado en el tiempo usado
  double calcularPrecioFinal() {
    int minutos = tiempoUsado ?? calcularTiempoUsado();
    return minutos * precioMinuto;
  }

  /// Verifica si el alquiler ha vencido
  bool estaVencido() {
    return DateTime.now().isAfter(fechaVencimiento);
  }

  /// Verifica si está en el margen de 5 minutos después del vencimiento
  bool estaEnMargenMulta() {
    if (!estaVencido()) return false;
    DateTime limiteMargen = fechaVencimiento.add(Duration(minutes: margenMinutos));
    return DateTime.now().isBefore(limiteMargen);
  }

  /// Verifica si pasó el margen de 5 minutos (debe haber multa)
  bool pasoMargenMulta() {
    return estaVencido() && 
           DateTime.now().isAfter(fechaVencimiento.add(Duration(minutes: margenMinutos)));
  }

  /// Tiempo restante en minutos (0 si ya vencido)
  int tiempoRestante() {
    Duration diferencia = fechaVencimiento.difference(DateTime.now());
    return diferencia.inMinutes > 0 ? diferencia.inMinutes : 0;
  }

  /// Libera la plaza y calcula el precio final
  void liberar({DateTime? fechaLiberacionCustom}) {
    fechaLiberacion = fechaLiberacionCustom ?? DateTime.now();
    tiempoUsado = calcularTiempoUsado();
    precioCalculado = calcularPrecioFinal();
    estado = EstadoAlquilerPorHoras.liberado;
  }

  /// Marca como vencido (lo hace el sistema automáticamente)
  void marcarVencido() {
    estado = EstadoAlquilerPorHoras.vencido;
    tiempoUsado = duracionContratada;
    precioCalculado = calcularPrecioFinal();
  }

  /// Marca como multa pendiente (después de 5 minutos del vencimiento)
  void marcarMultaPendiente() {
    estado = EstadoAlquilerPorHoras.multa_pendiente;
  }

  @override
  Map<String, dynamic> objectToMap() {
    return {
      'fechaInicio': Timestamp.fromDate(fechaInicio),
      'fechaVencimiento': Timestamp.fromDate(fechaVencimiento),
      'fechaLiberacion': fechaLiberacion != null ? Timestamp.fromDate(fechaLiberacion!) : null,
      'duracionContratada': duracionContratada,
      'tiempoUsado': tiempoUsado,
      'estado': estado.toString(),
      'precioMinuto': precioMinuto,
      'precioCalculado': precioCalculado,
      'idPlaza': idPlaza,
      'idArrendatario': idArrendatario,
      'tipo': tipo,
      'notificacionVencimientoEnviada': notificacionVencimientoEnviada,
      'notificacionMultaEnviada': notificacionMultaEnviada,
    };
  }

  @override
  factory AlquilerPorHoras.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    
    // Parsear el estado del string
    EstadoAlquilerPorHoras estado = EstadoAlquilerPorHoras.activo;
    try {
      String estadoStr = data['estado'] ?? 'EstadoAlquilerPorHoras.activo';
      if (estadoStr.contains('.')) {
        estado = EstadoAlquilerPorHoras.values.firstWhere(
          (e) => e.toString() == estadoStr,
          orElse: () => EstadoAlquilerPorHoras.activo,
        );
      }
    } catch (e) {
      print('Error parsing estado: $e');
    }

    return AlquilerPorHoras(
      idPlaza: data['idPlaza'],
      idArrendatario: data['idArrendatario'],
      fechaInicio: (data['fechaInicio'] as Timestamp).toDate(),
      fechaVencimiento: (data['fechaVencimiento'] as Timestamp).toDate(),
      fechaLiberacion: data['fechaLiberacion'] != null 
        ? (data['fechaLiberacion'] as Timestamp).toDate() 
        : null,
      duracionContratada: data['duracionContratada'] ?? 0,
      tiempoUsado: data['tiempoUsado'],
      precioMinuto: (data['precioMinuto'] ?? 0.0).toDouble(),
      precioCalculado: data['precioCalculado'] != null ? (data['precioCalculado'] as num).toDouble() : null,
      estado: estado,
      notificacionVencimientoEnviada: data['notificacionVencimientoEnviada'] ?? false,
      notificacionMultaEnviada: data['notificacionMultaEnviada'] ?? false,
    );
  }

  factory AlquilerPorHoras.fromMap(Map<String, dynamic> map) {
    // Parsear el estado del string
    EstadoAlquilerPorHoras estado = EstadoAlquilerPorHoras.activo;
    try {
      String estadoStr = map['estado'] ?? 'EstadoAlquilerPorHoras.activo';
      if (estadoStr.contains('.')) {
        estado = EstadoAlquilerPorHoras.values.firstWhere(
          (e) => e.toString() == estadoStr,
          orElse: () => EstadoAlquilerPorHoras.activo,
        );
      }
    } catch (e) {
      print('Error parsing estado: $e');
    }

    return AlquilerPorHoras(
      idPlaza: map['idPlaza'],
      idArrendatario: map['idArrendatario'],
      fechaInicio: map['fechaInicio'] is Timestamp 
        ? (map['fechaInicio'] as Timestamp).toDate()
        : DateTime.parse(map['fechaInicio']),
      fechaVencimiento: map['fechaVencimiento'] is Timestamp
        ? (map['fechaVencimiento'] as Timestamp).toDate()
        : DateTime.parse(map['fechaVencimiento']),
      fechaLiberacion: map['fechaLiberacion'] != null 
        ? (map['fechaLiberacion'] is Timestamp 
          ? (map['fechaLiberacion'] as Timestamp).toDate()
          : DateTime.parse(map['fechaLiberacion']))
        : null,
      duracionContratada: map['duracionContratada'] ?? 0,
      tiempoUsado: map['tiempoUsado'],
      precioMinuto: (map['precioMinuto'] ?? 0.0).toDouble(),
      precioCalculado: map['precioCalculado'] != null ? (map['precioCalculado'] as num).toDouble() : null,
      estado: estado,
      notificacionVencimientoEnviada: map['notificacionVencimientoEnviada'] ?? false,
      notificacionMultaEnviada: map['notificacionMultaEnviada'] ?? false,
    );
  }
}

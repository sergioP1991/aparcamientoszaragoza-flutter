import 'package:aparcamientoszaragoza/Models/alquiler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;

enum EstadoAlquilerPorHoras {
  activo,        // Alquiler en curso
  completado,    // Alquiler completado normalmente
  vencido,       // Pasó el tiempo de vencimiento
  multa_pendiente, // 5 minutos después de vencimiento
  liberado       // Liberado por el usuario
}

class AlquilerPorHoras extends Alquiler {
  // ID del documento en Firestore (para poder actualizar/eliminar)
  String? documentId;
  
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
    this.documentId,
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
    return (minutos.toDouble() * precioMinuto).toDouble();
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
    final map = {
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
      'documentId': documentId,
    };
    print('🗂️ AlquilerPorHoras.objectToMap() generando: idPlaza=$idPlaza, tipo=${tipo}, estado=${estado.toString()}, documentId=$documentId');
    return map;
  }

  @override
  factory AlquilerPorHoras.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Documento de alquiler está vacío');
    }
    
    // Parsear el estado del string - Soporta AMBOS formatos: "liberado" y "EstadoAlquilerPorHoras.liberado"
    EstadoAlquilerPorHoras estado = EstadoAlquilerPorHoras.activo;
    try {
      String estadoStr = data['estado'] ?? 'activo';
      estadoStr = estadoStr.trim().toLowerCase();
      
      // 🔍 INTENTO 1: Parsear como nombre simple (nuevo formato) - "liberado"
      for (var e in EstadoAlquilerPorHoras.values) {
        if (e.name.toLowerCase() == estadoStr) {
          estado = e;
          debugPrint('✅ [PARSE_ESTADO] Parseado como nombre: $estadoStr → $e');
          break;
        }
      }
      
      // 🔍 INTENTO 2: Si no encontró, intentar como .toString() (antiguo formato) - "EstadoAlquilerPorHoras.liberado"
      if (estado == EstadoAlquilerPorHoras.activo && estadoStr.contains('alquiler')) {
        for (var e in EstadoAlquilerPorHoras.values) {
          if (e.toString().toLowerCase() == estadoStr) {
            estado = e;
            debugPrint('✅ [PARSE_ESTADO] Parseado como .toString(): $estadoStr → $e');
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [PARSE_ESTADO] Error parsing estado: $e');
    }

    // Helper function to parse DateTime/Timestamp
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      } else if (value is DateTime) {
        return value;
      }
      return DateTime.now();
    }

    return AlquilerPorHoras(
      idPlaza: data['idPlaza'] as int? ?? 0,
      idArrendatario: data['idArrendatario'] as String? ?? 'unknown',
      documentId: snapshot.id, // 🔴 CRÍTICO: Usar snapshot.id como la fuente de verdad (siempre)
      fechaInicio: parseDateTime(data['fechaInicio']),
      fechaVencimiento: parseDateTime(data['fechaVencimiento']),
      fechaLiberacion: data['fechaLiberacion'] != null ? parseDateTime(data['fechaLiberacion']) : null,
      duracionContratada: (data['duracionContratada'] as int?) ?? 0,
      tiempoUsado: data['tiempoUsado'] as int?,
      precioMinuto: ((data['precioMinuto'] ?? 0.0) as num).toDouble(),
      precioCalculado: (data['precioCalculado'] as num?)?.toDouble(),
      estado: estado,
      notificacionVencimientoEnviada: (data['notificacionVencimientoEnviada'] as bool?) ?? false,
      notificacionMultaEnviada: (data['notificacionMultaEnviada'] as bool?) ?? false,
    );
  }

  factory AlquilerPorHoras.fromMap(Map<String, dynamic> map) {
    // Parsear el estado del string - Soporta AMBOS formatos: "liberado" y "EstadoAlquilerPorHoras.liberado"
    EstadoAlquilerPorHoras estado = EstadoAlquilerPorHoras.activo;
    try {
      String estadoStr = (map['estado'] ?? 'activo').toString().trim().toLowerCase();
      
      // 🔍 INTENTO 1: Parsear como nombre simple (nuevo formato) - "liberado"
      for (var e in EstadoAlquilerPorHoras.values) {
        if (e.name.toLowerCase() == estadoStr) {
          estado = e;
          debugPrint('✅ [PARSE_ESTADO_MAP] Parseado como nombre: $estadoStr → $e');
          break;
        }
      }
      
      // 🔍 INTENTO 2: Si no encontró, intentar como .toString() (antiguo formato) - "EstadoAlquilerPorHoras.liberado"
      if (estado == EstadoAlquilerPorHoras.activo && estadoStr.contains('alquiler')) {
        for (var e in EstadoAlquilerPorHoras.values) {
          if (e.toString().toLowerCase() == estadoStr) {
            estado = e;
            debugPrint('✅ [PARSE_ESTADO_MAP] Parseado como .toString(): $estadoStr → $e');
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [PARSE_ESTADO_MAP] Error parsing estado: $e');
    }

    return AlquilerPorHoras(
      idPlaza: map['idPlaza'],
      idArrendatario: map['idArrendatario'],
      documentId: map['documentId'] as String?,
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
      precioMinuto: ((map['precioMinuto'] ?? 0.0) as num).toDouble(),
      precioCalculado: map['precioCalculado'] != null ? (map['precioCalculado'] as num).toDouble() : null,
      estado: estado,
      notificacionVencimientoEnviada: map['notificacionVencimientoEnviada'] ?? false,
      notificacionMultaEnviada: map['notificacionMultaEnviada'] ?? false,
    );
  }
}

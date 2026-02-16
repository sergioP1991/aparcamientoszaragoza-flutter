import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoEstado {
  normal,
  especial,
}

enum TipoEvento {
  alquiler,
  registro_plaza,
  perfil_actualizado,
  reserva_cancelada,
  pago_recibido,
  registro_usuario,
  nuevo_comentario,
  favorito_actualizado,
  actualizacion_plaza,
  eliminacion_plaza,
}

class History {
  DateTime fecha;
  TipoEstado? estado;
  String? descripcion;
  bool done;
  String? userId;
  TipoEvento? tipo;
  String? meta; // Field for additional info like "Parking PZA001" or "Monto: 15€"

  History({
    required this.fecha,
    this.estado,
    this.descripcion,
    this.done = false,
    this.userId,
    this.tipo,
    this.meta,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'fecha': Timestamp.fromDate(fecha),
      'estado': estado?.name,
      'descripcion': descripcion,
      'done': done,
      'userId': userId,
      'tipo': tipo?.name,
      'meta': meta,
    };
  }

  factory History.fromFirestore(Map<String, dynamic> data) {
    DateTime fecha;
    if (data['fecha'] is Timestamp) {
      fecha = (data['fecha'] as Timestamp).toDate();
    } else if (data['fecha'] is String) {
      fecha = DateTime.tryParse(data['fecha']) ?? DateTime.now();
    } else {
      fecha = DateTime.now();
    }

    return History(
      fecha: fecha,
      estado: data['estado'] != null
          ? TipoEstado.values.firstWhere(
              (e) => e.name == data['estado'],
              orElse: () => TipoEstado.normal,
            )
          : null,
      descripcion: data['descripcion'],
      done: data['done'] ?? false,
      userId: data['userId'],
      tipo: data['tipo'] != null
          ? TipoEvento.values.firstWhere(
              (e) => e.name == data['tipo'],
              orElse: () => TipoEvento.alquiler, // Default or some other value
            )
          : null,
      meta: data['meta'],
    );
  }

  @override
  String toString() {
    return 'Historico(fecha: $fecha, estado: $estado?.name, descripcion: $descripcion)';
  }
}

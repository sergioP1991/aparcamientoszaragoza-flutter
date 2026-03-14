import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoMulta {
  pendiente,  // Multa creada, pendiente de pago
  pagada,     // Multa pagada
  condonada   // Multa perdonada
}

class Multa {
  final String? id; // ID del documento en Firestore
  final int idPlaza;
  final String idArrendatario;
  final String? idAlquilerPorHoras; // Referencia al alquiler que generó la multa
  
  final double monto; // Monto de la multa
  final String razon; // Razón: "exceso_tiempo", "margen_pasado", etc.
  
  final DateTime fechaCreacion;
  final DateTime? fechaPago; // null si no fue pagada
  
  final EstadoMulta estado;
  
  // Para auditoría
  final String? necearioPaymentIntentId; // ID del PaymentIntent si fue pagada

  Multa({
    this.id,
    required this.idPlaza,
    required this.idArrendatario,
    this.idAlquilerPorHoras,
    required this.monto,
    required this.razon,
    required this.fechaCreacion,
    this.fechaPago,
    this.estado = EstadoMulta.pendiente,
    this.necearioPaymentIntentId,
  });

  bool get estaPagada => estado == EstadoMulta.pagada;
  bool get estaPendiente => estado == EstadoMulta.pendiente;
  bool get estaCondonada => estado == EstadoMulta.condonada;

  // Convertir a map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'idPlaza': idPlaza,
      'idArrendatario': idArrendatario,
      'idAlquilerPorHoras': idAlquilerPorHoras,
      'monto': monto,
      'razon': razon,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaPago': fechaPago != null ? Timestamp.fromDate(fechaPago!) : null,
      'estado': estado.name,
      'paymentIntentId': necearioPaymentIntentId,
    };
  }

  // Crear desde documento de Firestore
  factory Multa.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return Multa(
      id: doc.id,
      idPlaza: data['idPlaza'] ?? 0,
      idArrendatario: data['idArrendatario'] ?? '',
      idAlquilerPorHoras: data['idAlquilerPorHoras'],
      monto: ((data['monto'] ?? 0.0) as num).toDouble(),
      razon: data['razon'] ?? 'desconocida',
      fechaCreacion: parseDateTime(data['fechaCreacion']),
      fechaPago: data['fechaPago'] != null ? parseDateTime(data['fechaPago']) : null,
      estado: EstadoMulta.values.firstWhere(
        (e) => e.name == data['estado'],
        orElse: () => EstadoMulta.pendiente,
      ),
      necearioPaymentIntentId: data['paymentIntentId'],
    );
  }

  // Crear desde map (para testing)
  factory Multa.fromMap(Map<String, dynamic> map) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return Multa(
      id: map['id'],
      idPlaza: map['idPlaza'] ?? 0,
      idArrendatario: map['idArrendatario'] ?? '',
      idAlquilerPorHoras: map['idAlquilerPorHoras'],
      monto: ((map['monto'] ?? 0.0) as num).toDouble(),
      razon: map['razon'] ?? 'desconocida',
      fechaCreacion: parseDateTime(map['fechaCreacion']),
      fechaPago: map['fechaPago'] != null ? parseDateTime(map['fechaPago']) : null,
      estado: map['estado'] is String 
        ? EstadoMulta.values.firstWhere(
            (e) => e.name == map['estado'],
            orElse: () => EstadoMulta.pendiente,
          )
        : EstadoMulta.pendiente,
      necearioPaymentIntentId: map['paymentIntentId'],
    );
  }

  @override
  String toString() => 'Multa(id: $id, monto: €$monto, razon: $razon, estado: ${estado.name})';
}

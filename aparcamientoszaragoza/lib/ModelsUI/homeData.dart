enum TipoEstado {
  normal,
  especial,
}

class History {
  DateTime fecha;
  TipoEstado? estado;
  String? descripcion;
  bool done;

  History({
    required this.fecha,
    this.estado,
    this.descripcion,
    this.done = false
  });

  @override
  String toString() {
    return 'Historico(fecha: $fecha, estado: $estado.name, descripcion: $descripcion)';
  }
}

class Comment{

  String? idPlaza;
  String? idUsuario;
  String? titulo;
  String? contenido;
  DateTime? fecha;
  double ranking;

  Comment( this.idPlaza,
          this.idUsuario,
          this.titulo,
          this.contenido,
          this.fecha,
          this.ranking);

  @override
  String toString() {
    return 'Comentario:{palza: $idPlaza, usuario: $idUsuario, titulo: $titulo, contenido: $contenido, '
        'fecha: $fecha, ranking: $ranking}';
  }
}
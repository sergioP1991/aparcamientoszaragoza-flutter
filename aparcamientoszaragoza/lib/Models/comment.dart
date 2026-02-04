
class Comment{

  String? idUsuario;
  String? titulo;
  String? contenido;
  DateTime? fecha;
  int ranking;

  Comment(this.idUsuario,
          this.titulo,
          this.contenido,
          this.fecha,
          this.ranking);

  @override
  String toString() {
    return 'Comentario:{usuario: $idUsuario, titulo: $titulo, contenido: $contenido, '
        'fecha: $fecha, ranking: $ranking}';
  }

  bool isOwner(String userID) {
    if(idUsuario == userID)
      return true;
    else
      return false;
  }

  @override
  Map <String, dynamic> objectToMap() {
    return {
      'idUsuario': idUsuario,
      'titulo': titulo,
      'contenido': contenido,
      'fecha': fecha,
      'ranking': ranking
    };
  }

  factory Comment.fromFirestore(Map<String, dynamic> snapshot) {
    return Comment(
        snapshot!['idUsuario'],
        snapshot!['titulo'],
        snapshot!['contenido'],
        snapshot!['fecha'].toDate(),
        snapshot!['ranking']
    );
  }
}
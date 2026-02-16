/// Categorías de FAQs disponibles
enum FAQCategory {
  general,
  account,    // Mi Cuenta
  bookings,   // Reservas
  payments,   // Pagos
  technical,  // Técnico
}

class FAQ {
  final String id;
  final String question;
  final String answer;
  final FAQCategory category;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    this.category = FAQCategory.general,
  });

  /// Genera un título automático basado en la respuesta
  static String _generateTitleFromAnswer(String answer) {
    if (answer.isEmpty) return 'Pregunta frecuente';
    
    // Tomar las primeras palabras de la respuesta y formar una pregunta
    final words = answer.split(' ');
    final previewWords = words.take(6).join(' ');
    
    // Limpiar y formatear
    String title = previewWords.trim();
    if (title.length > 50) {
      title = '${title.substring(0, 47)}...';
    } else if (words.length > 6) {
      title = '$title...';
    }
    
    return '¿$title?';
  }

  /// Convierte string a FAQCategory
  static FAQCategory _categoryFromString(String? categoryStr) {
    switch (categoryStr?.toLowerCase()) {
      case 'account':
        return FAQCategory.account;
      case 'bookings':
        return FAQCategory.bookings;
      case 'payments':
        return FAQCategory.payments;
      case 'technical':
        return FAQCategory.technical;
      default:
        return FAQCategory.general;
    }
  }

  /// Convierte FAQCategory a string
  static String categoryToString(FAQCategory category) {
    switch (category) {
      case FAQCategory.account:
        return 'account';
      case FAQCategory.bookings:
        return 'bookings';
      case FAQCategory.payments:
        return 'payments';
      case FAQCategory.technical:
        return 'technical';
      case FAQCategory.general:
        return 'general';
    }
  }

  factory FAQ.fromFirestore(Map<String, dynamic> data, String id) {
    final answer = data['answer'] ?? '';
    String question = data['question'] ?? '';
    
    // Si no hay pregunta, generar una basada en la respuesta
    if (question.isEmpty) {
      question = _generateTitleFromAnswer(answer);
    }
    
    return FAQ(
      id: id,
      question: question,
      answer: answer,
      category: _categoryFromString(data['category']),
    );
  }
}

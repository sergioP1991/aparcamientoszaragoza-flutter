import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Models/faq.dart';

final faqServiceProvider = Provider((ref) => FAQService());

class FAQService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// FAQs locales predeterminadas para la aplicación de aparcamientos
  static final List<FAQ> _defaultFAQs = [
    // === FAQs GENERALES ===
    FAQ(
      id: 'faq_general_1',
      question: '¿Cómo funciona la aplicación?',
      answer: 'La aplicación te permite buscar, reservar y pagar aparcamientos en Zaragoza. Simplemente busca un parking cercano, selecciona las fechas y horas, y confirma tu reserva. Recibirás un código QR para acceder.',
      category: FAQCategory.general,
    ),
    FAQ(
      id: 'faq_general_2',
      question: '¿En qué zonas de Zaragoza están disponibles los aparcamientos?',
      answer: 'Tenemos aparcamientos en el centro histórico, zonas comerciales, estaciones de tren y autobús, hospitales y principales áreas de la ciudad. Usa el mapa para ver todos los parkings disponibles cerca de ti.',
      category: FAQCategory.general,
    ),
    FAQ(
      id: 'faq_general_3',
      question: '¿La aplicación es gratuita?',
      answer: 'Sí, descargar y usar la aplicación es completamente gratuito. Solo pagas por el tiempo de estacionamiento que reserves.',
      category: FAQCategory.general,
    ),
    FAQ(
      id: 'faq_general_4',
      question: '¿Puedo usar la app sin conexión a internet?',
      answer: 'Necesitas conexión para buscar y reservar plazas. Sin embargo, tu código QR se guarda localmente y funciona sin conexión una vez generado.',
      category: FAQCategory.general,
    ),
    FAQ(
      id: 'faq_general_5',
      question: '¿Cómo contacto con soporte?',
      answer: 'Puedes contactarnos a través del chat de la app (24/7), por email a soporte@aparcamientoszaragoza.es o llamando al 976 123 456 de 8:00 a 22:00.',
      category: FAQCategory.general,
    ),

    // === FAQs MI CUENTA ===
    FAQ(
      id: 'faq_account_1',
      question: '¿Cómo puedo crear una cuenta?',
      answer: 'Puedes registrarte con tu email y contraseña, o iniciar sesión directamente con tu cuenta de Google. El proceso es rápido y solo necesitas verificar tu email.',
      category: FAQCategory.account,
    ),
    FAQ(
      id: 'faq_account_2',
      question: '¿Cómo cambio mi contraseña?',
      answer: 'Ve a Configuración > Mi Cuenta > Cambiar contraseña. Introduce tu contraseña actual y la nueva contraseña dos veces para confirmar.',
      category: FAQCategory.account,
    ),
    FAQ(
      id: 'faq_account_3',
      question: '¿Cómo actualizo mi foto de perfil?',
      answer: 'Toca tu avatar en la pantalla de perfil y selecciona "Cambiar foto". Puedes tomar una nueva foto o elegir una de tu galería.',
      category: FAQCategory.account,
    ),
    FAQ(
      id: 'faq_account_4',
      question: '¿Puedo vincular mi cuenta con Google?',
      answer: 'Sí, ve a Configuración > Mi Cuenta > Cuentas vinculadas y pulsa "Vincular con Google". Esto te permitirá iniciar sesión más rápido.',
      category: FAQCategory.account,
    ),
    FAQ(
      id: 'faq_account_5',
      question: '¿He olvidado mi contraseña, qué hago?',
      answer: 'En la pantalla de login, pulsa "¿Olvidaste tu contraseña?". Introduce tu email y te enviaremos un enlace para restablecerla.',
      category: FAQCategory.account,
    ),
    FAQ(
      id: 'faq_account_6',
      question: '¿Cómo elimino mi cuenta permanentemente?',
      answer: 'Ve a Configuración > Privacidad > Eliminar cuenta. Tus datos se borrarán en 30 días según la normativa GDPR. Esta acción es irreversible.',
      category: FAQCategory.account,
    ),
    FAQ(
      id: 'faq_account_7',
      question: '¿Cómo cambio mi número de teléfono?',
      answer: 'Accede a tu perfil y pulsa "Editar". Modifica tu número de teléfono y confirma con el código SMS que recibirás.',
      category: FAQCategory.account,
    ),

    // === FAQs RESERVAS ===
    FAQ(
      id: 'faq_bookings_1',
      question: '¿Cómo reservo una plaza de aparcamiento?',
      answer: 'Selecciona un aparcamiento en el mapa, elige fecha y hora de entrada/salida, y confirma la reserva. Recibirás un código QR para acceder.',
      category: FAQCategory.bookings,
    ),
    FAQ(
      id: 'faq_bookings_2',
      question: '¿Puedo cancelar mi reserva?',
      answer: 'Sí, cancela hasta 2 horas antes sin coste. Las cancelaciones posteriores pueden tener un cargo del 50%.',
      category: FAQCategory.bookings,
    ),
    FAQ(
      id: 'faq_bookings_3',
      question: '¿Qué pasa si llego tarde?',
      answer: 'Tu plaza se reserva 30 minutos extra. Después, podría cancelarse automáticamente. Contáctanos si prevés retraso.',
      category: FAQCategory.bookings,
    ),
    FAQ(
      id: 'faq_bookings_4',
      question: '¿Puedo modificar mi reserva?',
      answer: 'Sí, ve a "Mis Reservas", selecciona la reserva y pulsa "Modificar". Puedes cambiar fecha, hora o duración si hay disponibilidad.',
      category: FAQCategory.bookings,
    ),
    FAQ(
      id: 'faq_bookings_5',
      question: '¿Cómo amplío el tiempo de estancia?',
      answer: 'En "Mis Reservas", selecciona la reserva activa y pulsa "Ampliar tiempo". El coste adicional se calcula automáticamente.',
      category: FAQCategory.bookings,
    ),
    FAQ(
      id: 'faq_bookings_6',
      question: '¿Puedo reservar para otra persona?',
      answer: 'Sí, al confirmar la reserva puedes enviar el código QR por WhatsApp, email o mensaje a quien vaya a usar la plaza.',
      category: FAQCategory.bookings,
    ),
    FAQ(
      id: 'faq_bookings_7',
      question: '¿Hay plazas para vehículos grandes?',
      answer: 'Algunos parkings tienen plazas XL para furgonetas y SUV grandes. Filtra por "Plazas grandes" en la búsqueda.',
      category: FAQCategory.bookings,
    ),

    // === FAQs PAGOS ===
    FAQ(
      id: 'faq_payments_1',
      question: '¿Qué métodos de pago aceptan?',
      answer: 'Aceptamos Visa, Mastercard, American Express, PayPal y el wallet de la app. También Bizum en parkings seleccionados.',
      category: FAQCategory.payments,
    ),
    FAQ(
      id: 'faq_payments_2',
      question: '¿Cómo añado una tarjeta?',
      answer: 'Ve a Configuración > Métodos de pago > Añadir tarjeta. Tus datos están protegidos con encriptación SSL.',
      category: FAQCategory.payments,
    ),
    FAQ(
      id: 'faq_payments_3',
      question: '¿Puedo obtener factura?',
      answer: 'Sí, todas las facturas se generan automáticamente. Descárgalas desde el historial de reservas o configura envío automático por email.',
      category: FAQCategory.payments,
    ),
    FAQ(
      id: 'faq_payments_4',
      question: '¿Qué son los bonos de descuento?',
      answer: 'Los bonos te dan descuentos en futuras reservas. Los obtienes por recomendaciones, promociones o fidelidad. Aplícalos al pagar.',
      category: FAQCategory.payments,
    ),
    FAQ(
      id: 'faq_payments_5',
      question: '¿Cómo funcionan los abonos mensuales?',
      answer: 'Los abonos te dan acceso ilimitado a un parking por un precio fijo mensual. Ahorra hasta un 40% respecto al pago por horas.',
      category: FAQCategory.payments,
    ),
    FAQ(
      id: 'faq_payments_6',
      question: '¿Cómo solicito un reembolso?',
      answer: 'En el historial de reservas, selecciona la reserva y pulsa "Solicitar reembolso". Se procesa en 5-7 días hábiles.',
      category: FAQCategory.payments,
    ),
    FAQ(
      id: 'faq_payments_7',
      question: '¿Es seguro pagar en la app?',
      answer: 'Totalmente. Usamos encriptación bancaria, no almacenamos datos de tarjetas y cumplimos con la normativa PCI DSS.',
      category: FAQCategory.payments,
    ),

    // === FAQs TÉCNICO ===
    FAQ(
      id: 'faq_technical_1',
      question: '¿No puedo iniciar sesión, qué hago?',
      answer: 'Verifica tu conexión a internet, cierra la app completamente y vuelve a abrirla. Si persiste, limpia la caché o reinstala.',
      category: FAQCategory.technical,
    ),
    FAQ(
      id: 'faq_technical_2',
      question: '¿El código QR no abre la barrera?',
      answer: 'Sube el brillo de pantalla al máximo, centra el código en el lector. Si falla, pulsa el botón de ayuda en la barrera.',
      category: FAQCategory.technical,
    ),
    FAQ(
      id: 'faq_technical_3',
      question: '¿Por qué no recibo notificaciones?',
      answer: 'Activa las notificaciones en Configuración > Notificaciones y verifica los permisos de la app en ajustes de tu móvil.',
      category: FAQCategory.technical,
    ),
    FAQ(
      id: 'faq_technical_4',
      question: '¿El GPS no me localiza bien?',
      answer: 'Activa el GPS y da permisos de ubicación a la app. En interiores la señal es débil, busca el parking manualmente.',
      category: FAQCategory.technical,
    ),
    FAQ(
      id: 'faq_technical_5',
      question: '¿Cómo libero espacio de la app?',
      answer: 'Ve a Configuración > Almacenamiento > Limpiar caché. Esto elimina datos temporales sin afectar tu cuenta.',
      category: FAQCategory.technical,
    ),
    FAQ(
      id: 'faq_technical_6',
      question: '¿La app consume mucha batería?',
      answer: 'El uso de GPS puede consumir batería. Desactiva la ubicación en segundo plano en ajustes si no la necesitas.',
      category: FAQCategory.technical,
    ),
    FAQ(
      id: 'faq_technical_7',
      question: '¿Cómo reporto un error en la app?',
      answer: 'Ve a Configuración > Ayuda > Reportar problema. Describe el error y adjunta capturas de pantalla si es posible.',
      category: FAQCategory.technical,
    ),
  ];

  Stream<List<FAQ>> getFAQs() {
    // Usar solo las FAQs locales predeterminadas para evitar duplicados
    // Las FAQs están organizadas por categoría y son únicas
    return Stream.value(_defaultFAQs);
  }

  /// Obtener FAQs locales sin conexión a Firebase
  List<FAQ> getDefaultFAQs() {
    return _defaultFAQs;
  }

  /// Sube las FAQs predeterminadas a Firebase Firestore
  /// Retorna el número de FAQs subidas exitosamente
  Future<int> uploadDefaultFAQsToFirebase() async {
    int uploaded = 0;
    final batch = _firestore.batch();
    
    for (final faq in _defaultFAQs) {
      final docRef = _firestore.collection('faqs').doc(faq.id);
      batch.set(docRef, {
        'question': faq.question,
        'answer': faq.answer,
        'category': FAQ.categoryToString(faq.category),
        'order': _defaultFAQs.indexOf(faq),
        'createdAt': FieldValue.serverTimestamp(),
      });
      uploaded++;
    }
    
    await batch.commit();
    return uploaded;
  }

  /// Verifica si existen FAQs en Firebase y las sube si no hay ninguna
  Future<bool> initializeFAQsIfEmpty() async {
    final snapshot = await _firestore.collection('faqs').limit(1).get();
    if (snapshot.docs.isEmpty) {
      await uploadDefaultFAQsToFirebase();
      return true; // Se subieron las FAQs
    }
    return false; // Ya existían FAQs
  }
}

final faqsProvider = StreamProvider<List<FAQ>>((ref) {
  return ref.watch(faqServiceProvider).getFAQs();
});

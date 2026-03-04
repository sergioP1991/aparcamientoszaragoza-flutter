/// Servicio experto que proporciona descripciones realistas de plazas de aparcamiento en Zaragoza
/// basadas en información de estacionamiento regulado (ORA), ZBE y características locales
///
/// Información de Zaragoza:
/// - Zona Azul (ESRO): Alta rotación, máximo 120 min, tarifa 0,25€ (25 min), 0,70€ (1h), 1,45€ (2h)
/// - Zona Naranja (ESRE): Residentes, máximo 60 min para visitantes, tarifa 0,25€ (25 min), 1,15€ (1h)
/// - Zona de Bajas Emisiones (ZBE): Centro histórico, restricción 8:00-20:00 L-V para vehículos no etiquetados
/// - Park & Ride: Valdespartera y La Chimenea, 0,06€/hora con tranvía
/// - Zonas Blancas: Gratuitas - Macanaz, Expo Sur, Actur, Almozara, Delicias, San José

class PlazaDescriptionService {
  /// Genera una descripción realista basada en la dirección de la plaza
  static String generateDescription(String direccion) {
    final direccionLower = direccion.toLowerCase().trim();
    
    // Centro Histórico - Zona Azul (ZBE Fase 1)
    if (_isInCentro(direccionLower)) {
      return 'Plaza en el centro histórico de Zaragoza. Incluida en la Zona de Bajas Emisiones (restricción 8:00-20:00 L-V). Zona Azul (ESRO) con tarifa de 0,70€/hora y máximo 120 minutos. Acceso hasta Plaza España, Coso, Conde Aranda y Echegaray. Ideal para compras y visitas turísticas.';
    }
    
    // Conde Aranda - Zona Azul ampliada
    if (_isInCondeAranda(direccionLower)) {
      return 'Plaza en la avenida Conde Aranda, cercana al Casco Histórico. Zona Azul extendida (ESRO) con tarifa de 0,70€/hora y máximo 120 minutos. Buen conectada con el centro por bus y a pie (10 min). Zona de Bajas Emisiones próxima (ZBE Fase 1). Excelente para negocios y compras.';
    }
    
    // Campus Río Ebro - Zona Blanca (Gratuita)
    if (_isInCampus(direccionLower)) {
      return 'Plaza en la Zona Blanca de Actur/Campus Río Ebro. Estacionamiento completamente GRATUITO sin límite de tiempo. Vigilancia 24/7 en la zona. Parada de tranvía cercana (Línea 1) a 5 minutos a pie. Excelente opción para estancias largas y visitas a la Universidad.';
    }
    
    // Almozara - Zona Blanca
    if (_isInAlmozara(direccionLower)) {
      return 'Plaza en el barrio de Almozara. Zona Blanca GRATUITA sin limitaciones de tiempo. Zona de aparcamiento segura y bien mantenida. Acceso rápido al centro mediante bus línea 30, 31, 35. Ideal para residentes y estancias prolongadas. Tarifa: 0€.';
    }
    
    // Delicias - Zona Blanca
    if (_isInDelicias(direccionLower)) {
      return 'Plaza en Delicias, cerca de la Estación Intermodal. Zona Blanca GRATUITA con vigilancia. Conexión directa con tren (Renfe), autobús y tranvía (Línea 1). Ideal para viajeros que necesitan estacionar mientras utilizan transporte público. Tarifa: 0€.';
    }
    
    // Park & Ride Valdespartera
    if (_isInValdespartera(direccionLower)) {
      return 'Plaza en Valdespartera Park & Ride (Acceso Sur). Estacionamiento disuasorio con tarifa bonificada: 0,06€/hora si usas el tranvía. Parada directa de Línea 1 (Tranvía). Excelente para evitar tráfico del centro. Tarifa normal: 0,60€/hora. Recomendado para el sector sur y sur-oeste.';
    }
    
    // Park & Ride La Chimenea
    if (_isInChimenea(direccionLower)) {
      return 'Plaza en La Chimenea Park & Ride (Acceso Norte). Estacionamiento disuasorio con tarifa bonificada: 0,06€/hora con tranvía. Parada Línea 1 directa. Gran capacidad. Ideal para usuarios del norte y noreste que prefieren evitar el centro. Tarifa normal: 0,60€/hora.';
    }
    
    // Expo/Sur - Zona Blanca
    if (_isInExpo(direccionLower)) {
      return 'Plaza en Zona Expo Sur. Zona Blanca GRATUITA con capacidad de 5.600 plazas. Conexión directa con autobús y tranvía (Línea 1). Perfecta para estancias largas sin coste. Vigilancia y bien iluminada. Ideal para fiestas, eventos y turismo.';
    }
    
    // San José - Zona Blanca
    if (_isInSanJose(direccionLower)) {
      return 'Plaza en el barrio de San José. Zona Blanca GRATUITA sin limitaciones. Acceso fácil al centro mediante bus (líneas 22, 23, 24). Barrio residencial tranquilo y seguro. Excelente relación precio-ubicación. Tarifa: 0€.';
    }
    
    // Macanaz - Zona Blanca
    if (_isInMacanaz(direccionLower)) {
      return 'Plaza en Macanaz. Zona Blanca GRATUITA, la más cercana a la Basílica del Pilar (10 min a pie). Unas 200 plazas disponibles. Ideal para visitantes del centro histórico queriendo evitar tarifas de parking. Conectada por bus y a pie. Tarifa: 0€.';
    }
    
    // Descripción genérica por defecto (mejorada)
    return _generateGenericDescription(direccion);
  }

  /// Descripción genérica realista mejorada
  static String _generateGenericDescription(String direccion) {
    return 'Plaza de aparcamiento en $direccion, Zaragoza. Ubicada en un área bien conectada con transporte público. Cercana a comercios, servicios y zonas de interés. Cumple con las normativas de estacionamiento regulado (ORA) según la zona. Consulta las tarifas horarias: L-V 9:00-20:00 (zona azul/naranja), gratuito S-D. Acceso también mediante tranvía (L1) y autobús.';
  }

  // Funciones auxiliares para detectar zona
  static bool _isInCentro(String dir) {
    return (dir.contains('pilar') || dir.contains('coso') || dir.contains('españa') ||
        dir.contains('puente') || dir.contains('alfonso') || dir.contains('plaza') ||
        dir.contains('mayor') || dir.contains('catedral') || dir.contains('seo')) &&
        !dir.contains('macanaz');
  }

  static bool _isInCondeAranda(String dir) {
    return dir.contains('conde aranda') || dir.contains('conde') || 
        (dir.contains('mayor') && !dir.contains('plaza mayor'));
  }

  static bool _isInCampus(String dir) {
    return dir.contains('campus') || dir.contains('actur') || 
        dir.contains('rio ebro') || dir.contains('universidad');
  }

  static bool _isInAlmozara(String dir) {
    return dir.contains('almozara') || dir.contains('gutierrez');
  }

  static bool _isInDelicias(String dir) {
    return dir.contains('delicias') || dir.contains('estacion') ||
        dir.contains('intermodal');
  }

  static bool _isInValdespartera(String dir) {
    return dir.contains('valdespartera') || dir.contains('p&r') ||
        dir.contains('park & ride');
  }

  static bool _isInChimenea(String dir) {
    return dir.contains('chimenea') || dir.contains('la chimenea');
  }

  static bool _isInExpo(String dir) {
    return dir.contains('expo') || dir.contains('sur') && dir.contains('expo');
  }

  static bool _isInSanJose(String dir) {
    return dir.contains('san jose') || dir.contains('san josé');
  }

  static bool _isInMacanaz(String dir) {
    return dir.contains('macanaz');
  }

  /// Obtiene información de tarifas según la zona detectada
  static String getTarifInfo(String direccion) {
    if (_isInCentro(direccion)) {
      return 'Zona Azul: 0,70€/h. Máx 120min (L-V 9:00-20:00)';
    } else if (_isInCondeAranda(direccion)) {
      return 'Zona Azul: 0,70€/h. Máx 120min (L-V 9:00-20:00)';
    } else if (_isInValdespartera(direccion) || _isInChimenea(direccion)) {
      return 'P&R: 0,06€/h con tranvía, 0,60€/h sin';
    } else if (_isInCampus(direccion) || _isInAlmozara(direccion) ||
        _isInDelicias(direccion) || _isInExpo(direccion) || _isInSanJose(direccion) ||
        _isInMacanaz(direccion)) {
      return 'Zona Blanca: 0€ (GRATUITO)';
    }
    return 'Tarifa según zona regulada (ORA)';
  }

  /// Obtiene recomendación de uso según zona
  static String getRecommendation(String direccion) {
    if (_isInCentro(direccion)) {
      return 'Ideal para visitas cortas al centro. Caduca tarifa a los 120min. Verifica ZBE si eres vehículo no etiquetado.';
    } else if (_isInCondeAranda(direccion)) {
      return 'Buena zona para compras y negocios. Acceso a pie al centro en 10 minutos.';
    } else if (_isInCampus(direccion)) {
      return 'Perfecto para estancias largas sin coste. Ideal para estudiantes y trabajadores.';
    } else if (_isInValdespartera(direccion) || _isInChimenea(direccion)) {
      return 'Estacionamiento disuasorio. Usa el tranvía para ahorrar. Bonificación: 0,06€/h.';
    } else if (_isInExpo(direccion)) {
      return 'Excelente para eventos y ferias. 5.600 plazas gratuitas. Conexión directa con tranvía.';
    }
    return 'Consulta tarifas y horarios en Zaragoza ApParca.';
  }
}

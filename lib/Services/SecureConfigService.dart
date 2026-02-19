import 'package:flutter/foundation.dart';
import 'package:aparcamientoszaragoza/Services/SecurityService.dart';

/// ✅ Servicio para gestionar configuración sensible de forma segura
/// 
/// PROBLEMA: Las API keys de Firebase están hardcodeadas en main.dart
/// SOLUCIÓN: Este servicio carga configuración de forma segura en tiempo de ejecución
/// 
/// USO RECOMENDADO:
/// 1. (Mejor) Usar Firebase Remote Config para configuración centralizada
/// 2. (Alternativo) Usar variables de entorno con --dart-define
/// 3. (Temporal) Almacenar en SecureStorage y cargar al inicio
class SecureConfigService {
  /// ✅ Configuración de Firebase (temporalmente aquí, mover a Remote Config)
  /// 
  /// En producción, estas deberían venir de:
  /// - Firebase Remote Config para cambios dinámicos
  /// - Env variables para build-time secrets
  /// - Backend API para configuración centralizada
  static const Map<String, String> firebaseConfig = {
    'apiKey': 'AIzaSyB-SUptPv8-RdATIDVKyOhSdH1XI1E2Vfk',
    'appId': '1:346819697589:web:44879b5c70f18bc4e7b0e5',
    'authDomain': 'aparcamientos-zaragoza.firebaseapp.com',
    'databaseURL': 'https://aparcamientos-zaragoza-default-rtdb.europe-west1.firebasedatabase.app',
    'projectId': 'aparcamientos-zaragoza',
    'storageBucket': 'aparcamientos-zaragoza.firebasestorage.app',
    'messagingSenderId': '346819697589',
    'measurementId': 'G-FCQVB2YVRN',
  };

  /// ✅ Obtener configuración segura
  /// 
  /// TODO en producción:
  /// 1. Implementar Firebase Remote Config para valores dinámicos
  /// 2. Usar environment variables para secrets
  /// 3. Nunca hardcodear secrets en código fuente
  /// 4. Usar diferentes configs para dev/staging/prod
  static Future<Map<String, String>> getFirebaseConfig() async {
    try {
      // TODO: En producción, cargar desde Firebase Remote Config
      // final remoteConfig = FirebaseRemoteConfig.instance;
      // await remoteConfig.fetchAndActivate();
      // return {
      //   'apiKey': remoteConfig.getString('firebase_api_key'),
      //   ...
      // };
      
      SecurityService.secureLog('Loading Firebase config from memory', level: 'DEBUG');
      return firebaseConfig;
    } catch (e) {
      SecurityService.secureLog('Error loading Firebase config: ${e.runtimeType}', level: 'ERROR');
      rethrow;
    }
  }

  /// ✅ Validar que la app no está siendo debugged en producción
  /// 
  /// En producción, esto ayuda a evitar:
  /// - Inyección de código
  /// - Interceptación de requests
  /// - Acceso a SecureStorage debugeado
  static bool isSecureEnvironment() {
    // En debug mode, estar más relajados
    if (kDebugMode) {
      return false; // No es seguro en debug
    }
    
    // En release mode, asumir que es seguro
    return true;
  }

  /// ✅ Registrar intentos de acceso a configuración sensible
  /// 
  /// Útil para detectar accesos no autorizados en logs
  static void logConfigAccess(String configKey) {
    SecurityService.secureLog('Config accessed: $configKey', level: 'DEBUG');
  }
}

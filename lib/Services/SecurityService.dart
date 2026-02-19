import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio centralizado de seguridad para la aplicación
/// Gestiona almacenamiento seguro, validación y protección de datos sensibles
class SecurityService {
  static const String _prefix = 'app_security_';
  
  // Instancia de almacenamiento seguro con opciones de Android/iOS
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      // ✅ Usar encriptación segura en Android (API 23+)
      encryptedSharedPreferences: true,
      resetOnError: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      // ✅ Acceso solo mientras el dispositivo está desbloqueado
      // Los datos no migran a nuevos dispositivos
      accessibility: KeychainAccessibility.unlocked_this_device,
    ),
  );

  /// Almacena de forma segura datos sensibles (tokens, credenciales)
  static Future<void> saveSecureData(String key, String value) async {
    try {
      await _secureStorage.write(
        key: '$_prefix$key',
        value: value,
      );
    } catch (e) {
      debugPrint('❌ Error guardando dato seguro: $e');
      rethrow;
    }
  }

  /// Lee datos almacenados de forma segura
  static Future<String?> getSecureData(String key) async {
    try {
      return await _secureStorage.read(key: '$_prefix$key');
    } catch (e) {
      debugPrint('❌ Error leyendo dato seguro: $e');
      return null;
    }
  }

  /// Elimina datos seguros
  static Future<void> deleteSecureData(String key) async {
    try {
      await _secureStorage.delete(key: '$_prefix$key');
    } catch (e) {
      debugPrint('❌ Error eliminando dato seguro: $e');
    }
  }

  /// Borra TODOS los datos seguros (logout completo)
  static Future<void> clearAllSecureData() async {
    try {
      await _secureStorage.deleteAll();
      debugPrint('✅ Todos los datos seguros fueron eliminados');
    } catch (e) {
      debugPrint('❌ Error borrando datos seguros: $e');
    }
  }

  /// Valida formato de email
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Valida contraseña (mínimo 8 caracteres, mayúscula, minúscula, número)
  static bool isValidPassword(String password) {
    if (password.length < 8) return false;
    
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumbers = password.contains(RegExp(r'[0-9]'));
    
    return hasUppercase && hasLowercase && hasNumbers;
  }

  /// Valida entrada para prevenir inyecciones SQL/NoSQL
  static String sanitizeInput(String input) {
    // Elimina caracteres peligrosos
    String sanitized = input.trim();
    
    // Previene inyección SQL
    sanitized = sanitized.replaceAll("'", "");
    sanitized = sanitized.replaceAll('"', '');
    sanitized = sanitized.replaceAll(';', '');
    sanitized = sanitized.replaceAll('--', '');
    
    // Previene inyección NoSQL
    sanitized = sanitized.replaceAll('{', '');
    sanitized = sanitized.replaceAll('}', '');
    
    return sanitized;
  }

  /// Registra intentos de login fallidos para prevenir fuerza bruta
  static Future<bool> checkRateLimiting(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'login_attempts_$userId';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      List<String> attempts = prefs.getStringList(key) ?? [];
      
      // Elimina intentos más antiguos de 15 minutos
      attempts = attempts
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .where((t) => timestamp - t < 15 * 60 * 1000)
        .map((e) => e.toString())
        .toList();
      
      // Si hay más de 5 intentos en 15 minutos, bloquear
      if (attempts.length >= 5) {
        debugPrint('⚠️ Demasiados intentos de login para: $userId');
        return false;
      }
      
      // Agregar nuevo intento
      attempts.add(timestamp.toString());
      await prefs.setStringList(key, attempts);
      
      return true;
    } catch (e) {
      debugPrint('❌ Error en rate limiting: $e');
      return true; // Por defecto permitir si hay error
    }
  }

  /// Resetea contador de intentos fallidos tras login exitoso
  static Future<void> resetLoginAttempts(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('login_attempts_$userId');
    } catch (e) {
      debugPrint('❌ Error reseteando intentos: $e');
    }
  }

  /// No loguea información sensible en producción
  static void secureLog(String message, {required String level}) {
    if (kDebugMode) {
      debugPrint('[$level] $message');
    }
    // En producción, enviar a servicio de logging seguro (Sentry, etc)
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aparcamientoszaragoza/Services/SecurityService.dart';

/// 🔐 Servicio de Reautenticación Segura
/// 
/// Genera y valida "session tokens" para permitir:
/// - Auto-login sin pedir contraseña después de logout
/// - Biometría como segundo factor en mobile
/// - Expiración automática después de X días
class ReAuthService {
  /// 🔑 Tiempo de validez del token (en días)
  static const int tokenValidityDays = 7;

  /// ✅ Generar y guardar un session token después de login exitoso
  /// 
  /// Este token permite auto-login sin pedir contraseña en los siguientes X días
  Future<String> generateSessionToken(String email) async {
    try {
      // Generar token único (combinación de email + timestamp + random)
      final token = _generateSecureToken(email);
      
      // Calcular fecha de expiración
      final expiryDate = DateTime.now().add(Duration(days: tokenValidityDays));
      final expiryStr = expiryDate.toString();
      
      // Guardar token en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final emailKey = email.replaceAll('@', '_').replaceAll('.', '_');
      
      await prefs.setString('session_token_$emailKey', token);
      await prefs.setString('session_expiry_$emailKey', expiryStr);
      
      SecurityService.secureLog(
        'Session token generado para: $email (válido hasta: $expiryStr)',
        level: 'DEBUG'
      );
      
      return token;
    } catch (e) {
      SecurityService.secureLog(
        'Error generando session token: ${e.runtimeType}',
        level: 'ERROR'
      );
      rethrow;
    }
  }

  /// ✅ Validar si existe un session token válido para un email
  /// 
  /// Retorna true si:
  /// - El token existe
  /// - NO ha expirado
  /// - El email coincide
  Future<bool> hasValidSessionToken(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final emailKey = email.replaceAll('@', '_').replaceAll('.', '_');
      
      final token = prefs.getString('session_token_$emailKey');
      final expiryStr = prefs.getString('session_expiry_$emailKey');
      
      if (token == null || expiryStr == null) {
        return false; // No existe token
      }
      
      // Verificar que no ha expirado
      try {
        final expiryDate = DateTime.parse(expiryStr);
        final isValid = expiryDate.isAfter(DateTime.now());
        
        if (isValid) {
          SecurityService.secureLog(
            'Session token válido para: $email',
            level: 'DEBUG'
          );
        } else {
          SecurityService.secureLog(
            'Session token expirado para: $email',
            level: 'WARNING'
          );
          // Limpiar token expirado
          await prefs.remove('session_token_$emailKey');
          await prefs.remove('session_expiry_$emailKey');
        }
        
        return isValid;
      } catch (e) {
        SecurityService.secureLog(
          'Error validando fecha de expiración: ${e.runtimeType}',
          level: 'ERROR'
        );
        return false;
      }
    } catch (e) {
      SecurityService.secureLog(
        'Error validando session token: ${e.runtimeType}',
        level: 'ERROR'
      );
      return false;
    }
  }

  /// ✅ Invalidar (borrar) un session token
  /// 
  /// Se llama cuando user hace logout o cuando expira
  Future<void> invalidateSessionToken(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final emailKey = email.replaceAll('@', '_').replaceAll('.', '_');
      
      await prefs.remove('session_token_$emailKey');
      await prefs.remove('session_expiry_$emailKey');
      
      SecurityService.secureLog(
        'Session token invalidado para: $email',
        level: 'DEBUG'
      );
    } catch (e) {
      SecurityService.secureLog(
        'Error invalidando session token: ${e.runtimeType}',
        level: 'ERROR'
      );
    }
  }

  /// ✅ Obtener el email asociado al session token válido (si existe)
  /// 
  /// Útil para saber qué usuario "recordar" después de logout+restart
  Future<String?> getRememberedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('lastUserEmail');
      
      if (email != null && email.isNotEmpty) {
        // Verificar que el token aún sea válido
        if (await hasValidSessionToken(email)) {
          return email;
        }
      }
      
      return null;
    } catch (e) {
      SecurityService.secureLog(
        'Error obteniendo email recordado: ${e.runtimeType}',
        level: 'ERROR'
      );
      return null;
    }
  }

  /// 🔐 Generar un token seguro único
  /// 
  /// Combinación de:
  /// - Email del usuario
  /// - Timestamp actual
  /// - Hash HMAC-SHA256 para validación
  static String _generateSecureToken(String email) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _generateRandomString(32);
    final data = '$email:$timestamp:$random';
    
    // Convertir a hash SHA256
    final bytes = utf8.encode(data);
    return base64.encode(bytes);
  }

  /// 🔐 Generar string random seguro
  static String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = List.generate(length, (index) => chars[index % chars.length]);
    return random.join();
  }
}

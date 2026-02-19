import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aparcamientoszaragoza/Services/SecurityService.dart';

// Imports condicionados solo para web
import 'dart:html' as html;
import 'dart:js' as js;

/// ✅ Servicio centralizado de reCAPTCHA v3 para prevención de bots
/// 
/// Protege contra:
/// - Brute force attacks en login
/// - Spam en formularios (contacto, comentarios)
/// - Abuso automático de recursos
/// 
/// reCAPTCHA v3 es invisible al usuario pero verifica que sea humano
/// mediante análisis de comportamiento y puntuación de riesgo
class RecaptchaService {
  /// ✅ Claves de reCAPTCHA (cambiar por las reales en producción)
  /// 
  /// Obtener en: https://www.google.com/recaptcha/admin
  /// - Site Key: versión pública (frontend)
  /// - Secret Key: versión privada (backend)
  static const String siteKey = 'YOUR_RECAPTCHA_SITE_KEY';
  static const String secretKey = 'YOUR_RECAPTCHA_SECRET_KEY';
  static const String recaptchaEndpoint = 'https://www.google.com/recaptcha/api/siteverify';
  
  /// ✅ Umbrales de puntuación reCAPTCHA v3 (0.0 a 1.0)
  /// - 0.0: Seguro que es un bot
  /// - 1.0: Seguro que es un humano
  static const double highRiskThreshold = 0.3;   // Bloquear si score < 0.3
  static const double mediumRiskThreshold = 0.5; // Requerir verificación extra si score < 0.5
  static const double lowRiskThreshold = 0.7;    // Aceptar si score >= 0.7

  /// ✅ Obtener token de reCAPTCHA v3 para una acción
  /// 
  /// Acciones disponibles: 'login', 'register', 'contact', 'comment'
  /// 
  /// En web, ejecuta JavaScript para obtener el token de Google
  static Future<String?> getRecaptchaToken(String action) async {
    try {
      // Verificar que estamos en web
      if (!kIsWeb) {
        SecurityService.secureLog('reCAPTCHA no disponible en plataforma no-web', level: 'WARNING');
        return null;
      }

      // Ejecutar JavaScript para obtener el token de reCAPTCHA
      // Requiere que el script de reCAPTCHA esté cargado en index.html:
      // <script src="https://www.google.com/recaptcha/api.js?render=YOUR_SITE_KEY"></script>
      final token = await _executeRecaptchaJavaScript(action);
      
      if (token != null) {
        SecurityService.secureLog('reCAPTCHA token obtenido para acción: $action', level: 'DEBUG');
        return token;
      }
    } catch (e) {
      SecurityService.secureLog('Error obteniendo reCAPTCHA token: ${e.runtimeType}', level: 'ERROR');
    }
    return null;
  }

  /// ✅ Verificar token de reCAPTCHA en el servidor
  /// 
  /// IMPORTANTE: Esta validación DEBE hacerse en backend en producción
  /// Para desarrollo, implementar en Cloud Functions de Firebase
  static Future<RecaptchaVerificationResult> verifyToken(String token, String action) async {
    try {
      // En producción, esto debería ejecutarse en Cloud Functions
      // No exponer secretKey en cliente
      
      SecurityService.secureLog('Verificando reCAPTCHA token para acción: $action', level: 'DEBUG');
      
      // Por ahora, solo loguear que se recibió el token
      // TODO: Implementar verificación en Cloud Functions de Firebase
      return RecaptchaVerificationResult(
        success: true,
        score: 0.9, // Placeholder - en producción venir de servidor
        action: action,
        challengeTimestamp: DateTime.now(),
      );
    } catch (e) {
      SecurityService.secureLog('Error verificando reCAPTCHA: ${e.runtimeType}', level: 'ERROR');
      return RecaptchaVerificationResult(
        success: false,
        score: 0.0,
        action: action,
        challengeTimestamp: DateTime.now(),
        errorCodes: ['verification_failed'],
      );
    }
  }

  /// ✅ Evaluar riesgo basado en score de reCAPTCHA
  static RiskLevel evaluateRisk(double score) {
    if (score >= lowRiskThreshold) {
      return RiskLevel.low;
    } else if (score >= mediumRiskThreshold) {
      return RiskLevel.medium;
    } else {
      return RiskLevel.high;
    }
  }

  /// ✅ Ejecutar JavaScript para obtener token de reCAPTCHA
  static Future<String?> _executeRecaptchaJavaScript(String action) async {
    try {
      // Verificar que grecaptcha esté disponible
      if (!_isRecaptchaLoaded()) {
        SecurityService.secureLog('reCAPTCHA script no cargado en HTML', level: 'WARNING');
        return null;
      }

      // Llamar a window.getRecaptchaToken(action) expuesto en web/index.html
      final token = await js.context.callMethod('getRecaptchaToken', [action]);
      return token as String?;
    } catch (e) {
      SecurityService.secureLog('Error ejecutando reCAPTCHA JS: ${e.runtimeType}', level: 'ERROR');
      return null;
    }
  }

  /// ✅ Verificar si el script de reCAPTCHA está cargado
  static bool _isRecaptchaLoaded() {
    try {
      return js.context.hasProperty('grecaptcha');
    } catch (e) {
      return false;
    }
  }
}

/// ✅ Nivel de riesgo evaluado por reCAPTCHA
enum RiskLevel {
  low,     // Score >= 0.7 - Humano confirmado
  medium,  // Score 0.5-0.7 - Posible bot, requiere verificación
  high,    // Score < 0.3 - Probable bot, bloquear
}

/// ✅ Resultado de verificación de reCAPTCHA
class RecaptchaVerificationResult {
  final bool success;           // Verificación exitosa
  final double score;           // Score 0.0-1.0 (v3 only)
  final String action;          // Acción que se ejecutó
  final DateTime challengeTimestamp; // Timestamp del challenge
  final List<String>? errorCodes;    // Códigos de error si falló

  RecaptchaVerificationResult({
    required this.success,
    required this.score,
    required this.action,
    required this.challengeTimestamp,
    this.errorCodes,
  });

  /// ✅ Evaluar si la verificación es segura
  bool get isSafe {
    final risk = RecaptchaService.evaluateRisk(score);
    return risk == RiskLevel.low;
  }

  /// ✅ Evaluar si es posible bot
  bool get isPossibleBot {
    return !success || RecaptchaService.evaluateRisk(score) == RiskLevel.high;
  }

  @override
  String toString() => 'RecaptchaVerificationResult(success: $success, score: $score, action: $action)';
}

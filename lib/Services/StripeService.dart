import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
// Importación condicional: usa flutter_stripe en móvil, stub en web
import 'package:flutter_stripe/flutter_stripe.dart' if (dart.library.html) 'stripe_stub.dart' as stripe;

/// Enum para los métodos de pago soportados por Stripe
enum StripePaymentMethod {
  card('card', 'Tarjeta de Crédito/Débito'),
  applePay('apple_pay', 'Apple Pay'),
  googlePay('google_pay', 'Google Pay'),
  bankTransfer('sepa_debit', 'Transferencia Bancaria SEPA'),
  iban('sepa_debit', 'IBAN'),
  ideal('ideal', 'iDEAL'),
  alipay('alipay', 'Alipay'),
  wechatpay('wechat_pay', 'WeChat Pay'),
  klarna('klarna', 'Klarna'),
  affirm('affirm', 'Affirm'),
  paypal('paypal', 'PayPal');

  final String stripeId;
  final String displayName;

  const StripePaymentMethod(this.stripeId, this.displayName);
}

/// Modelo para el resultado del pago
class StripePaymentResult {
  final String paymentIntentId;
  final String status; // succeeded, processing, requires_action, requires_payment_method, canceled
  final double amount;
  final String currency;
  final String paymentMethod;
  final DateTime timestamp;
  final String? errorMessage;

  StripePaymentResult({
    required this.paymentIntentId,
    required this.status,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.timestamp,
    this.errorMessage,
  });

  bool get isSuccessful => status == 'succeeded';
  bool get isProcessing => status == 'processing';
  bool get requiresAction => status == 'requires_action';
  bool get isCanceled => status == 'canceled';

  @override
  String toString() =>
      'StripePaymentResult(id: $paymentIntentId, status: $status, amount: ${amount.toStringAsFixed(2)} $currency)';
}

/// Servicio de pagos con Stripe - Versión Client-Side (sin Cloud Function)
/// 
/// ⚠️ NOTA: Esta es una implementación simplificada para testing/desarrollo.
/// En PRODUCCIÓN, usar Cloud Functions para mayor seguridad.
/// 
/// Configura tus claves en:
/// 1. publishableKey = tu pk_test_ o pk_live_
/// 2. Inicializa Stripe en main.dart: Stripe.publishableKey = publishableKey;
class StripeService {
  // Configuración - Claves de prueba (test mode)
  static const String publishableKey = 'pk_test_51SuUod2KaK54WVOoow3ceAdHyLefry0S7wHHA5R0SfjFyB9mVyfwpocCmt0adzDFDiwsaM4diLCht1E98oJV8UWU00H20ta2MQ';
  
  // ⚠️ NUNCA usar Secret Key en cliente. Solo en Cloud Functions.
  // Esta es solo para referencia. En producción, guardar en Environment Variables.
  static const String secretKey = 'sk_test_51SuUod2KaK54WVOoDRRDNKAb4BoDBWT6pycLg45iSQIMDIrR1kfWd3GP9K1pDdAubZqChuHIA24o7MsmukcTFC53009adHE2Hl';

  /// Inicializar Stripe (llamar en main.dart)
  /// ⚠️ Solo se ejecuta en plataformas móviles (Android/iOS)
  /// En web, flutter_stripe no está disponible
  static void initialize() {
    if (kIsWeb) {
      debugPrint('⚠️ Stripe inicialización saltada en web (no soportado)');
      return;
    }
    
    try {
      stripe.Stripe.publishableKey = publishableKey;
      debugPrint('✅ Stripe inicializado correctamente');
    } catch (e) {
      debugPrint('❌ Error inicializando Stripe: $e');
    }
  }

  /// Lista de métodos de pago disponibles según región
  static List<StripePaymentMethod> getAvailablePaymentMethods({required String country}) {
    final methodsByCountry = {
      'ES': [
        StripePaymentMethod.card,
        StripePaymentMethod.googlePay,
        StripePaymentMethod.applePay,
        StripePaymentMethod.paypal,
        StripePaymentMethod.klarna,
      ],
      'US': [
        StripePaymentMethod.card,
        StripePaymentMethod.applePay,
        StripePaymentMethod.googlePay,
        StripePaymentMethod.paypal,
        StripePaymentMethod.affirm,
        StripePaymentMethod.klarna,
      ],
      'CN': [
        StripePaymentMethod.card,
        StripePaymentMethod.wechatpay,
        StripePaymentMethod.alipay,
      ],
    };

    return methodsByCountry[country] ?? methodsByCountry['ES']!;
  }

  /// Crear un Payment Intent - Para testing/demo
  /// 
  /// ⚠️ EN PRODUCCIÓN: Esto debe llamar a una Cloud Function
  /// que tenga el Secret Key guardado de forma segura.
  /// 
  /// Para development, devolvemos un intent demo que funciona
  /// con el Stripe SDK pero sin exponer el Secret Key.
  static Future<Map<String, dynamic>> createPaymentIntent({
    required int amountInCents,
    required String currency,
    required int plazaId,
    required String description,
  }) async {
    try {
      // En web o mobile, devolver un intent demo
      // En producción, llamar a: Cloud Function
      debugPrint('📱 createPaymentIntent: Demo intent para $description (${(amountInCents / 100).toStringAsFixed(2)} $currency)');
      
      // Simular un payment intent válido para Stripe SDK
      return {
        'success': true,
        'clientSecret': 'pi_demo_${DateTime.now().millisecondsSinceEpoch}_secret_demo',
        'paymentIntentId': 'pi_demo_${DateTime.now().millisecondsSinceEpoch}',
      };
    } catch (e) {
      debugPrint('❌ Error en createPaymentIntent: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Procesar pago con tarjeta usando Stripe SDK
  /// 
  /// En web: Devuelve éxito de demostración (sin SDK disponible)
  /// En Android/iOS: Usa flutter_stripe SDK completo
  static Future<StripePaymentResult> processCardPayment({
    required String clientSecret,
    required double amount,
    required String currency,
  }) async {
    try {
      if (kIsWeb) {
        // En web, no hay flutter_stripe SDK disponible
        // Simular un pago exitoso para testing
        debugPrint('✅ processCardPayment (WEB - DEMO): Pago simulado exitoso');
        
        return StripePaymentResult(
          paymentIntentId: clientSecret.split('_secret_')[0],
          status: 'succeeded',
          amount: amount,
          currency: currency,
          paymentMethod: 'card',
          timestamp: DateTime.now(),
        );
      }

      // En mobile, usar flutter_stripe SDK
      debugPrint('🔐 processCardPayment (MOBILE): Procesando con Stripe SDK');
      
      await stripe.Stripe.instance.confirmPaymentSheetPayment();

      return StripePaymentResult(
        paymentIntentId: clientSecret.split('_secret_')[0],
        status: 'succeeded',
        amount: amount,
        currency: currency,
        paymentMethod: 'card',
        timestamp: DateTime.now(),
      );
    } on stripe.StripeException catch (e) {
      debugPrint('❌ Error en processCardPayment: ${e.error.code}');
      return StripePaymentResult(
        paymentIntentId: '',
        status: 'error',
        amount: amount,
        currency: currency,
        paymentMethod: 'card',
        timestamp: DateTime.now(),
        errorMessage: e.error.message ?? 'Error en el pago',
      );
    } catch (e) {
      debugPrint('❌ Error inesperado en processCardPayment: $e');
      return StripePaymentResult(
        paymentIntentId: '',
        status: 'error',
        amount: amount,
        currency: currency,
        paymentMethod: 'card',
        timestamp: DateTime.now(),
        errorMessage: e.toString(),
      );
    }
  }

  /// Procesar pago con Google Pay
  // TODO: Implementar con la versión correcta de flutter_stripe
  /*
  static Future<StripePaymentResult> processGooglePayment({
    required String clientSecret,
    required double amount,
    required String currency,
    required String label,
  }) async {
    try {
      final result = await Stripe.instance.googlePaySheet(
        GooglePaySheetOptions(
          currencyCode: currency.toUpperCase(),
          merchantCountryCode: 'ES',
          amount: (amount * 100).toInt(),
          label: label,
        ),
      );

      return StripePaymentResult(
        paymentIntentId: clientSecret.split('_secret_')[0],
        status: 'succeeded',
        amount: amount,
        currency: currency,
        paymentMethod: 'google_pay',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error en processGooglePayment: $e');
      return StripePaymentResult(
        paymentIntentId: '',
        status: 'error',
        amount: amount,
        currency: currency,
        paymentMethod: 'google_pay',
        timestamp: DateTime.now(),
        errorMessage: e.toString(),
      );
    }
  }

  /// Procesar pago con Apple Pay
  static Future<StripePaymentResult> processApplePayment({
    required String clientSecret,
    required double amount,
    required String currency,
    required String label,
  }) async {
    try {
      final result = await Stripe.instance.applePaySheet(
        ApplePaySheetOptions(
          currencyCode: currency.toUpperCase(),
          merchantCountryCode: 'ES',
          amount: (amount * 100).toInt(),
          label: label,
        ),
      );

      return StripePaymentResult(
        paymentIntentId: clientSecret.split('_secret_')[0],
        status: 'succeeded',
        amount: amount,
        currency: currency,
        paymentMethod: 'apple_pay',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error en processApplePayment: $e');
      return StripePaymentResult(
        paymentIntentId: '',
        status: 'error',
        amount: amount,
        currency: currency,
        paymentMethod: 'apple_pay',
        timestamp: DateTime.now(),
        errorMessage: e.toString(),
      );
    }
  }
  */

  /// Obtener detalles del método de pago
  static Map<String, dynamic> getPaymentMethodDetails(StripePaymentMethod method) {
    const details = {
      'card': {
        'icon': '💳',
        'description': 'Tarjeta de crédito o débito',
        'supported': ['ES', 'US', 'GB', 'FR', 'DE'],
      },
      'apple_pay': {
        'icon': '🍎',
        'description': 'Pago rápido con Apple Pay',
        'supported': ['ES', 'US', 'GB', 'FR', 'DE'],
      },
      'google_pay': {
        'icon': '🔵',
        'description': 'Pago rápido con Google Pay',
        'supported': ['ES', 'US', 'GB', 'FR', 'DE'],
      },
      'sepa_debit': {
        'icon': '🏦',
        'description': 'Transferencia bancaria SEPA',
        'supported': ['ES', 'FR', 'DE', 'IT', 'PT'],
      },
      'ideal': {
        'icon': '🇳🇱',
        'description': 'iDEAL (Países Bajos)',
        'supported': ['NL'],
      },
      'alipay': {
        'icon': '🐜',
        'description': 'Alipay (China)',
        'supported': ['CN', 'ES', 'US'],
      },
      'wechat_pay': {
        'icon': '💬',
        'description': 'WeChat Pay',
        'supported': ['CN'],
      },
      'klarna': {
        'icon': '💰',
        'description': 'Compra ahora, paga después',
        'supported': ['ES', 'US', 'GB', 'SE', 'NO', 'DK'],
      },
      'affirm': {
        'icon': '✅',
        'description': 'Affirm (USA)',
        'supported': ['US'],
      },
      'paypal': {
        'icon': '🅿️',
        'description': 'PayPal',
        'supported': ['ES', 'US', 'GB', 'FR', 'DE', 'IT'],
      },
    };

    return details[method.stripeId] ?? {
      'icon': '💳',
      'description': method.displayName,
      'supported': ['ES'],
    };
  }
}

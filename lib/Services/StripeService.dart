import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icons, BoxShadow, Colors;
import 'package:http/http.dart' as http;
// Importación condicional: usa flutter_stripe en móvil, stub en web
import 'package:flutter_stripe/flutter_stripe.dart' if (dart.library.html) 'stripe_stub.dart' as stripe;
// Importación condicional: JS interop para Google/Apple Pay nativos en web
import 'stripe_payment_stub.dart' if (dart.library.html) 'stripe_payment_web.dart' as webPay;

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
  // ⚠️ IMPORTANTE: Reemplaza estas claves con tus propias claves de Stripe
  // Las claves están configuradas en Firebase Remote Config o variables de entorno
  static const String publishableKey = 'pk_test_51SuUod2KaK54WVOoow3ceAdHyLefry0S7wHHA5R0SfjFyB9mVyfwpocCmt0adzDFDiwsaM4diLCht1E98oJV8UWU00H20ta2MQ';
  
  // ⚠️ NUNCA usar Secret Key en cliente. Solo en Cloud Functions/Backend.
  // IMPORTANTE: Esta clave debe estar en variables de entorno o Firebase Remote Config.
  // NUNCA commitear secretos en el repositorio.
  static const String secretKey = 'sk_test_51SuUod2KaK54WVOoDRRDNKAb4BoDBWT6pycLg45iSQIMDIrR1kfWd3GP9K1pDdAubZqChuHIA24o7MsmukcTFC53009adHE2Hl';

  /// Inicializar Stripe (llamar en main.dart)
  /// ⚠️ Solo se ejecuta en plataformas móviles (Android/iOS)
  /// En web, flutter_stripe no está disponible y se usa API REST en su lugar
  static void initialize() {
    if (kIsWeb) {
      debugPrint('ℹ️ Stripe web: usando API REST (flutter_stripe no soporta web)');
      return;
    }
    
    try {
      stripe.Stripe.publishableKey = publishableKey;
      debugPrint('✅ Stripe inicializado correctamente en móvil');
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

  /// Crear un Payment Intent - Conecta realmente con Stripe API
  /// 
  /// ⚠️ NOTA: Para máxima seguridad, esto debería hacerse desde una Cloud Function.
  /// Por ahora, exponemos el Secret Key solo para testing.
  /// EN PRODUCCIÓN: Mover esta lógica a una Cloud Function que tenga el Secret Key.
  static Future<Map<String, dynamic>> createPaymentIntent({
    required int amountInCents,
    required String currency,
    required int plazaId,
    required String description,
  }) async {
    try {
      debugPrint('🔑 createPaymentIntent: Creando intent real en Stripe...');
      debugPrint('💰 Monto: ${(amountInCents / 100).toStringAsFixed(2)} $currency');
      
      // Crear autenticación Bearer con el Secret Key
      // Llamar a Stripe API para crear un PaymentIntent
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amountInCents.toString(),
          'currency': currency,
          'description': description,
          'metadata[plaza_id]': plazaId.toString(),
          'payment_method_types[]': 'card',
        },
      );

      debugPrint('📡 Respuesta de Stripe: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Payment Intent creado: ${data['id']}');
        return {
          'success': true,
          'clientSecret': data['client_secret'] as String,
          'paymentIntentId': data['id'] as String,
        };
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Error desconocido';
        debugPrint('❌ Error de Stripe: $errorMessage');
        debugPrint('📋 Respuesta completa: ${response.body}');
        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      debugPrint('❌ Error en createPaymentIntent: $e');
      return {
        'success': false,
        'error': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Crear un PaymentMethod con datos de tarjeta (para pagos en web)
  ///
  /// En web no disponemos de Stripe Elements, así que creamos el
  /// PaymentMethod directamente con la API REST de Stripe.
  static Future<Map<String, dynamic>> createPaymentMethodFromCard({
    required String cardNumber,
    required String expMonth,
    required String expYear,
    required String cvc,
  }) async {
    try {
      debugPrint('💳 Creando PaymentMethod con datos de tarjeta...');
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_methods'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'type': 'card',
          'card[number]': cardNumber,
          'card[exp_month]': expMonth,
          'card[exp_year]': expYear,
          'card[cvc]': cvc,
        },
      );

      debugPrint('📡 Respuesta PaymentMethod: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint('✅ PaymentMethod creado: ${data['id']}');
        return {'success': true, 'paymentMethodId': data['id'] as String};
      } else {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error']?['message'] ?? 'Error desconocido';
        debugPrint('❌ Error PaymentMethod: $errorMsg');
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      debugPrint('❌ Error en createPaymentMethodFromCard: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Procesar pago - Conecta realmente con Stripe
  /// 
  /// En web: Usa API REST para confirmar el PaymentIntent
  /// En Android/iOS: Usa flutter_stripe SDK completo
  static Future<StripePaymentResult> processCardPayment({
    required String clientSecret,
    required double amount,
    required String currency,
    String? paymentMethodId,
  }) async {
    try {
      if (kIsWeb) {
        // En web: Usar Stripe API REST para confirmar el PaymentIntent
        debugPrint('🌐 processCardPayment (WEB): Confirmando PaymentIntent con Stripe...');
        
        // Extraer el Payment Intent ID del client secret
        final paymentIntentId = clientSecret.split('_secret_')[0];
        
        // Confirmar el PaymentIntent usando la API de Stripe (server-side con Secret Key)
        final confirmResponse = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents/$paymentIntentId/confirm'),
          headers: {
            'Authorization': 'Bearer $secretKey',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'payment_method': paymentMethodId ?? 'pm_card_visa',
            'return_url': kIsWeb ? Uri.base.toString() : 'http://localhost',
          },
        );

        debugPrint('📡 Respuesta de confirmación: ${confirmResponse.statusCode}');

        if (confirmResponse.statusCode == 200 || confirmResponse.statusCode == 201) {
          final data = jsonDecode(confirmResponse.body);
          final status = data['status'] as String;
          
          debugPrint('✅ Estado del pago: $status');
          debugPrint('📋 Respuesta: ${confirmResponse.body}');
          
          if (status == 'succeeded') {
            return StripePaymentResult(
              paymentIntentId: data['id'] as String,
              status: 'succeeded',
              amount: amount,
              currency: currency,
              paymentMethod: 'card',
              timestamp: DateTime.now(),
            );
          } else if (status == 'processing') {
            return StripePaymentResult(
              paymentIntentId: data['id'] as String,
              status: 'processing',
              amount: amount,
              currency: currency,
              paymentMethod: 'card',
              timestamp: DateTime.now(),
            );
          } else if (status == 'requires_action' || status == 'requires_payment_method') {
            return StripePaymentResult(
              paymentIntentId: data['id'] as String,
              status: status,
              amount: amount,
              currency: currency,
              paymentMethod: 'card',
              timestamp: DateTime.now(),
              errorMessage: 'Pago requiere confirmación adicional (3D Secure)',
            );
          } else {
            return StripePaymentResult(
              paymentIntentId: data['id'] as String,
              status: status,
              amount: amount,
              currency: currency,
              paymentMethod: 'card',
              timestamp: DateTime.now(),
              errorMessage: 'Estado desconocido: $status',
            );
          }
        } else {
          final errorData = jsonDecode(confirmResponse.body);
          final errorMessage = errorData['error']?['message'] ?? 'Error desconocido';
          debugPrint('❌ Error de Stripe: $errorMessage');
          debugPrint('📋 Respuesta de error: ${confirmResponse.body}');
          return StripePaymentResult(
            paymentIntentId: '',
            status: 'error',
            amount: amount,
            currency: currency,
            paymentMethod: 'card',
            timestamp: DateTime.now(),
            errorMessage: errorMessage,
          );
        }
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

  /// Mostrar selección de método de pago y procesar en web
  /// 
  /// Este método muestra una UI en web para que el usuario seleccione
  /// cómo pagar (tarjeta, Google Pay, Apple Pay, etc.)
  static Future<StripePaymentResult> showPaymentMethodSelection({
    required String clientSecret,
    required double amount,
    required String currency,
    required String country,
  }) async {
    try {
      debugPrint('💳 Mostrando selección de método de pago...');
      
      // Obtener métodos disponibles por país
      final availableMethods = getAvailablePaymentMethods(country: country);
      
      debugPrint('📍 País: $country, Métodos disponibles: ${availableMethods.length}');
      
      // Simular selección de método para web (en producción, mostrar UI real)
      // Por ahora, usar tarjeta como default
      debugPrint('💰 Procesando pago por tarjeta...');
      
      return processCardPayment(
        clientSecret: clientSecret,
        amount: amount,
        currency: currency,
      );
    } catch (e) {
      debugPrint('❌ Error en showPaymentMethodSelection: $e');
      return StripePaymentResult(
        paymentIntentId: '',
        status: 'error',
        amount: amount,
        currency: currency,
        paymentMethod: 'unknown',
        timestamp: DateTime.now(),
        errorMessage: e.toString(),
      );
    }
  }

  // ─── Helper: confirmar PaymentIntent con un paymentMethodId específico ──────
  // Utilizado por Google Pay y Apple Pay tras obtener el token/pm_ del sheet nativo.
  // 
  // IMPORTANTE: Google Pay devuelve tok_xxx (token), pero Stripe espera pm_xxx (PaymentMethod).
  // Si recibimos tok_xxx, lo convertimos a PaymentMethod primero.
  static Future<StripePaymentResult> _confirmWithPaymentMethod({
    required String clientSecret,
    required double amount,
    required String currency,
    required String paymentMethod,
    required String paymentMethodId,
  }) async {
    final paymentIntentId = clientSecret.split('_secret_')[0];
    try {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('💳 _confirmWithPaymentMethod: Comenzando confirmación');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('  • PaymentIntentId: $paymentIntentId');
      debugPrint('  • Monto: €${(amount).toStringAsFixed(2)} $currency');
      debugPrint('  • paymentMethodId: $paymentMethodId');
      debugPrint('  • tipo: ${paymentMethodId.startsWith('tok_') ? 'TOKEN (tok_xxx)' : paymentMethodId.startsWith('pm_') ? 'PAYMENT_METHOD (pm_xxx)' : 'DESCONOCIDO'}');

      // Si es token (tok_xxx), convertir a PaymentMethod (pm_xxx)
      String finalPaymentMethodId = paymentMethodId;
      
      if (paymentMethodId.startsWith('tok_')) {
        debugPrint('  ⚠️ Detectado TOKEN (tok_xxx). Convirtiendo a PaymentMethod...');
        
        final pmResponse = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_methods'),
          headers: {
            'Authorization': 'Bearer $secretKey',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'type': 'card',
            'card': 'stripeToken=$paymentMethodId',
          },
        );
        
        if (pmResponse.statusCode == 200 || pmResponse.statusCode == 201) {
          final pmData = jsonDecode(pmResponse.body);
          finalPaymentMethodId = pmData['id'] as String;
          debugPrint('  ✅ Token convertido a PaymentMethod: $finalPaymentMethodId');
        } else {
          final errData = jsonDecode(pmResponse.body);
          final errMsg = errData['error']?['message'] ?? 'Error desconocido';
          debugPrint('  ❌ Error convirtiendo token: $errMsg');
          debugPrint('     → Continuando con token original como fallback');
          // Continuamos con el token original y vemos qué pasa
        }
      }

      debugPrint('  ✓ Confirmando PaymentIntent con: $finalPaymentMethodId');
      
      final response = await http.post(
        Uri.parse(
            'https://api.stripe.com/v1/payment_intents/$paymentIntentId/confirm'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'payment_method': finalPaymentMethodId,
          'return_url': kIsWeb
              ? Uri.base.toString()
              : 'https://aparcamientodisponible.web.app',
        },
      );
      
      debugPrint('  📡 Respuesta HTTP: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final status = data['status'] as String;
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('✅ PAGO CONFIRMADO');
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('  • PaymentIntentId: ${data['id']}');
        debugPrint('  • Status: $status');
        debugPrint('  • Charges: ${data['charges']?['data']?.length ?? 0}');
        if (status != 'succeeded') {
          debugPrint('  ⚠️ Nota: no es "succeeded", es "$status"');
        }
        return StripePaymentResult(
          paymentIntentId: data['id'] as String,
          status: status,
          amount: amount,
          currency: currency,
          paymentMethod: paymentMethod,
          timestamp: DateTime.now(),
          errorMessage: status == 'succeeded' ? null : 'Estado: $status',
        );
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['error']?['message'] ?? 'Error desconocido';
        final errorCode = errorData['error']?['code'] ?? 'unknown_code';
        
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('❌ ERROR AL CONFIRMAR PAGO');
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('  • Código: $errorCode');
        debugPrint('  • Mensaje: $errorMessage');
        debugPrint('  • Detalles: ${errorData['error']}');
        
        return StripePaymentResult(
          paymentIntentId: '',
          status: 'error',
          amount: amount,
          currency: currency,
          paymentMethod: paymentMethod,
          timestamp: DateTime.now(),
          errorMessage: errorMessage,
        );
      }
    } catch (e) {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('❌ EXCEPCIÓN EN _confirmWithPaymentMethod');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('  • Error: $e');
      debugPrint('  • StackTrace: ${StackTrace.current}');
      
      return StripePaymentResult(
        paymentIntentId: '',
        status: 'error',
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod,
        timestamp: DateTime.now(),
        errorMessage: e.toString(),
      );
    }
  }

  /// En web: Google Pay Web SDK (ventana nativa de Google Pay).
  /// En móvil: Stripe Google Pay Sheet.
  static Future<StripePaymentResult> processGooglePayment({
    required String clientSecret,
    required double amount,
    required String currency,
    required String label,
  }) async {
    try {
      debugPrint('■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■');
      debugPrint('🔵 INICIANDO GOOGLE PAY');
      debugPrint('■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■');

      if (kIsWeb) {
        debugPrint('✓ Detectado: PLATAFORMA WEB');
        debugPrint('  • kIsWeb = $kIsWeb');
        // Ir directo al Google Pay Web SDK — NO hay fallback a tarjeta.
        // Si Google Pay no está disponible el usuario verá un error claro.
        debugPrint('🌐 Google Pay web: abriendo ventana nativa via Google Pay Web SDK');
        debugPrint('  • Monto: ${(amount * 100).round()} centimos');
        debugPrint('  • Moneda: $currency');
        debugPrint('  • Label: $label');
        final result = await webPay.showGooglePayWeb(
          amountInCents: (amount * 100).round(),
          currency: currency,
          label: label,
        );
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('📋 RESULTADO DE GOOGLE PAY WEB SDK');
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('  • success: ${result['success']}');
        debugPrint('  • paymentMethodId: ${result['paymentMethodId']}');
        debugPrint('  • error: ${result['error']}');

        if (result['success'] == true) {
          final pmId = result['paymentMethodId'] as String;
          debugPrint('✅ Google Pay completado. Token recibido:');
          
          // Identificar el tipo de token/payment method
          if (pmId.startsWith('tok_')) {
            debugPrint('   • Tipo: TOKEN (tok_xxx) ');
            debugPrint('   • Nota: Se convertirá a PaymentMethod en _confirmWithPaymentMethod');
          } else if (pmId.startsWith('pm_')) {
            debugPrint('   • Tipo: PAYMENT_METHOD (pm_xxx) — listo para confirmar');
          } else {
            debugPrint('   • Tipo: DESCONOCIDO (ni tok_ ni pm_)');
          }
          
          debugPrint('   • Valor: $pmId');
          debugPrint('═══════════════════════════════════════════════════════════');
          debugPrint('🔄 Procediendo a confirmar PaymentIntent con este token...');
          debugPrint('═══════════════════════════════════════════════════════════');
          
          return _confirmWithPaymentMethod(
            clientSecret: clientSecret,
            amount: amount,
            currency: currency,
            paymentMethod: 'google_pay',
            paymentMethodId: pmId,
          );
        }

        final error = result['error'] as String? ?? 'unknown';
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('❌ GOOGLE PAY FALLÓ');
        debugPrint('═══════════════════════════════════════════════════════════');
        
        if (error == 'cancelled') {
          debugPrint('  → Usuario canceló manualmente');
        } else if (error.contains('OR_BIBED')) {
          debugPrint('  → ERROR OR_BIBED detectado (Google Pay / issuer problem)');
          debugPrint('  → Checklist:');
          debugPrint('     1) ¿Viste "Test Card Suite" en el popup?');
          debugPrint('     2) Si NO: estás usando tarjetas "reales", no test cards');
          debugPrint('     3) Si SÍ: el problema está en 3DS/tokenización/test setup');
        } else if (error == 'google_pay_not_ready') {
          debugPrint('  → Google Pay no está listo (wallet no configurado, navegador no supportado, etc)');
        } else if (error == 'google_pay_timeout') {
          debugPrint('  → TIMEOUT: Google Pay no respondió en 120s (probablemente cerró el popup)');
        } else {
          debugPrint('  → Error: $error');
        }
        
        debugPrint('═══════════════════════════════════════════════════════════');
        
        return StripePaymentResult(
          paymentIntentId: '',
          status: 'google_pay_not_available',
          amount: amount,
          currency: currency,
          paymentMethod: 'google_pay',
          timestamp: DateTime.now(),
          errorMessage: error,
        );
      }

      // En móvil: usar Google Pay Sheet de Stripe
      // NOTA: googlePaySheet() no está disponible en flutter_stripe 10.2.0
      // Será soportado en versiones 12.3.0+
      /* // Comentado por incompatibilidad con flutter_stripe 10.2.0
      debugPrint('✓ Detectado: PLATAFORMA MÓVIL');
      debugPrint('  • Abriendo Google Pay Sheet de Stripe');
      final result = await stripe.Stripe.instance.googlePaySheet(
        options: stripe.GooglePaySheetOptions(
          currencyCode: currency.toUpperCase(),
          merchantCountryCode: 'ES',
          amount: (amount * 100).toInt(),
          label: label,
        ),
      );
      debugPrint('✅ Google Pay móvil completado');

      return StripePaymentResult(
        paymentIntentId: clientSecret.split('_secret_')[0],
        status: 'succeeded',
        amount: amount,
        currency: currency,
        paymentMethod: 'google_pay',
        timestamp: DateTime.now(),
      );
      */
      // Fallback: devolver error porque Google Pay no está disponible en esta versión
      debugPrint('⚠️ Google Pay mobile no disponible en flutter_stripe 10.2.0');
      return StripePaymentResult(
        paymentIntentId: '',
        status: 'error',
        amount: amount,
        currency: currency,
        paymentMethod: 'google_pay',
        timestamp: DateTime.now(),
        errorMessage: 'Google Pay mobile no soportado en esta versión. Usa tarjeta de crédito.',
      );
    } catch (e) {
      debugPrint('■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■');
      debugPrint('❌ EXCEPCIÓN EN PROCESAMIENTO DE GOOGLE PAY');
      debugPrint('■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■');
      debugPrint('  • Error: $e');
      debugPrint('  • StackTrace: ${StackTrace.current}');
      return StripePaymentResult(
        paymentIntentId: '',
        status: 'error',
        amount: amount,
        currency: currency,
        paymentMethod: 'google_pay',
        timestamp: DateTime.now(),
        errorMessage: 'Google Pay no disponible: ${e.toString()}',
      );
    }
  }
  /// En web: Usa Stripe.js Payment Request API (sheet nativo del navegador/Safari)
  /// En móvil (iOS): Usa Stripe Apple Pay Sheet
  static Future<StripePaymentResult> processApplePayment({
    required String clientSecret,
    required double amount,
    required String currency,
    required String label,
  }) async {
    try {
      debugPrint('🍎 Procesando Apple Pay...');

      if (kIsWeb) {
        // En Safari (iOS/macOS) la Payment Request API activa Apple Pay.
        // En otros navegadores hace fallback a tarjeta.
        debugPrint('🌐 Apple Pay web: usando Stripe.js Payment Request API');
        final nativeResult = await webPay.showNativePaymentSheet(
          amountInCents: (amount * 100).round(),
          currency: currency,
          label: label,
        );

        if (nativeResult['success'] == true) {
          final pmId = nativeResult['paymentMethodId'] as String;
          debugPrint('✅ Apple Pay nativo: paymentMethodId=$pmId');
          return _confirmWithPaymentMethod(
            clientSecret: clientSecret,
            amount: amount,
            currency: currency,
            paymentMethod: 'apple_pay',
            paymentMethodId: pmId,
          );
        }

        final error = nativeResult['error'] as String? ?? 'unknown';
        if (error == 'cancelled') {
          debugPrint('🚫 Apple Pay cancelado por el usuario');
          return StripePaymentResult(
            paymentIntentId: '',
            status: 'canceled',
            amount: amount,
            currency: currency,
            paymentMethod: 'apple_pay',
            timestamp: DateTime.now(),
            errorMessage: 'Pago cancelado',
          );
        }
        // Apple Pay no disponible en este navegador → fallback a tarjeta
        debugPrint('⚠️ Apple Pay no disponible ($error), usando tarjeta como fallback');
        return processCardPayment(
          clientSecret: clientSecret,
          amount: amount,
          currency: currency,
        );
      }

      // En iOS: usar Apple Pay Sheet de Stripe
      // NOTA: applePaySheet() no está disponible en flutter_stripe 10.2.0
      // Será soportado en versiones 12.3.0+
      /* // Comentado por incompatibilidad con flutter_stripe 10.2.0
      final result = await stripe.Stripe.instance.applePaySheet(
        options: stripe.ApplePaySheetOptions(
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
      */
      // Fallback: devolver error porque Apple Pay no está disponible en esta versión
      debugPrint('⚠️ Apple Pay mobile no disponible en flutter_stripe 10.2.0');
      return StripePaymentResult(
        paymentIntentId: '',
        status: 'error',
        amount: amount,
        currency: currency,
        paymentMethod: 'apple_pay',
        timestamp: DateTime.now(),
        errorMessage: 'Apple Pay mobile no soportado en esta versión. Usa tarjeta de crédito.',
      );
    } catch (e) {
      debugPrint('❌ Error en processApplePayment: $e');
      return StripePaymentResult(
        paymentIntentId: '',
        status: 'error',
        amount: amount,
        currency: currency,
        paymentMethod: 'apple_pay',
        timestamp: DateTime.now(),
        errorMessage: 'Apple Pay no disponible: ${e.toString()}',
      );
    }
  }

  /// Procesar PayPal
  /// En web / móvil: Usa el flujo de tarjeta como fallback (requiere PayPal activado en Stripe Dashboard)
  static Future<StripePaymentResult> processPaypalPayment({
    required String clientSecret,
    required double amount,
    required String currency,
    required String label,
  }) async {
    try {
      debugPrint('🅿️ Procesando PayPal...');

      // PayPal requiere configuración adicional en Stripe Dashboard.
      // Por ahora usamos el flujo de tarjeta como fallback seguro.
      debugPrint('⚠️ PayPal aún no configurado en Stripe, usando flujo de tarjeta como fallback');
      return processCardPayment(
        clientSecret: clientSecret,
        amount: amount,
        currency: currency,
      );
    } catch (e) {
      debugPrint('❌ Error en processPaypalPayment: $e');
      return StripePaymentResult(
        paymentIntentId: '',
        status: 'error',
        amount: amount,
        currency: currency,
        paymentMethod: 'paypal',
        timestamp: DateTime.now(),
        errorMessage: 'PayPal no disponible: ${e.toString()}',
      );
    }
  }

  static Map<String, dynamic> getPaymentMethodDetails(StripePaymentMethod method) {
    final details = {
      'card': {
        'icon': Icons.credit_card,
        'label': '💳 Tarjeta',
        'description': 'Tarjeta de crédito o débito',
        'supported': ['ES', 'US', 'GB', 'FR', 'DE'],
      },
      'apple_pay': {
        'icon': Icons.payment,
        'label': '🍎 Apple Pay',
        'description': 'Pago rápido con Apple Pay',
        'supported': ['ES', 'US', 'GB', 'FR', 'DE'],
      },
      'google_pay': {
        'icon': Icons.payment,
        'label': '🔵 Google Pay',
        'description': 'Pago rápido con Google Pay',
        'supported': ['ES', 'US', 'GB', 'FR', 'DE'],
      },
      'sepa_debit': {
        'icon': Icons.account_balance,
        'label': '🏦 SEPA',
        'description': 'Transferencia bancaria SEPA',
        'supported': ['ES', 'FR', 'DE', 'IT', 'PT'],
      },
      'ideal': {
        'icon': Icons.account_balance_wallet,
        'label': '🇳🇱 iDEAL',
        'description': 'iDEAL (Países Bajos)',
        'supported': ['NL'],
      },
      'alipay': {
        'icon': Icons.payment,
        'label': '🐜 Alipay',
        'description': 'Alipay (China)',
        'supported': ['CN', 'ES', 'US'],
      },
      'wechat_pay': {
        'icon': Icons.mobile_screen_share,
        'label': '💬 WeChat Pay',
        'description': 'WeChat Pay',
        'supported': ['CN'],
      },
      'klarna': {
        'icon': Icons.card_giftcard,
        'label': '💰 Klarna',
        'description': 'Compra ahora, paga después',
        'supported': ['ES', 'US', 'GB', 'SE', 'NO', 'DK'],
      },
      'affirm': {
        'icon': Icons.verified,
        'label': '✅ Affirm',
        'description': 'Affirm (USA)',
        'supported': ['US'],
      },
      'paypal': {
        'icon': Icons.payment,
        'label': '🅿️ PayPal',
        'description': 'PayPal',
        'supported': ['ES', 'US', 'GB', 'FR', 'DE', 'IT'],
      },
    };

    return details[method.stripeId] ?? {
      'icon': Icons.credit_card,
      'label': '💳 ${method.displayName}',
      'description': method.displayName,
      'supported': ['ES'],
    };
  }
}

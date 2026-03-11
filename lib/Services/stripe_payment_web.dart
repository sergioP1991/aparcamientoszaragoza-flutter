/// Implementación WEB: Google Pay (Web SDK) y Apple Pay (Stripe.js) nativos.
/// 
/// - Google Pay: llama a `window.showGooglePayDirect` (Google Pay Web SDK)
/// - Apple Pay / generico: llama a `window.showStripePaymentRequest` (Stripe.js Payment Request API)
///
/// Este archivo SOLO se compila en web (importación condicional en StripeService).
library stripe_payment_web;

import 'dart:async'; // Para Completer
import 'dart:js' as js;
import 'dart:js' show allowInterop;

/// Muestra la ventana nativa de pagos de Google Pay usando el Google Pay Web SDK.
///
/// Debe llamarse DENTRO de un handler de interacción del usuario (tap/click)
/// para que el navegador permita activar el sheet de Google Pay.
///
/// Devuelve:
///   `{ 'success': true,  'paymentMethodId': 'pm_xxx' }` si el usuario paga
///   `{ 'success': false, 'error': 'cancelled' }`         si cancela
///   `{ 'success': false, 'error': 'google_pay_not_available' }` si el navegador/cuenta no lo soporta
///   `{ 'success': false, 'error': '<msg>' }`             otro error
Future<Map<String, dynamic>> showGooglePayWeb({
  required int amountInCents,
  required String currency,
  required String label,
}) async {
  try {
    print('═══════════════════════════════════════════════════════════');
    print('📡 GOOGLE PAY WEB: Iniciando flujo (ENVIRONMENT: TEST, PAN_ONLY)');
    print('═══════════════════════════════════════════════════════════');
    
    final options = js.JsObject.jsify({
      'amountInCents': amountInCents,
      'currency': currency.toLowerCase(),
      'label': label,
    });

    print('  ✓ Opciones creadas:');
    print('    • Monto: €${(amountInCents / 100).toStringAsFixed(2)}');
    print('    • Moneda: ${currency.toUpperCase()}');
    print('    • Etiqueta: $label');

    // Usar Completer para convertir callback de JS en Future de Dart
    final completer = Completer<Map<String, dynamic>>();
    var timeoutTriggered = false;
    
    // Crear callback que Dart recibirá desde JavaScript
    final dartCallback = (dynamic result) {
      print('  📢 Callback JS → Dart recibido');
      
      if (timeoutTriggered) {
        print('  ⚠️ (ignorando porque ya hubo timeout)');
        return;
      }
      
      if (result == null) {
        print('  ❌ result es null');
        completer.complete({'success': false, 'error': 'null_result'});
        return;
      }

      try {
        final bool success = result['success'] == true;
        final dynamic errorProp = result['error'];
        final dynamic pmId = result['paymentMethodId'];
        
        print('  ✓ Propiedades extraídas:');
        print('    • success: $success');
        print('    • error: $errorProp');
        print('    • paymentMethodId: $pmId');
        
        if (success) {
          print('  ✅ ÉXITO: Google Pay completed');
          completer.complete({'success': true, 'paymentMethodId': (pmId as String?) ?? ''});
        } else {
          final errMsg = (errorProp as String?) ?? 'unknown';
          print('  ❌ FALLO: $errMsg');
          
          // Analizar el error específico
          if (errMsg == 'cancelled') {
            print('     → Usuario CANCELÓ');
          } else if (errMsg.contains('OR_BIBED')) {
            print('     → ERROR OR_BIBED detectado (Google Pay / issuer declined)');
            print('     → Checklist:');
            print('        1) ¿Ves la "Test Card Suite" en el popup?');
            print('        2) Si NO: cambiar a "tarjeta real" puede ayudar');
            print('        3) Si SÍ: el problema es en el flujo de tokenización/3DS');
          }
          
          completer.complete({'success': false, 'error': errMsg});
        }
      } catch (e) {
        print('  ❌ Error extrayendo propiedades: $e');
        completer.complete({'success': false, 'error': e.toString()});
      }
    };

    // Convertir callback de Dart a JsFunction compatible con JavaScript
    final jsCallback = js.allowInterop(dartCallback);

    print('  ✓ Callback creado, llamando window.showGooglePayDirect...');
    
    // Llamar JavaScript con callback
    js.context.callMethod('showGooglePayDirect', [options, jsCallback]);
    
    print('  ✓ callMethod completó, esperando respuesta de Google Pay (120s)...');

    // Esperar a que JavaScript llame al callback
    final result = await completer.future.timeout(
      const Duration(seconds: 135),
      onTimeout: () {
        timeoutTriggered = true;
        print('  ⏱️ TIMEOUT: Google Pay no respondió en 135 segundos');
        print('     → Probable causa: Google Pay popup cerrado / error sin callback');
        return {'success': false, 'error': 'timeout'};
      },
    );
    
    print('═══════════════════════════════════════════════════════════');
    print('✅ GOOGLE PAY WEB: Finalizado, retornando a StripeService');
    print('═══════════════════════════════════════════════════════════');
    
    return result;
  } catch (e) {
    print('═══════════════════════════════════════════════════════════');
    print('❌ EXCEPCIÓN EN showGooglePayWeb');
    print('═══════════════════════════════════════════════════════════');
    print('  • Error: $e');
    print('  • Type: ${e.runtimeType}');
    return {'success': false, 'error': e.toString()};
  }
}

/// Muestra Google Pay o Apple Pay via Stripe.js Payment Request API.
/// Usar solo para Apple Pay (Safari). Para Google Pay preferir [showGooglePayWeb].
Future<Map<String, dynamic>> showGooglePayDirect({
  required int amountInCents,
  required String currency,
  required String label,
}) async {
  // Mantenido por compatibilidad; delega en showGooglePayWeb.
  return showGooglePayWeb(
    amountInCents: amountInCents,
    currency: currency,
    label: label,
  );
}

Future<Map<String, dynamic>> showNativePaymentSheet({
  required int amountInCents,
  required String currency,
  required String label,
}) async {
  try {
    final options = js.JsObject.jsify({
      'amountInCents': amountInCents,
      'currency': currency.toLowerCase(),
      'label': label,
      'country': 'ES',
    });

    // Usar Completer para callback
    final completer = Completer<Map<String, dynamic>>();
    
    final dartCallback = (dynamic result) {
      if (result == null) {
        completer.complete({'success': false, 'error': 'null_result'});
        return;
      }

      try {
        final bool success = result['success'] == true;
        if (success) {
          final dynamic pmId = result['paymentMethodId'];
          completer.complete({'success': true, 'paymentMethodId': (pmId as String?) ?? ''});
        } else {
          final dynamic error = result['error'];
          completer.complete({'success': false, 'error': (error as String?) ?? 'unknown'});
        }
      } catch (e) {
        completer.complete({'success': false, 'error': e.toString()});
      }
    };

    final jsCallback = js.allowInterop(dartCallback);
    js.context.callMethod('showStripePaymentRequest', [options, jsCallback]);

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => {'success': false, 'error': 'timeout'},
    );
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}

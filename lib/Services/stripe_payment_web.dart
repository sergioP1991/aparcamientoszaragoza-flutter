/// Implementación WEB: Google Pay (Web SDK) y Apple Pay (Stripe.js) nativos.
/// 
/// - Google Pay: llama a `window.showGooglePayDirect` (Google Pay Web SDK)
/// - Apple Pay / generico: llama a `window.showStripePaymentRequest` (Stripe.js Payment Request API)
///
/// Este archivo SOLO se compila en web (importación condicional en StripeService).
library stripe_payment_web;

import 'dart:js' as js;
import 'dart:js_util' as js_util;

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
    print('📡 LLAMADA DESDE DART A JAVASCRIPT');
    print('═══════════════════════════════════════════════════════════');
    
    final options = js.JsObject.jsify({
      'amountInCents': amountInCents,
      'currency': currency.toLowerCase(),
      'label': label,
    });

    print('  ✓ Opciones creadas:');
    print('    • amountInCents: $amountInCents');
    print('    • currency: $currency');
    print('    • label: $label');
    print('  ✓ Verificando window.showGooglePayDirect...');

    final dynamic promise =
        js.context.callMethod('showGooglePayDirect', [options]);
    
    print('  ✓ callMethod retornó: ${promise.runtimeType}');
    
    if (promise == null) {
      print('  ❌ ERROR: showGooglePayDirect no está definida en window');
      return {
        'success': false,
        'error': 'showGooglePayDirect no está definida en window',
      };
    }
    print('  ✓ Promise recibida, esperando resolución...');

    final dynamic result = await js_util.promiseToFuture<dynamic>(promise);
    print('  ✓ Promise resuelta');
    print('  ✓ Resultado: $result');
    
    final bool success =
        js_util.getProperty<dynamic>(result, 'success') == true;
    
    if (success) {
      final dynamic pmId = js_util.getProperty<dynamic>(result, 'paymentMethodId');
      print('  ✅ ÉXITO: paymentMethodId = $pmId');
      return {'success': true, 'paymentMethodId': (pmId as String?) ?? ''};
    } else {
      final dynamic error = js_util.getProperty<dynamic>(result, 'error');
      print('  ❌ ERROR RETORNADO: $error');
      return {'success': false, 'error': (error as String?) ?? 'unknown'};
    }
  } catch (e) {
    print('═══════════════════════════════════════════════════════════');
    print('❌ EXCEPCIÓN EN DART showGooglePayWeb');
    print('═══════════════════════════════════════════════════════════');
    print('  • Error: $e');
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
    // Construir el objeto de opciones como JsObject para pasarlo a JS
    final options = js.JsObject.jsify({
      'amountInCents': amountInCents,
      'currency': currency.toLowerCase(),
      'label': label,
      'country': 'ES',
    });

    // Llamar a window.showStripePaymentRequest() definida en index.html.
    // Esta llamada es SÍNCRONA con respecto al contexto de activación del usuario,
    // de modo que pr.show() (dentro del JS) hereda la activación del tap.
    final dynamic promise =
        js.context.callMethod('showStripePaymentRequest', [options]);

    if (promise == null) {
      return {
        'success': false,
        'error': 'showStripePaymentRequest no está definida en window',
      };
    }

    // Convertir la Promise de JS en un Future de Dart
    final dynamic result = await js_util.promiseToFuture<dynamic>(promise);

    final dynamic successRaw = js_util.getProperty<dynamic>(result, 'success');
    final bool success = successRaw == true;

    if (success) {
      final dynamic pmId =
          js_util.getProperty<dynamic>(result, 'paymentMethodId');
      return {'success': true, 'paymentMethodId': (pmId as String?) ?? ''};
    } else {
      final dynamic error =
          js_util.getProperty<dynamic>(result, 'error');
      return {'success': false, 'error': (error as String?) ?? 'unknown'};
    }
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}

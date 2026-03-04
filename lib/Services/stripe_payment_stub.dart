/// Stub para plataformas no-web (Android / iOS).
///
/// Google Pay y Apple Pay nativos en web usan Stripe.js Payment Request API
/// via JS interop, lo cual solo es posible en web. En móvil se usa
/// flutter_stripe con sus propios sheets nativos, por lo que este stub
/// simplemente indica que la vía web no está disponible.
library stripe_payment_stub;

Future<Map<String, dynamic>> showGooglePayWeb({
  required int amountInCents,
  required String currency,
  required String label,
}) async {
  return {'success': false, 'error': 'not_web_platform'};
}

Future<Map<String, dynamic>> showGooglePayDirect({
  required int amountInCents,
  required String currency,
  required String label,
}) async {
  return {'success': false, 'error': 'not_web_platform'};
}

Future<Map<String, dynamic>> showNativePaymentSheet({
  required int amountInCents,
  required String currency,
  required String label,
}) async {
  return {'success': false, 'error': 'not_web_platform'};
}

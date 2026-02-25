/// Stub para flutter_stripe en plataformas que no la soportan (Web)
/// 
/// Proporciona clases vacías que cumplen la interfaz de flutter_stripe
/// para que el código pueda compilar en web sin errores.

class Stripe {
  static final Stripe _instance = Stripe._();
  static String _publishableKey = '';
  
  Stripe._();
  
  static Stripe get instance => _instance;
  
  static set publishableKey(String value) {
    _publishableKey = value;
  }
  
  static String get publishableKey => _publishableKey;
  
  Future<void> confirmPaymentSheetPayment() async {
    throw UnsupportedError('Stripe no está soportado en web');
  }
  
  Future<void> initPaymentSheet({required PaymentSheetParameters parameters}) async {
    throw UnsupportedError('Stripe no está soportado en web');
  }
  
  Future<void> presentPaymentSheet() async {
    throw UnsupportedError('Stripe no está soportado en web');
  }
  
  Future<PaymentSheetPaymentOption> googlePaySheet({
    required GooglePaySheetOptions options,
  }) async {
    throw UnsupportedError('Google Pay no está soportado en web');
  }
  
  Future<PaymentSheetPaymentOption> applePaySheet({
    required ApplePaySheetOptions options,
  }) async {
    throw UnsupportedError('Apple Pay no está soportado en web');
  }
}

class StripeException implements Exception {
  final StripeError error;
  
  StripeException(this.error);
  
  @override
  String toString() => 'StripeException: ${error.message}';
}

class StripeError {
  final String? code;
  final String? message;
  
  StripeError({this.code, this.message});
}

class PaymentSheetPaymentOption {
  final String id;
  final String label;
  final String? image;

  PaymentSheetPaymentOption({
    required this.id,
    required this.label,
    this.image,
  });
}

class BillingDetails {
  final String? name;
  final String? email;
  final String? phone;
  final Address? address;

  BillingDetails({
    this.name,
    this.email,
    this.phone,
    this.address,
  });
}

class Address {
  final String? country;
  final String? state;
  final String? city;
  final String? line1;
  final String? line2;
  final String? postalCode;

  Address({
    this.country,
    this.state,
    this.city,
    this.line1,
    this.line2,
    this.postalCode,
  });
}

class CardFieldInputDetails {
  final String? number;
  final int? expiryMonth;
  final int? expiryYear;
  final String? cvc;
  final BillingDetails? billingDetails;

  CardFieldInputDetails({
    this.number,
    this.expiryMonth,
    this.expiryYear,
    this.cvc,
    this.billingDetails,
  });
}

class PaymentSheetParameters {
  final String paymentIntentClientSecret;
  final String merchantDisplayName;
  final String? applePay;
  final String? googlePay;
  final BillingDetailsCollectionConfiguration? billingDetailsCollectionConfiguration;
  
  PaymentSheetParameters({
    required this.paymentIntentClientSecret,
    required this.merchantDisplayName,
    this.applePay,
    this.googlePay,
    this.billingDetailsCollectionConfiguration,
  });
}

class BillingDetailsCollectionConfiguration {
  final bool name;
  final bool email;
  final bool phone;
  final bool address;
  
  BillingDetailsCollectionConfiguration({
    this.name = true,
    this.email = true,
    this.phone = true,
    this.address = true,
  });
}

class GooglePaySheetOptions {
  final String currencyCode;
  final String merchantCountryCode;
  final int amount;
  final String label;
  
  GooglePaySheetOptions({
    required this.currencyCode,
    required this.merchantCountryCode,
    required this.amount,
    required this.label,
  });
}

class ApplePaySheetOptions {
  final String currencyCode;
  final String merchantCountryCode;
  final int amount;
  final String label;
  
  ApplePaySheetOptions({
    required this.currencyCode,
    required this.merchantCountryCode,
    required this.amount,
    required this.label,
  });
}

enum PaymentMethodType {
  card,
  applePay,
  googlePay,
  ideal,
  bankAccount,
  epsBank,
  fpx,
  klarna,
  paypal,
  weChatPay,
  aupeBecs,
  affirm,
  alipay,
}

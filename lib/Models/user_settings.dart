import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettings {
  final String language;
  final bool reservationAlerts;
  final bool offersPromotions;
  final String theme;
  final List<String> availablePaymentMethods;

  UserSettings({
    this.language = 'es',
    this.reservationAlerts = true,
    this.offersPromotions = false,
    this.theme = 'dark',
    this.availablePaymentMethods = const [
      'card',
      'apple_pay',
      'google_pay',
      'paypal',
    ],
  });

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'reservationAlerts': reservationAlerts,
      'offersPromotions': offersPromotions,
      'theme': theme,
      'availablePaymentMethods': availablePaymentMethods,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      language: map['language'] ?? 'es',
      reservationAlerts: map['reservationAlerts'] ?? true,
      offersPromotions: map['offersPromotions'] ?? false,
      theme: map['theme'] ?? 'dark',
      availablePaymentMethods: List<String>.from(
        map['availablePaymentMethods'] ?? ['card', 'apple_pay', 'google_pay', 'paypal'],
      ),
    );
  }

  UserSettings copyWith({
    String? language,
    bool? reservationAlerts,
    bool? offersPromotions,
    String? theme,
    List<String>? availablePaymentMethods,
  }) {
    return UserSettings(
      language: language ?? this.language,
      reservationAlerts: reservationAlerts ?? this.reservationAlerts,
      offersPromotions: offersPromotions ?? this.offersPromotions,
      theme: theme ?? this.theme,
      availablePaymentMethods: availablePaymentMethods ?? this.availablePaymentMethods,
    );
  }
}

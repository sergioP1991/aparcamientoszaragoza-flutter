import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettings {
  final String language;
  final bool reservationAlerts;
  final bool offersPromotions;
  final String theme;

  UserSettings({
    this.language = 'es',
    this.reservationAlerts = true,
    this.offersPromotions = false,
    this.theme = 'dark',
  });

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'reservationAlerts': reservationAlerts,
      'offersPromotions': offersPromotions,
      'theme': theme,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      language: map['language'] ?? 'es',
      reservationAlerts: map['reservationAlerts'] ?? true,
      offersPromotions: map['offersPromotions'] ?? false,
      theme: map['theme'] ?? 'dark',
    );
  }

  UserSettings copyWith({
    String? language,
    bool? reservationAlerts,
    bool? offersPromotions,
    String? theme,
  }) {
    return UserSettings(
      language: language ?? this.language,
      reservationAlerts: reservationAlerts ?? this.reservationAlerts,
      offersPromotions: offersPromotions ?? this.offersPromotions,
      theme: theme ?? this.theme,
    );
  }
}

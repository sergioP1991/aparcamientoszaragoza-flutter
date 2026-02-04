import 'package:aparcamientoszaragoza/Models/user_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState extends StateNotifier<UserSettings> {
  SettingsState() : super(UserSettings()) {
    _loadSettings();
  }

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _loadSettings() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data.containsKey('settings')) {
            state = UserSettings.fromMap(data['settings']);
          }
        }
      } catch (e) {
        print('Error loading settings: $e');
      }
    }
  }

  Future<void> updateLanguage(String lang) async {
    state = state.copyWith(language: lang);
    await _saveSettings();
  }

  Future<void> updateReservationAlerts(bool value) async {
    state = state.copyWith(reservationAlerts: value);
    await _saveSettings();
  }

  Future<void> updateOffersPromotions(bool value) async {
    state = state.copyWith(offersPromotions: value);
    await _saveSettings();
  }

  Future<void> updateTheme(String theme) async {
    state = state.copyWith(theme: theme);
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'settings': state.toMap(),
        }, SetOptions(merge: true));
      } catch (e) {
        print('Error saving settings: $e');
      }
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsState, UserSettings>((ref) {
  return SettingsState();
});

final localeProvider = Provider<Locale>((ref) {
  final settings = ref.watch(settingsProvider);
  return Locale(settings.language);
});

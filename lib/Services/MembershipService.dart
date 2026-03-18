import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aparcamientoszaragoza/Models/membership_subscription.dart';
import 'package:flutter/foundation.dart';

class MembershipService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Obtiene la suscripción actual del usuario (stream en tiempo real)
  static Stream<MembershipSubscription?> watchUserMembership() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(null);

    return _firestore
        .collection('memberships')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            // Si no existe, crear suscripción básica por defecto
            return MembershipSubscription(
              id: userId,
              userId: userId,
              status: MembershipStatus.basic,
              createdAt: DateTime.now(),
            );
          }
          return MembershipSubscription.fromFirestore(snapshot);
        });
  }

  /// Obtiene la suscripción actual del usuario (una sola vez)
  static Future<MembershipSubscription?> getUserMembership() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    try {
      final snapshot = await _firestore.collection('memberships').doc(userId).get();
      if (!snapshot.exists) {
        return MembershipSubscription(
          id: userId,
          userId: userId,
          status: MembershipStatus.basic,
          createdAt: DateTime.now(),
        );
      }
      return MembershipSubscription.fromFirestore(snapshot);
    } catch (e) {
      debugPrint('❌ Error getting user membership: $e');
      return null;
    }
  }

  /// Verifica si el usuario actual es PRO
  static Future<bool> isUserPro() async {
    final membership = await getUserMembership();
    return membership?.isProActive ?? false;
  }

  /// Crea una nueva suscripción PRO (debe llamarse desde Cloud Function después de Stripe webhook)
  static Future<void> createProSubscription({
    required String userId,
    required MembershipPlan plan,
    required String stripeSubscriptionId,
  }) async {
    try {
      final now = DateTime.now();
      final endDate = plan == MembershipPlan.monthly
          ? now.add(const Duration(days: 30))
          : now.add(const Duration(days: 365));

      final subscription = MembershipSubscription(
        id: userId,
        userId: userId,
        status: MembershipStatus.pro,
        plan: plan,
        stripeSubscriptionId: stripeSubscriptionId,
        createdAt: now,
        startDate: now,
        endDate: endDate,
        autoRenew: true,
      );

      await _firestore
          .collection('memberships')
          .doc(userId)
          .set(subscription.toMap());

      debugPrint('✅ Pro subscription created for user: $userId');
    } catch (e) {
      debugPrint('❌ Error creating pro subscription: $e');
      rethrow;
    }
  }

  /// Cancela la suscripción PRO del usuario
  static Future<void> cancelProSubscription() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final membership = await getUserMembership();
      if (membership == null) return;

      final updated = membership.copyWith(
        status: MembershipStatus.canceled,
        canceledAt: DateTime.now(),
        autoRenew: false,
      );

      await _firestore
          .collection('memberships')
          .doc(userId)
          .update(updated.toMap());

      debugPrint('✅ Pro subscription canceled for user: $userId');
    } catch (e) {
      debugPrint('❌ Error canceling pro subscription: $e');
      rethrow;
    }
  }

  /// Reactiva una suscripción cancelada
  static Future<void> reactivateProSubscription() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final membership = await getUserMembership();
      if (membership == null) return;

      // Si ya expirό, configurar nuevas fechas
      late DateTime newEndDate;
      if (membership.isProActive) {
        // Si aun es valida, extender desde la fecha actual de expiracion
        newEndDate =
            membership.endDate!.add(const Duration(days: 30));
      } else {
        // Si expirό, usar 30 dias desde ahora
        newEndDate = DateTime.now().add(const Duration(days: 30));
      }

      final updated = membership.copyWith(
        status: MembershipStatus.pro,
        canceledAt: null,
        endDate: newEndDate,
        autoRenew: true,
      );

      await _firestore
          .collection('memberships')
          .doc(userId)
          .update(updated.toMap());

      debugPrint('✅ Pro subscription reactivated for user: $userId');
    } catch (e) {
      debugPrint('❌ Error reactivating pro subscription: $e');
      rethrow;
    }
  }

  /// Actualiza del servidor (para sincronizar con Stripe)
  static Future<void> syncMembershipWithStripe(String userId) async {
    try {
      // En un flujo real, esto llamaría a una Cloud Function
      // que verifica el estado en Stripe y actualiza Firestore
      debugPrint('📡 Syncing membership with Stripe for user: $userId');
    } catch (e) {
      debugPrint('❌ Error syncing with Stripe: $e');
      rethrow;
    }
  }

  /// Obtiene información de contacto para support (ej: ayuda con suscripción)
  static Future<void> contactSupportAboutSubscription(String message) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore.collection('support_tickets').add({
        'userId': userId,
        'userEmail': _auth.currentUser?.email,
        'type': 'membership_support',
        'message': message,
        'createdAt': Timestamp.now(),
        'resolved': false,
      });

      debugPrint('✅ Support ticket created');
    } catch (e) {
      debugPrint('❌ Error creating support ticket: $e');
      rethrow;
    }
  }
}

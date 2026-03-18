import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aparcamientoszaragoza/Models/membership_subscription.dart';
import 'package:aparcamientoszaragoza/Services/MembershipService.dart';

/// Provider que escucha los cambios de membresía del usuario en tiempo real
final membershipProvider = StreamProvider<MembershipSubscription?>((ref) {
  return MembershipService.watchUserMembership();
});

/// Notifier para actualizar membresía
final membershipNotifierProvider =
    StateNotifierProvider<MembershipNotifier, AsyncValue<MembershipSubscription?>>(
  (ref) => MembershipNotifier(),
);

class MembershipNotifier extends StateNotifier<AsyncValue<MembershipSubscription?>> {
  MembershipNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() async {
    try {
      final membership = await MembershipService.getUserMembership();
      state = AsyncValue.data(membership);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshMembership() async {
    state = const AsyncValue.loading();
    try {
      final membership = await MembershipService.getUserMembership();
      state = AsyncValue.data(membership);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> cancelSubscription() async {
    try {
      await MembershipService.cancelProSubscription();
      await refreshMembership();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> reactivateSubscription() async {
    try {
      await MembershipService.reactivateProSubscription();
      await refreshMembership();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

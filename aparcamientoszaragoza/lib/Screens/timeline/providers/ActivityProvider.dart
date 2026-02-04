import 'package:aparcamientoszaragoza/Models/history.dart';
import 'package:aparcamientoszaragoza/Services/activity_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../login/providers/UserProviders.dart';

final activityStreamProvider = StreamProvider<List<History>>((ref) {
  final user = ref.watch(loginUserProvider);
  
  return user.when(
    data: (userData) {
      if (userData != null) {
        return ActivityService.getUserActivity(
          userData.uid,
          userEmail: userData.email,
        );
      }
      return Stream.value([]);
    },
    loading: () => Stream.value([]),
    error: (err, stack) => Stream.error(err, stack),
  );
});

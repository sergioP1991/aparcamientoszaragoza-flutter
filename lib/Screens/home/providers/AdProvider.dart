import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aparcamientoszaragoza/Screens/settings/providers/settings_provider.dart';

class AdState {
  final DateTime lastAdTime;
  final int intervalMinutes;

  AdState({
    required this.lastAdTime,
    required this.intervalMinutes,
  });

  AdState copyWith({
    DateTime? lastAdTime,
    int? intervalMinutes,
  }) {
    return AdState(
      lastAdTime: lastAdTime ?? this.lastAdTime,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
    );
  }
}

//Solo hice los cambios aqui, en el tema de screnn no hice ninguna
//Es por llo de la publicidad que cuando pase X min, se reinicie el temporizador
//Y cada vez que veas uun detale de plaza y haya pasado ese temporizador, te aparezca publicidad

//Lo que queria haber hecho pero creia que haria falta llamar a lo de firebase, 
//es que en la pantalla de myLocacion, aparezcan la  ubicacion de las plazas mas cercanas
//No se si para esto hara falta la llamada o simplemente con traer a lista es suficiente

class AdNotifier extends StateNotifier<AdState> {
  final Ref ref;
  
  AdNotifier(this.ref) : super(AdState(
    lastAdTime: DateTime.now().subtract(const Duration(days: 1)), // Ensure first ad shows
    intervalMinutes: 5, // Default interval
  ));

  void setInterval(int minutes) {
    state = state.copyWith(intervalMinutes: minutes);
  }

  void resetTimer() {
    state = state.copyWith(lastAdTime: DateTime.now());
  }

  bool shouldShowAd() {
    final settings = ref.read(settingsProvider);
    
    // Don't show ads if user has disabled promotions
    if (!settings.offersPromotions) {
      return false;
    }
    
    final now = DateTime.now();
    final difference = now.difference(state.lastAdTime);
    return difference.inMinutes >= state.intervalMinutes;
  }
}

final adProvider = StateNotifierProvider<AdNotifier, AdState>((ref) {
  return AdNotifier(ref);
});

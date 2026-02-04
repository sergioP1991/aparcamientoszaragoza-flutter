import 'package:aparcamientoszaragoza/Models/history.dart';
import 'package:aparcamientoszaragoza/Screens/detailsGarage/detailsGarage_screen.dart';
import 'package:aparcamientoszaragoza/Screens/Timeline/providers/ActivityProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../Values/app_colors.dart';
import '../login/providers/UserProviders.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';

class TimelinePage extends ConsumerWidget {
  static const routeName = '/timeline-page';

  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loginUserProvider);
    final activityAsync = ref.watch(activityStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.darkerBlue,
      appBar: _buildAppBar(context, user.value),
      body: activityAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.noRecentActivity,
                style: const TextStyle(color: Colors.white54),
              ),
            );
          }

          final groupedHistory = _groupHistory(history);

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              if (groupedHistory['hoy']!.isNotEmpty) ...[
                _buildSectionHeader(context, AppLocalizations.of(context)!.todayGroup),
                ...groupedHistory['hoy']!.map((item) => _buildTimelineItem(context, item)),
              ],
              if (groupedHistory['unaSemana']!.isNotEmpty) ...[
                _buildSectionHeader(context, AppLocalizations.of(context)!.last7DaysGroup),
                ...groupedHistory['unaSemana']!.map((item) => _buildTimelineItem(context, item)),
              ],
              if (groupedHistory['mesAnterior']!.isNotEmpty) ...[
                _buildSectionHeader(context, AppLocalizations.of(context)!.previousMonthGroup),
                ...groupedHistory['mesAnterior']!.map((item) => _buildTimelineItem(context, item)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(AppLocalizations.of(context)!.genericError(err.toString()), style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  Map<String, List<History>> _groupHistory(List<History> history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = today.subtract(const Duration(days: 7));
    
    List<History> hoy = [];
    List<History> unaSemana = [];
    List<History> mesAnterior = [];

    for (var item in history) {
      if (item.fecha.isAfter(today)) {
        hoy.add(item);
      } else if (item.fecha.isAfter(sevenDaysAgo)) {
        unaSemana.add(item);
      } else {
        mesAnterior.add(item);
      }
    }

    return {
      'hoy': hoy,
      'unaSemana': unaSemana,
      'mesAnterior': mesAnterior,
    };
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, User? user) {
    return AppBar(
      backgroundColor: AppColors.darkerBlue,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.timelineTitle,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            AppLocalizations.of(context)!.userNameLabel(user?.displayName ?? 'Moises', user?.email ?? 'moises@zara...'),
            style: const TextStyle(color: Colors.white54, fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: const [],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, History item) {
    IconData icon = Icons.notifications_outlined;
    Color iconBg = Colors.blue;
    final l10n = AppLocalizations.of(context)!;
    String title = item.descripcion ?? l10n.activityLabel;
    String metaLabel = item.meta ?? l10n.spainIndicatorMeta;
    IconData metaIcon = Icons.info_outline;

    switch (item.tipo) {
      case TipoEvento.alquiler:
        icon = Icons.directions_car;
        iconBg = Colors.blue;
        metaIcon = Icons.location_on;
        break;
      case TipoEvento.registro_plaza:
        icon = Icons.add_business;
        iconBg = Colors.orange;
        metaIcon = Icons.home_work;
        break;
      case TipoEvento.perfil_actualizado:
        icon = Icons.person;
        iconBg = Colors.purple;
        metaIcon = Icons.contact_mail;
        break;
      case TipoEvento.reserva_cancelada:
        icon = Icons.close;
        iconBg = Colors.red;
        metaIcon = Icons.event_busy;
        break;
      case TipoEvento.pago_recibido:
        icon = Icons.account_balance_wallet;
        iconBg = Colors.green;
        metaIcon = Icons.monetization_on;
        break;
      case TipoEvento.registro_usuario:
        icon = Icons.person_add;
        iconBg = Colors.teal;
        metaIcon = Icons.verified_user_outlined;
        break;
      case TipoEvento.nuevo_comentario:
        icon = Icons.comment;
        iconBg = Colors.pink;
        metaIcon = Icons.star_border;
        break;
      case TipoEvento.favorito_actualizado:
        icon = Icons.favorite;
        iconBg = Colors.redAccent;
        metaIcon = Icons.stars;
        break;
      default:
        icon = Icons.notifications;
        iconBg = Colors.blueGrey;
        metaIcon = Icons.info;
    }

    return IntrinsicHeight(
      child: Row(
        children: [
          const SizedBox(width: 20),
          Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(width: 2, color: Colors.white10),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              Expanded(
                flex: 4,
                child: Container(width: 2, color: Colors.white10),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Details could be smarter based on meta/type
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 20, right: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('hh:mm a').format(item.fecha),
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(metaIcon, color: iconBg.withOpacity(0.8), size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            metaLabel,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

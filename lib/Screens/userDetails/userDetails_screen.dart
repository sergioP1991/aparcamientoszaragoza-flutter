import 'package:aparcamientoszaragoza/Screens/timeline/timeline_screen.dart';
import 'package:aparcamientoszaragoza/Screens/favorites/favorites_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/HomeProviders.dart';
import 'package:aparcamientoszaragoza/Screens/login/login_screen.dart';
import 'package:aparcamientoszaragoza/Screens/login/providers/UserProviders.dart';
import 'package:aparcamientoszaragoza/Screens/my_garages/my_garages_screen.dart';
import 'package:aparcamientoszaragoza/Screens/settings/settings_screen.dart';
import 'package:aparcamientoszaragoza/Screens/settings/help_support_screen.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';

class UserDetailScreen extends ConsumerStatefulWidget {
  static const routeName = '/user_details-page';

  const UserDetailScreen({super.key});

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final homeDataState = ref.watch(fetchHomeProvider(allGarages: true, onlyMine: false));
    final user = homeDataState.value?.user;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.darkestBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.navProfile,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProfileHeader(user),
              const SizedBox(height: 40),
              
              _buildMenuCard(
                context,
                icon: Icons.home_work_rounded,
                title: l10n.viewMyProperties,
                subtitle: l10n.manageRegisteredSpots,
                onTap: () => Navigator.pushNamed(context, MyGaragesScreen.routeName),
              ),
              const SizedBox(height: 16),
              
              _buildMenuCard(
                context,
                icon: Icons.history_rounded,
                title: l10n.checkHistory,
                subtitle: l10n.historySubtitle,
                onTap: () => Navigator.pushNamed(context, TimelinePage.routeName),
              ),
              const SizedBox(height: 16),
              
              _buildMenuCard(
                context,
                icon: Icons.favorite_rounded,
                title: l10n.favoriteSpots,
                subtitle: l10n.favoriteSubtitle,
                onTap: () => Navigator.pushNamed(context, FavoritesScreen.routeName),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: _buildGridItem(
                      context,
                      icon: Icons.settings_rounded,
                      title: l10n.settingsTitle,
                      onTap: () => Navigator.pushNamed(context, SettingsScreen.routeName),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildGridItem(
                      context,
                      icon: Icons.credit_card_rounded,
                      title: l10n.paymentMethods,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildGridItem(
                      context,
                      icon: Icons.help_outline_rounded,
                      title: l10n.helpSupport,
                      onTap: () => Navigator.pushNamed(context, HelpSupportScreen.routeName),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              _buildLogoutButton(context, ref, l10n),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryColor.withOpacity(0.3), width: 2),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.cardBackground,
                backgroundImage: (user?.photoURL != null && user!.photoURL!.isNotEmpty)
                    ? NetworkImage("https://api.allorigins.win/raw?url=${user.photoURL}")
                    : const AssetImage('assets/default_icon.png') as ImageProvider,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xff00B0FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.displayName ?? l10n.userSpecial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.homeHeaderLocation,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.userPro,
                style: TextStyle(
                  color: Color(0xff4FC3F7),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 24),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return InkWell(
      onTap: () async {
        // Mostrar diálogo de confirmación
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1F2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              l10n.logoutAction,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              '¿Estás seguro de que deseas cerrar sesión?',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xffFF5252),
                ),
                child: Text(
                  l10n.logoutAction,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );

        if (shouldLogout == true) {
          // Cerrar sesión
          await ref.read(loginUserProvider.notifier).signOut();
          
          // Invalidar providers para limpiar el estado
          ref.invalidate(loginUserProvider);
          ref.invalidate(fetchHomeProvider(allGarages: true, onlyMine: false));
          
          if (mounted) {
            // Navegar al login y eliminar todas las rutas anteriores
            Navigator.of(context).pushNamedAndRemoveUntil(
              LoginPage.routeName, 
              (route) => false,
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xff1A0F0F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xffFF5252), size: 20),
            SizedBox(width: 12),
            Text(
              l10n.logoutAction,
              style: TextStyle(
                color: Color(0xffFF5252),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

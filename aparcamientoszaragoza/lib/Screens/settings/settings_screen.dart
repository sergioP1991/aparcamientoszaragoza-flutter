import 'package:aparcamientoszaragoza/Screens/forgetPassword/ForgetPassword_screen.dart';
import 'package:aparcamientoszaragoza/Screens/settings/help_support_screen.dart';
import 'package:aparcamientoszaragoza/Screens/admin/AdminPlazasScreen.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/Screens/settings/providers/settings_provider.dart';
import 'package:aparcamientoszaragoza/Models/user_settings.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _versionTapCount = 0;
  static const int _adminTapThreshold = 5;
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
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
        title: GestureDetector(
          onTap: () {
            setState(() {
              _versionTapCount++;
            });
            if (_versionTapCount >= _adminTapThreshold) {
              _versionTapCount = 0;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔧 Panel Admin desbloqueado')),
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminPlazasScreen()),
              );
            }
          },
          child: Text(
            l10n.settingsTitle,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(l10n.preferencesSection),
            const SizedBox(height: 12),
            _buildSettingsCard(children: [
              _buildSettingsItem(
                Icons.language,
                l10n.languageItem,
                settings.language == 'es' ? l10n.spanish : l10n.english,
                onTap: () => _showLanguageDialog(context, ref),
              ),
              const Divider(color: Colors.white10),
              _buildSettingsItem(
                Icons.dark_mode, 
                l10n.themeItem, 
                settings.theme == 'light' ? l10n.lightMode : l10n.darkMode,
                onTap: () => _showThemeDialog(context, ref, settings),
              ),
            ]),

            const SizedBox(height: 32),
            _buildSectionTitle(l10n.notificationsSection),
            const SizedBox(height: 12),
            _buildSettingsCard(children: [
              _buildToggleItem(
                  Icons.notifications, l10n.reservationAlerts, settings.reservationAlerts, (val) {
                settingsNotifier.updateReservationAlerts(val);
              }),
              const Divider(color: Colors.white10),
              _buildToggleItem(
                  Icons.campaign, l10n.offersPromotions, settings.offersPromotions, (val) {
                settingsNotifier.updateOffersPromotions(val);
              }),
            ]),

            const SizedBox(height: 32),
            _buildSectionTitle(l10n.accountSection),
            const SizedBox(height: 12),
            _buildSettingsCard(children: [
              _buildSettingsItem(Icons.lock_reset_rounded, l10n.changePassword, "", onTap: () {
                Navigator.pushNamed(context, ForgetPasswordScreen.routeName);
              }),
              const Divider(color: Colors.white10),
              _buildSettingsItem(Icons.credit_card, l10n.paymentMethods, ""),
            ]),
          ],
        ),
      ),
    );
  }

void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.read(settingsProvider);
    final isDarkTheme = settings.theme == 'dark';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkTheme ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        title: Text(l10n.languageItem, style: TextStyle(color: isDarkTheme ? Colors.white : AppColors.lightText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.spanish, style: TextStyle(color: isDarkTheme ? Colors.white : AppColors.lightText)),
              onTap: () {
                ref.read(settingsProvider.notifier).updateLanguage('es');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.english, style: TextStyle(color: isDarkTheme ? Colors.white : AppColors.lightText)),
              onTap: () {
                ref.read(settingsProvider.notifier).updateLanguage('en');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

Widget _buildSectionTitle(String title) {
    final settings = ref.read(settingsProvider);
    final isDarkTheme = settings.theme == 'dark';
    
    return Text(
      title,
      style: TextStyle(
        color: isDarkTheme ? Colors.white38 : AppColors.lightSecondaryText,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, UserSettings settings) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkTheme = settings.theme == 'dark';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkTheme ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        title: Text(l10n.themeItem, style: TextStyle(color: isDarkTheme ? Colors.white : AppColors.lightText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.darkMode, style: TextStyle(color: isDarkTheme ? Colors.white : AppColors.lightText)),
              onTap: () {
                ref.read(settingsProvider.notifier).updateTheme('dark');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.lightMode, style: TextStyle(color: isDarkTheme ? Colors.white : AppColors.lightText)),
              onTap: () {
                ref.read(settingsProvider.notifier).updateTheme('light');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

Widget _buildSettingsCard({required List<Widget> children}) {
    final settings = ref.read(settingsProvider);
    final isDarkTheme = settings.theme == 'dark';
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkTheme ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 22),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            if (value.isNotEmpty)
              Text(
                value,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(IconData icon, String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
            activeTrackColor: AppColors.primaryColor.withOpacity(0.3),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }
}

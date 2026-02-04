import 'package:aparcamientoszaragoza/Screens/settings/providers/settings_provider.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HelpSupportScreen extends ConsumerWidget {
  static const routeName = '/help-support';

  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final isDark = settings.theme == 'dark';

    // Definición de colores locales para el tema
    final bgColor = isDark ? const Color(0xFF05080F) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: bgColor,
            elevation: 0,
            floating: true,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              l10n.helpSupport,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: _buildSearchBar(isDark, l10n, cardColor, textColor),
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "¿Con qué necesitas ayuda?",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Grid de Categorías
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.3,
                        children: [
                          _buildCategoryCard(Icons.person_outline, "Mi Cuenta", isDark, cardColor, textColor),
                          _buildCategoryCard(Icons.calendar_month_outlined, "Reservas", isDark, cardColor, textColor),
                          _buildCategoryCard(Icons.credit_card_outlined, "Pagos", isDark, cardColor, textColor),
                          _buildCategoryCard(Icons.build_outlined, "Técnico", isDark, cardColor, textColor),
                        ],
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  Text(
                    l10n.faqTitle,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          // Lista de FAQs
          SliverList(
            delegate: SliverChildListDelegate([
              _buildFAQTile("¿Cómo solicitar una factura?", isDark, cardColor, textColor),
              _buildFAQTile("Cambiar método de pago predeterminado", isDark, cardColor, textColor),
              _buildFAQTile("Política de cancelación", isDark, cardColor, textColor),
              _buildFAQTile("Problemas con el acceso al garaje", isDark, cardColor, textColor),
              
               const SizedBox(height: 40),
               _buildContactSection(isDark, l10n, textColor),
               const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, AppLocalizations l10n, Color cardColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.grey),
          hintText: "Buscar temas, preguntas...",
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(IconData icon, String title, bool isDark, Color cardColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
        ]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryColor, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQTile(String title, bool isDark, Color cardColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.white30 : Colors.grey),
        onTap: () {},
      ),
    );
  }
  
  Widget _buildContactSection(bool isDark, AppLocalizations l10n, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            "¿Aún necesitas ayuda?",
            style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: Text(l10n.contactUs),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}





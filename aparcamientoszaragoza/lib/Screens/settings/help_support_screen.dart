import 'package:aparcamientoszaragoza/Screens/settings/providers/settings_provider.dart';
import 'package:aparcamientoszaragoza/Screens/settings/contact_screen.dart';
import 'package:aparcamientoszaragoza/Services/faq_service.dart';
import 'package:aparcamientoszaragoza/Models/faq.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  static const routeName = '/help-support';

  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showAllFAQs = false;
  FAQCategory? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filtra las FAQs según el texto de búsqueda y categoría
  List<FAQ> _filterFAQs(List<FAQ> faqs) {
    List<FAQ> filtered = faqs;
    
    // Filtrar por categoría si hay una seleccionada
    if (_selectedCategory != null) {
      filtered = filtered.where((faq) => faq.category == _selectedCategory).toList();
    } else {
      // Si no hay categoría seleccionada, mostrar solo las generales
      filtered = filtered.where((faq) => faq.category == FAQCategory.general).toList();
    }
    
    // Filtrar por texto de búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      // Cuando hay búsqueda, buscar en todas las categorías
      filtered = faqs.where((faq) {
        return faq.question.toLowerCase().contains(query) ||
               faq.answer.toLowerCase().contains(query);
      }).toList();
    }
    
    return filtered;
  }

  /// Obtiene el título de la categoría seleccionada
  String _getCategoryTitle() {
    switch (_selectedCategory) {
      case FAQCategory.account:
        return 'Mi Cuenta';
      case FAQCategory.bookings:
        return 'Reservas';
      case FAQCategory.payments:
        return 'Pagos';
      case FAQCategory.technical:
        return 'Técnico';
      default:
        return 'Preguntas Frecuentes';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final faqsAsync = ref.watch(faqsProvider);
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
                child: _buildSearchBar(isDark, l10n, cardColor, textColor, _searchController, (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                }),
              ),
            ),
          ),
          
          // Título de FAQs con botón de volver si hay categoría seleccionada
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  if (_selectedCategory != null)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = null;
                          _showAllFAQs = false;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      _getCategoryTitle(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Lista de FAQs (máximo 3 o todas si está expandido)
          faqsAsync.when(
            data: (faqs) {
              final filteredFAQs = _filterFAQs(faqs);
              if (filteredFAQs.isEmpty && _searchQuery.isNotEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: isDark ? Colors.white38 : Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No se encontraron resultados para "$_searchQuery"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              
              // Mostrar solo 3 FAQs o todas según el estado
              final displayFAQs = _showAllFAQs || _searchQuery.isNotEmpty
                  ? filteredFAQs
                  : filteredFAQs.take(3).toList();
              final hasMoreFAQs = filteredFAQs.length > 3 && _searchQuery.isEmpty;
              
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Último elemento: botón "Ver más" o "Ver menos"
                    if (index == displayFAQs.length && hasMoreFAQs) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _showAllFAQs = !_showAllFAQs;
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _showAllFAQs ? "Ver menos" : "Ver más (${filteredFAQs.length - 3} más)",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _showAllFAQs ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final faq = displayFAQs[index];
                    return _buildFAQTile(context, faq.question, faq.answer, isDark, cardColor, textColor);
                  },
                  childCount: displayFAQs.length + (hasMoreFAQs ? 1 : 0),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              )),
            ),
            error: (err, stack) => SliverToBoxAdapter(
              child: Center(child: Text("Error: $err")),
            ),
          ),
          
          // Sección de categorías (solo visible si no hay categoría seleccionada)
          if (_selectedCategory == null && _searchQuery.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
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
                          _buildCategoryCard(Icons.person_outline, "Mi Cuenta", FAQCategory.account, isDark, cardColor, textColor),
                          _buildCategoryCard(Icons.calendar_month_outlined, "Reservas", FAQCategory.bookings, isDark, cardColor, textColor),
                          _buildCategoryCard(Icons.credit_card_outlined, "Pagos", FAQCategory.payments, isDark, cardColor, textColor),
                          _buildCategoryCard(Icons.build_outlined, "Técnico", FAQCategory.technical, isDark, cardColor, textColor),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Sección de contacto
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildContactSection(isDark, l10n, textColor),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, AppLocalizations l10n, Color cardColor, Color textColor, TextEditingController controller, ValueChanged<String> onChanged) {
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
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.grey),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: isDark ? Colors.white54 : Colors.grey),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          hintText: "Buscar temas, preguntas...",
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(IconData icon, String title, FAQCategory category, bool isDark, Color cardColor, Color textColor) {
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
          onTap: () {
            setState(() {
              _selectedCategory = category;
              _showAllFAQs = false;
            });
          },
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

  Widget _buildFAQTile(BuildContext context, String title, String answer, bool isDark, Color cardColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(title, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
          trailing: Icon(Icons.keyboard_arrow_down, size: 20, color: isDark ? Colors.white30 : Colors.grey),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  answer,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
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
              onPressed: () {
                Navigator.of(context).pushNamed(ContactScreen.routeName);
              },
            ),
          ),
        ],
      ),
    );
  }
}





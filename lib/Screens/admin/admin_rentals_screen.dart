import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/Services/RentalByHoursService.dart';
import 'package:aparcamientoszaragoza/Screens/admin/admin_plazas_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/HomeProviders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRentalsScreen extends ConsumerStatefulWidget {
  static const routeName = '/admin-rentals';

  const AdminRentalsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminRentalsScreen> createState() => _AdminRentalsScreenState();
}

class _AdminRentalsScreenState extends ConsumerState<AdminRentalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;
  int _releasedCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _releaseAllRentals() async {
    setState(() {
      _isLoading = true;
      _message = null;
      _isSuccess = false;
      _releasedCount = 0;
    });

    try {
      // Obtener todos los alquileres activos de Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('alquileres')
          .where('tipo', isEqualTo: 2) // tipo 2 = alquiler por horas
          .get();

      debugPrint('🔍 Encontrados ${snapshot.docs.length} alquileres para liberar');

      int releasedCount = 0;

      // Liberar cada alquiler usando método admin (sin verificación de propiedad)
      for (var doc in snapshot.docs) {
        try {
          debugPrint('📋 Liberando alquiler: ${doc.id}');
          await RentalByHoursService.releaseRentalAsAdmin(doc.id);
          releasedCount++;
          debugPrint('✅ Alquiler liberado: ${doc.id}');
        } catch (e) {
          debugPrint('⚠️ Error liberando ${doc.id}: $e');
        }
      }

      // ⏳ Esperar a que Firestore se actualice
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _message = '✅ $releasedCount alquileres liberados exitosamente';
        _releasedCount = releasedCount;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_message!),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // 🔄 Refrescar los providers del Home para actualizar estado de plazas
        ref.refresh(fetchHomeProvider(allGarages: true, onlyMine: false));
        ref.refresh(fetchHomeProvider(allGarages: true, onlyMine: true));
      }
    } catch (e) {
      debugPrint('❌ Error liberando alquileres: $e');
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _message = '❌ Error: ${e.toString()}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _confirmReleaseAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBlue,
        title: const Text(
          '⚠️ Liberar Todos los Alquileres',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Esto liberará TODOS los alquileres activos en la aplicación.\n\n'
          'Todas las plazas volverán a estar disponibles.\n\n'
          '¿Estás seguro?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _releaseAllRentals();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Liberar Todo',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        title: const Text('🔐 Panel Admin'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryColor,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(
              icon: Icon(Icons.receipt),
              text: 'Alquileres',
            ),
            Tab(
              icon: Icon(Icons.business_outlined),
              text: 'Plazas',
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.darkCardBackground,
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Gestión de Alquileres
          _buildRentalsTab(),
          
          // TAB 2: Gestión de Plazas
          const AdminPlazasScreen(),
        ],
      ),
    );
  }

  Widget _buildRentalsTab() {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const Text(
              'Panel de Administración',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '⚙️ Herramientas de desarrollo y testing',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // Sección: Resetear Alquileres
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.delete_sweep, color: Colors.red, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Liberar Todos los Alquileres',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Marca todos los alquileres activos como liberados.\n'
                    'Esto hará que todas las plazas vuelvan a estar disponibles.\n\n'
                    '⚠️ Acción irreversible - Usar solo para testing/development',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _confirmReleaseAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              '🔄 Liberar Todos',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Resultado de la operación
            if (_message != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  border: Border.all(
                    color: _isSuccess
                        ? Colors.green.withOpacity(0.5)
                        : Colors.orange.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _message!,
                      style: TextStyle(
                        color:
                            _isSuccess ? Colors.green[300] : Colors.orange[300],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_releasedCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '✅ Alquileres liberados: $_releasedCount',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 32),

            // Información adicional
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                border: Border.all(color: Colors.blue.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '📋 Información',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Esta función libera alquileres localmente\n'
                    '• Busca todos los alquileres con estado "activo"\n'
                    '• Los marca como "liberado" con timestamp actual\n'
                    '• Cálcula precio final según tiempo usado\n'
                    '• Solo disponible en modo desarrollo/admin',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
}
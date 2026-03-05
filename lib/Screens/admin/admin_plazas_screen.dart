import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/Screens/registerGarage/registerGarage.dart';
import 'package:aparcamientoszaragoza/Screens/registerGarage/providers/RegisterGarageProviders.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';

class AdminPlazasScreen extends StatefulWidget {
  static const routeName = '/admin-plazas';

  const AdminPlazasScreen({Key? key}) : super(key: key);

  @override
  State<AdminPlazasScreen> createState() => _AdminPlazasScreenState();
}

class _AdminPlazasScreenState extends State<AdminPlazasScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showOnlyOccupied = false;
  bool _showOnlyMine = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deletePlaza(Garaje garaje) async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBlue,
        title: Text(
          '⚠️ Borrar Plaza',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'Vas a borrar la plaza en ${garaje.direccion}\n\n'
          'Esta acción no se puede deshacer.\n\n'
          '¿Estás seguro?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancelAction,
              style: const TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
            ),
            child: Text(
              l10n.deleteAction,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && garaje.docId != null && mounted) {
      try {
        await GarajeProvider().deleteGaraje(garaje.docId!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Plaza eliminada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _editPlaza(Garaje garaje) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterGarage(garageToEdit: garaje),
      ),
    );
  }

  void _viewRentals(Garaje garaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBlue,
        title: Text(
          'Alquileres - ${garaje.direccion}',
          style: const TextStyle(color: Colors.white),
        ),
        content: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('alquileres')
              .where('idPlaza', isEqualTo: garaje.idPlaza)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text(
                'No hay alquileres para esta plaza',
                style: TextStyle(color: Colors.white70),
              );
            }

            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final rental = snapshot.data!.docs[index];
                  final estado = rental['estado'] ?? 'desconocido';
                  final tipo = rental['tipo'] ?? 'normal';
                  final tiempoInicio = rental['tiempoInicio'] != null
                      ? (rental['tiempoInicio'] as Timestamp).toDate()
                      : null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID: ${rental.id}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Estado: $estado',
                          style: TextStyle(
                            color: estado == 'activo'
                                ? Colors.green
                                : Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (tiempoInicio != null)
                          Text(
                            'Inicio: ${tiempoInicio.toString().split('.')[0]}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        title: const Text(
          '🏢 Admin - Gestión de Plazas',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Container(
        color: AppColors.darkBlue,
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.darkBlue,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por dirección...',
                      hintStyle: TextStyle(color: Colors.white30),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primaryColor,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryColor.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() => _searchQuery = value.toLowerCase());
                    },
                  ),
                  const SizedBox(height: 12),
                  // Filter Chips
                  Row(
                    children: [
                      FilterChip(
                        label: const Text('Solo Ocupadas'),
                        selected: _showOnlyOccupied,
                        onSelected: (selected) {
                          setState(() => _showOnlyOccupied = selected);
                        },
                        backgroundColor: Colors.white.withOpacity(0.1),
                        selectedColor: AppColors.primaryColor.withOpacity(0.7),
                        labelStyle: TextStyle(
                          color: _showOnlyOccupied
                              ? Colors.black
                              : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterGarage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Nueva Plaza'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Plazas List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('garaje')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay plazas registradas',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  final allPlazas = snapshot.data!.docs
                      .map((doc) => Garaje.fromFirestore(
                          doc as DocumentSnapshot<Map<String, dynamic>>))
                      .toList();

                  // Apply filters
                  final filteredPlazas = allPlazas.where((plaza) {
                    final matchesSearch = _searchQuery.isEmpty ||
                        plaza.direccion
                            .toLowerCase()
                            .contains(_searchQuery);

                    final matchesOccupied = !_showOnlyOccupied ||
                        (plaza.alquiler != null);

                    return matchesSearch && matchesOccupied;
                  }).toList();

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPlazas.length,
                    itemBuilder: (context, index) {
                      final plaza = filteredPlazas[index];
                      final isOccupied = plaza.alquiler != null;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: isOccupied
                                ? AppColors.accentRed.withOpacity(0.5)
                                : AppColors.accentGreen.withOpacity(0.5),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: Direction + Status
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plaza.direccion,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'ID Plaza: ${plaza.idPlaza}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isOccupied
                                        ? AppColors.accentRed.withOpacity(0.2)
                                        : AppColors.accentGreen.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isOccupied ? '🔴 Ocupada' : '🟢 Disponible',
                                    style: TextStyle(
                                      color: isOccupied
                                          ? AppColors.accentRed
                                          : AppColors.accentGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Details Grid
                            GridView.count(
                              crossAxisCount: 3,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: 1.2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              children: [
                                _buildDetailCard(
                                  '💰',
                                  '${plaza.precio}€/h',
                                  'Precio',
                                ),
                                _buildDetailCard(
                                  '📏',
                                  '${plaza.ancho}m × ${plaza.largo}m',
                                  'Tamaño',
                                ),
                                _buildDetailCard(
                                  '🏢',
                                  'Planta ${plaza.planta}',
                                  'Ubicación',
                                ),
                                _buildDetailCard(
                                  plaza.esCubierto ? '🏠' : '☀️',
                                  plaza.esCubierto ? 'Cubierta' : 'Abierta',
                                  'Tipo',
                                ),
                                _buildDetailCard(
                                  '🚗',
                                  plaza.vehicleType.name,
                                  'Vehículo',
                                ),
                                _buildDetailCard(
                                  plaza.rentIsNormal ? '📅' : '🎫',
                                  plaza.rentIsNormal ? 'Normal' : 'Especial',
                                  'Alquiler',
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _editPlaza(plaza),
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Editar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _viewRentals(plaza),
                                    icon: const Icon(Icons.list),
                                    label: const Text('Alquileres'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.primaryColor.withOpacity(0.7),
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _deletePlaza(plaza),
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Borrar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentRed,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

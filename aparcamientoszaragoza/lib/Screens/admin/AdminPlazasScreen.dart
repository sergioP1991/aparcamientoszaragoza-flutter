import 'package:flutter/material.dart';
import 'package:aparcamientoszaragoza/Services/PlazaCoordinatesUpdater.dart';

/// Pantalla de administración para actualizar coordenadas de plazas
/// Acceder: Agregué un botón oculto en la pantalla de settings (click en versión 5 veces)
class AdminPlazasScreen extends StatefulWidget {
  const AdminPlazasScreen({super.key});

  @override
  State<AdminPlazasScreen> createState() => _AdminPlazasScreenState();
}

class _AdminPlazasScreenState extends State<AdminPlazasScreen> {
  bool _isUpdating = false;
  final List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add(message);
    });
    // Auto-scroll al final
    Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _updateAllCoordinates() async {
    setState(() {
      _isUpdating = true;
      _logs.clear();
    });

    _addLog('🔄 Iniciando actualización de coordenadas...\n');

    try {
      final resultado = await PlazaCoordinatesUpdater.updateAllPlazas(
        onProgress: _addLog,
      );

      _addLog('\n✅ Proceso completado');
      _addLog(
          'Total: ${resultado['total']} | Actualizadas: ${resultado['updated']} | No encontradas: ${resultado['notFound']} | Errores: ${resultado['errors']}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Actualización completada: ${resultado['updated']} plazas'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _addLog('\n❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _checkInvalidCoordinates() async {
    _addLog('🔍 Buscando coordenadas inválidas...\n');

    try {
      final invalid = await PlazaCoordinatesUpdater.getInvalidCoordinates();

      if (invalid.isEmpty) {
        _addLog('✅ Todas las coordenadas son válidas');
      } else {
        _addLog('⚠️ Se encontraron ${invalid.length} plazas con coordenadas inválidas:\n');

        for (final item in invalid) {
          _addLog(
              'ID: ${item['id']} | ${item['direccion']}\n   Lat: ${item['latitud']}, Lon: ${item['longitud']}\n');
        }
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Coordenadas de Plazas'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Column(
        children: [
          // Botones de acción
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _isUpdating ? null : _updateAllCoordinates,
                  icon: const Icon(Icons.update),
                  label: const Text('Actualizar Coordenadas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _isUpdating ? null : _checkInvalidCoordinates,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar Inválidas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    disabledBackgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          // Indicador de progreso
          if (_isUpdating) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  const Text('Actualizando...'),
                ],
              ),
            ),
          ],

          // Logs
          Expanded(
            child: Container(
              color: Colors.grey.shade900,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    _logs.join('\n'),
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 12,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Información
          Container(
            color: Colors.blue.shade50,
            padding: const EdgeInsets.all(12),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '📍 Información de Coordenadas:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• Las plazas se actualizan basándose en la dirección\n'
                  '• Se validan coordenadas dentro de Zaragoza (41.0-42.0 lat, -1.5 a -0.5 lon)\n'
                  '• Mapa se recargará automáticamente tras actualización',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

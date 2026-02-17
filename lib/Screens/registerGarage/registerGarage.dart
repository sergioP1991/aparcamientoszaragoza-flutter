import 'package:aparcamientoszaragoza/Screens/Timeline/timeline_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/home_screen.dart';
import 'package:aparcamientoszaragoza/Screens/userDetails/userDetails_screen.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;

import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Screens/login/providers/UserProviders.dart';
import 'package:aparcamientoszaragoza/Models/municipio.dart';
import 'package:aparcamientoszaragoza/Models/codigo_postal.dart';
import 'providers/RegisterGarageProviders.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/ConfigurationProvider.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/HomeProviders.dart';
import 'package:aparcamientoszaragoza/Models/comunidad.dart';
import 'package:aparcamientoszaragoza/Models/provincia.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';

ImageProvider _getImageProvider(String path) {
  if (kIsWeb) {
    return NetworkImage(path);
  } else {
    return FileImage(io.File(path));
  }
}

class RegisterGarage extends ConsumerStatefulWidget {

  static const routeName = '/register-garage';
  final Garaje? garageToEdit;

  const RegisterGarage({super.key, this.garageToEdit});

  @override
  _RegisterGarageState createState() => _RegisterGarageState();
}

class _RegisterGarageState extends ConsumerState<RegisterGarage> {
  final _formKey = GlobalKey<FormState>();
  String textoInfo = "";
  String _locationErrorMessage = '';

  TextEditingController _direccionController = TextEditingController();
  TextEditingController _latitudController = TextEditingController();
  TextEditingController _longitudController = TextEditingController();

  Comunidad? _selectedComunidad;
  Provincia? _selectedProvincia;
  Municipio? _selectedMunicipio;
  CodigoPostalApp? _selectedCP;

  TextEditingController _largoController = TextEditingController(text: "5.0");
  TextEditingController _anchoController = TextEditingController(text: "2.5");
  TextEditingController _plantaController = TextEditingController(text: "-1");

  bool _isAlquilerEspecial = false;
  TextEditingController _precioController = TextEditingController(text: "60.00");

  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  String _selectedVehicle = "Coche G.";
  bool _esCubierto = true;

  @override
  void initState() {
    super.initState();
    if (widget.garageToEdit != null) {
      final g = widget.garageToEdit!;
      _direccionController.text = g.direccion;
      _latitudController.text = g.latitud.toString();
      _longitudController.text = g.longitud.toString();
      _largoController.text = g.largo.toString();
      _anchoController.text = g.ancho.toString();
      _plantaController.text = g.planta.toString();
      _precioController.text = g.precio.toString();
      _isAlquilerEspecial = !g.rentIsNormal;
      _esCubierto = g.esCubierto;
      _imagePath = g.imagen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Update selected vehicle label to localized version if it was set during edit
    if (widget.garageToEdit != null && (_direccionController.text == widget.garageToEdit!.direccion || _direccionController.text.isEmpty)) {
      switch (widget.garageToEdit!.vehicleType) {
        case VehicleType.moto:
          _selectedVehicle = l10n.vehicleMoto;
          break;
        case VehicleType.cochePequeno:
          _selectedVehicle = l10n.vehicleSmallCar;
          break;
        case VehicleType.cocheGrande:
          _selectedVehicle = l10n.vehicleLargeCar;
          break;
        case VehicleType.furgoneta:
          _selectedVehicle = l10n.vehicleVan;
          break;
      }
    } else if (widget.garageToEdit == null && _selectedVehicle == "Coche G.") {
      _selectedVehicle = l10n.vehicleLargeCar;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(configurationProvider).comunidades.isEmpty) {
        ref.read(configurationProvider.notifier).fetchComunidades();
      }
    });
    return Scaffold(
      backgroundColor: AppColors.darkestBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.garageToEdit != null ? l10n.modifyGarageTitle : l10n.registerGarageTitle,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white54, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: AppColors.darkestBlue,
        child: SafeArea(child: _buildSubmitButton(l10n)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(l10n.multimediaSection),
              _buildPhotoUploadArea(l10n),
              const SizedBox(height: 30),

              _buildSectionTitle(l10n.locationSection),
              _buildTextField(
                controller: _direccionController,
                hintText: l10n.addressHint,
                label: l10n.addressLabel,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final configState = ref.watch(configurationProvider);
                        return _buildDropdown<Comunidad>(
                          value: _selectedComunidad,
                          hint: l10n.comunidadHint,
                          label: l10n.comunidadLabel,
                          items: configState.comunidades,
                          itemLabel: (c) => c.nombre,
                          onChanged: (Comunidad? newValue) {
                            setState(() {
                              _selectedComunidad = newValue;
                              _selectedProvincia = null;
                            });
                            if (newValue != null) {
                              ref.read(configurationProvider.notifier).fetchProvincia(newValue.ccom);
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                     child: Consumer(
                      builder: (context, ref, child) {
                        final configState = ref.watch(configurationProvider);
                        return _buildDropdown<Provincia>(
                          value: _selectedProvincia,
                          hint: l10n.provinciaHint,
                          label: l10n.provinciaLabel,
                          items: configState.provincia, // uses 'provincia' list from state
                          itemLabel: (p) => p.nombre,
                          onChanged: (Provincia? newValue) {
                            setState(() {
                              _selectedProvincia = newValue;
                              _selectedMunicipio = null;
                              _selectedCP = null;
                            });
                            if (newValue != null) {
                              ref.read(configurationProvider.notifier).fetchMunicipio(newValue.cpro);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 1,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final configState = ref.watch(configurationProvider);
                        return _buildDropdown<Municipio>(
                          value: _selectedMunicipio,
                          hint: l10n.municipioHint,
                          label: l10n.municipioLabel,
                          items: configState.municipio,
                          itemLabel: (m) => m.nombre,
                          onChanged: (Municipio? newValue) {
                            setState(() {
                              _selectedMunicipio = newValue;
                              _selectedCP = null;
                            });
                            if (newValue != null && _selectedProvincia != null) {
                              ref.read(configurationProvider.notifier).fetchCP(
                                _selectedProvincia!.cpro,
                                newValue.cmum,
                                "", // Passing empty string for Nucleo
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 1,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final configState = ref.watch(configurationProvider);
                        // Filter unique CPs to avoid duplicates if any
                        final uniqueCPs = configState.cps.fold<Map<String, CodigoPostalApp>>({}, (map, cp) {
                          map[cp.codigoPostal] = cp;
                          return map;
                        }).values.toList();
                        
                        return _buildDropdown<CodigoPostalApp>(
                          value: _selectedCP,
                          hint: "50001",
                          label: l10n.cpLabel,
                          items: uniqueCPs,
                          itemLabel: (cp) => cp.codigoPostal,
                          onChanged: (CodigoPostalApp? newValue) {
                            setState(() {
                              _selectedCP = newValue;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                   width: 160,
                   height: 50,
                   child: ElevatedButton.icon(
                      onPressed: _getLocation,
                      icon: const Icon(Icons.near_me, color: Colors.white, size: 18),
                      label: Text(l10n.getGps, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                ),
              ),
              const SizedBox(height: 16),
              _buildMapPreview(l10n),
              const SizedBox(height: 25),
              Text(
                l10n.manualLocationHint,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildCoordsField(_latitudController, "41.6488")),
                  const SizedBox(width: 15),
                  Expanded(child: _buildCoordsField(_longitudController, "-0.8891")),
                ],
              ),
              const SizedBox(height: 35),

              _buildSectionTitle(l10n.measuresSection),
              Row(
                children: [
                  Expanded(child: _buildTextField(controller: _largoController, hintText: "5.0", label: l10n.lengthLabel)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(controller: _anchoController, hintText: "2.5", label: l10n.widthLabel)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(controller: _plantaController, hintText: "-1", label: l10n.floorLabel)),
                ],
              ),
              const SizedBox(height: 35),

              _buildSectionTitle(l10n.vehicleTypeSection),
              _buildVehicleGrid(l10n),
              const SizedBox(height: 16),
              _buildCoveredToggle(l10n),
              const SizedBox(height: 35),

              _buildSectionTitle(l10n.conditionsSection),
              _buildConditionsToggle(l10n),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _precioController,
                hintText: "60.00",
                label: l10n.priceLabel,
                suffixText: "€",
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required String label,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: Text(hint, style: const TextStyle(color: Colors.white24, fontSize: 15)),
              isExpanded: true,
              dropdownColor: AppColors.darkBlue,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
              items: items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? label,
    String? suffixText,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        ),

        TextField(
          controller: controller,
          readOnly: readOnly,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 15),
            filled: true,
            fillColor: AppColors.cardBackground.withOpacity(0.4),
            suffixText: suffixText,
            suffixStyle: const TextStyle(color: Colors.white38, fontSize: 16),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryColor, width: 1)),
          ),
        ),
      ],
    );
  }

  Widget _buildCoordsField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: AppColors.cardBackground.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Validation Logic
          String? missingField;
          if (_imagePath == null) {
            missingField = l10n.photoField;
          } else if (_direccionController.text.trim().isEmpty) {
            missingField = l10n.addressLabel;
          } else if (_selectedComunidad == null) {
            missingField = l10n.comunidadLabel;
          } else if (_selectedProvincia == null) {
            missingField = l10n.provinciaLabel;
          } else if (_selectedMunicipio == null) {
            missingField = l10n.municipioLabel;
          } else if (_selectedCP == null) {
            missingField = l10n.cpLabel;
          } else if (_largoController.text.trim().isEmpty) {
            missingField = l10n.lengthLabel;
          } else if (_anchoController.text.trim().isEmpty) {
            missingField = l10n.widthLabel;
          } else if (_plantaController.text.trim().isEmpty) {
            missingField = l10n.floorLabel;
          } else if (_precioController.text.trim().isEmpty) {
            missingField = l10n.priceLabel;
          }

          if (missingField != null) {
            _showWarningDialog(missingField, l10n);
            return;
          }

          if (_formKey.currentState!.validate()) {
            final user = ref.read(loginUserProvider).value;
            if (user == null) return;

            final garageData = Garaje(
              widget.garageToEdit?.idPlaza ?? DateTime.now().millisecondsSinceEpoch,
              _direccionController.text,
              _selectedCP?.codigoPostal ?? widget.garageToEdit?.CodigoPostal ?? "50001",
              _selectedProvincia?.nombre ?? widget.garageToEdit?.Provincia ?? "Zaragoza",
              double.tryParse(_latitudController.text) ?? 41.6488,
              double.tryParse(_longitudController.text) ?? -0.8891,
              double.tryParse(_anchoController.text) ?? 2.5,
              double.tryParse(_largoController.text) ?? 5.0,
              int.tryParse(_plantaController.text) ?? -1,
              _selectedVehicle == l10n.vehicleMoto 
                ? VehicleType.moto 
                : _selectedVehicle == l10n.vehicleSmallCar 
                  ? VehicleType.cochePequeno 
                  : _selectedVehicle == l10n.vehicleLargeCar 
                    ? VehicleType.cocheGrande 
                    : VehicleType.furgoneta,
              widget.garageToEdit?.alquiler,
              user.uid,
              !_isAlquilerEspecial,
              int.tryParse(_precioController.text.replaceAll(".00", "")) ?? 60,
              _esCubierto,
              widget.garageToEdit?.comments ?? [],
              imagen: _imagePath,
              docId: widget.garageToEdit?.docId,
            );

            if (widget.garageToEdit != null) {
              await GarajeProvider().updateGaraje(widget.garageToEdit!.docId!, garageData);
            } else {
              await GarajeProvider().addGaraje(garageData);
            }
            
            // Refrescar listado de la Home (forzando ambos casos para seguridad)
            ref.refresh(fetchHomeProvider(allGarages: true, onlyMine: false));
            ref.refresh(fetchHomeProvider(allGarages: true, onlyMine: true));
            
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(widget.garageToEdit != null ? l10n.successModify : l10n.successRegister)),
              );
            }
          }
        },
        icon: Icon(widget.garageToEdit != null ? Icons.edit : Icons.save, color: Colors.white, size: 20),
        label: Text(widget.garageToEdit != null ? l10n.modifyButton : l10n.registerButton, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
          shadowColor: AppColors.primaryColor.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildVehicleGrid(AppLocalizations l10n) {
    final types = [
      {'label': l10n.vehicleMoto, 'icon': Icons.motorcycle},
      {'label': l10n.vehicleSmallCar, 'icon': Icons.directions_car},
      {'label': l10n.vehicleLargeCar, 'icon': Icons.directions_bus_filled},
      {'label': l10n.vehicleVan, 'icon': Icons.local_shipping},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: types.map((type) {
        bool isSelected = _selectedVehicle == type['label'];
        return GestureDetector(
          onTap: () => setState(() => _selectedVehicle = type['label'] as String),
          child: Container(
            width: (MediaQuery.of(context).size.width - 52) / 2,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor : AppColors.cardBackground.withOpacity(0.4),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(type['icon'] as IconData, color: isSelected ? Colors.white : Colors.white70, size: 22),
                const SizedBox(width: 12),
                Text(
                  type['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70, 
                    fontSize: 15, 
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConditionsToggle(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.4),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user, color: AppColors.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.specialRentLabel, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(l10n.specialRentSubtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _isAlquilerEspecial,
            onChanged: (val) => setState(() => _isAlquilerEspecial = val),
            activeColor: AppColors.primaryColor,
            activeTrackColor: AppColors.primaryColor.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildCoveredToggle(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.4),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.roofing, color: AppColors.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.coveredLabel, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(l10n.coveredSubtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _esCubierto,
            onChanged: (val) => setState(() => _esCubierto = val),
            activeColor: AppColors.primaryColor,
            activeTrackColor: AppColors.primaryColor.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview(AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Stack(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black26,
              image: DecorationImage(
                image: AssetImage('assets/map_placeholder.png'), // Or real GoogleMap if implemented
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
            child: Center(
              child: Icon(Icons.location_on, color: AppColors.primaryColor, size: 40),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.add, color: Colors.white70, size: 20),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
              child: Text(l10n.homeHeaderLocation, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadArea(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10, style: BorderStyle.solid), // Dash effect usually needs CustomPainter
          image: _imagePath != null
              ? DecorationImage(image: _getImageProvider(_imagePath!), fit: BoxFit.cover)
              : null,
        ),
        child: _imagePath == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.image_outlined, color: AppColors.primaryColor, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.exploreImages,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(l10n.photoDetailHint, style: const TextStyle(color: Colors.white24, fontSize: 12)),
                ],
              )
            : Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _getLocation() async {
    try {
      final Position? position = await _getCurrentLocation();
      if (position != null) {
        setState(() {
          _latitudController.text = position.latitude.toStringAsFixed(4);
          _longitudController.text = position.longitude.toStringAsFixed(4);
          _locationErrorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _longitudController.text = '';
        _latitudController.text = '';
        _locationErrorMessage = e.toString();
      });
      print('Error al obtener la ubicación: $e');
    }
  }

  Future<Position?> _getCurrentLocation() async {
    LocationPermission permission;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(AppLocalizations.of(context)!.locationServicesDisabled);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(AppLocalizations.of(context)!.locationPermissionsDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          AppLocalizations.of(context)!.locationPermissionsPermanentlyDenied);
    }

    return await Geolocator.getCurrentPosition();
  }

  void _showWarningDialog(String fieldName, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 28),
            const SizedBox(width: 12),
            Text(l10n.missingFieldTitle, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          l10n.missingFieldMessage(fieldName),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.okAction, style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

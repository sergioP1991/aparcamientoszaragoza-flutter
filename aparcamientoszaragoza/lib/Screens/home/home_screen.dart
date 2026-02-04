import 'package:aparcamientoszaragoza/Screens/Timeline/timeline_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/ConfigurationProvider.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/HomeProviders.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/LocationProvider.dart';
import 'package:aparcamientoszaragoza/Screens/login/login_screen.dart';
import 'package:aparcamientoszaragoza/Screens/registerGarage/registerGarage.dart';
import 'package:aparcamientoszaragoza/Screens/userDetails/userDetails_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aparcamientoszaragoza/Screens/ad/ad_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/AdProvider.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aparcamientoszaragoza/Models/configurationApp.dart';
import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/ModelsUI/homeData.dart';
import 'package:aparcamientoszaragoza/Screens/detailsGarage/detailsGarage_screen.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';

import 'components/listGarages.dart' as listGarages;
import 'components/configuration.dart' as configuration;
import 'components/myLocation.dart' as myLocation;

enum _ScafollState {listado, localizacion, modificacion }

class HomePage extends ConsumerStatefulWidget {
  static const routeName = '/home-page';
  final String title;
  final int adIntervalMinutes;
  final bool showOnlyMine;

  HomePage({super.key, this.title = "", this.adIntervalMinutes = 2, this.showOnlyMine = false});

  @override
  ConsumerState<HomePage> createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {

  late _ScafollState stateHome;
  late ConfigurationApp configurationState;

  // Filter/Sort State
  String? _priceSort; // 'asc', 'desc', null
  VehicleType? _vehicleFilter;
  String? _statusFilter; // 'libre', 'ocupado', null
  bool _favoritesFilter = false;
  bool _onlyMineFilter = false;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();

     configurationState = ConfigurationApp();
    stateHome = _ScafollState.listado;
    
    // Set interval on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adProvider.notifier).setInterval(widget.adIntervalMinutes);
    });
  }

  void _navigateToDetails(int idPlaza) async {
    final adNotifier = ref.read(adProvider.notifier);
    if (adNotifier.shouldShowAd()) {
      await Navigator.of(context).pushNamed(AdScreen.routeName);
      adNotifier.resetTimer();
    }
    Navigator.of(context).pushNamed(DetailsGarajePage.routeName, arguments: idPlaza);
  }

  @override
  Widget build(BuildContext context) {
    final homeDataState = ref.watch(fetchHomeProvider(allGarages: true, onlyMine: false));
    final mapDataState = ref.watch(fetchHomeProvider(allGarages: true, onlyMine: false));
    final locationState = ref.watch(locationProvider);
    final stateConfiguracion = ref.watch(configurationProvider);

    this.configurationState.comunidadAutonomaDisponible = stateConfiguracion.comunidades;
    this.configurationState.provinciasDisponibles = stateConfiguracion.provincia;
    this.configurationState.municipioDisponibles = stateConfiguracion.municipio;
    this.configurationState.poblacionDisponibles = stateConfiguracion.poblacion;
    this.configurationState.nucleonDisponibles = stateConfiguracion.nucleo;
    this.configurationState.cpsDisponibles = stateConfiguracion.cps;

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: stateHome == _ScafollState.localizacion
            ? Stack(
                children: [
                  viewScafoldOptions(locationState, mapDataState),
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        _buildSearchBar(),
                        _buildFilters(),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildHeader(context, homeDataState.value?.user),
                  _buildSearchBar(),
                  _buildFilters(),
                  Expanded(
                    child: viewScafoldOptions(locationState, homeDataState),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: FloatingActionButton(
        heroTag: "addGarage",
        onPressed: () => Navigator.of(context).pushNamed(RegisterGarage.routeName),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User? user) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeHeaderTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    // Open location selector
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primaryColor, size: 20),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l10n.homeHeaderLocation,
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() => stateHome = _ScafollState.localizacion);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.map_outlined, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.searchBackground,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  icon: const Icon(Icons.search, color: Colors.white54),
                  hintText: AppLocalizations.of(context)!.searchHint,
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.searchBackground,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.tune, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final l10n = AppLocalizations.of(context)!;
    final filters = [
      l10n.filterAll,
      l10n.filterMyGarages,
      l10n.filterPrice,
      l10n.filterVehicle,
      l10n.filterStatus,
      l10n.filterFavorites
    ];
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          String label = filters[index];
          bool isActive = false;
          String subLabel = "";

          if (label == l10n.filterAll) {
            isActive = !_onlyMineFilter &&
                _priceSort == null &&
                _vehicleFilter == null &&
                _statusFilter == null &&
                !_favoritesFilter;
          } else if (label == l10n.filterMyGarages) {
            isActive = _onlyMineFilter;
          } else if (label == l10n.filterPrice) {
            isActive = _priceSort != null;
            subLabel = _priceSort == 'asc' ? l10n.filterPriceAsc : (_priceSort == 'desc' ? l10n.filterPriceDesc : "");
          } else if (label == l10n.filterVehicle) {
            isActive = _vehicleFilter != null;
            if (_vehicleFilter != null) {
              switch (_vehicleFilter) {
                case VehicleType.moto:
                  subLabel = l10n.filterVehicleMoto;
                  break;
                case VehicleType.cochePequeno:
                  subLabel = l10n.filterVehicleSmallCar;
                  break;
                case VehicleType.cocheGrande:
                  subLabel = l10n.filterVehicleLargeCar;
                  break;
                case VehicleType.furgoneta:
                  subLabel = l10n.filterVehicleVan;
                  break;
                default:
                  subLabel = "";
              }
            }
          } else if (label == l10n.filterStatus) {
            isActive = _statusFilter != null;
            subLabel = _statusFilter == 'libre' ? l10n.filterStatusFree : (_statusFilter == 'ocupado' ? l10n.filterStatusOccupied : "");
          } else if (label == l10n.filterFavorites) {
            isActive = _favoritesFilter;
          }

          if (label == l10n.filterVehicle) {
            return PopupMenuButton<VehicleType?>(
              offset: const Offset(0, 45),
              color: AppColors.darkerBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              onSelected: (VehicleType? value) {
                setState(() {
                  _vehicleFilter = value;
                });
              },
              itemBuilder: (context) => [
                PopupMenuItem<VehicleType?>(
                  value: null,
                  child: Text(l10n.filterAll, style: const TextStyle(color: Colors.white70)),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem(
                  value: VehicleType.moto,
                  child: Row(
                    children: [
                      const Icon(Icons.motorcycle, color: AppColors.primaryColor, size: 18),
                      const SizedBox(width: 10),
                      Text(l10n.filterVehicleMoto.replaceAll("(", "").replaceAll(")", "").trim(),
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: VehicleType.cochePequeno,
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car, color: AppColors.primaryColor, size: 18),
                      const SizedBox(width: 10),
                      Text(l10n.filterVehicleSmallCar.replaceAll("(", "").replaceAll(")", "").trim(),
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: VehicleType.cocheGrande,
                  child: Row(
                    children: [
                      const Icon(Icons.directions_bus_filled, color: AppColors.primaryColor, size: 18),
                      const SizedBox(width: 10),
                      Text(l10n.filterVehicleLargeCar.replaceAll("(", "").replaceAll(")", "").trim(),
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: VehicleType.furgoneta,
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping, color: AppColors.primaryColor, size: 18),
                      const SizedBox(width: 10),
                      Text(l10n.filterVehicleVan.replaceAll("(", "").replaceAll(")", "").trim(),
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
              child: _buildFilterItem(label, isActive, subLabel,
                  icon: label == l10n.filterMyGarages ? Icons.person_outline : null, l10n: l10n),
            );
          }

          return GestureDetector(
            onTap: () {
              setState(() {
                if (label == l10n.filterAll) {
                  _onlyMineFilter = false;
                  _priceSort = null;
                  _vehicleFilter = null;
                  _statusFilter = null;
                  _favoritesFilter = false;
                } else if (label == l10n.filterMyGarages) {
                  _onlyMineFilter = !_onlyMineFilter;
                } else if (label == l10n.filterPrice) {
                  if (_priceSort == null)
                    _priceSort = 'asc';
                  else if (_priceSort == 'asc')
                    _priceSort = 'desc';
                  else
                    _priceSort = null;
                } else if (label == l10n.filterStatus) {
                  if (_statusFilter == null)
                    _statusFilter = 'libre';
                  else if (_statusFilter == 'libre')
                    _statusFilter = 'ocupado';
                  else
                    _statusFilter = null;
                } else if (label == l10n.filterFavorites) {
                  _favoritesFilter = !_favoritesFilter;
                }
              });
            },
            child: _buildFilterItem(label, isActive, subLabel,
                icon: label == l10n.filterMyGarages ? Icons.person_outline : null, l10n: l10n),
          );
        },
      ),
    );
  }

  Widget _buildFilterItem(String label, bool isActive, String subLabel, {IconData? icon, required AppLocalizations l10n}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryColor : AppColors.chipBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isActive ? [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: isActive ? Colors.black : Colors.white70),
            const SizedBox(width: 8),
          ],
          Text(
            "$label$subLabel",
            style: TextStyle(
              color: isActive ? Colors.black : Colors.white,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (label != l10n.filterAll && label != l10n.filterMyGarages) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isActive ? Colors.black : Colors.white70,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.darkerBlue,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.search, l10n.navSearch, isSelected: stateHome == _ScafollState.listado, onTap: () {
            setState(() => stateHome = _ScafollState.listado);
          }),
          _navItem(Icons.map_outlined, l10n.navMap, isSelected: stateHome == _ScafollState.localizacion, onTap: () {
            ref.read(locationProvider.notifier).refresh();
            setState(() => stateHome = _ScafollState.localizacion);
          }),
          _navItem(Icons.timeline, l10n.navActivity, isSelected: false, onTap: () {
            Navigator.of(context).pushNamed(TimelinePage.routeName);
          }),
          _navItem(Icons.person, l10n.navProfile, isSelected: false, onTap: () {
            Navigator.of(context).pushNamed(UserDetailScreen.routeName);
          }),
        ],
      ),
    );
  }

  configurationStateCall(ConfigurationApp configuration) {
    setState(() {
      if (configuration.comunidadAutonoma == null) {
        ref.read(configurationProvider.notifier).fetchComunidades();
      } else if (configuration.provincia == null) {
        ref.read(configurationProvider.notifier).fetchProvincia(configuration.comunidadAutonoma?.ccom ?? "");
      } else if (configuration.municipio == null) {
        ref.read(configurationProvider.notifier).fetchMunicipio(configuration.provincia?.cpro ?? "");
      } else if (configuration.poblacion == null) {
        ref.read(configurationProvider.notifier).fetchPoblacion(configuration.municipio?.cmun ?? "");
      } else if (configuration.nucleo == null) {
        ref.read(configurationProvider.notifier).fetchNucleos(configuration.poblacion?.cpob ?? "");
      } else if (configuration.cp == null) {
        ref.read(configurationProvider.notifier).fetchCP(configuration.nucleo?.cpro ?? "",
                                                          configuration.nucleo?.cmum ?? "",
                                                          configuration.nucleo?.codigoUnidad ?? "");
      }
    });
  }

  Widget _navItem(IconData icon, String label, {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryColor : Colors.white54,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryColor : Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget viewScafoldOptions(LocationState location, AsyncValue<HomeData?> homeData) {
    return homeData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text(AppLocalizations.of(context)!.genericError(err.toString()))),
      data: (data) {
        if (data == null) return Center(child: Text(AppLocalizations.of(context)!.noData));

        List<Garaje> filteredList = List.from(data.listGarajes);

        // Always filter out my own garages in the map view to be double sure
        if (stateHome == _ScafollState.localizacion) {
          filteredList = filteredList.where((g) => g.propietario != data.user?.uid).toList();
        }

        // Search Filter
        if (_searchQuery.isNotEmpty) {
          filteredList = filteredList.where((g) => 
            g.direccion.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }

        // Vehicle Filter
        if (_vehicleFilter != null) {
          filteredList = filteredList.where((Garaje g) => g.vehicleType == _vehicleFilter).toList();
        }

        // Status Filter
        if (_statusFilter == 'libre') {
          filteredList = filteredList.where((Garaje g) => g.alquiler == null).toList();
        } else if (_statusFilter == 'ocupado') {
          filteredList = filteredList.where((Garaje g) => g.alquiler != null).toList();
        }

        // Favorites Filter
        if (_favoritesFilter) {
          final currentUserEmail = data.user?.email;
          filteredList = filteredList.where((Garaje g) => g.isFavorite(currentUserEmail)).toList();
        }

        // Owner Filter (explicitly requested by filter chip)
        if (_onlyMineFilter) {
          filteredList = filteredList.where((g) => g.propietario == data.user?.uid).toList();
        }

        // Price Sort
        if (_priceSort == 'asc') {
          filteredList.sort((Garaje a, Garaje b) => a.precio.compareTo(b.precio));
        } else if (_priceSort == 'desc') {
          filteredList.sort((Garaje a, Garaje b) => b.precio.compareTo(a.precio));
        }

        if (filteredList.isEmpty) {
          final l10n = AppLocalizations.of(context)!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _onlyMineFilter ? Icons.garage_outlined : Icons.search_off,
                  size: 64,
                  color: Colors.white24,
                ),
                const SizedBox(height: 16),
                Text(
                  _onlyMineFilter 
                      ? l10n.noMyGarages 
                      : (_favoritesFilter ? l10n.noFavorites : l10n.noGaragesFound),
                  style: const TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ],
            ),
          );
        }

        final filteredHomeData = HomeData(
          listGarajes: filteredList,
          listFavorite: data.listFavorite,
          user: data.user,
        );

        switch(stateHome) {
          case _ScafollState.listado:
            return listGarages.bodyContainer(context, ref, filteredHomeData, _navigateToDetails) as Widget;
          case _ScafollState.localizacion:
            return myLocation.bodyLocation(context, ref, location, AsyncData<HomeData?>(filteredHomeData), _navigateToDetails) as Widget;
          case _ScafollState.modificacion:
            return configuration.bodyConfiguration(context, configurationState, configurationStateCall) as Widget;
          default:
            return listGarages.bodyContainer(context, ref, filteredHomeData, _navigateToDetails) as Widget;
        }
      },
    );
  }
}


closeSesion(BuildContext context){
  Navigator.of(context).pushNamed(LoginPage.routeName);
/*
  class PreferenciasService {
  Future<void> guardarUsuario(String nombre) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('usuario', nombre);
  }

  Future<String?> leerUsuario() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('usuario');
  }

  Future<void> borrarUsuario() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  }
*/
}
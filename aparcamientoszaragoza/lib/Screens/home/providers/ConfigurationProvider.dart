import 'dart:convert';

import 'package:aparcamientoszaragoza/Models/codigo_postalResponse.dart';
import 'package:aparcamientoszaragoza/Models/municipioResponse.dart';
import 'package:aparcamientoszaragoza/Models/nucleoResponse.dart';
import 'package:aparcamientoszaragoza/Models/poblacion.dart';
import 'package:aparcamientoszaragoza/Models/poblacionesResponse.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../Models/codigo_postal.dart';
import '../../../Models/comunidad.dart';
import '../../../Models/comunidad_response.dart';
import '../../../Models/municipio.dart';
import '../../../Models/nucleo.dart';
import '../../../Models/provincia.dart';
import '../../../Models/provinciasResponse.dart';

class ConfigurationState {
  final List<Comunidad> comunidades;
  final List<Provincia> provincia;
  final List<Municipio> municipio;
  final List<Poblacion> poblacion;
  final List<Nucleo> nucleo;
  final List<CodigoPostalApp> cps;

  final bool isLoading;
  final String? error;

  const ConfigurationState({
    this.comunidades = const [],
    this.provincia = const [],
    this.municipio = const [],
    this.poblacion = const [],
    this.nucleo = const [],
    this.cps = const [],
    this.isLoading = false,
    this.error,
  });

  ConfigurationState copyWith({
    List<Comunidad>? comunidades,
    List<Provincia>? provincia,
    List<Municipio>? municipio,
    List<Poblacion>? poblacion,
    List<Nucleo>? nucleo,
    List<CodigoPostalApp>? cps,
    bool? isLoading,
    String? error,
  }) {
    return ConfigurationState(
      comunidades: comunidades ?? this.comunidades,
      provincia: provincia ?? this.provincia,
      municipio: municipio ?? this.municipio,
      poblacion: poblacion ?? this.poblacion,
      nucleo: nucleo ?? this.nucleo,
      cps: cps ?? this.cps,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ConfigurationNotifier extends StateNotifier<ConfigurationState> {
  ConfigurationNotifier() : super(const ConfigurationState());

  static const _baseUrlComunidad = 'https://apiv1.geoapi.es/comunidades';
  static const _baseUrlProvincias = 'https://apiv1.geoapi.es/provincias';
  static const _baseUrlMunicipio = 'https://apiv1.geoapi.es/municipios';
  static const _baseUrlPoblacion = 'https://apiv1.geoapi.es/poblaciones';
  static const _baseUrlNucleos = 'https://apiv1.geoapi.es/nucleos';
  static const _baseUrlCodigoPostal = 'https://apiv1.geoapi.es/codigos_postales';

  static const _apiKey = 'ea31642fd29c6496806643774f0e7c3fa2e2ef323b87da729c8d5f26696437cc';

  Future<void> fetchComunidades() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final uri = Uri.parse(
        '$_baseUrlComunidad?type=JSON&version=2021.01&key=$_apiKey',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final parsed = ComunidadesResponse.fromJson(decoded);

        state = state.copyWith(
          comunidades: parsed.data,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error ${response.statusCode}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }


  Future<void> fetchProvincia(String codeAutonoma) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final uri = Uri.parse(
        '$_baseUrlProvincias?CCOM=$codeAutonoma&type=JSON&version=2021.01&key=$_apiKey',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {

        final decoded = json.decode(response.body);
        final provinciasResponse = ProvinciasResponse.fromJson(decoded);

        state = state.copyWith(
          provincia: provinciasResponse.data,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error ${response.statusCode}',
        );
      }
    } catch (e) {
      print(e.toString());
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> fetchMunicipio(String codeProvincia) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final uri = Uri.parse(
        '$_baseUrlMunicipio?CPRO=$codeProvincia&type=JSON&version=2021.01&key=$_apiKey',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {

        final decoded = json.decode(response.body);
        final municipioResponse = MunicipiosResponse.fromJson(decoded);

        state = state.copyWith(
          municipio: municipioResponse.data,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error ${response.statusCode}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }


  Future<void> fetchNucleos(String codePoblacion) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final uri = Uri.parse(
        '$_baseUrlNucleos?CPOB=$codePoblacion&type=JSON&version=2021.01&key=$_apiKey',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {

        final decoded = json.decode(response.body);
        final nucleoResponse = NucleosResponse.fromJson(decoded);

        state = state.copyWith(
          nucleo: nucleoResponse.data,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error ${response.statusCode}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> fetchCP(String codeProvincia, String codeMunicipio, String codeNucleos) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final uri = Uri.parse(
        '$_baseUrlCodigoPostal?CPRO=$codeProvincia&CMUM=$codeMunicipio&CUN=$codeNucleos&type=JSON&version=2021.01&key=$_apiKey',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {

        final decoded = json.decode(response.body);
        final cpResponse = CodigosPostalesResponse.fromJson(decoded);

        state = state.copyWith(
          cps: cpResponse.data,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error ${response.statusCode}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> fetchPoblacion(String codeMunicipio) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final uri = Uri.parse(
        '$_baseUrlPoblacion?CMUN=$codeMunicipio&type=JSON&version=2021.01&key=$_apiKey',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {

        final decoded = json.decode(response.body);
        final poblacionResponse = PoblacionesResponse.fromJson(decoded);

        state = state.copyWith(
          poblacion: poblacionResponse.data,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error ${response.statusCode}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final configurationProvider =
StateNotifierProvider<ConfigurationNotifier, ConfigurationState>(
      (ref) => ConfigurationNotifier(),
);



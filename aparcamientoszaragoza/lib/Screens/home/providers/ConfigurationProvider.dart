import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../Models/comunidad.dart';
import '../../../Models/comunidad_response.dart';

class ComunidadesState {
  final List<Comunidad> comunidades;
  final bool isLoading;
  final String? error;

  const ComunidadesState({
    this.comunidades = const [],
    this.isLoading = false,
    this.error,
  });

  ComunidadesState copyWith({
    List<Comunidad>? comunidades,
    bool? isLoading,
    String? error,
  }) {
    return ComunidadesState(
      comunidades: comunidades ?? this.comunidades,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }



class ComunidadesState {
  final List<Comunidad> comunidades;
  final bool isLoading;
  final String? error;

  const ComunidadesState({
    this.comunidades = const [],
    this.isLoading = false,
    this.error,
  });

  ComunidadesState copyWith({
    List<Comunidad>? comunidades,
    bool? isLoading,
    String? error,
  }) {
    return ComunidadesState(
      comunidades: comunidades ?? this.comunidades,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ConfigurationNotifier extends StateNotifier<ComunidadesState> {
  ConfigurationNotifier() : super(const ComunidadesState());

  static const _baseUrl = 'https://apiv1.geoapi.es/comunidades';
  static const _apiKey = 'ea31642fd29c6496806643774f0e7c3fa2e2ef323b87da729c8d5f26696437cc';

  Future<void> fetchComunidades() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final uri = Uri.parse(
        '$_baseUrl?type=JSON&version=2021.01&key=$_apiKey',
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
}

final comunidadesProvider =
StateNotifierProvider<ConfigurationNotifier, ComunidadesState>(
      (ref) => ConfigurationNotifier(),
);

import 'package:aparcamientoszaragoza/Models/comunidad.dart';
import 'package:aparcamientoszaragoza/Models/configurationApp.dart';
import 'package:aparcamientoszaragoza/Models/municipio.dart';
import 'package:flutter/material.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';

import '../../../Models/codigo_postal.dart';
import '../../../Models/nucleo.dart';
import '../../../Models/poblacion.dart';
import '../../../Models/provincia.dart';

Widget bodyConfiguration(BuildContext context,
                          ConfigurationApp configuration,
                          ValueChanged<ConfigurationApp> configurationCallback) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: const EdgeInsets.all(16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              Icon(Icons.settings, color: Colors.blue),
              SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.searchConfigTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: configuration.comunidadAutonoma?.nombre,
            hint: Text(AppLocalizations.of(context)!.selectComunidadHint),
            items: configuration.comunidadAutonomaDisponible.map((comunidad_autonoma) {
              return DropdownMenuItem(
                value: comunidad_autonoma.nombre,
                child: Text(comunidad_autonoma.nombre),
              );
            }).toList(),
            onChanged: (value) {
              configuration.resetFromComunidad();
              configuration.comunidadAutonoma = Comunidad.getByNombre(configuration.comunidadAutonomaDisponible, value ?? "");
              configurationCallback(configuration);
            },
          ),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: configuration.provincia?.nombre,
            hint: Text(AppLocalizations.of(context)!.selectProvinciaHint),
            items: configuration.provinciasDisponibles.map((provincia) {
              return DropdownMenuItem(
                value: provincia.nombre,
                child: Text(provincia.nombre),
              );
            }).toList(),
            onChanged: (value) {
              configuration.resetFromProvincia();
              configuration.provincia = Provincia.getByNombre(configuration.provinciasDisponibles, value ?? "");
              configurationCallback(configuration);
            },
          ),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: configuration.municipio?.nombre,
            hint: Text(AppLocalizations.of(context)!.selectMunicipioHint),
            items: configuration.municipioDisponibles.map((municipio) {
              return DropdownMenuItem(
                value: municipio.nombre,
                child: Text(municipio.nombre),
              );
            }).toList(),
            onChanged: (value) {
              configuration.resetFromMunicipio();
              configuration.municipio = Municipio.getByNombre(configuration.municipioDisponibles, value ?? "");
              configurationCallback(configuration);
            },
          ),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: configuration.poblacion?.nombreOficial,
            hint: Text(AppLocalizations.of(context)!.selectPoblacionHint),
            items: configuration.poblacionDisponibles.map((poblacion) {
              return DropdownMenuItem(
                value: poblacion.nombreOficial,
                child: Text(poblacion.nombreOficial),
              );
            }).toList(),
            onChanged: (value) {
              configuration.resetFromPoblacion();
              configuration.poblacion = Poblacion.getByNombre(configuration.poblacionDisponibles, value ?? "");
              configurationCallback(configuration);
            },
          ),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: configuration.nucleo?.nombre,
            hint: Text(AppLocalizations.of(context)!.selectNucleoHint),
            items: configuration.nucleonDisponibles.map((nucleo) {
              return DropdownMenuItem(
                value: nucleo.nombre,
                child: Text(nucleo.nombre),
              );
            }).toList(),
            onChanged: (value) {
              configuration.resetFromNucleo();
              configuration.nucleo = Nucleo.getByNombre(configuration.nucleonDisponibles, value ?? "");
              configurationCallback(configuration);
            },
          ),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: configuration.cp?.codigoPostal,
            hint: Text(AppLocalizations.of(context)!.selectCpHint),
            items: configuration.cpsDisponibles.map((cp) {
              return DropdownMenuItem(
                value: cp.codigoPostal,
                child: Text(cp.codigoPostal),
              );
            }).toList(),
            onChanged: (value) {
              //configuration.resetFromNucleo();
              configuration.cp = CodigoPostalApp.getByCodigo(configuration.cpsDisponibles, value ?? "");
              configurationCallback(configuration);
            },
          ),
          const SizedBox(height: 27),
          /// Botón guardar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.configurationSaved)),
                );
              },
              child: Text(AppLocalizations.of(context)!.saveChangesAction),
            ),
          ),
        ],
      ),
    ),
  );
}
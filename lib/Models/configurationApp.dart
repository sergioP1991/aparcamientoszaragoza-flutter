import 'package:aparcamientoszaragoza/Models/comunidad.dart';
import 'package:aparcamientoszaragoza/Models/municipio.dart';
import 'package:aparcamientoszaragoza/Models/nucleo.dart';
import 'package:aparcamientoszaragoza/Models/poblacion.dart';
import 'package:aparcamientoszaragoza/Models/provincia.dart';

import 'codigo_postal.dart';

class ConfigurationApp {
  // Listas disponibles
  List<Comunidad> comunidadAutonomaDisponible = [];
  List<Provincia> provinciasDisponibles = [];
  List<Municipio> municipioDisponibles = [];
  List<Poblacion> poblacionDisponibles = [];
  List<Nucleo> nucleonDisponibles = [];
  List<CodigoPostalApp> cpsDisponibles = [];

  List<String> tipos = ["todos", "libres", "especiales"];

  // Selección actual
  Comunidad? comunidadAutonoma;
  Provincia? provincia;
  Municipio? municipio;
  Poblacion? poblacion;
  Nucleo? nucleo;
  CodigoPostalApp? cp;
  int tipo = 0;

  ConfigurationApp();

  /* ─────────────────────────────
     RESET TOTAL (estado inicial)
     ───────────────────────────── */
  void resetAll() {
    comunidadAutonomaDisponible = [];
    provinciasDisponibles = [];
    municipioDisponibles = [];
    poblacionDisponibles = [];
    nucleonDisponibles = [];
    cpsDisponibles = [];

    comunidadAutonoma = null;
    provincia = null;
    municipio = null;
    poblacion = null;
    nucleo = null;
    cp = null;
    tipo = 0;
  }

  /* ─────────────────────────────
     RESET DESDE COMUNIDAD
     ───────────────────────────── */
  void resetFromComunidad() {
    provinciasDisponibles = [];
    municipioDisponibles = [];
    poblacionDisponibles = [];
    nucleonDisponibles = [];
    cpsDisponibles = [];

    provincia = null;
    municipio = null;
    poblacion = null;
    nucleo = null;
    cp = null;
  }

  /* ─────────────────────────────
     RESET DESDE PROVINCIA
     ───────────────────────────── */
  void resetFromProvincia() {
    municipioDisponibles = [];
    poblacionDisponibles = [];
    nucleonDisponibles = [];
    cpsDisponibles = [];

    municipio = null;
    poblacion = null;
    nucleo = null;
    cp = null;
  }

  /* ─────────────────────────────
     RESET DESDE MUNICIPIO
     ───────────────────────────── */
  void resetFromMunicipio() {
    poblacionDisponibles = [];
    nucleonDisponibles = [];
    cpsDisponibles =[];

    poblacion = null;
    nucleo = null;
    cp = null;
  }

  /* ─────────────────────────────
     RESET DESDE POBLACIÓN
     ───────────────────────────── */
  void resetFromPoblacion() {
    nucleonDisponibles = [];
    cpsDisponibles = [];

    nucleo = null;
    cp = null;
  }

  /* ─────────────────────────────
     RESET DESDE POBLACIÓN
     ───────────────────────────── */
  void resetFromNucleo() {
    cpsDisponibles = [];

    cp = null;
  }

  /* ─────────────────────────────
     RESET SOLO CP
     ───────────────────────────── */
  void resetCP() {
    cp = null;
  }

  @override
  String toString() {
    return '''
ConfigurationApp(
  comunidad: ${comunidadAutonoma?.nombre},
  provincia: ${provincia?.nombre},
  municipio: ${municipio?.nombre},
  poblacion: ${poblacion?.nombreOficial},
  nucleo: ${nucleo?.nombre},
  cp: ${cp?.codigoPostal},
  tipo: ${tipos[tipo]}
)
''';
  }
}

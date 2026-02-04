import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../login/providers/UserProviders.dart';

class Incidenciasscreen extends ConsumerStatefulWidget {

  static const routeName = '/incidencias';

  //static String idUser;//faltaria inllectar el usuario como en HomeScreen

  @override
  _IncidenciasState createState() => _IncidenciasState();
}

class _IncidenciasState extends ConsumerState<Incidenciasscreen<incidencia> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para cada campo
  //TextEditingController _nombreController = TextEditingController();
  TextEditingController _direccionController = TextEditingController();
  TextEditingController _latitudController = TextEditingController();
  TextEditingController _longitudController = TextEditingController();
  TextEditingController _largoController = TextEditingController();
  TextEditingController _anchoController = TextEditingController();
  //bool _moto = false;

  // Función para guardar los datos en Firebase
  Future<void> _guardarDatos() async {
    // Validar el formulario
    if (_formKey.currentState!.validate()) {
      // Crear un mapa con los datos
      Map<String, dynamic> data = {
        //'nombre': _nombreController.text,
        'direccion': _direccionController.text,
        'latitud': double.parse(_latitudController.text),
        'longitud': double.parse(_longitudController.text),
        'largo': int.parse(_largoController.text) ,
        'ancho': int.parse(_anchoController.text),
        //'moto': _moto,
      };

      if(_longitudController == null || _latitudController == null){
        String error = 'Debe ingresar las conrdenadas en los campos de longitud y latitud para indicar la direccion usable por google maps';
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('¿Permitir acceso a la ubicación?'),
              content: Text('Los campos de latitud y longitud están vacíos. ¿Deseas obtener tu ubicación actual?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancelar'),
                ),
                TextButton (
                    onPressed: () {  },
                    child: Text('Aceptar')
                ),
              ],
            );
          },
        );
      }
      else {
        // Agregar el documento a la colección "garaje" en Firebase
        await FirebaseFirestore.instance.collection('garaje').add(data);
      }
      // Mostrar un mensaje de éxito o error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos guardados correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    AsyncValue<UserCredential?> user = ref.watch(loginUserProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Formulario de Garaje')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Campos de texto para cada propiedad
              /*
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el nombre';
                  }
                  return null;
                },
              ),
              */
              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(labelText: 'Dirección'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa la dirección';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _latitudController,
                decoration: InputDecoration(labelText: 'Altitud'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _longitudController,
                decoration: InputDecoration(labelText: 'Longitud'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _largoController,
                decoration: InputDecoration(labelText: 'largo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el largo de la plaza en metros';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _anchoController,
                decoration: InputDecoration(labelText: 'ancho'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el ancho de la plaza en metros';
                  }
                  return null;
                },
              ),
              /*
              CheckboxListTile(
                title: Text('moto'),
                value: _moto,
                onChanged: (value) {
                  setState(() {
                    _moto = value!;
                  });
                },
              ),
              */
              // Botón para guardar los datos
              ElevatedButton(
                onPressed: _guardarDatos,
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _obtenerUbicacion() async {
    try {
      // Solicitar permiso al usuario para acceder a la ubicación
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // El usuario denegó el permiso, mostrar un mensaje o tomar alguna acción
        return;
      }

      // Obtener la posición actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Actualizar los controladores de texto con los valores obtenidos
      setState(() {
        _longitudController.text = position.longitude.toString();
        _latitudController.text = position.latitude.toString();
      });
    } catch (e) {
      print('Error al obtener la ubicación: $e');
      // Mostrar un mensaje de error al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener la ubicación')),
      );
    }
  }
}
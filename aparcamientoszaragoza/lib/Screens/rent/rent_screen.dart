import 'package:aparcamientoszaragoza/Components/app_text_form_field.dart';
import 'package:aparcamientoszaragoza/Models/alquiler.dart';
import 'package:aparcamientoszaragoza/Models/especial.dart';
import 'package:aparcamientoszaragoza/Models/normal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RentPage extends ConsumerStatefulWidget {

  static const routeName = '/normal_rent';

  @override
  _RentNormalState createState() => _RentNormalState();
  //Faltaria obtener el id del usuario, y el id de la plaza
}

class _RentNormalState extends ConsumerState<RentPage> {
  final _formKey = GlobalKey<FormState>();

  List<String> _meses = ['','Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']; // Lista de opciones

  String? _mesInicioSeleccionado; // Variable para almacenar la opción seleccionada
  String? _mesFinSeleccionado; // Variable para almacenar la opción seleccionada

  late final TextEditingController anyoComienzo;
  late final TextEditingController anyoFinalizacion;

  void initializeControllers() {
    anyoComienzo = TextEditingController()..addListener(controllerListener);
    anyoFinalizacion = TextEditingController()..addListener(controllerListener);
  }

  void disposeControllers() {
    anyoComienzo.dispose();
    anyoFinalizacion.dispose();
  }

  void controllerListener() {

  }

  @override
  void initState() {
    super.initState();
    initializeControllers();
  }

  @override
  Widget build(BuildContext context) {
    final indexPlaza = (ModalRoute
        .of(context)
        ?.settings
        .arguments ?? 0) as int;
    //El usuario que registra la plaza ya indica que tipo de alquiler tiene,
    return Scaffold(
      appBar: AppBar(title: Text('Alquiler normal de la plaza $indexPlaza')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Mes de inicio del alquiler'),
                value: _mesInicioSeleccionado,
                items: _meses.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _mesInicioSeleccionado = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona el mes de inicio del alquiler';
                  }
                  return null;
                },
              ),
              AppTextFormField(
                labelText: "Año de inicio",
                controller: anyoComienzo,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                onChanged: (_) => _formKey.currentState?.validate(),
              ),
              Divider(
                color: Colors.grey, // Puedes cambiar el color de la línea
                thickness: 6,      // Puedes cambiar el grosor de la línea
                indent: 6,        // Espacio al inicio de la línea
                endIndent: 6,     // Espacio al final de la línea
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Mes de final del alquiler'),
                value: _mesFinSeleccionado,
                items: _meses.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _mesInicioSeleccionado = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona el mes de finalizacion del alquiler';
                  }
                  return null;
                },
              ),
              AppTextFormField(
                labelText: "Año de fin de alquiler",
                controller: anyoComienzo,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                onChanged: (_) => _formKey.currentState?.validate(),
              ),
              Divider(
                color: Colors.grey, // Puedes cambiar el color de la línea
                thickness: 6,      // Puedes cambiar el grosor de la línea
                indent: 6,        // Espacio al inicio de la línea
                endIndent: 6,     // Espacio al final de la línea
              ),
              _buttonRent(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttonRent(BuildContext context){
    AsyncValue<Alquiler?> result = ref.watch(newRentProvider);
    return Container(
        height: 80,
        width: double.infinity,
        padding: const EdgeInsets.only(top: 25, left: 24, right: 24),
        child: ElevatedButton(
          onPressed: () {
            if (type == especial) {
              ref .read(rentProvider.notifier)
                  .register(AlquilerEspecial(dias, plaza, arrendatario, idPlaza, idArrendatario)
              )),
            } else {
            ref .read(rentProvider.notifier)
                .register(AlquilerNormal(mesInicio, mesFin, anyoInicio, anyoFinal, idPlaza, idPropietario))
            )),
            }

          );
          },
          child: const Text(
            'Finalizar alquiler',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        )
    );
  }

}
import 'package:flutter/material.dart';

enum SingingCharacter { all, normal, special }

class AlquilerRadioButtonWidget extends StatefulWidget {
  const AlquilerRadioButtonWidget({super.key});

  @override
  State<AlquilerRadioButtonWidget> createState() => _AlquilerRadioButtonWidgetState();
}

class _AlquilerRadioButtonWidgetState extends State<AlquilerRadioButtonWidget> {
  SingingCharacter? _character = SingingCharacter.all;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('todos alquileres'),
          leading: Radio<SingingCharacter>(
            value: SingingCharacter.all,
            groupValue: _character,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('alquileres normales'),
          leading: Radio<SingingCharacter>(
            value: SingingCharacter.normal,
            groupValue: _character,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('alquileres especiales'),
          leading: Radio<SingingCharacter>(
            value: SingingCharacter.special,
            groupValue: _character,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
      ],
    );
  }


}



import 'package:flutter/material.dart';

class InputTextField extends StatelessWidget {
  String labelText;
  String hintText;
  TextEditingController controller;

  InputTextField (this.labelText, this.hintText, this.controller) : super();

  bool isValid () {
    return controller.text.isNotEmpty;
  }

  String text () {
    return controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: TextField(
        controller: this.controller,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: this.labelText,
            hintText: this.hintText),
      ),
    );
  }
}
class UsernameInputTextField extends InputTextField {

  UsernameInputTextField() : super("Username", "Username", TextEditingController());

  @override
  bool isValid() {
    return super.isValid();
  }

  setUser (String user) {
    this.controller.text = user;
  }
}

class TextToSearchInputTextField extends InputTextField {

  TextToSearchInputTextField({required String value}) : super("Texto a buscar", "Texto a buscar", TextEditingController(text: value));

  @override
  bool isValid() {
    return super.isValid();
  }

}
/*
class EmailInputTextField extends InputTextField {

  EmailInputTextField() : super("Email", "Email", TextEditingController());

  @override
  bool isValid() {
     return super.isValid() && EmailValidator.validate(this.controller.text);
  }
}
*/

class PasswordInputTextField extends InputTextField {

  PasswordInputTextField() : super("Password", "Password", TextEditingController());

  @override
  bool isValid() {
    return super.isValid();
  }
}

class PhoneInputTextField extends InputTextField {

  PhoneInputTextField() : super("Telefono", "Telefono", TextEditingController());

  @override
  bool isValid() {
    return super.isValid() && this.controller.text.length > 9;
  }
}


class DireccionInputTextField extends InputTextField {

  DireccionInputTextField() : super("Direccion en la que se encuentra la plaza", "Altitud", TextEditingController());

  @override
  bool isValid() {
    return super.isValid();
  }
}

class LatitudInputTextField extends InputTextField {

  LatitudInputTextField() : super("Altitud a la que se encuentra la plaza", "Altitud", TextEditingController());

  @override
  bool isValid() {
    return super.isValid();
  }
}

class LongitudInputTextField extends InputTextField {

  LongitudInputTextField() : super("Longitud a la que se encuentra la plaza", "Longitud", TextEditingController());

  @override
  bool isValid() {
    return super.isValid();
  }
}


class AnchoInputTextField extends InputTextField {

  AnchoInputTextField() : super("Ancho de la plaza", "Ancho", TextEditingController());

  @override
  bool isValid() {
    return super.isValid();
  }
}

class LargoInputTextField extends InputTextField {

  LargoInputTextField() : super("Largo de la plaza", "Largo", TextEditingController());

  @override
  bool isValid() {
    return super.isValid();
  }
}

class NumCountGarageView extends InputTextField {

  NumCountGarageView() : super("Numero de plazas a mostrar", "cantidad", TextEditingController());

  @override
  bool isValid() {
    return super.isValid();
  }

  setNum (String num) {
    this.controller.text = num;
  }
  //estuve mirando ver como poner el teclado, tipo numerico
}

class NewComment extends InputTextField {

  NewComment() : super("Escriba el nuevo comentario", "comentario", TextEditingController());

  @override
  bool isValid() {
    return super.isValid();
  }

  setNum (String num) {
    this.controller.text = num;
  }
  //estuve mirando ver como poner el teclado, tipo numerico
}


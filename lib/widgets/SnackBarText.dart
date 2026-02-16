import 'package:flutter/material.dart';

class SnackBarText extends SnackBar {
  String texto;
  Color? backgroundColor = Colors.black;

  SnackBarText(this.texto, {this.backgroundColor}) : super (content: Text(texto),
                                                          backgroundColor: backgroundColor);

/*action: SnackBarAction(
  label: 'Undo',
  onPressed: () {
  // Some code to undo the change.
  },
  ),*/
}

import 'package:flutter/material.dart';

class ButtonGreyBlueApp extends TextButton {
  String texto;
  ButtonGreyBlueApp(this.texto,
      {required VoidCallback? onPressed}) :

        super(child: Text(
        texto,
        style: TextStyle(color: Colors.blueGrey, fontSize: 15),
      ),
          onPressed: onPressed);
}

class ButtonLessAuto extends TextButton {
  String texto;
  ButtonLessAuto(this.texto,
      {required VoidCallback? onPressed}) :

        super(child: Text(
        texto,
        style: TextStyle(color: Colors.blueGrey, fontSize: 15),
      ),
          onPressed: onPressed);
}

class ButtonBlueApp extends Container {
  String texto;
  ButtonBlueApp(this.texto,
      {required VoidCallback? onPressed}) :
        super(height: 50,
        width: 250,
        decoration: BoxDecoration(
            color: Colors.blue, borderRadius: BorderRadius.circular(15)),
        child: TextButton (
          onPressed: onPressed,
          style: TextButton.styleFrom(alignment: Alignment.center, padding: EdgeInsets.symmetric(horizontal: 0)),
          child: Text(
            texto,
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
        ),
      );
}

class ButtonAlert extends Container {
  String texto;
  ButtonAlert( this.texto,
      {required VoidCallback? onPressed}) :
        super(height: 30,
        width: 250,
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(10)),
        child: TextButton (
          onPressed: onPressed,
          child: Text(
            texto,
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      );
}

class ButtonCoordenadas extends Container {
  String texto;
  ButtonCoordenadas( this.texto,
      {required VoidCallback? onPressed}) :
        super(height: 30,
        width: 250,
        decoration: BoxDecoration(
            color: Colors.lightBlue, borderRadius: BorderRadius.circular(10)),
        child: TextButton (
          onPressed: onPressed,
          child: Text(
            texto,
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      );
}

class ButtonMoto extends Container {
  String texto;
  ButtonMoto( this.texto,
    {required VoidCallback? onPressed}) :
      super(height: 30,
      width: 250,
      decoration: BoxDecoration(
          color: Colors.purpleAccent, borderRadius: BorderRadius.circular(10)),
      child: TextButton (
        onPressed: onPressed,
        child: Text(
          texto,
          style: TextStyle(color: Colors.black, fontSize: 13),
        ),
      ),
    );
}

class ShareButton extends Container {
  ShareButton({required VoidCallback? onPressed}) :
        super(height: 30,
        width: 250,
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(10)),
        child: TextButton (
          onPressed: onPressed,
          child: Row(
            children: [ Text(
              "Compartir",
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            Icon(Icons.share, color: Colors.white, size: 20),
          ]
        ),
      ),
    );
}
/*
class ButtonAnimationIcon extends LoopAnimationBuilder {
  ButtonAnimationIcon({
                        required VoidCallback? onPressed,
                        required IconData icon}) :
        super(builder: (context, dynamic value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  color: Colors.blue.shade900,
                  borderRadius: BorderRadius.circular(30)),
              child: Align(alignment: Alignment.center,
                child: TextButton (
                  onPressed: onPressed,
                  child: Icon(icon, color: Colors.blue.shade50, size: 25),
                ),
              ),
            ),
          );
        },
        tween: Tween<double>(begin: 0, end: 2),
        duration: const Duration(seconds: 2));
}

class RutButton extends Container {
  RutButton({required VoidCallback? onPressed}) :
        super(height: 30,
        width: 250,
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(10)),
        child: TextButton (
          onPressed: onPressed,
          child: Row(
              children: [ Text(
                "Ruta",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
                Icon(Icons.accessibility, color: Colors.white, size: 20),
              ]
          ),
        ),
      );
}
*/

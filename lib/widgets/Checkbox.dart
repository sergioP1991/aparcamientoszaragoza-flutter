
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class CheckBoxApp extends Checkbox {
  bool? value;

  CheckBoxApp(this.value,
              {required ValueChanged? onChanged}) :

      super(value: true,
            onChanged: onChanged,
            checkColor: Colors.white
  );

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }
}
class ParkingIsMoto extends Checkbox {
  bool? value;

  ParkingIsMoto(this.value,
              {required ValueChanged? onChanged}) :

      super(value: true,
            onChanged: onChanged,
            checkColor: Colors.white
  );

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.white;
  }
}
class AutoLocation extends Checkbox {
  bool? value;

  AutoLocation(this.value,
              {required ValueChanged? onChanged}) :

      super(value: true,
            onChanged: onChanged,
            checkColor: Colors.white
  );

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.black;
    }
    return Colors.blue;
  }
}

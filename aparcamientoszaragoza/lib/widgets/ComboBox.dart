
import 'package:flutter/material.dart';

class InputTextField extends StatelessWidget {
  String labelText;
  String hintText;

  InputTextField (this.labelText, this.hintText) : super();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: TextField(
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: this.labelText,
            hintText: this.hintText),
      ),
    );
  }
}

class SelectedLanguage extends DropdownButton {

  SelectedLanguage(String value,
                    ValueChanged<dynamic> onChange) : super(
      value: value,
      items: <DropdownMenuItem>[
        DropdownMenuItem<String>(
          value: "English",
          child: Text("English"),
        ),
        DropdownMenuItem<String>(
          value: "Spanish",
          child: Text("Spanish"),
        ),
        DropdownMenuItem<String>(
          value: "French",
          child: Text("French"),
        ),
        DropdownMenuItem<String>(
          value: "Italian",
          child: Text("Italian"),
        ),
        DropdownMenuItem<String>(
          value: "German",
          child: Text("German"),
        ),
        DropdownMenuItem<String>(
          value: "Portuguese",
          child: Text("Portuguese"),
        )
      ],
    onChanged: onChange);

}

class SelectedNumImages extends DropdownButton {

  SelectedNumImages({required String value,
                    required ValueChanged<dynamic> onChange}) : super(
      value: value,
      items: <DropdownMenuItem>[
        DropdownMenuItem<String>(
          value: "1",
          child: Text("1"),
        ),
        DropdownMenuItem<String>(
          value: "2",
          child: Text("2"),
        ),
        DropdownMenuItem<String>(
          value: "3",
          child: Text("3"),
        ),
        DropdownMenuItem<String>(
          value: "4",
          child: Text("4"),
        ),
        DropdownMenuItem<String>(
          value: "5",
          child: Text("5"),
        ),
        DropdownMenuItem<String>(
          value: "6",
          child: Text("6"),
        ),
        DropdownMenuItem<String>(
          value: "7",
          child: Text("7"),
        ),
        DropdownMenuItem<String>(
          value: "8",
          child: Text("8"),
        ),
        DropdownMenuItem<String>(
          value: "9",
          child: Text("9"),
        ),
        DropdownMenuItem<String>(
          value: "10",
          child: Text("10"),
        )
      ],
      onChanged: onChange);

}
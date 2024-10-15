import 'package:flutter/material.dart';

import '../Values/app_colors.dart';
import '../extensions.dart';

class GradientBackground extends StatelessWidget {
  GradientBackground({
    required this.children,
    this.colors = AppColors.defaultGradient,
    this.urlCircleImage,
    super.key,
  });

  final List<Color> colors;
  String? urlCircleImage;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {

    return DecoratedBox(
      decoration: BoxDecoration(gradient: LinearGradient(colors: colors)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              //sección izquierda
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: context.heightFraction(sizeFraction: 0.1),
                  ),
                  ...children,
                ],
              ),
              // sección central
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '+52 55 12345678',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Texto a expandir',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              () {
              if (urlCircleImage != null) {
                // sección derecha
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                  CircleAvatar(
                  radius: 45.0,
                  backgroundImage: NetworkImage(urlCircleImage ?? ""),
                  backgroundColor: Colors.blueGrey,
                  )
                ],
                );
              } else {
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[],
                );
              }
              }()
      ]),
    ));
  }



}

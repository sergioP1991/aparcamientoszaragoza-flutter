import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Values/app_models.dart';
import 'package:aparcamientoszaragoza/widgets/Buttons.dart';
import 'package:aparcamientoszaragoza/widgets/Spaces.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Values/app_colors.dart';

class DetailsGarajePage extends StatefulWidget {

  static const routeName = '/details-garage';

  const DetailsGarajePage({super.key});

  @override
  State<DetailsGarajePage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsGarajePage> {
  @override
  Widget build(BuildContext context) {

    final indexPlaza = ModalRoute.of(context)!.settings.arguments as int;
    final plaza = AppModels.defaultGarajes[indexPlaza];//.get(indexPlaza);
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: _viewInfo(plaza)
    );
  }

  Widget _viewInfo(Garaje plaza) {
    return
      Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          child:
          Padding(
            padding: const EdgeInsets.all(15.0),
            child:
            Wrap(
                children:[ Column(
                  children: [
                    _buildValue("Direccion", plaza?.direccion ?? ""),
                    spaceXXXXS(),
                    _buildValue("Latitud", plaza?.latitud.toString() ?? ""),
                    spaceXXXXS(),
                    _buildValue("Longitud", plaza?.longitud.toString() ?? ""),
                    spaceXXXXS(),
                    _buildValue("Moto", plaza?.moto.toString() ?? ""),
                    spaceXXXXS(),
                    _buildValue("Largo", plaza?.largo.toString() ?? ""),
                    spaceXXXXS(),
                    _buildValue("Ancho", plaza?.ancho.toString() ?? ""),
                    spaceXXXXS(),
                    ButtonBlueApp('Comentarios', onPressed:() => {} /* => Routemaster.of(context).push("/plaza/${plaza?.id.toString()}")*/),
                    spaceXXS(),
                  ],
                )]
            ),
          ));
  }

  Widget _buildValue(String key, String value) {
    return
      Row(children: [
        Text( key, style: TextStyle( fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        Flexible(child: Container()),
        Text( value, style: TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)
      ]);
  }

  /*Widget _buildMap(){

  }*/
}


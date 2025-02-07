import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Screens/detailsGarage/detailsGarage_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/GarajesProviders.dart';
import 'package:aparcamientoszaragoza/Screens/registerGarage/registerGarage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Values/app_colors.dart';
import '../login/providers/UserProviders.dart';

class HomePage extends ConsumerWidget {

  static const routeName = '/home-page';

  final String title;

  HomePage({super.key, this.title = ""});

@override
Widget build(BuildContext context, WidgetRef ref) {
  AsyncValue<List<Garaje>> garageList = ref.watch(fetchGarajeProvider);
  AsyncValue<UserCredential?> user = ref.watch(loginUserProvider);

  return Scaffold(
    appBar: infoHead(user.value),
    backgroundColor: AppColors.darkBlue,
    body: Container(child:bodyContainer(context, ref, garageList)),
    bottomNavigationBar: menuNavigator(context),
  );
}

AppBar infoHead(UserCredential? user) {
  return AppBar(
      title: Row(
      children: [
      CircleAvatar(
        backgroundImage: user?.user?.photoURL != null
            ? NetworkImage(user?.user?.photoURL?.toString() ?? "")
            : AssetImage('assets/default_icon.png') as ImageProvider,
      ),
      const SizedBox(width: 10),
      Text(user?.user?.displayName ?? "Usuario Registrado"),
      ],
  ));
}

Widget? bodyContainer ( BuildContext context,
                        WidgetRef ref,
                        AsyncValue<List<Garaje>> garajeList) {
  return garajeList.when(
      loading: () => loadingBody(context),
      error: (err, stack) => Text('error: $err'),
      data: (data) {
        return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                return itemList(context, index, data.elementAt(index));
              },
          );
      });
    }
}

Widget loadingBody (BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height / 1.3,
    child: const Center(
      child: CircularProgressIndicator(),
    ),
  );
}

Widget itemList (BuildContext context, int index, Garaje item) {
 return
   GestureDetector(
     onTap: () {
       Navigator.of(context).pushNamed(DetailsGarajePage.routeName, arguments: index);
     },
   child:
     Card(
      elevation: 8.0,
      color: AppColors.darkBlue,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: const BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
        child: makeListTile(item),

      ),
  ),
  );
}

Widget makeListTile(Garaje item) {
  return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      leading: Container(
        padding: const EdgeInsets.only(right: 12.0),
        decoration: const BoxDecoration(
            border: Border(
                right: BorderSide(width: 1.0, color: Colors.white24))),
        child: Icon(Icons.event_available_rounded, color: item.alquilada ? Colors.blueGrey : Colors.white),
      ),
      title: Text(
        item.nombre ?? "Garage",
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),

      subtitle:
      Column(
        children: [
          Row(
            children: <Widget>[
              const Icon(Icons.business, color: Colors.blueGrey),
              Text("   ${item.direccion ?? ""}", style: const TextStyle(color: Colors.white)),
            ],
          ),
          Row(
            children: <Widget>[
              const Icon(Icons.linear_scale, color: Colors.blueGrey),
              Text("  Ancho ${item.ancho}  -  Largo: ${item.largo}", style: const TextStyle(color: Colors.white))
            ],
          ),
          Row(
            children: <Widget>[
              if (item.alquilada) const Icon(Icons.check, color: Colors.green) else const Icon(Icons.check, color: Colors.red),
              if (item.alquilada) const Text("Alquilada", style: TextStyle(color: Colors.green)) else const Text("NO Alquilada", style: TextStyle(color: Colors.red))
            ],
          )]
      ),
      trailing:
      const Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0));
}

AppBar infoHead(String username) {
  return AppBar(
      backgroundColor: Color.fromRGBO(108, 116, 136, 1.0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text("Bienvenido $username")
        ],
      ),
    );
}


Widget menuNavigator(BuildContext context) {
    return Container(
      height: 55.0,
      child: BottomAppBar(
        color: Color.fromRGBO(58, 66, 86, 1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.blur_on, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.settings, color: Colors.white),
              onPressed: () {},
              //onPressed:() => Navigator.of(context).pushNamed(settingPage.routeName),
            ),
            IconButton(
              icon: Icon(Icons.add, color: Colors.blue),
              //onPressed: () {},
              onPressed:() => Navigator.of(context).pushNamed(RegisterGarage.routeName),
            )
          ],
        ),
      ),
    );
}

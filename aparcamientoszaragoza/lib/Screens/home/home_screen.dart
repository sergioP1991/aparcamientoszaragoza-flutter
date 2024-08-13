import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Screens/detailsGarage/detailsGarage_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/GarajesProviders.dart';
import 'package:aparcamientoszaragoza/Screens/registerGarage/registerGarage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Values/app_colors.dart';
import '../../Values/app_regex.dart';

class HomePage extends ConsumerWidget {

  static const routeName = '/home-page';

  final String title;

  HomePage({super.key, this.title = ""});

@override
Widget build(BuildContext context, WidgetRef ref) {
  AsyncValue<List<Garaje>> garageList = ref.watch(fetchGarajeProvider);

  return Scaffold(
    backgroundColor: AppColors.darkBlue,
    body: Container(child:bodyContainer(context, garageList)),
    bottomNavigationBar: menuNavigator(context),
  );
}

PreferredSizeWidget topAppBar () {
  return AppBar(
    elevation: 0.3,
    backgroundColor: AppColors.darkBlue,
    iconTheme: const IconThemeData(
      color: Colors.white, //change your color here
    ),
    title: Text("Title"),
    actions: <Widget>[
      IconButton(
        icon: const Icon(Icons.list, color: Colors.white), onPressed: () {  },
      ),

    ],
  );
}

Widget? bodyContainer ( BuildContext context,
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
            )]
      ),
      trailing:
      const Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0));
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

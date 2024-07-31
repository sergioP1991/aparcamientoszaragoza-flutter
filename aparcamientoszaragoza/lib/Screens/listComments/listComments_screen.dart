import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Screens/detailsGarage/detailsGarage_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/GarajesProviders.dart';
import 'package:aparcamientoszaragoza/Screens/listComments/providers/CommentsProviders.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../Models/comment.dart';
import '../../Values/app_colors.dart';
import '../../Values/app_regex.dart';

class listCommentsPage extends ConsumerWidget {

  static const routeName = '/listComments-page';

  final String title;

  listCommentsPage({super.key, this.title = ""});

@override
Widget build(BuildContext context, WidgetRef ref) {
  AsyncValue<List<Comment>> commentsList = ref.watch(fetchCommentsProvider);

  return Scaffold(
    backgroundColor: AppColors.darkBlue,
    body: Container(child:bodyContainer(context, commentsList)),
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
                        AsyncValue<List<Comment>> commentList) {
  return commentList.when(
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

Widget itemList (BuildContext context, int index, Comment item) {
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
        child: commentCard(item),
      ),
  ),
  );
}

Widget commentCard (Comment item){
  return Card(
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del comentario
          Text(
            item?.titulo ?? "",
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),

          // Descripción del comentario
          Text(
            item?.contenido ?? "",
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 16.0),

          // Calificación con estrellas
          Row(
            children: [
              for (int i = 0; i < item.ranking.toInt(); i++)
                Icon(
                  Icons.star,
                  color: Colors.yellow[700],
                ),
              for (int i = 0; i < (5 - item.ranking.toInt()); i++)
                Icon(
                  Icons.star_border,
                  color: Colors.yellow[700],
                ),
            ],
          ),
          Text(
            "Fecha: " + item.fecha.toString(),
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 16.0),

        ],
      ),
    ),
  );
}

Widget makeListTile(Comment item) {
  return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      leading: Container(
        padding: const EdgeInsets.only(right: 12.0),
        decoration: const BoxDecoration(
            border: Border(
                right: BorderSide(width: 1.0, color: Colors.white24))),
        child: Icon(Icons.event_available_rounded, color: item.idUsuario != null ? Colors.blueGrey : Colors.white),
      ),
      title: Text(
        item.titulo ?? "Comment",
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),

      subtitle:
      Column(
        children: [
          Row(
            children: <Widget>[
              const Icon(Icons.business, color: Colors.blueGrey),
              Text("  Tilulo${item.titulo ?? ""}", style: const TextStyle(color: Colors.white)),
            ],
          ),
          Row(
            children: <Widget>[
              Text("   Contenido${item.contenido ?? ""}", style: const TextStyle(color: Colors.white)),
            ],
          ),
          Row(
            children: <Widget>[
              const Icon(Icons.linear_scale, color: Colors.blueGrey),
              Text("  RATING ${item.ranking}  -  rating: ${item.ranking}", style: const TextStyle(color: Colors.white))
            ],
          ),
          Row(
              children: <Widget>[
                const Icon(Icons.linear_scale, color: Colors.blueGrey),
                Text("  fecha ${item.fecha}  -  Fecha: ${item.fecha}", style: const TextStyle(color: Colors.white))
              ],
            )]
      ),
      trailing:
      const Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0));
}

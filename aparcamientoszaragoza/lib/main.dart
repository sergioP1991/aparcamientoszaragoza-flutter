import 'package:aparcamientoszaragoza/Screens/detailsGarage/detailsGarage_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/home_screen.dart';
import 'package:aparcamientoszaragoza/Screens/listComments/listComments_screen.dart';
import 'package:aparcamientoszaragoza/Screens/register/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import './Screens/welcome_screen.dart';
import './Models/auth.dart';
import 'Screens/login/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
      // For widgets to be able to read providers, we need to wrap the entire
      // application in a "ProviderScope" widget.
      // This is where the state of our providers will be stored.
      ProviderScope(
        child: MyApp(),
      ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return provider.ChangeNotifierProvider(
      create: (ctx) => Auth(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: WelcomeScreen(),
        routes: {
          WelcomeScreen.routeName: (context) => WelcomeScreen(),
          RegisterPage.routeName: (context) => RegisterPage(),
          LoginPage.routeName: (context) => LoginPage(),
          HomePage.routeName: (context) => HomePage(),
          DetailsGarajePage.routeName: (context) => DetailsGarajePage(),
          listCommentsPage.routeName: (context) => listCommentsPage()
        },
      ),
    );
  }
}

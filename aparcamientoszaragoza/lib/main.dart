import 'package:aparcamientoszaragoza/Screens/detailsGarage/detailsGarage_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/home_screen.dart';
import 'package:aparcamientoszaragoza/Screens/listComments/listComments_screen.dart';
import 'package:aparcamientoszaragoza/Screens/register/register_screen.dart';
import 'package:aparcamientoszaragoza/Screens/setting/setting_screen.dart';
import 'package:aparcamientoszaragoza/Screens/registerGarage/RegisterGarage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import './Screens/welcome_screen.dart';
import './Models/auth.dart';
import 'Screens/login/login_screen.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  /*
    apiKey: "AIzaSyB-SUptPv8-RdATIDVKyOhSdH1XI1E2Vfk",
  authDomain: "aparcamientodisponible.firebaseapp.com",
  databaseURL: "https://aparcamientodisponible-default-rtdb.firebaseio.com",
  projectId: "aparcamientodisponible",
  storageBucket: "aparcamientodisponible.appspot.com",
  messagingSenderId: "342617603309",
  appId: "1:342617603309:web:8e36ac7ad968c01ac4e0e4",
  measurementId: "G-21CTBFGFJP"
   */
  FirebaseOptions options = FirebaseOptions(
      apiKey: "AIzaSyB-SUptPv8-RdATIDVKyOhSdH1XI1E2Vfk",
      appId: "1:342617603309:web:8e36ac7ad968c01ac4e0e4",
      authDomain: "aparcamientodisponible.firebaseapp.com",
      storageBucket: "aparcamientodisponible.appspot.com",
      measurementId: "342617603309",
      messagingSenderId: "342617603309",
      databaseURL: "https://aparcamientodisponible-default-rtdb.firebaseio.com",
      projectId: "aparcamientodisponible");

  await Firebase.initializeApp(
    options: options,
  );

  runApp(MyApp());

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
          SettingPage.routeName: (Context) => SettingPage(),
          DetailsGarajePage.routeName: (context) => DetailsGarajePage(),
          listCommentsPage.routeName: (context) => listCommentsPage(),
          //registerGarage.routeName: (context) => registerGarage()
        },
      ),
    );
  }
}

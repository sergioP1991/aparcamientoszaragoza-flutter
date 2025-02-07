import 'package:aparcamientoszaragoza/Screens/detailsGarage/detailsGarage_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/home_screen.dart';
import 'package:aparcamientoszaragoza/Screens/listComments/listComments_screen.dart';
import 'package:aparcamientoszaragoza/Screens/register/register_screen.dart';
import 'package:aparcamientoszaragoza/Screens/registerGarage/registerGarage.dart';
import 'package:aparcamientoszaragoza/Screens/smsVerified/smsvalidate_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart' as provider;
import 'package:web3dart/web3dart.dart';
import './Screens/welcome_screen.dart';
import './Models/auth.dart';
import 'Screens/bit/bit_screen.dart';
import 'Screens/login/login_screen.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseOptions options = const FirebaseOptions(
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

  // Disable persistence on web platforms. Must be called on initialization:
  //final auth = FirebaseAuth.instanceFor(app: Firebase.app(), persistence: Persistence.LOCAL);
// To change it after initialization, use `setPersistence()`:
  //await auth.setPersistence(Persistence.LOCAL);

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
  const MyApp({super.key});

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
          RegisterPage.routeName: (context) => const RegisterPage(),
          LoginPage.routeName: (context) => const LoginPage(),
          HomePage.routeName: (context) => HomePage(),
          DetailsGarajePage.routeName: (context) => DetailsGarajePage(),
          listCommentsPage.routeName: (context) => listCommentsPage(),
          RegisterGarage.routeName: (context) => RegisterGarage(),
          SmsValidatePage.routeName: (context) => const SmsValidatePage(),
          BitPage.routeName: (context) => const BitPage()
        },
      ),
    );
  }
}

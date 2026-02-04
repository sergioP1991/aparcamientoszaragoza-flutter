import 'package:aparcamientoszaragoza/Screens/Timeline/timeline_screen.dart';
import 'package:aparcamientoszaragoza/Screens/detailsGarage/detailsGarage_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/home_screen.dart';
import 'package:aparcamientoszaragoza/Screens/listComments/addComments_screen.dart';
import 'package:aparcamientoszaragoza/Screens/listComments/listComments_screen.dart';
import 'package:aparcamientoszaragoza/Screens/register/register_screen.dart';
import 'package:aparcamientoszaragoza/Screens/registerGarage/registerGarage.dart';
import 'package:aparcamientoszaragoza/Screens/smsVerified/smsvalidate_screen.dart';
import 'package:aparcamientoszaragoza/Screens/rent/rent_screen.dart';
import 'package:aparcamientoszaragoza/Screens/userDetails/userDetails_screen.dart';
import 'package:aparcamientoszaragoza/Values/app_theme.dart';
import 'package:aparcamientoszaragoza/Screens/ad/ad_screen.dart';
import 'package:aparcamientoszaragoza/Screens/favorites/favorites_screen.dart';
import 'package:aparcamientoszaragoza/Screens/my_garages/my_garages_screen.dart';
import 'package:aparcamientoszaragoza/Screens/settings/settings_screen.dart';
import 'package:aparcamientoszaragoza/Screens/settings/providers/settings_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import './Screens/welcome_screen.dart';
import './Models/auth.dart';
import 'Screens/forgetPassword/ForgetPassword_screen.dart';
import 'Screens/login/login_screen.dart';
import 'Screens/tutorial/tutorial_screen.dart';

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

  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 30),
    minimumFetchInterval: const Duration(seconds: 0), // Ajusta según necesidad
  ));
  await remoteConfig.fetchAndActivate();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
      ProviderScope(
        child: MyApp(),
      ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

@override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final settings = ref.watch(settingsProvider);
    
    return provider.ChangeNotifierProvider(
      create: (ctx) => Auth(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.getLightTheme(),
        darkTheme: AppTheme.getDarkTheme(),
        themeMode: settings.theme == 'light' ? ThemeMode.light : ThemeMode.dark,
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', ''),
          Locale('en', ''),
        ],
        home: WelcomeScreen(),
        routes: {
          WelcomeScreen.routeName: (context) => WelcomeScreen(),
          TutorialScreen.routeName: (context) => const TutorialScreen(),
          RegisterPage.routeName: (context) => const RegisterPage(),
          LoginPage.routeName: (context) => const LoginPage(),
          HomePage.routeName: (context) => HomePage(),
          DetailsGarajePage.routeName: (context) => DetailsGarajePage(),
          //GaragesMapScreen.routeName: (context) => GaragesMapScreen(),
          ListCommentsPage.routeName: (context) => ListCommentsPage(),
          AddComments.routeName: (context) => AddComments(),
          RegisterGarage.routeName: (context) => RegisterGarage(),
          RentPage.routeName: (context) => RentPage(),
          //OptionsMyGarage.routeName : (context) => OptionsMyGarage(),
          SmsValidatePage.routeName: (context) => const SmsValidatePage(),
          TimelinePage.routeName: (context) => TimelinePage(),
          UserDetailScreen.routeName: (context) => UserDetailScreen(),
          ForgetPasswordScreen.routeName: (context) => ForgetPasswordScreen(),
          AdScreen.routeName: (context) => const AdScreen(),
          FavoritesScreen.routeName: (context) => const FavoritesScreen(),
          MyGaragesScreen.routeName: (context) => const MyGaragesScreen(),
          SettingsScreen.routeName: (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
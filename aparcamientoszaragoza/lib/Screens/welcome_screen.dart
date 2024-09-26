import 'package:aparcamientoszaragoza/Screens/login/login_screen.dart';
import 'package:aparcamientoszaragoza/Screens/register/register_screen.dart';
import 'package:easter_egg_trigger/easter_egg_trigger.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {

  static const routeName = '/welcome-screen';

  /*
  Widget routeButton(Color buttonColor, String title, Color textColor, BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 25, left: 24, right: 24),
      child: RaisedButton(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        color: buttonColor,
        onPressed: () => context,
        child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor,),),
      ),
    );
  }
  */

  @override
  Widget build(BuildContext context) {

    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.indigo,
      backgroundColor: Colors.indigo,
      minimumSize: Size(88, 36),
      padding: EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
    );

    return Scaffold(
      body:
      EasterEggTrigger(
        action: () => print("Easter Egg !!!"),
        child: bodyWelcomeWidget(raisedButtonStyle: raisedButtonStyle),
        codes: [
          EasterEggTriggers.SwipeLeft,
          EasterEggTriggers.SwipeUp,
        ],
      )
    );
  }
}

class bodyWelcomeWidget extends StatelessWidget {
  const bodyWelcomeWidget({
    super.key,
    required this.raisedButtonStyle,
  });

  final ButtonStyle raisedButtonStyle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(
                    'https://images.unsplash.com/photo-1557683316-973673baf926?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1yZWxhdGVkfDE4fHx8ZW58MHx8fHw%3D&w=1000&q=80'),
                fit: BoxFit.fill),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.only(top: 60, left: 25),
                child: Column(
                  children: [
                    Text('Zaragoza\nParking', style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: Colors.white),),
                    Text('¡Accede a los parking de Zaragoza! Desde Github Actions', style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.white),),
                  ],
                ),
              ),),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Container(
                    height: 80,
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 25, left: 24, right: 24),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamed(LoginPage.routeName),
                      style: raisedButtonStyle,
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,),
                      ),
                    ),
                  ),
                  Container(
                    height: 80,
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 25, left: 24, right: 24),
                    child: ElevatedButton(
                      style: raisedButtonStyle,
                      onPressed: () => Navigator.of(context).pushNamed(RegisterPage.routeName),
                      child: const Text(
                        'Registrar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.lightBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

}

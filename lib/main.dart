import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/ui/splash/loading.dart';
import 'package:flexflutter/ui/splash/splash.dart';
import 'package:flexflutter/ui/signin.dart';
import 'package:flexflutter/ui/signup.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        LOADING_SCREEN: (BuildContext context) => LoadingScreen(),
        SPLASH_SCREEN: (BuildContext context) =>  SplashScreen(),
        SIGN_IN: (BuildContext context) =>  SignInScreen(),
        SIGN_UP: (BuildContext context) =>  SignUpScreen(),
      },
      initialRoute: LOADING_SCREEN,
    );
  }
}




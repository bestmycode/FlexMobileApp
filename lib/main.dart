import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/ui/splash/loading.dart';
import 'package:flexflutter/ui/splash/splash.dart';
import 'package:flexflutter/ui/auth/signin/signin.dart';
import 'package:flexflutter/ui/auth/signin/signin_auth.dart';
import 'package:flexflutter/ui/auth/signin/forgotpwd.dart';
import 'package:flexflutter/ui/auth/signup/index.dart';
import 'package:flexflutter/ui/main.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        LOADING_SCREEN: (BuildContext context) => const LoadingScreen(),
        SPLASH_SCREEN: (BuildContext context) =>  const SplashScreen(),
        SIGN_IN: (BuildContext context) =>  const SignInScreen(),
        SIGN_IN_AUTH: (BuildContext context) =>  const SignInAuthScreen(),
        FORGOT_PWD: (BuildContext context) =>  const ForgotPwdScreen(),
        SIGN_UP: (BuildContext context) =>  const SignUpScreen(),
        MAIN_SCREEN: (BuildContext context) =>  const MainScreen(),
      },
      initialRoute: LOADING_SCREEN,
    );
  }
}




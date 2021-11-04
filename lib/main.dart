import 'package:flexflutter/ui/auth/signup/almost_done.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/ui/splash/loading.dart';
import 'package:flexflutter/ui/splash/splash.dart';
import 'package:flexflutter/ui/auth/signin/signin.dart';
import 'package:flexflutter/ui/auth/signin/signin_auth.dart';
import 'package:flexflutter/ui/auth/signin/forgotpwd.dart';
import 'package:flexflutter/ui/auth/signup/index.dart';
import 'package:flexflutter/ui/auth/signup/mail_verify.dart';
import 'package:flexflutter/ui/auth/signup/company_detail.dart';
import 'package:flexflutter/ui/auth/signup/registered_address.dart';
import 'package:flexflutter/ui/auth/signup/main_contact_person.dart';
import 'package:flexflutter/ui/auth/signup/two_step_verification.dart';
import 'package:flexflutter/ui/auth/signup/two_step_final.dart';
import 'package:flexflutter/ui/auth/signup/two_step_failed.dart';
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
        MAIL_VERIFY: (BuildContext context) => const MailVerifyScreen(),
        COMPANY_DETAIL: (BuildContext context) => const CompanyDetailScreen(),
        REGISTERED_ADDRESS: (BuildContext context) => const RegisteredAddressScreen(),
        MAIN_CONTACT_PERSON: (BuildContext context) => const MainContactPersonScreen(),
        TWO_STEP_VERIFICATION: (BuildContext context) => const TwoStepVerificationScreen(),
        TWO_STEP_FINAL: (BuildContext context) => const TwoStepFinalScreen(),
        TWO_STEP_FAILED: (BuildContext context) => const TwoStepFailedScreen(),
        ALMOST_DONE: (BuildContext context) => const AlmostDoneScreen(),
        MAIN_SCREEN: (BuildContext context) =>  const MainScreen(),
      },
      initialRoute: LOADING_SCREEN,
    );
  }
}




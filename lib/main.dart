import 'package:co/ui/auth/signup/almost_done.dart';
import 'package:co/ui/main/cards/physical_card.dart';
import 'package:co/ui/main/cards/virtual_card.dart';
import 'package:co/ui/main/credit/credit.dart';
import 'package:co/ui/main/home/home.dart';
import 'package:co/ui/main/transactions/transaction_admin.dart';
import 'package:co/ui/main/transactions/transaction_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:co/constants/constants.dart';
import 'package:co/ui/splash/loading.dart';
import 'package:co/ui/splash/splash.dart';
import 'package:co/ui/auth/signin/signin.dart';
import 'package:co/ui/auth/signin/signin_auth.dart';
import 'package:co/ui/auth/signin/forgotpwd.dart';
import 'package:co/ui/auth/signup/index.dart';
import 'package:co/ui/auth/signup/mail_verify.dart';
import 'package:co/ui/auth/signup/company_detail.dart';
import 'package:co/ui/auth/signup/registered_address.dart';
import 'package:co/ui/auth/signup/main_contact_person.dart';
import 'package:co/ui/auth/signup/two_step_verification.dart';
import 'package:co/ui/auth/signup/two_step_final.dart';
import 'package:co/ui/auth/signup/two_step_failed.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

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
        SPLASH_SCREEN: (BuildContext context) => const SplashScreen(),
        SIGN_IN: (BuildContext context) => const SignInScreen(),
        SIGN_IN_AUTH: (BuildContext context) => const SignInAuthScreen(),
        FORGOT_PWD: (BuildContext context) => const ForgotPwdScreen(),
        SIGN_UP: (BuildContext context) => const SignUpScreen(),
        MAIL_VERIFY: (BuildContext context) => const MailVerifyScreen(),
        COMPANY_DETAIL: (BuildContext context) => const CompanyDetailScreen(),
        REGISTERED_ADDRESS: (BuildContext context) =>
            const RegisteredAddressScreen(),
        MAIN_CONTACT_PERSON: (BuildContext context) =>
            const MainContactPersonScreen(),
        TWO_STEP_VERIFICATION: (BuildContext context) =>
            const TwoStepVerificationScreen(),
        TWO_STEP_FINAL: (BuildContext context) => const TwoStepFinalScreen(),
        TWO_STEP_FAILED: (BuildContext context) => const TwoStepFailedScreen(),
        ALMOST_DONE: (BuildContext context) => const AlmostDoneScreen(),
        // MAIN_SCREEN: (BuildContext context) =>  MainScreen(),
        HOME_SCREEN: (BuildContext context) => const HomeScreen(),
        PHYSICAL_CARD: (BuildContext context) => const PhysicalCards(),
        VIRTUAL_CARD: (BuildContext context) => const VirtualCards(),
        TRANSACTION_ADMIN: (BuildContext context) => const TransactionAdmin(),
        TRANSACTION_USER: (BuildContext context) => const TransactionUser(),
        CREDIT_SCREEN: (BuildContext context) => const CreditScreen(),
      },
      initialRoute: LOADING_SCREEN,
    );
  }
}

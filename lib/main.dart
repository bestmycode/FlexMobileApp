import 'package:co/ui/auth/signup/almost_done.dart';
import 'package:co/ui/auth/signup/signup_web.dart';
import 'package:co/ui/main/cards/physical_card.dart';
import 'package:co/ui/main/cards/virtual_card.dart';
import 'package:co/ui/main/credit/credit.dart';
import 'package:co/ui/main/home/home.dart';
import 'package:co/ui/main/transactions/transaction_admin.dart';
import 'package:co/ui/main/transactions/transaction_user.dart';
import 'package:co/ui/splash/first_loading.dart';
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

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:localstorage/localstorage.dart';

// void main() => runApp(MyApp());
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Intercom.initialize(
    'gyig20s7',
    androidApiKey: 'android_sdk-b636d4562969f34701d23ae59be81ca77ca619d5',
    iosApiKey: 'ios_sdk-121e7be1206bf3835b6187b837d61c37fe28f9c0',
  );
  await Intercom.registerUnidentifiedUser();
  /*
  final LocalStorage userStorage = LocalStorage('user_info');
  final signed_user = {
    'email': userStorage.getItem('email'),
    'name': userStorage.getItem('name'),
    'phone': userStorage.getItem('phone'),
    'company': userStorage.getItem('orgName'),
    'companyId': userStorage.getItem('orgId'),
    'userId': userStorage.getItem('id')
  };

  await Intercom.updateUser(signed_user);
  */
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''), // English, no country code
        Locale('vi', ''), // Vietnamese, no country code
        Locale('ru', ''), // Russian, no country code
      ],
      home: SplashScreen(),
      routes: <String, WidgetBuilder>{
        LOADING_SCREEN: (BuildContext context) => const LoadingScreen(),
        FIRST_LOADING_SCREEN: (BuildContext context) =>
            const FirstLoadingScreen(),
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
        SIGN_UP_WEB: (BuildContext context) => const SignUpWebScreen(),
      },
      initialRoute: LOADING_SCREEN,
    );
  }
}

class SINGUP_WEB {}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/widgets.dart';
import 'package:co/ui/auth/signup/almost_done.dart';
import 'package:co/ui/auth/signup/signup_web.dart';
import 'package:co/ui/main/cards/physical_card.dart';
import 'package:co/ui/main/cards/virtual_card.dart';
import 'package:co/ui/main/credit/credit.dart';
import 'package:co/ui/main/home/home.dart';
import 'package:co/ui/main/transactions/transaction_admin.dart';
import 'package:co/ui/main/transactions/transaction_user.dart';
import 'package:co/ui/splash/first_loading.dart';
import 'package:co/constants/constants.dart';
import 'package:co/ui/splash/loading.dart';
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
import 'package:new_version/new_version.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    tz.initializeTimeZones();

    await Intercom.initialize(
      'gyig20s7',
      androidApiKey: 'android_sdk-b636d4562969f34701d23ae59be81ca77ca619d5',
      iosApiKey: 'ios_sdk-121e7be1206bf3835b6187b837d61c37fe28f9c0',
    );

    await Intercom.registerUnidentifiedUser();

    await SentryFlutter.init(
      (options) => options.dsn =
          'https://757abfffd5094eedbd5ae17059778f1a@o65628.ingest.sentry.io/5376823',
      appRunner: () => runApp(MyApp()),
    );
  }, (exception, stackTrace) async {
    await Sentry.captureException(exception, stackTrace: stackTrace);
  });
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

    final newVersion = NewVersion(
      iOSId: '284815942',
      androidId: 'com.android.chrome',
    );

    const simpleBehavior = true;
    if (simpleBehavior) {
      basicStatusCheck(newVersion);
    } else {
      advancedStatusCheck(newVersion);
    }
  }

  basicStatusCheck(NewVersion newVersion) {
    newVersion.showAlertIfNecessary(context: context);
  }

  advancedStatusCheck(NewVersion newVersion) async {
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status,
        dialogTitle: 'Custom Title',
        dialogText: 'Custom Text',
      );
    }
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
      home: SignInScreen(),
      routes: <String, WidgetBuilder>{
        LOADING_SCREEN: (BuildContext context) => const LoadingScreen(),
        FIRST_LOADING_SCREEN: (BuildContext context) =>
            const FirstLoadingScreen(),
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

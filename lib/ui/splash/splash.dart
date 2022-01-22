import 'package:co/ui/auth/signin/signin.dart';
import 'package:co/utils/scale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  handleExistingUser() async {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => SignInScreen()),
    );
  }

  handleNewCustomer() async {    
    // Navigator.of(context).push(
    //   CupertinoPageRoute(builder: (context) => SignUpWebScreen()),
    // );
    var signupUrl = 'https://app.staging.fxr.one/signup';
    if (await canLaunch(signupUrl)) {
      await launch(signupUrl);
    } else {
      throw 'Could not launch $signupUrl';
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset(
          "assets/splash_background.png",
          height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height,
          width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
            backgroundColor: Colors.transparent,
            body: Align(
                child: Column(children: <Widget>[
              const CustomSpacer(size: 120),
              logo(),
              const CustomSpacer(size: 130),
              newCustomerButton(),
              const CustomSpacer(size: 26),
              existingUserButton()
            ]))),
      ],
    );
  }

  Widget logo() {
    return Image.asset('assets/logo.png',
        fit: BoxFit.contain, width: wScale(187));
  }

  Widget existingUserButton() {
    return Container(
        width: wScale(295),
        height: hScale(54),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16), border: Border.all()),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () async {
            await handleExistingUser();
          },
          child: Text(AppLocalizations.of(context)!.existingUser,
              style: TextStyle(
                  color: Color(0xff1A2831),
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget newCustomerButton() {
    return Container(
        width: wScale(295),
        height: hScale(54),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 2)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.transparent,
          ),
          onPressed: () async {
            await handleNewCustomer();
          },
          child: Text(AppLocalizations.of(context)!.newCustomer,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
        ));
  }
}

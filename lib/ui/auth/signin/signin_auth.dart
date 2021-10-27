import 'dart:async';

import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;

class SignInAuthScreen extends StatefulWidget {
  const SignInAuthScreen({Key? key}) : super(key: key);

  @override
  SignInAuthScreenState createState() => SignInAuthScreenState();
}

class SignInAuthScreenState extends State<SignInAuthScreen> with SingleTickerProviderStateMixin {

  hScale(double scale) {
    return Scale().hScale(context, scale);
  }
  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  int flagStatus = 0;

  startTime() async {
    var _duration = const Duration(seconds: 3);
    return Timer(_duration, stateAuth);
  }

  stateAuth() {
    setState(() {
      flagStatus = 2;
    });
    Timer(const Duration(seconds: 3), navigationMainPage );
  }

  navigationMainPage() {
    Navigator.of(context).pushReplacementNamed(MAIN_SCREEN);
  }

  handleEnableFaceID() {
    setState(() {
      flagStatus = 1;
    });
    startTime();
  }

  handleSetUpLater() {
    navigationMainPage();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var platform = Theme.of(context).platform;
    return Stack(
      children: <Widget>[
        Image.asset(
          "assets/loading_background.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: platform == TargetPlatform.iOS
              ? flagStatus == 0 ? initAuth('ios') : flagStatus == 1 ? statusAuth("waiting") : statusAuth("done")
              : initAuth('android')
        )
      ],
    );
  }

  Widget initAuth(platform) {
    return Center(
      child: Column(
          children: [
            const CustomSpacer(size: 72),
            Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                width: wScale(71)),
            const CustomSpacer(size: 101),
            Image.asset(
                platform == 'ios' ? 'assets/face_id_white.png' : 'assets/touch_id_white.png',
                fit: BoxFit.contain,
                width: hScale(150)),
            Container(
              margin: EdgeInsets.only(top: hScale(113), left: wScale(40), right: wScale(40)),
              child: Text(
                  platform == 'ios' ? "Secure your account with Face ID" :  "Secure your account with Touch ID",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: const Color(0xffffffff), fontSize: fSize(24))),
            ),
            const CustomSpacer(size: 120),
            enableFaceIDButton(platform),
            const CustomSpacer(size: 14),
            setUpLaterButton()
          ]
      ),
    );
  }

  Widget enableFaceIDButton(platform) {
    return SizedBox(
        width: wScale(187),
        height: hScale(56),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff30E7A9),
            side: const BorderSide(width: 0, color: Color(0xff30E7A9)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
            ),
          ),
          onPressed: () { handleEnableFaceID(); },
          child: Text(
              platform == 'ios' ? "Enable Face ID": 'Enable Touch ID',
              style: TextStyle(color: Colors.black, fontSize: fSize(16), fontWeight: FontWeight.w700 )),
        )
    );
  }

  Widget setUpLaterButton() {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xffffffff),
        textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xffffffff)),
      ),
      onPressed: () { handleSetUpLater(); },
      child: const Text('I’ll set it up later'),
    );
  }

  Widget statusAuth(status) {
    return Center(
      child: Column(
          children: [
            const CustomSpacer(size: 134),
            Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                width: wScale(137)),
            const CustomSpacer(size: 103),
            statusAuthField(status),
          ]
      ),
    );
  }

  Widget statusAuthField(status) {
    return Container(
        width: hScale(155),
        height: hScale(155),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(hScale(8)),
          color: const Color(0xffc0c3c9),
        ),
        child: Center(
          child: Column(
            children: [
              const CustomSpacer(size: 26),
              Image.asset(
                  status == 'waiting' ? 'assets/face_id_blue.png' : 'assets/blue_check.png',
                  fit: BoxFit.contain,
                  width: hScale(72)),
              const CustomSpacer(size: 19),
              Text(
                  "Face ID",
                  style: TextStyle(color: Colors.black, fontSize: fSize(16))),
            ],
          ),
        )
    );
  }
}
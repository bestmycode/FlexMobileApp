import 'dart:async';

import 'package:flexflutter/constants/constants.dart';
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

  // ignore: non_constant_identifier_names
  int flag_status = 0;

  startTime() async {
    var _duration = const Duration(seconds: 3);
    return Timer(_duration, stateAuth);
  }

  stateAuth() {
    setState(() {
      flag_status = 2;
    });
    Timer(const Duration(seconds: 3), navigationMainPage );
  }

  navigationMainPage() {
    Navigator.of(context).pushReplacementNamed(MAIN_SCREEN);
  }

  handleEnableFaceID() {
    setState(() {
      flag_status = 1;
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
    // platform == TargetPlatform.iOS
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
              ? flag_status == 0 ? initAuth('ios') : flag_status == 1 ? statusAuth("waiting") : statusAuth("done")
              : initAuth('android')
        )
      ],
    );
  }

  Widget initAuth(platform) {
    return Center(
      child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: hScale(72)),
              child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                  width: wScale(71)),
            ),
            Container(
              margin: EdgeInsets.only(top: hScale(101)),
              child: Image.asset(
                  platform == 'ios' ? 'assets/face_id_white.png' : 'assets/touch_id_white.png',
                  fit: BoxFit.contain,
                  width: hScale(150)),
            ),
            Container(
              margin: EdgeInsets.only(top: hScale(113), left: wScale(40), right: wScale(40)),
              child: Text(
                  platform == 'ios' ? "Secure your account with Face ID" :  "Secure your account with Touch ID",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: const Color(0xffffffff), fontSize: fSize(24))),

            ),
            enableFaceIDButton(platform),
            setUpLaterButton()
          ]
      ),
    );
  }

  Widget enableFaceIDButton(platform) {
    return Container(
        width: wScale(187),
        height: hScale(56),
        margin: EdgeInsets.only(top: hScale(120)),
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
    return Container(
      margin: EdgeInsets.only(top: hScale(14)),
      child: TextButton(
        style: TextButton.styleFrom(
          primary: const Color(0xffffffff),
          textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xffffffff)),
        ),
        onPressed: () { handleSetUpLater(); },
        child: const Text('I’ll set it up later'),
      )
    );
  }

  Widget statusAuth(status) {
    return Center(
      child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: hScale(134)),
              child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                  width: wScale(137)),
            ),
            statusAuthField(status),
          ]
      ),
    );
  }

  Widget statusAuthField(status) {
    return Container(
        width: hScale(155),
        height: hScale(155),
        margin: EdgeInsets.only(top: hScale(103)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(hScale(8)),
          color: Color(0xffc0c3c9),
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: hScale(26)),
                child: Image.asset(
                    status == 'waiting' ? 'assets/face_id_blue.png' : 'assets/blue_check.png',
                    fit: BoxFit.contain,
                    width: hScale(72)),
              ),
              Container(
                margin: EdgeInsets.only(top: hScale(19)),
                child: Text(
                    "Face ID",
                    style: TextStyle(color: Colors.black, fontSize: fSize(16))),
              )
            ],
          ),
        )
    );
  }
}
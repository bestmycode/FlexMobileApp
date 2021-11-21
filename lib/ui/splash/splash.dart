import 'dart:async';

import 'package:flexflutter/utils/scale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

  hScale(double scale) {
    return Scale().hScale(context, scale);
  }
  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  handleExistingUser() {
    Navigator.of(context).pushReplacementNamed(SIGN_IN);
  }

  handleNewCustomer() {
    Navigator.of(context).pushReplacementNamed(SIGN_UP);
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
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Align(
            child: Column(
                children: <Widget>[
                  const CustomSpacer(size: 120),
                  logo(),
                  const CustomSpacer(size: 130),
                  existingUserButton(),
                  const CustomSpacer(size: 26),
                  newCustomerButton()
                ]
            )
          )
        ),
      ],
    );
  }

  Widget logo() {
   return Image.asset(
    'assets/logo.png',
    fit: BoxFit.contain,
    width: wScale(187));
  }

  Widget existingUserButton() {
    return Container(
      width: wScale(295),
      height: hScale(54),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all()
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)
          ),
        ),
        onPressed: () { handleExistingUser(); },
        child: const Text(
            "Existing User",
            style: TextStyle(color: Color(0xff1A2831), fontSize: 16, fontWeight: FontWeight.w700 )),
      )
    );
  }

  Widget newCustomerButton() {
    return Container(
        width: wScale(295),
        height: hScale(54),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 2)
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.transparent,
          ),
          onPressed: () { handleNewCustomer(); },
          child: const Text(
              "New Customer",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700 )),
        )
    );
  }
}
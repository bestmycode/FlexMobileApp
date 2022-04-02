import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var _visible = true;
  late AnimationController animationController;
  late Animation<double> animation;

  startTime() async {
    var _duration = const Duration(seconds: 3);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() async {
    SharedPreferences prefs = await _prefs;
    bool? isFirst = prefs.getBool("isFirst");
    bool? isRememberd = prefs.getBool("isRemembered");
    isFirst == false
        ? Navigator.of(context).pushReplacementNamed(SIGN_IN)
        : Navigator.of(context).pushReplacementNamed(FIRST_LOADING_SCREEN);
  }

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => setState(() {
          _visible = !_visible;
        }));
    animationController.forward();

    startTime();
  }

  @override
  Widget build(BuildContext context) {
    double widthRatio =
        MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width /
            375;
    return Stack(
      children: <Widget>[
        Image.asset(
          "assets/loading_background.png",
          height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
              .size
              .height,
          width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
              .size
              .width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
              child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.contain,
            width: 161 * widthRatio,
          )),
        )
      ],
    );
  }
}

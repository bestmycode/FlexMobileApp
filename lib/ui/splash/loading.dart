import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/constants/constants.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key key}) : super(key: key);

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  var _visible = true;

  AnimationController animationController;
  Animation<double> animation;

  startTime() async {
    var _duration = const Duration(seconds: 3);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed(SPLASH_SCREEN);
  }

  @override
  void initState() {
    super.initState();
    // animationController =
    //     AnimationController(vsync: this, duration: const Duration(seconds: 3));
    // animation =
    //     CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    // animation.addListener(() => setState(() {
    //       _visible = !_visible;
    //     }));
    // animationController.forward();

    startTime();
  }

  @override
  Widget build(BuildContext context) {
    double widthRatio = MediaQuery.of(context).size.width / 375;
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

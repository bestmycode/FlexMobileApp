import 'dart:async';

import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/scale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/constants/constants.dart';
import 'package:localstorage/localstorage.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstLoadingScreen extends StatefulWidget {
  const FirstLoadingScreen({Key? key}) : super(key: key);

  @override
  FirstLoadingScreenState createState() => FirstLoadingScreenState();
}

class FirstLoadingScreenState extends State<FirstLoadingScreen>
    with SingleTickerProviderStateMixin {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final LocalStorage firstStorage = LocalStorage('first_time');
  var step = 0;

  startTime() async {
    SharedPreferences prefs = await _prefs;
    await prefs.setBool("isFirst", false);

    var _duration = const Duration(seconds: 10);
    return Timer(_duration, nextStep);
  }

  void nextStep() {
    if (step < 3) {
      setState(() {
        step++;
      });
      startTime();
    }
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    var firstDetail = AppLocalizations.of(context)!.welcometoworld;
    var secondDetail =  AppLocalizations.of(context)!.flexletsyouissues;
    var thirdDetail = AppLocalizations.of(context)!.withmoretransparency;
    return Material(
        child: Scaffold(
            body: SingleChildScrollView(
                child: Container(
                    color: Colors.white,
                    child: Column(children: [
                      logo(),
                      step == 0
                          ? firstTitle()
                          : step == 1
                              ? secondTitle()
                              : thirdTitle(),
                      CustomSpacer(size: 25),
                      detail(step == 0
                          ? firstDetail
                          : step == 1
                              ? secondDetail
                              : thirdDetail),
                      CustomSpacer(size: 110),
                      CircularPercentIndicator(
                        radius: hScale(80),
                        animation: true,
                        animationDuration: 30000,
                        lineWidth: 5.0,
                        percent: 1.0,
                        center: progressButton(),
                        circularStrokeCap: CircularStrokeCap.butt,
                        backgroundColor: Color(0xFFEFEFEF),
                        progressColor: Color(0xFF29C490),
                      ),
                      CustomSpacer(size: 19),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed(SPLASH_SCREEN);
                          },
                          child: Text(AppLocalizations.of(context)!.skip,
                              style: TextStyle(
                                  fontSize: fSize(14),
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1A2831))))
                    ])))));
  }

  Widget logo() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: hScale(300),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/signin_top_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                width: wScale(137),
              )
            ]));
  }

  Widget progressButton() {
    return TextButton(
        onPressed: () {
          if (step < 3) {
            nextStep();
          } else {
            Navigator.of(context).pushReplacementNamed(SPLASH_SCREEN);
          }
        },
        child: Container(
          width: hScale(50),
          height: hScale(50),
          decoration: BoxDecoration(
            color: const Color(0xFF29C490),
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
          child: Icon(step == 3 ? Icons.check : Icons.arrow_forward_rounded,
              color: Color(0xFFFFFFFF), size: 20.0),
        ));
  }

  Widget firstTitle() {
    return Container(
        height: hScale(150),
        width: wScale(375),
        alignment: Alignment.center,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: fSize(20),
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A2831),
            ),
            children: [
              TextSpan(text: AppLocalizations.of(context)!.the),
              TextSpan(
                  text: AppLocalizations.of(context)!.simpler, style: TextStyle(color: Color(0xFF29C490))),
              TextSpan(
                  text: AppLocalizations.of(context)!.cashandpayments),
            ],
          ),
        ));
  }

  Widget secondTitle() {
    return Container(
        height: hScale(150),
        width: wScale(375),
        alignment: Alignment.center,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: fSize(20),
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A2831),
            ),
            children: [
              TextSpan(text: AppLocalizations.of(context)!.takechargeof),
              TextSpan(
                  text: AppLocalizations.of(context)!.physicalandvirtualcards,
                  style: TextStyle(color: Color(0xFF29C490))),
            ],
          ),
        ));
  }

  Widget thirdTitle() {
    return Container(
        height: hScale(150),
        width: wScale(375),
        alignment: Alignment.center,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: fSize(20),
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A2831),
            ),
            children: [
              TextSpan(text: AppLocalizations.of(context)!.easily),
              TextSpan(
                  text: AppLocalizations.of(context)!.tracktransactions,
                  style: TextStyle(color: Color(0xFF29C490))),
              TextSpan(text: AppLocalizations.of(context)!.madebyanyone),
            ],
          ),
        ));
  }

  Widget detail(text) {
    return Text(text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: fSize(14), color: Color(0xFF515151)));
  }
}

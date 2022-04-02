import 'dart:async';

import 'package:co/constants/constants.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInAuthScreen extends StatefulWidget {
  const SignInAuthScreen({Key? key}) : super(key: key);

  @override
  SignInAuthScreenState createState() => SignInAuthScreenState();
}

class SignInAuthScreenState extends State<SignInAuthScreen> {
  // final LocalAuthentication _localAuthentication = LocalAuthentication();
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  String title = "";

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
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  navigationMainPage() {
    // Navigator.of(context).pushReplacementNamed(MAIN_SCREEN);
    Navigator.of(context).pushReplacementNamed(HOME_SCREEN);
  }

  handleEnableFaceID() {
    _authenticateWithBiometrics();
  }

  handleSetUpLater() {
    navigationMainPage();
  }

  getBioMetrics() async {
    SharedPreferences prefs = await _prefs;
    bool? bioMetrics = await prefs.getBool("bioMetrics");
    if (bioMetrics == true) {
      _authenticateWithBiometrics();
    }
  }

  @override
  void initState() {
    super.initState();
    getBioMetrics();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );
    _checkBiometrics();
    _getAvailableBiometrics();
  }

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;

    try {
      availableBiometrics = await auth.getAvailableBiometrics();
      setState(() {
        // if (Platform.isIOS) {
          if (availableBiometrics.contains(BiometricType.face)) {
            title = "Enable Face ID";
          } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
            title = "Enable Touch ID";
          }
        // }
      });
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
          localizedReason: ' ', useErrorDialogs: true, stickyAuth: true);
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    setState(
        () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
    navigationMainPage();
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
          localizedReason: ' ',
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: false);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    if (authenticated) {
      final String message = authenticated ? 'Authorized' : 'Not Authorized';
      setState(() {
        _authorized = message;
      });
      SharedPreferences prefs = await _prefs;
      authenticated
          ? await prefs.setBool("bioMetrics", true)
          : await prefs.setBool("bioMetrics", false);
      navigationMainPage();
    }
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

  @override
  Widget build(BuildContext context) {
    var platform = Theme.of(context).platform;
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
            body: platform == TargetPlatform.iOS
                ? flagStatus == 0
                    ? initAuth('ios')
                    : flagStatus == 1
                        ? statusAuth("waiting")
                        : statusAuth("done")
                : initAuth('android'))
      ],
    );
  }

  Widget initAuth(platform) {
    return Center(
      child: Column(children: [
        const CustomSpacer(size: 72),
        Image.asset('assets/logo.png', fit: BoxFit.contain, width: wScale(71)),
        const CustomSpacer(size: 101),
        title == ""
            ? SizedBox(height: hScale(150))
            : Image.asset(
                title == 'Enable Face ID'
                    ? 'assets/face_id_white.png'
                    : 'assets/touch_id_white.png',
                fit: BoxFit.contain,
                height: hScale(150)),
        Container(
          margin: EdgeInsets.only(
              top: hScale(113), left: wScale(40), right: wScale(40)),
          child: Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: const Color(0xffffffff), fontSize: fSize(24))),
        ),
        const CustomSpacer(size: 120),
        title == ""
            ? SizedBox(height: hScale(56))
            : enableFaceIDButton(platform),
        const CustomSpacer(size: 14),
        setUpLaterButton()
      ]),
    );
  }

  Widget enableFaceIDButton(platform) {
    return SizedBox(
        // width: wScale(187),
        height: hScale(56),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff30E7A9),
            side: const BorderSide(width: 0, color: Color(0xff30E7A9)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            handleEnableFaceID();
          },
          child: Text(
              // platform == 'ios'
              //     ? AppLocalizations.of(context)!.enableFaceID
              //     : AppLocalizations.of(context)!.enableTouchID,
              title,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget setUpLaterButton() {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xffffffff),
        textStyle:
            TextStyle(fontSize: fSize(14), color: const Color(0xffffffff)),
      ),
      onPressed: () {
        handleSetUpLater();
      },
      child: Text(AppLocalizations.of(context)!.setUpLater),
    );
  }

  Widget statusAuth(status) {
    return Center(
      child: Column(children: [
        const CustomSpacer(size: 134),
        Image.asset('assets/logo.png', fit: BoxFit.contain, width: wScale(137)),
        const CustomSpacer(size: 103),
        statusAuthField(status),
      ]),
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
                  status == 'waiting'
                      ? 'assets/face_id_blue.png'
                      : 'assets/blue_check.png',
                  fit: BoxFit.contain,
                  width: hScale(72)),
              const CustomSpacer(size: 19),
              Text(AppLocalizations.of(context)!.faceID,
                  style: TextStyle(color: Colors.black, fontSize: fSize(16))),
            ],
          ),
        ));
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

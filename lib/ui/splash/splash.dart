import 'dart:convert';

import 'package:co/utils/scale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/constants/constants.dart';
import 'package:co/ui/widgets/custom_spacer.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterAppAuth appAuth = FlutterAppAuth();
const FlutterSecureStorage secureStorage = FlutterSecureStorage();

/// -----------------------------------
///           Auth0 Variables
/// -----------------------------------

const String AUTH0_DOMAIN = 'bestmycode.us.auth0.com';
const String AUTH0_CLIENT_ID = 'YLwES4vB50rVj7GOQCRqj8zZiX9zSpbw';

const String AUTH0_REDIRECT_URI = 'com.auth0.flutterdemo://login-callback';
const String AUTH0_ISSUER = 'https://$AUTH0_DOMAIN';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool isBusy = false;
  bool isLoggedIn = false;
  String errorMessage;
  String name;
  String picture;

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
    // Navigator.of(context).pushReplacementNamed(SIGN_IN);
    await loginAction();
  }

  handleNewCustomer() {
    Navigator.of(context).pushReplacementNamed(SIGN_UP);
  }

  @override
  void initState() {
    initAction();
    super.initState();
  }

  parseIdToken(String idToken) {
    final List<String> parts = idToken.split('.');
    assert(parts.length == 3);

    return jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  }

  getUserDetails(String accessToken) async {
    const String url = 'https://$AUTH0_DOMAIN/userinfo';
    final http.Response response = await http.get(
      url,
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user details');
    }
  }

  loginAction() async {
    setState(() {
      isBusy = true;
      errorMessage = '';
    });

    try {
      final AuthorizationTokenResponse result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AUTH0_CLIENT_ID,
          AUTH0_REDIRECT_URI,
          issuer: AUTH0_ISSUER,
          scopes: ['openid', 'profile', 'email', 'offline_access', 'api'],
        ),
      );

      final Map<String, Object> idToken = parseIdToken(result.idToken);
      final Map<String, Object> profile =
          await getUserDetails(result.accessToken);

      await secureStorage.write(
          key: 'refresh_token', value: result.refreshToken);

      setState(() {
        isBusy = false;
        isLoggedIn = true;
        name = idToken['name'];
        picture = profile['picture'];
      });
    } on Exception catch (e, s) {
      debugPrint('login error: $e - stack: $s');

      setState(() {
        isBusy = false;
        isLoggedIn = false;
        errorMessage = e.toString();
      });
    }
  }

  logoutAction() async {
    await secureStorage.delete(key: 'refresh_token');
    setState(() {
      isLoggedIn = false;
      isBusy = false;
    });
  }

  initAction() async {
    final String storedRefreshToken =
        await secureStorage.read(key: 'refresh_token');
    if (storedRefreshToken == null) return;

    setState(() {
      isBusy = true;
    });

    try {
      final TokenResponse response = await appAuth.token(TokenRequest(
        AUTH0_CLIENT_ID,
        AUTH0_REDIRECT_URI,
        issuer: AUTH0_ISSUER,
        refreshToken: storedRefreshToken,
      ));

      final Map<String, Object> idToken = parseIdToken(response.idToken);
      final Map<String, Object> profile =
          await getUserDetails(response.accessToken);

      await secureStorage.write(
          key: 'refresh_token', value: response.refreshToken);

      setState(() {
        isBusy = false;
        isLoggedIn = true;
        name = idToken['name'];
        picture = profile['picture'];
      });
    } on Exception catch (e, s) {
      debugPrint('error on refresh token: $e - stack: $s');
      await logoutAction();
    }
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
                child: Column(children: <Widget>[
              const CustomSpacer(size: 120),
              logo(),
              const CustomSpacer(size: 130),
              isBusy
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        isLoggedIn
                            ? newCustomerButton()
                            :
                            // const CustomSpacer(size: 26),
                            existingUserButton()
                      ],
                    )
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
          child: const Text("Existing User",
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
          onPressed: () {
            handleNewCustomer();
          },
          child: const Text("New Customer",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
        ));
  }
}

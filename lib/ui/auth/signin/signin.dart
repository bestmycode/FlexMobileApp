import 'dart:convert';

import 'package:co/ui/auth/signin/forgotpwd.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/utils/basedata.dart';
import 'package:co/utils/token.dart';
import 'package:co/utils/validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/constants/constants.dart';
import 'package:co/utils/scale.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:auth0/auth0.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage loginStorage = LocalStorage('login_user');
  final emailCtr = TextEditingController();
  final passwordCtr = TextEditingController();
  String errorText = '';
  bool flagRemember = false;
  bool loading = false;
  bool isErrorEmailCtl = false;
  bool isErrorPasswordCtl = false;
  bool showPassword = true;
  bool bioMetrics = false;
  late String firstName = '';
  late String email = '';
  late String password = '';

  final LocalAuthentication auth = LocalAuthentication();
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  getDefaultValue() async {
    SharedPreferences prefs = await _prefs;
    bool? isRemembered = prefs.getBool("isRemembered");
    bool? temp_bioMetrics = prefs.getBool("bioMetrics");
    String? temp_firstName = prefs.getString("firstName");
    String? temp_email = prefs.getString('email');
    String? temp_password = prefs.getString('password');

    setState(() {
      bioMetrics = temp_bioMetrics == true ? true : false;
      firstName = temp_firstName != null ? temp_firstName : '';
      email = temp_email != null ? temp_email : '';
      password = temp_password != null ? temp_password : '';
    });

    if (isRemembered == true) {
      emailCtr.text = prefs.getString("email")!;
      passwordCtr.text = prefs.getString("password")!;
      setState(() {
        flagRemember = true;
      });
    }
  }

  handleLogin() {
    if (emailCtr.text == '') {
      this.setState(() {
        isErrorEmailCtl = true;
      });
    } else if (passwordCtr.text == '') {
      this.setState(() {
        isErrorPasswordCtl = true;
      });
    } else {
      _handleLogin(0);
    }
  }

  _handleLogin(type) async {
    setState(() {
      isErrorEmailCtl = false;
      isErrorPasswordCtl = false;
      loading = true;
    });

    Uri url = Uri.parse('${BaseData.BASE_URL}/oauth/token');

    var data = {
      "client_id": BaseData.CLIENT_ID,
      "client_secret": BaseData.CLIENT_SECRET,
      "audience": BaseData.AUDIENCE,
      "grant_type": "client_credentials"
    };

    var tokenResponse = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: json.encode(data));

    var body = json.decode(tokenResponse.body);
    var token = body["access_token"];
    storage.setItem('client_token', token);

    var client = Auth0Client(
        clientId: data["client_id"].toString(),
        clientSecret: data["client_secret"].toString(),
        domain: "finaxar-staging.auth0.com",
        connectTimeout: 10000,
        sendTimeout: 10000,
        receiveTimeout: 60000,
        useLoggerInterceptor: true,
        accessToken: token);

    try {
      var user = await client.passwordGrant({
        // "username": "ronak+testflex@finaxar.com",
        // "password": "Gofast@123",
        // "username": "ronak+testivbbank1@finaxar.com",
        // "password": "Gofast@123",
        // "username": "demo@flexnow.co",
        // "password": "Flex@01082021",
        // "username": "holger610@vomoto.com",
        // "password": "1qaz@WSX",
        // "username": "anubha.gupta+tes0909@finaxar.com",
        // "password": "Anubha@22",
        "username": type == 0 ? emailCtr.text : email,
        "password": type == 0 ? passwordCtr.text : password,
        "scope": "openid profile email",
        "realm": "Username-Password-Authentication"
      });

      var accessToken = user.accessToken;
      storage.setItem('jwt_token', accessToken);
      setState(() {
        loading = false;
      });

      SharedPreferences prefs = await _prefs;
      await prefs.setString("email", emailCtr.text);
      await prefs.setString("password", passwordCtr.text);
      await loginStorage.setItem("email", emailCtr.text);
      await loginStorage.setItem("password", passwordCtr.text);

      if (flagRemember) {
        await prefs.setBool("isRemembered", true);
      } else {
        await prefs.setBool("isRemembered", false);
      }
      bool? temp_biometrics = await prefs.getBool('bioMetrics');
      if(temp_biometrics == true && type == 0) {
        _authenticateWithBiometrics(); // right ?
      } else {
        Navigator.of(context)
          .pushReplacementNamed(type == 0 ? SIGN_IN_AUTH : HOME_SCREEN);
      }
    } catch (error) {
      setState(() {
        loading = false;
        errorText = error.toString().split('invalid_grant')[1];
      });
    }
  }

  handleRegister() async {
    // Navigator.of(context).pushReplacementNamed(SIGN_UP_WEB);
    var signupUrl = 'https://app.staging.fxr.one/signup';
    if (await canLaunch(signupUrl)) {
      await launch(signupUrl);
    } else {
      throw 'Could not launch $signupUrl';
    }
  }

  handleForgotPwd() {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => ForgotPwdScreen()),
    );
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
      _handleLogin(1);
    }
  }

  handleLoginSecurely() {
    _authenticateWithBiometrics();
  }

  @override
  void initState() {
    super.initState();
    getDefaultValue();
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
        client: Token().getLink(Token().getClientToken()), child: main());
  }

  Widget main() {
    print("===========AAAAAAAAAAA======== ${bioMetrics}");
    return Material(
        child: Scaffold(
            body: loading == true
                ? const CustomLoading(isLogin: true)
                : SingleChildScrollView(
                    child: bioMetrics ? secondMethod() : firstMethod())));
  }

  Widget firstMethod() {
    return Container(
        color: Colors.white,
        child: Column(children: [
          logo(),
          const CustomSpacer(size: 66),
          title(),
          const CustomSpacer(size: 50),
          CustomTextField(
              isError: isErrorEmailCtl,
              ctl: emailCtr,
              onChanged: (text) {
                setState(() {
                  isErrorEmailCtl =
                      Validator().validateEmail(text) == "" ? false : true;
                });
              },
              hint: AppLocalizations.of(context)!.enterEmailAddress,
              label: AppLocalizations.of(context)!.email),
          isErrorEmailCtl
              ? Container(
                  height: hScale(32),
                  width: wScale(295),
                  padding: EdgeInsets.only(top: hScale(5)),
                  child: Text(
                      Validator().validateEmail(emailCtr.text).toString(),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: fSize(12),
                          color: Color(0xFFEB5757),
                          fontWeight: FontWeight.w400)))
              : const CustomSpacer(size: 32),
          passwordField(),
          isErrorPasswordCtl
              ? Container(
                  height: hScale(32),
                  width: wScale(295),
                  padding: EdgeInsets.only(top: hScale(5)),
                  child: Text(
                      Validator()
                          .validatePasswordLength(passwordCtr.text)
                          .toString(),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: fSize(12),
                          color: Color(0xFFEB5757),
                          fontWeight: FontWeight.w400)))
              : const CustomSpacer(size: 32),
          forgotPwdField(),
          const CustomSpacer(size: 25),
          loginButton(),
          errorText != '' ? showErrorText() : const CustomSpacer(size: 50),
          registerField()
        ]));
  }

  Widget passwordField() {
    return Stack(children: [
      CustomTextField(
          isError: isErrorPasswordCtl,
          ctl: passwordCtr,
          onChanged: (text) {
            setState(() {
              isErrorPasswordCtl =
                  Validator().validatePasswordLength(text) == "" ? false : true;
            });
          },
          hint: AppLocalizations.of(context)!.enterPassword,
          label: AppLocalizations.of(context)!.password,
          pwd: showPassword),
      Positioned(
        top: hScale(24),
        right: wScale(1),
        child: Container(
          padding: EdgeInsets.all(0),
          height: hScale(16),
          color: Colors.white,
          child: IconButton(
            padding: EdgeInsets.all(0),
            icon: Image.asset(
                showPassword ? 'assets/hide_eye.png' : 'assets/show_eye.png',
                fit: BoxFit.contain,
                height: hScale(16)),
            iconSize: hScale(16),
            onPressed: () {
              setState(() {
                showPassword = !showPassword;
              });
            },
          ),
        ),
      )
    ]);
  }

  Widget logo() {
    return Container(
        width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
            .size
            .width,
        height: hScale(265),
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

  Widget title() {
    return Text(AppLocalizations.of(context)!.letsSignYouIn,
        style: TextStyle(
            color: const Color(0xff1A2831),
            fontSize: fSize(24),
            fontWeight: FontWeight.w700));
  }

  Widget forgotPwdField() {
    return SizedBox(
        width: wScale(295),
        height: hScale(24),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            rememberMeCheckBox(),
            rememberMeTitle(),
          ]),
          forgotPwdButton()
        ]));
  }

  Widget rememberMeCheckBox() {
    return SizedBox(
        width: hScale(28),
        height: hScale(28),
        child: Transform.scale(
          scale: 1,
          child: Checkbox(
            value: flagRemember,
            activeColor: const Color(0xff30E7A9),
            onChanged: (value) {
              setState(() {
                flagRemember = value!;
              });
            },
          ),
        ));
  }

  Widget rememberMeTitle() {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xFFFFFFFF),
        padding: const EdgeInsets.all(0),
      ),
      child: Text(AppLocalizations.of(context)!.rememberMe,
          style:
              TextStyle(fontSize: fSize(14), color: const Color(0xFF515151))),
      onPressed: () {
        setState(() {
          flagRemember = !flagRemember;
        });
      },
    );
  }

  Widget forgotPwdButton() {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff515151).withOpacity(0.5),
        padding: EdgeInsets.zero,
        textStyle: TextStyle(
            fontSize: fSize(14),
            decoration: TextDecoration.underline,
            color: const Color(0xff515151).withOpacity(0.5)),
      ),
      onPressed: () {
        handleForgotPwd();
      },
      child: Text(AppLocalizations.of(context)!.forgotPassword),
    );
  }

  Widget loginButton() {
    return SizedBox(
        width: wScale(295),
        height: hScale(56),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            handleLogin();
          },
          child: Text(AppLocalizations.of(context)!.login,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget registerField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppLocalizations.of(context)!.dontHaveAnAccount,
            style:
                TextStyle(color: const Color(0xFF666666), fontSize: fSize(14))),
        registerButton(),
      ],
    );
  }

  Widget registerButton() {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff29c490),
        padding: EdgeInsets.all(0),
        textStyle:
            TextStyle(fontSize: fSize(14), color: const Color(0xff29c490)),
      ),
      onPressed: () {
        handleRegister();
      },
      child: Text(' Register on the web browser'),
    );
  }

  Widget showErrorText() {
    return Container(
        width: wScale(295),
        height: hScale(60),
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: hScale(15)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                  child: Text(errorText,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: const Color(0xFFEB5757),
                          fontSize: fSize(16),
                          fontWeight: FontWeight.bold)))
            ]));
  }

  Widget secondMethod() {
    return Column(
      children: [
        logo(),
        CustomSpacer(size: 85),
        // userImage(),
        CustomSpacer(size: 13),
        welcomeUser(),
        CustomSpacer(size: 19),
        useFlex(),
        CustomSpacer(size: 15),
        emailText(),
        CustomSpacer(size: 70),
        loginSecurelyButton(),
        CustomSpacer(size: 90),
        anotherAccountField()
      ],
    );
  }

  Widget userImage() {
    return Container(
      width: wScale(60),
      height: wScale(60),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(wScale(30)),
          topRight: Radius.circular(wScale(30)),
          bottomLeft: Radius.circular(wScale(30)),
          bottomRight: Radius.circular(wScale(30)),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Image.asset(
        'assets/user.png',
        fit: BoxFit.contain,
        width: wScale(60),
      ),
    );
  }

  Widget welcomeUser() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Welcome back, ', style: TextStyle(fontSize: fSize(24))),
        Text(firstName,
            style: TextStyle(fontSize: fSize(24), fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget useFlex() {
    return Text('You are using Flex with',
        style: TextStyle(
            fontSize: fSize(14),
            fontWeight: FontWeight.w800,
            color: Color(0xFF515151)));
  }

  Widget emailText() {
    return Text(email,
        style: TextStyle(
            fontSize: fSize(18),
            fontWeight: FontWeight.w600,
            color: Color(0xFF29C490)));
  }

  Widget loginSecurelyButton() {
    return SizedBox(
        width: wScale(295),
        height: hScale(56),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            handleLoginSecurely();
          },
          child: Text('Login Securely',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget anotherAccountField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Not ${firstName}? Login to another account',
            style:
                TextStyle(color: const Color(0xFF666666), fontSize: fSize(14))),
        anotherLoginButton(),
      ],
    );
  }

  Widget anotherLoginButton() {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff29c490),
        padding: EdgeInsets.all(0),
        textStyle:
            TextStyle(fontSize: fSize(14), color: const Color(0xff29c490)),
      ),
      onPressed: () {
        setState(() {
          bioMetrics = false;
        });
      },
      child: Text('here'),
    );
  }
}

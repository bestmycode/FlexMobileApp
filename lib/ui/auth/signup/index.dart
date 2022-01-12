import 'dart:convert';

import 'package:auth0/auth0.dart';
import 'package:co/ui/auth/signup/mail_verify.dart';
import 'package:co/utils/basedata.dart';
import 'package:co/utils/token.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:co/ui/widgets/custom_mobile_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:co/constants/constants.dart';
import 'package:co/utils/scale.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/signup_progress_header.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final LocalStorage storage = LocalStorage('sign_up_info1');
  final LocalStorage tokenStorage = LocalStorage('token');
  final firstNameCtl = TextEditingController();
  final lastNameCtl = TextEditingController();
  final mobileNumberCtl = TextEditingController();
  final companyNameCtl = TextEditingController();
  final companyEmailCtl = TextEditingController();
  final passwordCtl = TextEditingController();
  late String testtext = 'tete';

  bool flagTerm = false;
  int signUpProgress = 1;
  String errorText = '';

  handleBack() {
    Navigator.of(context).pop();
  }

  handleContinue() async {
    setState(() {
      errorText = '';
    });
    storage.setItem('firstName', firstNameCtl.text);
    storage.setItem('lastName', lastNameCtl.text);
    storage.setItem('mobileNumber', mobileNumberCtl.text);
    storage.setItem('companyName', companyNameCtl.text);
    storage.setItem('companyEmail', companyEmailCtl.text);
    storage.setItem('password', passwordCtl.text);
    storage.setItem('flagTerm', flagTerm);

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
      var user = await client.createUser({
        "email": companyEmailCtl.text,
        "password": passwordCtl.text,
        "connection": "Username-Password-Authentication",
        "metadata": {
          "phone": mobileNumberCtl.text,
          "first_name": firstNameCtl.text,
          "last_name": lastNameCtl.text,
        }
      });

      var temp_user = await client.passwordGrant({
        // "username": companyEmailCtl.text,
        // "password": passwordCtl.text,
        // "username": "demo@flexnow.co",
        // "password": "Flex@01082021",
        "username":"ronak+testivbbank1@finaxar.com",
	      "password": "Gofast@123",
        "scope": "openid profile email",
        "realm": "Username-Password-Authentication"
      });
      
      var accessToken = temp_user.accessToken;
      await tokenStorage.setItem('jwt_token', accessToken);


      // Uri url = Uri.parse('${BaseData.BASE_URL}/co/authenticate');

      // var data = {
      //   "client_id": BaseData.CLIENT_ID,
      //   "credential_type": "http://auth0.com/oauth/grant-type/password-realm",
      //   "realm": "Username-Password-Authentication",
      //   "username": companyEmailCtl.text,
      //   "password": passwordCtl.text
      // };  

      // var jwtTokenResponse = await http.post(url,
      //     headers: {
      //       "Content-Type": "application/json",
      //       "auth0-client": token,
      //       "Origin": "https://app.staging.fxr.one",
      //       "Referer": "https://app.staging.fxr.one/"
      //     }, body: json.encode(data));

      // var jwtbody = json.decode(jwtTokenResponse.body);
      // var jwttoken = jwtbody["access_token"];
      
      // print("----------------");
      // print(token);
      // print("----------------");
      // print(jwtbody);
      // print("----------------");
      // print(jwttoken);

      // await tokenStorage.setItem('jwt_token', jwttoken);
      
      Navigator.of(context).push(
        CupertinoPageRoute(builder: (context) => MailVerifyScreen(verifyCode: user['app_metadata']['verification_code'])),
      );
    } catch(error) {
      setState(() {
        errorText = error.toString();
      });
    }
  }

  handleLogin() {
    Navigator.of(context).pushReplacementNamed(SIGN_IN);
  }

  @override
  void initState() {
    firstNameCtl.text = storage.getItem('firstName');
    lastNameCtl.text = storage.getItem('lastName');
    mobileNumberCtl.text = storage.getItem('mobileNumber');
    companyNameCtl.text = storage.getItem('companyName');
    companyEmailCtl.text = storage.getItem('companyEmail');
    passwordCtl.text = storage.getItem('password');
    flagTerm = storage.getItem('flagTerm') ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
        client: Token().getLink(Token().getClientToken()),
        child: main()
    );
  }

  Widget main() {
    return Material(
        child: Scaffold(
            body: SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  child: Column(children: [
      const SignupProgressHeader(prev: SPLASH_SCREEN),
      const CustomSpacer(size: 38),
      CustomTextField(
          ctl: firstNameCtl, hint: 'Enter First Name', label: 'First Name'),
      const CustomSpacer(size: 32),
      CustomTextField(
          ctl: lastNameCtl, hint: 'Enter Last Name', label: 'Last Name'),
      const CustomSpacer(size: 32),
      CustomMobileTextField(
          ctl: mobileNumberCtl,
          hint: 'Enter Mobile Number',
          label: 'Mobile Number'),
      const CustomSpacer(size: 32),
      CustomTextField(
          ctl: companyNameCtl,
          hint: 'Enter Company Name',
          label: 'Registered Company Name'),
      const CustomSpacer(size: 32),
      CustomTextField(
          ctl: companyEmailCtl,
          hint: 'Enter Company Email Address',
          label: 'Company Email Address'),
      const CustomSpacer(size: 32),
      CustomTextField(
          ctl: passwordCtl,
          hint: 'At Least 8 Characters',
          label: 'Password',
          pwd: true),
      const CustomSpacer(size: 21),
      termsField(),
      const CustomSpacer(size: 22),
      continueButton(),
      errorText != ''? showErrorText() : const CustomSpacer(size: 45),
      loginField(),
      const CustomSpacer(size: 52),
                
                
    ])))));
  }

  Widget termsField() {
    return Container(
      width: wScale(295),
      height: hScale(48),
      alignment: Alignment.topLeft,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            termsCheckBox(),
            termsTitle(),
          ]),
    );
  }

  Widget termsCheckBox() {
    return SizedBox(
        width: hScale(14),
        height: hScale(24),
        child: Transform.scale(
          scale: 0.7,
          child: Checkbox(
            value: flagTerm,
            activeColor: const Color(0xff30E7A9),
            onChanged: (value) {
              setState(() {
                flagTerm = value!;
              });
            },
          ),
        ));
  }

  Widget termsTitle() {
    return SizedBox(
        width: wScale(264),
        height: hScale(48),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: fSize(14),
              color: Colors.black,
            ),
            children: const [
              TextSpan(
                  text: 'I agree to the ',
                  style: TextStyle(color: Color(0xFF515151))),
              TextSpan(
                  text: 'terms of use ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF515151))),
              TextSpan(
                  text: 'and ', style: TextStyle(color: Color(0xFF515151))),
              TextSpan(
                  text: 'privacy policy',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF515151))),
            ],
          ),
        ));
  }

  Widget continueButton() {
    return SizedBox(
        width: wScale(295),
        height: hScale(56),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: flagTerm ? const Color(0xff1A2831) : const Color(0xff1A2831).withOpacity(0.5),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            flagTerm ? handleContinue() : null;
          },
          child: Text("Continue",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget loginField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account?",
            style:
                TextStyle(color: const Color(0xFF666666), fontSize: fSize(14))),
        loginButton()
      ],
    );
  }

  Widget loginButton() {
    return SizedBox(
        width: wScale(40),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            primary: const Color(0xff29c490),
            textStyle:
                TextStyle(fontSize: fSize(14), color: const Color(0xff29c490)),
          ),
          onPressed: () {
            handleLogin();
          },
          child: const Text('Login'),
        ));
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
        children: [Flexible(child: 
            Text(errorText,
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFEB5757),
                fontSize: fSize(16),
                fontWeight: FontWeight.bold)))
        ]
      )      
    );
  }
}

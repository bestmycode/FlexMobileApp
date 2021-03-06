import 'dart:convert';

import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/basedata.dart';
import 'package:co/utils/validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/constants/constants.dart';
import 'package:co/utils/scale.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ForgotPwdScreen extends StatefulWidget {
  const ForgotPwdScreen({Key? key}) : super(key: key);

  @override
  ForgotPwdScreenState createState() => ForgotPwdScreenState();
}

class ForgotPwdScreenState extends State<ForgotPwdScreen> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final emailCtr = TextEditingController();
  String resultText = "";
  bool flagSubmit = false;
  bool isErrorEmailCtl = false;

  handleBack() {
    Navigator.of(context).pop();
  }

  handleSubmit() async {
    String? valid = Validator().validateEmail(emailCtr.text);
    if (valid != "") {
      setState(() {
        isErrorEmailCtl = true;
      });
    } else {
      Uri url = Uri.parse('${BaseData.BASE_URL}/dbconnections/change_password');
      var data = {
        "client_id": BaseData.CLIENT_ID,
        "client_secret": BaseData.CLIENT_SECRET,
        "Referer": "https://app.staging.fxr.one/",
        "connection": "Username-Password-Authentication",
        "email": emailCtr.text
      };
      try {
        await http.post(url,
            headers: {"Content-Type": "application/json"},
            body: json.encode(data));

        setState(() {
          flagSubmit = true;
        });
      } catch (error) {
        print("===== Error : Forgot Password Error =====");
        print(error);
        await Sentry.captureException(error);
        return null;
      }
    }
  }

  handleLogin() {
    Navigator.of(context).pushReplacementNamed(SIGN_IN);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Align(
                child: Column(children: [
      header(),
      flagSubmit
          ? loginTitle()
          : Column(
              children: [
                submitTitle(),
                const CustomSpacer(size: 46),
                CustomTextField(
                    ctl: emailCtr,
                    isError: isErrorEmailCtl,
                    onChanged: (text) {
                      setState(() {
                        isErrorEmailCtl = Validator().validateEmail(text) == ""
                            ? false
                            : true;
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
              ],
            ),
      customButton(flagSubmit)
    ]))));
  }

  Widget header() {
    return Container(
        width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
            .size
            .width,
        height: hScale(109),
        padding: EdgeInsets.only(top: hScale(49)),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/signup_top_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(children: [
          SizedBox(
              width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .width,
              height: hScale(40),
              child: Stack(alignment: Alignment.center, children: [
                Text(AppLocalizations.of(context)!.forgotPassword,
                    style: TextStyle(
                        color: const Color(0xffffffff),
                        fontSize: fSize(24),
                        fontWeight: FontWeight.w600)),
                backButton()
              ])),
        ]));
  }

  Widget backButton() {
    return Positioned(
        left: 24.0,
        top: 0.0,
        child: Container(
          width: hScale(40),
          height: hScale(40),
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: const Color(0xffF5F5F5).withOpacity(0.4),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(hScale(10)),
              topRight: Radius.circular(hScale(10)),
              bottomLeft: Radius.circular(hScale(10)),
              bottomRight: Radius.circular(hScale(10)),
            ),
          ),
          child: TextButton(
              style: TextButton.styleFrom(
                primary: const Color(0xffF5F5F5).withOpacity(0.4),
                padding: const EdgeInsets.all(0),
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 12,
              ),
              onPressed: () {
                handleBack();
              }),
        ));
  }

  Widget submitTitle() {
    return Container(
        margin: EdgeInsets.only(top: hScale(39)),
        child: Text(AppLocalizations.of(context)!.pleaseEnterYourEmail,
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w600)));
  }

  Widget loginTitle() {
    return Container(
        margin: EdgeInsets.only(top: hScale(92)),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: fSize(16),
              color: Colors.black,
            ),
            children: [
              TextSpan(
                  text: AppLocalizations.of(context)!.weHaveSentAnEmail,
                  style: TextStyle(fontWeight: FontWeight.w600)),
              TextSpan(
                  text: '${emailCtr.text}\n',
                  style: TextStyle(
                      color: Color(0xFF3362c4), fontWeight: FontWeight.w600)),
              TextSpan(
                  text: AppLocalizations.of(context)!.pelaseFollowResetPassword,
                  // text: resultText,
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ));
  }

  Widget customButton(flag) {
    return Container(
        width: wScale(295),
        height: hScale(56),
        margin: EdgeInsets.only(top: hScale(60)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            !flag ? handleSubmit() : handleLogin();
          },
          child: Text(
              !flag
                  ? AppLocalizations.of(context)!.submit
                  : AppLocalizations.of(context)!.loginSpace,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }
}

import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/utils/scale.dart';
import 'package:flexflutter/ui/widgets/custom_textfield.dart';

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
  bool flagSubmit = false;

  handleBack() {}

  handleSubmit() {
    setState(() {
      flagSubmit = true;
    });
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
                    ctl: emailCtr, hint: 'Enter Email Address', label: 'Email'),
              ],
            ),
      customButton(flagSubmit)
    ]))));
  }

  Widget header() {
    return Container(
        width: MediaQuery.of(context).size.width,
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
              width: MediaQuery.of(context).size.width,
              height: hScale(40),
              child: Stack(alignment: Alignment.center, children: [
                Text("Forgot Password",
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
        child: Text("Please enter your \n e-mail address below:",
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
            children: const [
              TextSpan(
                  text: 'We have sent an e-mail to\n',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              TextSpan(
                  text: 'jasmine.foo@flex.com',
                  style: TextStyle(
                      color: Color(0xFF3362c4), fontWeight: FontWeight.w600)),
              TextSpan(
                  text:
                      'Please follow the instructions in the e-mail\n on how to reset your password',
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
          child: Text(!flag ? "Submit" : 'Log In',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }
}

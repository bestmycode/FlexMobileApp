import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/utils/validator.dart';
import 'package:flexflutter/utils/scale.dart';

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

  final emailCtr = TextEditingController();
  final passwordCtr = TextEditingController();

  // ignore: non_constant_identifier_names
  bool flag_remember = false;

  handleLogin() {
    String? emailValidate = Validator().validateEmail(emailCtr.text);
    String? passwordValidate = Validator().validatePasswordLength(passwordCtr.text);
    if(emailValidate!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emailValidate),
        ),
      );
    } else if(passwordValidate!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(passwordValidate),
        ),
      );
    } else {
      Navigator.of(context).pushReplacementNamed(MAIN_SCREEN);
    }
  }

  handleRegister() {
    // ignore: avoid_print
    print('Register Button Clicked');
    Navigator.of(context).pushReplacementNamed(SIGN_UP);
  }

  handleForgotPwd() {
    // ignore: avoid_print
    print('Forgot password Button Clicked');
    Navigator.of(context).pop();
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
          child: Column(
            children: [
              logo(),
              title(),
              emailTextField(),
              passwordTextField(),
              forgotPwdField(),
              loginButton(),
              registerField()
            ]
          )
        )
      )
    );
  }

  Widget logo() {
    return Container(
      width: MediaQuery.of(context).size.width,
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
            width: wScale(137),)
        ]
      )
    );
  }

  Widget title() {
    return Container(
      margin: EdgeInsets.only(top: hScale(66), bottom: hScale(50)),
      child: Text(
          "Let’s Sign You In",
          style: TextStyle(color: const Color(0xff1A2831), fontSize: fSize(24), fontWeight: FontWeight.w700 )),
    );
  }

  Widget emailTextField() {
    return Container(
      width: wScale(295),
      height: hScale(56),
      alignment: Alignment.center,
      child: TextField(
        controller: emailCtr,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: 'Enter Email Address',
          hintStyle: TextStyle(
            color: const Color(0xff040415),
            fontSize: fSize(14),
            fontWeight: FontWeight.w500),
          labelText: ' Email ',
          labelStyle: TextStyle(
            color: const Color(0xff040415),
            fontSize: fSize(14),
            fontWeight: FontWeight.w500),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xff040415),
              width: 1.0)
          ),
        ),
      )
    );
  }

  Widget passwordTextField() {
    return Container(
        width: wScale(295),
        height: hScale(56),
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: hScale(32)),
        child: TextField(
          controller: passwordCtr,
          obscureText: true,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Enter Password',
            hintStyle: TextStyle(
              color: const Color(0xff040415),
              fontSize: fSize(14),
              fontWeight: FontWeight.w500),
            labelText: ' Password ',
            labelStyle: TextStyle(
              color: const Color(0xff040415),
              fontSize: fSize(14),
              fontWeight: FontWeight.w500),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xff040415),
                width: 1.0)
            ),
          ),
        )
    );
  }

  Widget forgotPwdField() {
    return Container(
      width: wScale(295),
      height: hScale(24),
      margin: EdgeInsets.only(top: hScale(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              rememberMeCheckBox(),
              rememberMeTitle(),
            ]
          ),
          forgotPwdButton()
        ]
      )
    );
  }

  Widget rememberMeCheckBox() {
    return SizedBox(
      width: hScale(14),
      height: hScale(14),
      child: Transform.scale(
        scale: 0.7,
        child:Checkbox(
          value: flag_remember,
          activeColor: const Color(0xff30E7A9),
          onChanged: (value) {
            setState(() {
              flag_remember = value!;
            });
          },
        ),
      )
    );
  }

  Widget rememberMeTitle() {
    return Container(
      margin: EdgeInsets.only(left: wScale(17)),
      child: Text(
          "Remember Me",
          style: TextStyle(fontSize: fSize(14))),
    );
  }

  Widget forgotPwdButton() {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff515151),
        padding: EdgeInsets.zero,
        textStyle: TextStyle(fontSize: fSize(14), decoration: TextDecoration.underline,color: const Color(0xff515151)),
      ),
      onPressed: () { handleForgotPwd(); },
      child: const Text('Forgot Password'),
    );
  }

  Widget loginButton() {
    return Container(
        width: wScale(295),
        height: hScale(56),
        margin: EdgeInsets.only(top: hScale(25)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
            ),
          ),
          onPressed: () { handleLogin(); },
          child: Text(
              "Login",
              style: TextStyle(color: Colors.white, fontSize: fSize(16), fontWeight: FontWeight.w700 )),
        )
    );
  }

  Widget registerField() {
    return Container(
      margin: EdgeInsets.only(top: hScale(62)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account?",
            style: TextStyle(color: Colors.black, fontSize: fSize(14), fontWeight: FontWeight.w500 )),
          registerButton()
        ],
      )
    );
  }

  Widget registerButton() {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff30E7A9),
        textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff30E7A9)),
      ),
      onPressed: () { handleRegister(); },
      child: const Text('Register'),
    );
  }
}
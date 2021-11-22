import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/utils/scale.dart';
import 'package:flexflutter/ui/widgets/custom_textfield.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';

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

  bool flagRemember = false;

  handleLogin() {
    // String? emailValidate = Validator().validateEmail(emailCtr.text);
    // String? passwordValidate = Validator().validatePasswordLength(passwordCtr.text);
    // if(emailValidate!.isNotEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(emailValidate),
    //     ),
    //   );
    // } else if(passwordValidate!.isNotEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(passwordValidate),
    //     ),
    //   );
    // } else {
    //   Navigator.of(context).pushReplacementNamed(MAIN_SCREEN);
    // }
    Navigator.of(context).pushReplacementNamed(SIGN_IN_AUTH);
  }

  handleRegister() {
    Navigator.of(context).pushReplacementNamed(SIGN_UP);
  }

  handleForgotPwd() {
    Navigator.of(context).pushReplacementNamed(FORGOT_PWD);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: SingleChildScrollView(
                child: Column(children: [
      logo(),
      const CustomSpacer(size: 66),
      title(),
      const CustomSpacer(size: 50),
      CustomTextField(
          ctl: emailCtr, hint: 'Enter Email Address', label: 'Email'),
      const CustomSpacer(size: 32),
      CustomTextField(
          ctl: passwordCtr,
          hint: 'Enter Password',
          label: 'Password',
          pwd: true),
      const CustomSpacer(size: 24),
      forgotPwdField(),
      const CustomSpacer(size: 25),
      loginButton(),
      const CustomSpacer(size: 62),
      registerField()
    ]))));
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
                width: wScale(137),
              )
            ]));
  }

  Widget title() {
    return Text("Let’s Sign You In",
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
        width: hScale(14),
        height: hScale(14),
        child: Transform.scale(
          scale: 0.7,
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
    return Container(
      margin: EdgeInsets.only(left: wScale(17)),
      child: Text("Remember Me",
          style:
              TextStyle(fontSize: fSize(14), color: const Color(0xFF515151))),
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
      child: const Text('Forgot Password'),
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
          child: Text("Login",
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
        Text("Don't have an account?",
            style:
                TextStyle(color: const Color(0xFF666666), fontSize: fSize(14))),
        registerButton()
      ],
    );
  }

  Widget registerButton() {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff29c490),
        textStyle:
            TextStyle(fontSize: fSize(14), color: const Color(0xff29c490)),
      ),
      onPressed: () {
        handleRegister();
      },
      child: const Text('Register'),
    );
  }
}

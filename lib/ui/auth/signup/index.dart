import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/utils/scale.dart';
import 'package:flexflutter/ui/widgets/custom_textfield.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';

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

  final firstNameCtl = TextEditingController();
  final lastNameCtl = TextEditingController();
  final mobileNumberCtl = TextEditingController();
  final companyNameCtl = TextEditingController();
  final companyEmailCtl = TextEditingController();
  final passwordCtl = TextEditingController();

  bool flagTerm = false;
  int signUpProgress = 1;

  handleBack() {
    Navigator.of(context).pop();
  }

  handleContinue() {
    Navigator.of(context).pushReplacementNamed(MAIN_SCREEN);
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              logo(),
              const CustomSpacer(size: 38),
              CustomTextField(ctl: firstNameCtl, hint: 'Enter First Name', label: ' First Name '),
              const CustomSpacer(size: 32),
              CustomTextField(ctl: lastNameCtl, hint: 'Enter Last Name', label: ' Last Name '),
              const CustomSpacer(size: 32),
              CustomTextField(ctl: mobileNumberCtl, hint: 'Enter Mobile Number', label: ' Mobile Number '),
              const CustomSpacer(size: 32),
              CustomTextField(ctl: companyNameCtl, hint: 'Enter Company Name', label: ' Registered Company Name '),
              const CustomSpacer(size: 32),
              CustomTextField(ctl: companyEmailCtl, hint: 'Enter Company Email Address', label: ' Company Email Address '),
              const CustomSpacer(size: 32),
              CustomTextField(ctl: passwordCtl, hint: 'At Least 8 Characters', label: ' Password ', pwd: true),
              const CustomSpacer(size: 21),
              termsField(),
              const CustomSpacer(size: 22),
              continueButton(),
              const CustomSpacer(size: 45),
              loginField(),
              const CustomSpacer(size: 52),
            ]
          )
        )
      )
    );
  }

  Widget backButton() {
    return Positioned(
      left: 24.0,
      top: 0.0,
      child: SizedBox(
        width: hScale(40),
        height: hScale(40),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff727a80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            ),
            padding: const EdgeInsets.all(0)
          ),
          onPressed: () { handleBack(); },
          child: Icon(Icons.arrow_back_ios, color: Colors.white, size:wScale(13)),
        )
      )
    );
  }

  Widget logo() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: hScale(174),
        padding: EdgeInsets.only(top: hScale(44)),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/signup_top_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: hScale(40),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                        "Create an account",
                        style: TextStyle(color: const Color(0xffffffff), fontSize: fSize(24), fontWeight: FontWeight.w700 )),
                    backButton()
                  ]
                )
              ),
              const CustomSpacer(size: 25),
              signUpProgressField()
            ]
        )
    );
  }

  Widget signUpProgressField() {
    return (
      SizedBox(
        width: MediaQuery.of(context).size.width,
        height: hScale(32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            roundNumber(1, signUpProgress >= 1),
            hypen(signUpProgress >= 1),
            roundNumber(2, signUpProgress >= 2),
            hypen(signUpProgress >= 2),
            roundNumber(3, signUpProgress >= 3),
            hypen(signUpProgress >= 3),
            roundNumber(4, signUpProgress >= 4)
          ],
        ),
      )
    );
  }
  
  Widget roundNumber(num, active) {
    return Container(
      width: hScale(32),
      height: hScale(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: active ? const Color(0xff30E7A9) : Colors.white,
        ),
        borderRadius: BorderRadius.circular(hScale(16)),
      ),
      child: num != 4
          ? Text(num.toString(), style: TextStyle(color: active ? const Color(0xff30E7A9) : Colors.white))
          : Icon(Icons.check , color: active ? const Color(0xff30E7A9) : Colors.white, size: wScale(16)),
    );
  }

  Widget hypen(active) {
    return Container(
      width: 30,
      height: 1,
      color: active ? const Color(0xff30E7A9) : Colors.white,
    );
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
          ]
        ),
      );
  }

  Widget termsCheckBox() {
    return SizedBox(
      width: hScale(14),
      height: hScale(24),
      child: Transform.scale(
        scale: 0.7,
        child:Checkbox(
          value: flagTerm,
          activeColor: const Color(0xff30E7A9),
          onChanged: (value) {
            setState(() {
              flagTerm = value!;
            });
          },
        ),
      )
    );
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
            TextSpan(text: 'I agree to the '),
            TextSpan(text: 'terms of use ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: 'and '),
            TextSpan(text: 'privacy policy', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      )
    );
  }

  Widget continueButton() {
    return SizedBox(
        width: wScale(295),
        height: hScale(56),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
            ),
          ),
          onPressed: () { handleContinue(); },
          child: Text(
              "Continue",
              style: TextStyle(color: Colors.white, fontSize: fSize(16), fontWeight: FontWeight.w700 )),
        )
    );
  }

  Widget loginField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
            "Already have an account?",
            style: TextStyle(color: Colors.black, fontSize: fSize(14), fontWeight: FontWeight.w500 )),
        loginButton()
      ],
    );
  }

  Widget loginButton() {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff30E7A9),
        textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff30E7A9)),
      ),
      onPressed: () { handleLogin(); },
      child: const Text('Login'),
    );
  }
}
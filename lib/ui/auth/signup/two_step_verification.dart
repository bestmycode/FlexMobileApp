import 'package:flexflutter/ui/widgets/signup_progress_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/utils/scale.dart';
import 'package:flexflutter/ui/widgets/custom_textfield.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flutter/services.dart';

class TwoStepVerificationScreen extends StatefulWidget {
  const TwoStepVerificationScreen({Key? key}) : super(key: key);

  @override
  TwoStepVerificationScreenState createState() => TwoStepVerificationScreenState();
}

class TwoStepVerificationScreenState extends State<TwoStepVerificationScreen> {

  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final numCtl1 = TextEditingController();
  final numCtl2 = TextEditingController();
  final numCtl3 = TextEditingController();
  final numCtl4 = TextEditingController();
  final numCtl5 = TextEditingController();
  final numCtl6 = TextEditingController();
  bool flagValid = true;

  handleVerify() {
    bool flag = numCtl1.text == "1" && numCtl2.text == "1" && numCtl3.text == "1" && numCtl4.text == "1" && numCtl5.text == "1" && numCtl6.text == "1";
    setState(() {
      flagValid = flag;
      if(flag) Navigator.of(context).pushReplacementNamed(COMPANY_DETAIL);
    });
  }

  resendEmail() {

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
              const SignupProgressHeader(title: '2-step verification process', progress: 3,),
              const CustomSpacer(size: 30),
              securityIcon(),
              const CustomSpacer(size: 21),
              twoStepTitle(),
              const CustomSpacer(size: 26),
              twoStepSubTitle(),
              const CustomSpacer(size: 36),
              verifyNumberSection(),
              flagValid ? const CustomSpacer(size: 14) : CustomSpacer(size: 0),
              subSection(),
              verifyButton(),
            ]
          )
        )
      )
    );
  }

  Widget securityIcon() {
    return Image.asset(
      'assets/security.png',
      fit: BoxFit.contain,
      width: wScale(74));
  }

  Widget twoStepTitle() {
    return Text(
        "John, we have 2 more steps to go!",
        style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w600 ));
  }

  Widget twoStepSubTitle() {
    return Text(
        "We just need a few more details as part of\nregulatory requirements. Tell us more about\nyourself, James.",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w400 ));
  }

  Widget verifyButton() {
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
          onPressed: () { handleVerify(); },
          child: Text(
              "Verify",
              style: TextStyle(color: Colors.white, fontSize: fSize(16), fontWeight: FontWeight.w700 )),
        )
    );
  }

  Widget verifyNumber(num) {
    return Container(
        width: wScale(50),
        height: wScale(50),
        margin: EdgeInsets.only(right: wScale(4), left: wScale(4)),
        child: TextField(
          textAlign: TextAlign.center,
          controller: num == 1 ? numCtl1 : num == 2 ? numCtl2 : num == 3 ? numCtl3 : num == 4 ? numCtl4 : num == 5 ? numCtl5 : numCtl6,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: fSize(24),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly
          ], // Only numbers can be entered
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(0),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Color(0xff040415),
                    width: 1.0)
            ),
          ),
        ),
    );
  }

  Widget verifyNumberSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        verifyNumber(1),
        verifyNumber(2),
        verifyNumber(3),
        verifyNumber(4),
        verifyNumber(5),
        verifyNumber(6),
      ],
    );
  }

  Widget validError(errorFlag) {
    return SizedBox(
      height: errorFlag ? 0 : hScale(18),
      child: Text(
          "Verification code is invalid",
          style: TextStyle(fontSize: fSize(14), color: const Color(0xffEB5757) )),
    );
  }

  Widget expireTitle() {
    return Text(
        "This OTP expires in 30 minutes",
        style: TextStyle(fontSize: fSize(14), fontWeight: FontWeight.bold ));
  }

  Widget subSection() {
    return SizedBox(
      height: hScale(137),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          validError(flagValid),
          expireTitle(),
          resendButton()
        ],
      ),
    );
  }

  Widget resendButton() {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff21C990),
        textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff21C990), fontWeight: FontWeight.bold),
      ),
      onPressed: () { resendEmail(); },
      child: const Text('Resend OTP to jasmine@gmail.com'),
    );
  }
}
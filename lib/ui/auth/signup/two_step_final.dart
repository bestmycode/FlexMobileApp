import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/ui/widgets/signup_progress_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';

class TwoStepFinalScreen extends StatefulWidget {
  const TwoStepFinalScreen({Key? key}) : super(key: key);

  @override
  TwoStepFinalScreenState createState() => TwoStepFinalScreenState();
}

class TwoStepFinalScreenState extends State<TwoStepFinalScreen> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  handleContinue() {
    Navigator.of(context).pushReplacementNamed(ALMOST_DONE);
  }

  handleResendSMS() {
    Navigator.of(context).pushReplacementNamed(TWO_STEP_FAILED);
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
      const SignupProgressHeader(
        title: '2-step verification process',
        progress: 3,
        prev: TWO_STEP_VERIFICATION,
      ),
      const CustomSpacer(size: 34),
      finalStepBoldTitle('You have reached the final step!', 0xff1A2831),
      const CustomSpacer(size: 19),
      finalStepSubTitle(
          'We have sent you an sms, please click on the link\nand complete your ID verification',
          0xff515151,
          'normal'),
      const CustomSpacer(size: 27),
      finalStepSubTitle('Link will expire in 90 minutes', 0xff29C490, 'bold'),
      const CustomSpacer(size: 37),
      finalStepPhoneIcon(),
      const CustomSpacer(size: 38),
      verifyField(),
      const CustomSpacer(size: 32),
      finalStepBoldTitle(
          'Once you have completed the verification\nprocess, click Continue',
          0xff1A2831),
      const CustomSpacer(size: 38),
      continueButton(),
      const CustomSpacer(size: 30),
      resendSMSButton(),
      const CustomSpacer(size: 76),
    ]))));
  }

  Widget finalStepPhoneIcon() {
    return Image.asset('assets/phone.png',
        fit: BoxFit.contain, width: wScale(37));
  }

  Widget finalStepCardIcon() {
    return Image.asset('assets/idcard.png',
        fit: BoxFit.contain, width: wScale(84));
  }

  Widget finalStepFaceIcon() {
    return Image.asset('assets/faceverify.png',
        fit: BoxFit.contain, width: wScale(74));
  }

  Widget finalStepBoldTitle(title, color) {
    return Text(title,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: fSize(16),
            fontWeight: FontWeight.w600,
            color: Color(color)));
  }

  Widget finalStepSubTitle(title, color, bold) {
    return Text(title,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: fSize(14),
            fontWeight: bold == 'bold' ? FontWeight.bold : FontWeight.normal,
            color: Color(color)));
  }

  Widget verifyField() {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(
          left: wScale(16),
          top: hScale(14),
          right: wScale(16),
          bottom: hScale(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(hScale(10)),
          topRight: Radius.circular(hScale(10)),
          bottomLeft: Radius.circular(hScale(10)),
          bottomRight: Radius.circular(hScale(10)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            spreadRadius: 4,
            blurRadius: 20,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          finalStepBoldTitle(
              'Upon opening the link, follow the\ninstructions provided below on your\nmobile device:',
              0xff1A2831),
          const CustomSpacer(size: 34),
          finalStepCardIcon(),
          const CustomSpacer(size: 24),
          finalStepBoldTitle('1. Upload a photo of your ID', 0xff515151),
          const CustomSpacer(size: 38),
          Container(
            width: wScale(182),
            height: hScale(1),
            color: const Color(0xffd9d9d9),
          ),
          const CustomSpacer(size: 17),
          finalStepFaceIcon(),
          const CustomSpacer(size: 17),
          finalStepBoldTitle('2. Record a video of your face', 0xff515151),
        ],
      ),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            handleContinue();
          },
          child: Text("Continue",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget resendSMSButton() {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff30E7A9),
        textStyle: TextStyle(
            fontSize: fSize(14),
            color: const Color(0xff30E7A9),
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline),
      ),
      onPressed: () {
        handleResendSMS();
      },
      child: const Text('Resend SMS'),
    );
  }
}

import 'package:co/constants/constants.dart';
import 'package:co/ui/widgets/signup_progress_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:co/ui/widgets/custom_spacer.dart';

class TwoStepFailedScreen extends StatefulWidget {
  const TwoStepFailedScreen({Key? key}) : super(key: key);

  @override
  TwoStepFailedScreenState createState() => TwoStepFailedScreenState();
}

class TwoStepFailedScreenState extends State<TwoStepFailedScreen> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  handleTryAgain() {
    Navigator.of(context).pushReplacementNamed(TWO_STEP_FINAL);
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
      const CustomSpacer(size: 149),
      finalStepErrorIcon(),
      const CustomSpacer(size: 22),
      finalStepBoldTitle('You need to complete the verification', 0xff1A2831),
      const CustomSpacer(size: 19),
      finalStepSubTitle(
          'It seems like you have not completed\nyour mobile verification.',
          0xff515151,
          'normal'),
      const CustomSpacer(size: 217),
      tryAgainButton()
    ]))));
  }

  Widget finalStepErrorIcon() {
    return Image.asset('assets/error.png',
        fit: BoxFit.contain, width: wScale(50));
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
            color: Color(color),
            height: 1.7));
  }

  Widget tryAgainButton() {
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
            handleTryAgain();
          },
          child: Text("Try Again",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }
}

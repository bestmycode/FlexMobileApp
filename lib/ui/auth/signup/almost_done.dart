import 'package:co/constants/constants.dart';
import 'package:co/ui/widgets/signup_progress_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:co/ui/widgets/custom_spacer.dart';

class AlmostDoneScreen extends StatefulWidget {
  const AlmostDoneScreen({Key? key}) : super(key: key);

  @override
  AlmostDoneScreenState createState() => AlmostDoneScreenState();
}

class AlmostDoneScreenState extends State<AlmostDoneScreen> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  handleDone() {
    // Navigator.of(context).pushReplacementNamed(MAIN_SCREEN);
    Navigator.of(context).pushReplacementNamed(HOME_SCREEN);
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
          progress: 4,
          prev: TWO_STEP_FINAL),
      const CustomSpacer(size: 34),
      finalStepBoldTitle(
          'You have successfully completed your\nsign up for a Flex account!',
          0xff1A2831),
      const CustomSpacer(size: 40),
      finalStepDoneIcon(),
      const CustomSpacer(size: 40),
      finalStepSubTitle(
          'We have received your application for\nFlex and are verifying your details. We will get back\nto you within 1 working day with your credentials.',
          0xff515151,
          'normal'),
      const CustomSpacer(size: 50),
      doneButton()
    ]))));
  }

  Widget finalStepDoneIcon() {
    return Image.asset('assets/verifyfinish.png',
        fit: BoxFit.contain, width: wScale(260));
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

  Widget doneButton() {
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
            handleDone();
          },
          child: Text("Done",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }
}

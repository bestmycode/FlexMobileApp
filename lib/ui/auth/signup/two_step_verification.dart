import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/ui/widgets/signup_progress_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';
import 'package:flexflutter/ui/widgets/custom_textfield.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';

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

  final firstNameCtl = TextEditingController();
  final lastNameCtl = TextEditingController();
  final birthdayCtl = TextEditingController();
  final countryCtl = TextEditingController();
  final postalCodeCtl = TextEditingController();
  final addressCtl = TextEditingController();
  final billingNameCtl = TextEditingController();
  final streetCtl = TextEditingController();
  final cityCtl = TextEditingController();
  final jobTitleCtl = TextEditingController();
  final companyEmailCtl = TextEditingController();

  handleContinue() {
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
          child: Column(
            children: [
              const SignupProgressHeader(title: '2-step verification process', progress: 3,),
              const CustomSpacer(size: 30),
              securityIcon(),
              const CustomSpacer(size: 21),
              twoStepTitle(),
              const CustomSpacer(size: 26),
              twoStepSubTitle(),
              const CustomSpacer(size: 33),
              personalDetailField(),
              const CustomSpacer(size: 30),
              continueButton(),
              const CustomSpacer(size: 34),
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

  Widget personalDetailField() {
    return Container(
      padding: EdgeInsets.only(left: wScale(16), top: hScale(14), right: wScale(16), bottom: hScale(20)),
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
          detailTitle('Personal Details'),
          const CustomSpacer(size: 22),
          CustomTextField(ctl: firstNameCtl, hint: 'Enter First Name', label: 'First Name'),
          const CustomSpacer(size: 32),
          CustomTextField(ctl: lastNameCtl, hint: 'Enter Last Name', label: 'Last Name'),
          const CustomSpacer(size: 32),
          CustomTextField(ctl: birthdayCtl, hint: 'Select Date of Birth', label: 'Date of Birth (DD/MM/YY)'),
          const CustomSpacer(size: 32),
          CustomTextField(ctl: birthdayCtl, hint: 'Select Country', label: 'Country'),
          const CustomSpacer(size: 32),
          CustomTextField(ctl: birthdayCtl, hint: 'Enter Postal Code', label: 'Postal Code'),
          const CustomSpacer(size: 32),
          CustomTextField(ctl: birthdayCtl, hint: 'Enter Home Address', label: 'Home Address'),
          const CustomSpacer(size: 32),
          CustomTextField(ctl: birthdayCtl, hint: 'Building Name, Level and Unit Number', label: 'Building Name, Level and Unit Number'),
          const CustomSpacer(size: 32),
          CustomTextField(ctl: birthdayCtl, hint: 'Enter Street', label: 'Street'),
          const CustomSpacer(size: 32),
          CustomTextField(ctl: birthdayCtl, hint: 'Select City', label: 'City'),
          const CustomSpacer(size: 32),
          CustomTextField(ctl: birthdayCtl, hint: 'Enter Job Title', label: 'Job Title'),
          const CustomSpacer(size: 32),
          CustomTextField(ctl: birthdayCtl, hint: 'Enter Company Email Address', label: 'Company Email Address'),
        ],
      ),
    );
  }

  Widget detailTitle(title) {
    return SizedBox(
      width: wScale(295),
      child: Text(
          title,
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w600, )),
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
}
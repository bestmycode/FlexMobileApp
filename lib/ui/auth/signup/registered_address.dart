import 'package:flexflutter/ui/widgets/signup_progress_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/utils/scale.dart';
import 'package:flexflutter/ui/widgets/custom_textfield.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flutter/services.dart';

class RegisteredAddressScreen extends StatefulWidget {
  const RegisteredAddressScreen({Key? key}) : super(key: key);

  @override
  RegisteredAddressScreenState createState() => RegisteredAddressScreenState();
}

class RegisteredAddressScreenState extends State<RegisteredAddressScreen> {

  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final companyNameCtl = TextEditingController();
  final companyNumberCtl = TextEditingController();
  final countryCtl = TextEditingController();
  final companyTypeCtl = TextEditingController();
  final companyIndustryCtl = TextEditingController();
  final companyPhoneNumberCtl = TextEditingController();
  bool flagAddress = false;

  handleBack() {
    Navigator.of(context).pushReplacementNamed(COMPANY_DETAIL);
  }

  handleContinue() {
    Navigator.of(context).pushReplacementNamed(MAIN_CONTACT_PERSON);
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
              const SignupProgressHeader(title: 'Company Detail', progress: 2,),
              const CustomSpacer(size: 20),
              groupIcon(),
              const CustomSpacer(size: 15),
              groupTitle(),
              const CustomSpacer(size: 36),
              registeredAddressField(),
              const CustomSpacer(size: 22),
              differentAddressField(),
              flagAddress == true ? const CustomSpacer(size: 22) : const CustomSpacer(size: 0),
              flagAddress == true ? mainOperatingAddressField() :  const CustomSpacer(size: 0),
              const CustomSpacer(size: 37),
              buttonField(),
              const CustomSpacer(size: 48),
            ]
          )
        )
      )
    );
  }

  Widget groupIcon() {
    return Image.asset(
      'assets/group.png',
      fit: BoxFit.contain,
      width: wScale(60));
  }

  Widget groupTitle() {
    return Text(
        "John, please verify that the information\n below is accurate",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w600 ));
  }

  Widget registeredAddressField() {
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
          addressTitle('Registered Address'),
          const CustomSpacer(size: 22),
          CustomTextField(ctl: companyNameCtl, hint: 'Enter Postal Code', label: 'Postal Code'),
          const CustomSpacer(size: 32),
          CustomTextField(ctl: companyNumberCtl, hint: 'Enter Street', label: 'Street'),
          const CustomSpacer(size: 32),
          CustomTextField(ctl: countryCtl, hint: 'Select City', label: 'City'),
        ],
      ),
    );
  }

  Widget addressTitle(title) {
    return SizedBox(
      width: wScale(295),
      child: Text(
          title,
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w600, )),
    );
  }

  Widget differentAddressField() {
    return Container(
      width: wScale(375),
      padding: EdgeInsets.only(left: wScale(24), right: wScale(24)),
      child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            differentAddressCheckBox(),
            Text(
                "My business operates at a different address",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: fSize(14) )),
          ]
      ),
    );
  }

  Widget differentAddressCheckBox() {
    return Container(
        width: hScale(14),
        height: hScale(24),
        margin: EdgeInsets.only(right: wScale(17)),
        child: Transform.scale(
          scale: 0.7,
          child:Checkbox(
            value: flagAddress,
            activeColor: const Color(0xff30E7A9),
            onChanged: (value) {
              setState(() {
                flagAddress = value!;
              });
            },
          ),
        )
    );
  }

  Widget buttonField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        backButton(),
        continueButton()
      ],
    );
  }

  Widget backButton() {
    return Container(
        width: wScale(156),
        height: hScale(56),
        margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xffc9c9c9),
            side: const BorderSide(width: 0, color: Color(0xffc9c9c9)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
            ),
          ),
          onPressed: () { handleBack(); },
          child: Text(
              "Back",
              style: TextStyle(color: Colors.black, fontSize: fSize(16), fontWeight: FontWeight.w700 )),
        )
    );
  }

  Widget continueButton() {
    return Container(
        width: wScale(156),
        height: hScale(56),
        margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
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

  Widget mainOperatingAddressField() {
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
          addressTitle('Main Operating Address'),
          const CustomSpacer(size: 22),
          CustomTextField(ctl: companyNameCtl, hint: 'Enter Operating Address', label: 'Operating Address'),
          const CustomSpacer(size: 32),
          CustomTextField(ctl: companyNumberCtl, hint: 'Enter Postal Code', label: 'Postal Code'),
        ],
      ),
    );
  }

}
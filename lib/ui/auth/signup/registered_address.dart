import 'package:co/ui/widgets/signup_progress_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/constants/constants.dart';
import 'package:co/utils/scale.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:localstorage/localstorage.dart';

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

  final LocalStorage storage = LocalStorage('sign_up_info3');
  var cityArr = ['city1', 'city2', 'city3', 'city4', 'city5'];
  final postalCodeCtl = TextEditingController();
  final streetCtl = TextEditingController();
  final cityCtl = TextEditingController();
  final operatingAddressCtl = TextEditingController();
  final operatingAddressPostalCodeCtl = TextEditingController();
  bool flagAddress = false;

  handleBack() {
    Navigator.of(context).pushReplacementNamed(COMPANY_DETAIL);
  }

  handleContinue() {
    storage.setItem('postalCode', postalCodeCtl.text);
    storage.setItem('street', streetCtl.text);
    storage.setItem('city', cityCtl.text);
    storage.setItem('operatingAddress', operatingAddressCtl.text);
    storage.setItem(
        'operatingAddressPostalCode', operatingAddressPostalCodeCtl.text);
    storage.setItem('flagAddress', flagAddress);

    Navigator.of(context).pushReplacementNamed(MAIN_CONTACT_PERSON);
  }

  @override
  void initState() {
    super.initState();
    postalCodeCtl.text = storage.getItem('postalCode');
    streetCtl.text = storage.getItem('street');
    cityCtl.text = storage.getItem('city');
    operatingAddressCtl.text = storage.getItem('operatingAddress');
    operatingAddressPostalCodeCtl.text =
        storage.getItem('operatingAddressPostalCode');
    flagAddress = storage.getItem('flagAddress') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: SingleChildScrollView(
                child: Column(children: [
      const SignupProgressHeader(
        title: 'Company Detail',
        progress: 2,
      ),
      const CustomSpacer(size: 20),
      groupIcon(),
      const CustomSpacer(size: 15),
      groupTitle(),
      const CustomSpacer(size: 36),
      registeredAddressField(),
      const CustomSpacer(size: 22),
      differentAddressField(),
      flagAddress == true
          ? const CustomSpacer(size: 22)
          : const CustomSpacer(size: 0),
      flagAddress == true
          ? mainOperatingAddressField()
          : const CustomSpacer(size: 0),
      const CustomSpacer(size: 37),
      buttonField(),
      const CustomSpacer(size: 48),
    ]))));
  }

  Widget groupIcon() {
    return Image.asset('assets/group.png',
        fit: BoxFit.contain, width: wScale(60));
  }

  Widget groupTitle() {
    return Text("John, please verify that the information\n below is accurate",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w600));
  }

  Widget registeredAddressField() {
    return Container(
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
          addressTitle('Registered Address'),
          const CustomSpacer(size: 22),
          CustomTextField(
              ctl: postalCodeCtl,
              hint: 'Enter Postal Code',
              label: 'Postal Code'),
          const CustomSpacer(size: 32),
          CustomTextField(
              ctl: streetCtl, hint: 'Enter Street', label: 'Street'),
          const CustomSpacer(size: 32),
          // CustomTextField(ctl: cityCtl, hint: 'Select City', label: 'City'),
          cityTypeField()
        ],
      ),
    );
  }

  Widget addressTitle(title) {
    return SizedBox(
      width: wScale(295),
      child: Text(title,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: fSize(16),
            fontWeight: FontWeight.w600,
          )),
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
            Text("My business operates at a different address",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: fSize(14))),
          ]),
    );
  }

  Widget differentAddressCheckBox() {
    return Container(
        width: hScale(14),
        height: hScale(24),
        margin: EdgeInsets.only(right: wScale(17)),
        child: Transform.scale(
          scale: 0.7,
          child: Checkbox(
            value: flagAddress,
            activeColor: const Color(0xff30E7A9),
            onChanged: (value) {
              setState(() {
                flagAddress = value!;
              });
            },
          ),
        ));
  }

  Widget buttonField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [backButton(), continueButton()],
    );
  }

  Widget backButton() {
    return Container(
        width: wScale(156),
        height: hScale(56),
        margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xffc9c9c9).withOpacity(0.1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            handleBack();
          },
          child: Text("Back",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
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

  Widget mainOperatingAddressField() {
    return Container(
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
          addressTitle('Main Operating Address'),
          const CustomSpacer(size: 22),
          CustomTextField(
              ctl: operatingAddressCtl,
              hint: 'Enter Operating Address',
              label: 'Operating Address'),
          const CustomSpacer(size: 32),
          CustomTextField(
              ctl: operatingAddressPostalCodeCtl,
              hint: 'Enter Postal Code',
              label: 'Postal Code'),
        ],
      ),
    );
  }

  Widget cityTypeField() {
    return Stack(
      children: [
        Container(
          width: wScale(295),
          height: hScale(56),
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: hScale(8)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border:
                  Border.all(color: const Color(0xFF040415).withOpacity(0.1))),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: TextField(
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF040415)),
                controller: cityCtl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
                  hintText: 'Select City',
                  hintStyle: TextStyle(
                      color: const Color(0xffBFBFBF), fontSize: fSize(14)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
                ),
              )),
              PopupMenuButton<String>(
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFFBFBFBF), size: wScale(15)),
                onSelected: (String value) {
                  cityCtl.text = value;
                },
                itemBuilder: (BuildContext context) {
                  return cityArr.map<PopupMenuItem<String>>((String value) {
                    return PopupMenuItem(
                      child: Text(value),
                      value: value,
                      textStyle: TextStyle(
                          fontSize: fSize(16),
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF040415)),
                    );
                  }).toList();
                },
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text('City',
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFBFBFBF))),
          ),
        )
      ],
    );
  }
}

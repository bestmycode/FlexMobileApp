import 'package:co/ui/main/more/complete_new_subsidiary.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class NewSubsidiary extends StatefulWidget {
  const NewSubsidiary({Key key}) : super(key: key);
  @override
  NewSubsidiaryState createState() => NewSubsidiaryState();
}

class NewSubsidiaryState extends State<NewSubsidiary> {
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
  final companyPhoneNumberCtl = TextEditingController();
  final companyAddressCtl = TextEditingController();
  final companyPostalCodeCtl = TextEditingController();
  bool flagAddress = false;

  handleConfirm() {
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (context) => const CompleteNewSubsidiary()),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Stack(children: [
      Container(
        color: Colors.white,
        child: SizedBox(
            height: hScale(812),
            child: SingleChildScrollView(
                child: Column(children: [
              const CustomSpacer(size: 44),
              const CustomMainHeader(title: 'Create New Subsidiary'),
              const CustomSpacer(size: 20),
              groupIcon(),
              const CustomSpacer(size: 15),
              groupTitle(),
              const CustomSpacer(size: 36),
              companyDetailSection(),
              const CustomSpacer(size: 15),
              registeredAddressField(),
              const CustomSpacer(size: 22),
              differentAddressField(),
              const CustomSpacer(size: 37),
              confirmButton(),
              const CustomSpacer(size: 24),
              const CustomSpacer(size: 88),
            ]))),
      ),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 14),
      )
    ])));
  }

  Widget groupIcon() {
    return Image.asset('assets/group.png',
        fit: BoxFit.contain, width: wScale(60));
  }

  Widget groupTitle() {
    return Text("Tell us more about your organisation",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w600));
  }

  Widget companyDetailSection() {
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
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 4,
            blurRadius: 20,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          detailTitle("Company Detail"),
          const CustomSpacer(size: 22),
          CustomTextField(
              ctl: companyNameCtl,
              hint: 'Enter Company Name',
              label: 'Company Name'),
          const CustomSpacer(size: 32),
          CustomTextField(
              ctl: companyNumberCtl,
              hint: 'Enter Company Registration Number',
              label: 'Company Registration Number'),
          const CustomSpacer(size: 32),
          CustomTextField(
              ctl: countryCtl, hint: 'Select Country', label: 'Country'),
          const CustomSpacer(size: 32),
          CustomTextField(
              ctl: companyPhoneNumberCtl,
              hint: 'Enter Company Phone Number',
              label: 'Company Phone Number'),
        ],
      ),
    );
  }

  Widget detailTitle(title) {
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
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 4,
            blurRadius: 20,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          detailTitle('Company Registered Address'),
          const CustomSpacer(size: 22),
          CustomTextField(
              ctl: companyAddressCtl,
              hint: 'Enter Company Address',
              label: 'Company Address'),
          const CustomSpacer(size: 32),
          CustomTextField(
              ctl: companyPostalCodeCtl,
              hint: 'Enter Company Address',
              label: 'Postal Code'),
        ],
      ),
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
                flagAddress = value;
              });
            },
          ),
        ));
  }

  Widget confirmButton() {
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
            handleConfirm();
          },
          child: Text("Continue",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.bold)),
        ));
  }
}

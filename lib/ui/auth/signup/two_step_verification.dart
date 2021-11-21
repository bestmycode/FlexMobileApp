import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/ui/widgets/signup_progress_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';
import 'package:flexflutter/ui/widgets/custom_textfield.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:localstorage/localstorage.dart';

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

  final LocalStorage storage = LocalStorage('two_step_info1');
  Country _selectedDialogCountry = CountryPickerUtils.getCountryByPhoneCode('65');
  var cityArr = ['city1', 'city2', 'city3', 'city4', 'city5'];
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
  final companyEmailCtl = TextEditingController(text: 'james.tan@flex.com');

  handleContinue() {
    storage.setItem('firstName', firstNameCtl);
    storage.setItem('lastName', lastNameCtl);
    storage.setItem('birthday', birthdayCtl);
    storage.setItem('country', countryCtl);
    storage.setItem('postalCode', postalCodeCtl);
    storage.setItem('address', addressCtl);
    storage.setItem('billingName', billingNameCtl);
    storage.setItem('street', streetCtl);
    storage.setItem('city', cityCtl);
    storage.setItem('jobTitle', jobTitleCtl);
    storage.setItem('companyEmail', companyEmailCtl);

    Navigator.of(context).pushReplacementNamed(TWO_STEP_FINAL);
  }

  @override
  void initState() {
    super.initState();
    firstNameCtl.text = storage.getItem('firstName');
    lastNameCtl.text = storage.getItem('lastName');
    birthdayCtl.text = storage.getItem('birthday');
    countryCtl.text = storage.getItem('country');
    postalCodeCtl.text = storage.getItem('postalCode');
    addressCtl.text = storage.getItem('address');
    billingNameCtl.text = storage.getItem('billingName');
    streetCtl.text = storage.getItem('street');
    cityCtl.text = storage.getItem('city');
    jobTitleCtl.text = storage.getItem('jobTitle');
    companyEmailCtl.text = storage.getItem('companyEmail');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SignupProgressHeader(title: '2-step verification process', progress: 3, prev: MAIN_CONTACT_PERSON,),
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
        style: TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w400, color: const Color(0xFF515151), height: 1.7 ));
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
          // CustomTextField(ctl: birthdayCtl, hint: 'Select Date of Birth', label: 'Date of Birth (DD/MM/YY)'),
          birthDayField(),
          const CustomSpacer(size: 32),
          // CustomTextField(ctl: countryCtl, hint: 'Select Country', label: 'Country'),
          countryField(),
          const CustomSpacer(size: 32),
          CustomTextField(ctl: postalCodeCtl, hint: 'Enter Postal Code', label: 'Postal Code'),
          const CustomSpacer(size: 32),
          CustomTextField(ctl: addressCtl, hint: 'Enter Home Address', label: 'Home Address'),
          const CustomSpacer(size: 32),
          CustomTextField(ctl: billingNameCtl, hint: 'Building Name, Level and Unit Number', label: 'Building Name, Level and Unit Number'),
          const CustomSpacer(size: 32),
          CustomTextField(ctl: streetCtl, hint: 'Enter Street', label: 'Street'),
          const CustomSpacer(size: 32),
          // CustomTextField(ctl: cityCtl, hint: 'Select City', label: 'City'),
          cityTypeField(),
          const CustomSpacer(size: 32),
          CustomTextField(ctl: jobTitleCtl, hint: 'Enter Job Title', label: 'Job Title'),
          const CustomSpacer(size: 32),
          companyEmailAddress()
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

  Widget companyEmailAddress() {
    return Container(
        width: wScale(295),
        height: hScale(56),
        alignment: Alignment.center,
        child: TextField(
          controller: companyEmailCtl,
          readOnly: true,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(
                color: const Color(0xff040415).withOpacity(0.1),
                width: 1.0)
            ),
            labelText: 'Company Email Address',
            labelStyle: TextStyle(
                color: const Color(0xff040415).withOpacity(0.4),
                fontSize: fSize(14),
                fontWeight: FontWeight.w500),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: const Color(0xff040415).withOpacity(0.1),
                    width: 1.0)
            ),
          ),
          style: TextStyle(color: const Color(0xFF040415).withOpacity(0.5), fontSize: fSize(14), fontWeight: FontWeight.w500),
        )
    );
  }

  Widget birthDayField() {
    return Stack(
      children: [
        Container(
          width: wScale(295),
          height: hScale(56),
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: hScale(8)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color:const Color(0xFF040415).withOpacity(0.1))
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: TextField(
                    style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w500, color: const Color(0xFF040415)),
                    controller: birthdayCtl,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder:  const OutlineInputBorder( borderSide: BorderSide( color: Colors.white, width: 1.0) ),
                      hintText: 'Select Date of Birth',
                      hintStyle: TextStyle( color: const Color(0xffBFBFBF), fontSize: fSize(14)),
                      focusedBorder: const OutlineInputBorder( borderSide: BorderSide( color: Colors.white, width: 1.0) ),
                    ),
                  )
              ),
              Container(
                margin: EdgeInsets.only(right: wScale(20)),
                child: Image.asset('assets/calendar.png', fit:BoxFit.contain, width: wScale(18))
              )
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text('Date of Birth (DD/MM/YY)', style: TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w400, color: const Color(0xFFBFBFBF))),
          ),
        )
      ],
    );
  }

  Widget countryField() {
    return Stack(
      children: [
        Container(
          width: wScale(295),
          height: hScale(56),
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: hScale(8)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color:const Color(0xFF040415).withOpacity(0.1))
          ),
          child: ListTile(
              onTap: _openCountryPickerDialog,
              title: _buildDialogItem(_selectedDialogCountry)),
        ),
        Positioned(
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text('Country', style: TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w400, color: const Color(0xFFBFBFBF))),
          ),
        )
      ],
    );
  }

  void _openCountryPickerDialog() => showDialog(
    context: context,
    builder: (context) => Theme(
      data: Theme.of(context).copyWith(primaryColor: Colors.black),
      child: CountryPickerDialog(
        contentPadding: const EdgeInsetsDirectional.all(0.0),
        titlePadding: const EdgeInsetsDirectional.all(0.0),
        searchCursorColor: Colors.black,
        searchInputDecoration: InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(
              color: const Color(0xff040415).withOpacity(0.1),
              width: 1.0)
          ),
          hintText: 'Search Country',
          hintStyle: TextStyle(
              color: const Color(0xff040415).withOpacity(0.1),
              fontSize: fSize(14),
              fontWeight: FontWeight.w500),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
                color: Color(0xff040415),
                width: 1.0),
          ),
        ),
        isSearchable: true,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select a country', style:TextStyle(fontSize: fSize(20), fontWeight: FontWeight.w600)),
                SizedBox(
                    width: wScale(20),
                    height: wScale(20),
                    child: TextButton(
                        style: TextButton.styleFrom(
                          primary: const Color(0xff000000),
                          padding: const EdgeInsets.all(0),
                        ),
                        child: const Icon( Icons.close_rounded, color: Color(0xFFC8C4D9), size: 20,),
                        onPressed: () { }
                    )
                )
              ],
            ),
            const CustomSpacer(size: 20,)
          ],
        ),
        onValuePicked: (Country country) =>
            setState(() => _selectedDialogCountry = country),
        itemBuilder: _showCountryDialogItem,
      ),
    ),
  );

  Widget _buildDialogItem(Country country) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(country.name, style: TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w500, color:const Color(0xFF040415))),
      Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFFBFBFBF), size: wScale(15),)
    ],
  );

  Widget _showCountryDialogItem(Country country) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(width: wScale(24),height: hScale(16), child: CountryPickerUtils.getDefaultFlagImage(country),),
              SizedBox(width: wScale(16)),
              SizedBox(
                  width: wScale(140),
                  child:Text(country.name, style: TextStyle(fontSize: fSize(14))))
            ],
          ),
        ],
      );

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
              border: Border.all(color:const Color(0xFF040415).withOpacity(0.1))
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: TextField(
                    style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w500, color: const Color(0xFF040415)),
                    controller: cityCtl,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder:  const OutlineInputBorder( borderSide: BorderSide( color: Colors.white, width: 1.0) ),
                      hintText: 'Select City',
                      hintStyle: TextStyle( color: const Color(0xffBFBFBF), fontSize: fSize(14)),
                      focusedBorder: const OutlineInputBorder( borderSide: BorderSide( color: Colors.white, width: 1.0) ),
                    ),
                  )
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFFBFBFBF), size: wScale(15)),
                onSelected: (String value) {
                  cityCtl.text = value;
                },
                itemBuilder: (BuildContext context) {
                  return cityArr.map<PopupMenuItem<String>>((String value) {
                    return PopupMenuItem(child: Text(value), value: value, textStyle:  TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w500, color: Color(0xFF040415)),);
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
            child: Text('City', style: TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w400, color: const Color(0xFFBFBFBF))),
          ),
        )
      ],
    );
  }
}
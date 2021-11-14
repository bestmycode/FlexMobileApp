import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/utils/scale.dart';
import 'package:flexflutter/ui/widgets/custom_textfield.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flexflutter/ui/widgets/signup_progress_header.dart';

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

  final LocalStorage storage = LocalStorage('sign_up_info1');

  final firstNameCtl = TextEditingController();
  final lastNameCtl = TextEditingController();
  final mobileNumberCtl = TextEditingController();
  final companyNameCtl = TextEditingController();
  final companyEmailCtl = TextEditingController();
  final passwordCtl = TextEditingController();

  Country _selectedDialogCountry = CountryPickerUtils.getCountryByPhoneCode('65');

  bool flagTerm = false;
  int signUpProgress = 1;

  handleBack() {
    Navigator.of(context).pop();
  }

  handleContinue() {
    storage.setItem('firstName', firstNameCtl.text);
    storage.setItem('lastName', lastNameCtl.text);
    storage.setItem('mobileNumber', mobileNumberCtl.text);
    storage.setItem('companyName', companyNameCtl.text);
    storage.setItem('companyEmail', companyEmailCtl.text);
    storage.setItem('password', passwordCtl.text);
    storage.setItem('flagTerm', flagTerm);

    Navigator.of(context).pushReplacementNamed(MAIL_VERIFY);
  }

  handleLogin() {
    Navigator.of(context).pushReplacementNamed(SIGN_IN);
  }

  @override
  void initState() {
    super.initState();
    firstNameCtl.text = storage.getItem('firstName');
    lastNameCtl.text = storage.getItem('lastName');
    mobileNumberCtl.text = storage.getItem('mobileNumber');
    companyNameCtl.text = storage.getItem('companyName');
    companyEmailCtl.text = storage.getItem('companyEmail');
    passwordCtl.text = storage.getItem('password');
    flagTerm = storage.getItem('flagTerm') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SignupProgressHeader(prev: SPLASH_SCREEN),
              const CustomSpacer(size: 38),
              CustomTextField(ctl: firstNameCtl, hint: 'Enter First Name', label: ' First Name '),
              const CustomSpacer(size: 32),
              CustomTextField(ctl: lastNameCtl, hint: 'Enter Last Name', label: ' Last Name '),
              const CustomSpacer(size: 32),
              mobileNumberField(),
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
            TextSpan(text: 'I agree to the ', style: TextStyle(color: Color(0xFF515151))),
            TextSpan(text: 'terms of use ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF515151))),
            TextSpan(text: 'and ', style:TextStyle(color: Color(0xFF515151))),
            TextSpan(text: 'privacy policy', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF515151))),
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
            style: TextStyle(color: const Color(0xFF666666), fontSize: fSize(14) )),
        loginButton()
      ],
    );
  }

  Widget loginButton() {
    return SizedBox(
      width: wScale(40),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          primary: const Color(0xff29c490),
          textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff29c490)),
        ),
        onPressed: () { handleLogin(); },
        child: const Text('Login'),
      )
    );
  }

  Widget _buildDialogItem(Country country) => Row(
    children: [
      SizedBox(width: wScale(20),height: hScale(10), child: CountryPickerUtils.getDefaultFlagImage(country),),
      SizedBox(width: wScale(5)),
      Text("+${country.phoneCode}", style: TextStyle(fontSize: fSize(14)))
    ],
  );

  Widget _showCountryDialogItem(Country country) =>
      Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          SizedBox(width: wScale(20),height: hScale(10), child: CountryPickerUtils.getDefaultFlagImage(country),),
          SizedBox(width: wScale(16)),
          SizedBox(
              width: wScale(140),
              child:Text(country.name, style: TextStyle(fontSize: fSize(14))))
        ],
      ),
      Text("+${country.phoneCode}", style: TextStyle(fontSize: fSize(14)))
    ],
  );

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

  Widget mobileNumberField() {
    return Container(
        width: wScale(295),
        height: hScale(56),
        alignment: Alignment.center,
        child: TextField(
          keyboardType: TextInputType.number,
          controller: mobileNumberCtl,
          decoration: InputDecoration(
            // prefixIcon: Container(
            //     width: wScale(105),
            //     alignment: Alignment.center,
            //     child:
            //       ListTile(
            //           // contentPadding: const EdgeInsets.,
            //           onTap: _openCountryPickerDialog,
            //           title: _buildDialogItem(_selectedDialogCountry))
            // ),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(
                color: const Color(0xff040415).withOpacity(0.1),
                width: 1.0)
            ),
            hintText: 'Enter Mobile Number',
            hintStyle: TextStyle(
                color: const Color(0xff040415).withOpacity(0.1),
                fontSize: fSize(14),
                fontWeight: FontWeight.w500),
            labelText: 'Mobile Number',
            // label: Container(width: 100, height: 10, color: Colors.red, margin: EdgeInsets.only(left: -10),),
            labelStyle: TextStyle(
                color: const Color(0xff040415).withOpacity(0.4),
                fontSize: fSize(14),
                fontWeight: FontWeight.w500),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                    color: Color(0xff040415),
                    width: 1.0)
            ),
          ),
        )
    );
  }
}
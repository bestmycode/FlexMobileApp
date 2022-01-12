import 'package:co/ui/auth/signup/two_step_verification.dart';
import 'package:co/ui/widgets/signup_progress_header.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/constants/constants.dart';
import 'package:co/utils/scale.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';

class MainContactPersonScreen extends StatefulWidget {
  const MainContactPersonScreen({Key? key}) : super(key: key);

  @override
  MainContactPersonScreenState createState() => MainContactPersonScreenState();
}

class MainContactPersonScreenState extends State<MainContactPersonScreen> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final LocalStorage storage = LocalStorage('sign_up_info2');
  final LocalStorage tokenStorage = LocalStorage('token');
  final fullNameCtl = TextEditingController();
  final mobileNumCtl = TextEditingController();
  bool flagMainContact = false;
  String createOrganizationMutation = FXRMutations.MUTATION_CREATE_ORGANIZATION;

  handleBack() {
    Navigator.of(context).pop();
  }

  handleContinue(runMutation) {
    // storage.setItem('mainContactFullName', fullNameCtl.text);
    // storage.setItem('mainContactMobileNum', mobileNumCtl.text);
    storage.setItem('flagMainContact', flagMainContact);
    runMutation({
      "baseCurrency": storage.getItem("currencyCode"),
      "businessDescription": "",
      "city": storage.getItem("cityId"),
      "companyType": "LC",
      "contactName": fullNameCtl.text,
      "contactNumber": mobileNumCtl.text,
      "country": storage.getItem("country"),
      "crn": "gb",
      "industries": [264,2039, 1637],
      "name": storage.getItem("companyName"),
      "operatingAddress": {
          "addressLine1": storage.getItem("operatingAddress"),
          "addressLine2": "",
          "addressLine3": "",
          "addressLine4": "",
          "zipCode": storage.getItem("operatingAddressPostalCode"),
      },
      "phone": storage.getItem("companyPhoneNumber"),
      "primaryAddress": {
          "addressLine1": storage.getItem("operatingAddress"),
          "addressLine2": "",
          "addressLine3": "",
          "addressLine4": "",
          "zipCode": "123123",
      },
      "proprietorPartner": false,
      "revenueGenerationDetail": "",
      "signupToken": null,
    });

    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => TwoStepVerificationScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    fullNameCtl.text = storage.getItem('fullName');
    mobileNumCtl.text = storage.getItem('mobileNum');
    flagMainContact = storage.getItem('flagMainContact') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = tokenStorage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    return Material(
        child: Scaffold(
            body: Mutation(
      options: MutationOptions(
        document: gql(createOrganizationMutation),
        update: ( GraphQLDataProxy cache, QueryResult? result) {
          return cache;
        },
        onCompleted: (resultData) {
          print(resultData);
        },
      ),
      builder: (RunMutation runMutation, QueryResult? result ) {
        return mainHome(runMutation);
      })));
  }
  
  Widget mainHome(runMutation) {
    return Material(
        child: Scaffold(
            body: SingleChildScrollView(
                child: Column(children: [
      const SignupProgressHeader(
        title: 'Company Detail',
        progress: 2,
        prev: REGISTERED_ADDRESS,
      ),
      const CustomSpacer(size: 20),
      groupIcon(),
      const CustomSpacer(size: 15),
      groupTitle(),
      const CustomSpacer(size: 36),
      mainContactPersonField(),
      const CustomSpacer(size: 30),
      buttonField(runMutation),
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

  Widget mainContactPersonField() {
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
          personTitle('Main Contact Person'),
          personSubTitle(),
          const CustomSpacer(size: 12),
          termsField(),
          const CustomSpacer(size: 24),
          CustomTextField(
              ctl: fullNameCtl, hint: 'Enter Full Name', label: 'Full Name'),
          const CustomSpacer(size: 32),
          CustomTextField(
              ctl: mobileNumCtl,
              hint: 'Enter Mobile Number',
              label: 'Mobile Number'),
        ],
      ),
    );
  }

  Widget personTitle(title) {
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

  Widget personSubTitle() {
    return SizedBox(
      width: wScale(295),
      child: Text('*For courier and mailing purposes',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: fSize(12),
            fontWeight: FontWeight.w400,
          )),
    );
  }

  Widget buttonField(runMutation) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [backButton(), continueButton(runMutation)],
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

  Widget continueButton(runMutation) {
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
            handleContinue(runMutation);
          },
          child: Text("Continue",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
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
          ]),
    );
  }

  Widget termsCheckBox() {
    return SizedBox(
        width: hScale(14),
        height: hScale(24),
        child: Transform.scale(
          scale: 0.7,
          child: Checkbox(
            value: flagMainContact,
            activeColor: const Color(0xff30E7A9),
            onChanged: (value) {
              setState(() {
                flagMainContact = value!;
                if(flagMainContact) {
                  LocalStorage info1_storage = LocalStorage('sign_up_info1');
                  fullNameCtl.text = "${info1_storage.getItem('firstName')} ${info1_storage.getItem('lastName')}";
                  mobileNumCtl.text = info1_storage.getItem("mobileNumber");
                }                
              });
            },
          ),
        ));
  }

  Widget termsTitle() {
    return SizedBox(
        width: wScale(264),
        child: Text('I am the main contact person for\n(Company Name)',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: fSize(14),
              fontWeight: FontWeight.w400,
            )));
  }
}

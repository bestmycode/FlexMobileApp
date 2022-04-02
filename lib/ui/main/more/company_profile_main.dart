import 'package:co/ui/widgets/custom_result_modal.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CompanyProfileMain extends StatefulWidget {
  final companyProfile;
  final countryInfo;
  final listCompany;
  const CompanyProfileMain(
      {Key? key, this.companyProfile, this.countryInfo, this.listCompany})
      : super(key: key);
  @override
  CompanyProfileMainState createState() => CompanyProfileMainState();
}

class CompanyProfileMainState extends State<CompanyProfileMain> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  bool flagEditable = false;
  final companyPhoneNumberCtl = TextEditingController();
  final contactPersonCtl = TextEditingController();
  final operatingAddressCtl = TextEditingController();
  final operatingPostalCodeCtl = TextEditingController();
  final operatingCityCtl = TextEditingController();
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String updateOrganizationMutation = FXRMutations.MUTATION_UPDATE_ORGANIZATION;
  late var selectedCity;
  bool isLoading = false;

  handleEditProfile() {
    setState(() {
      flagEditable = true;
    });
  }

  handleConfirmChange(companyProfile, runMutation) async {
    try {
      await runMutation({
        "city": companyProfile['city'].toString(),
        "country": companyProfile['country'].toString(),
        "crn": companyProfile['crn'].toString(),
        "name": contactPersonCtl.text,
        "orgId": userStorage.getItem('orgId'),
        "phone": companyPhoneNumberCtl.text,
        "proprietorPartner": true,
        "zipCode": companyProfile['zipCode'].toString(),
        "operatingAddress": {
          "addressLine1": operatingAddressCtl.text,
          "addressLine2": "",
          "addressLine3": "",
          "addressLine4": "",
          "city": selectedCity['id'].toString(),
          "zipCode": operatingPostalCodeCtl.text
        },
      });
      setState(() {
        isLoading = true;
      });
    } catch (error) {
      print("===== Error : update Organization Result =====");
      print("===== Mutation : updateOrganization =====");
      print(error);
      await Sentry.captureException(error);
      return null;
    }
  }

  handleCreditline() async {
    String msg = '''Hello Flex,

I would like to open a Flex business account. Please reach out to me to process the application further.

Thanks.''';

    Intercom.displayMessageComposer(msg);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      companyPhoneNumberCtl.text = widget.companyProfile['phone'];
      contactPersonCtl.text = widget.companyProfile['name'];
      operatingAddressCtl.text =
          widget.companyProfile['orgOperatingAddress']['addressLine1'];
      operatingPostalCodeCtl.text =
          widget.companyProfile['orgOperatingAddress']['postalCode'];
      selectedCity = widget.countryInfo['cities'].firstWhere((item) =>
          item['id'].toString() == widget.companyProfile['orgAddress']['city']);
      operatingCityCtl.text = selectedCity['name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Opacity(
          opacity: isLoading ? 0.5 : 1,
          child: Column(children: [
            const CustomSpacer(size: 15),
            userProfileField(
                widget.companyProfile, widget.countryInfo, widget.listCompany),
            flagEditable ? CustomSpacer(size: 30) : SizedBox(),
            flagEditable ? mutationButton(widget.companyProfile) : SizedBox(),
            const CustomSpacer(size: 46)
          ])),
      isLoading
          ? Positioned(
              child: Container(
                  margin: EdgeInsets.only(top: hScale(50)),
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF60C094)))))
          : SizedBox()
    ]);
  }

  Widget userProfileField(companyProfile, countryInfo, listCompany) {
    var company = listCompany.firstWhere(
        (item) => item['id'] == companyProfile['companyType'],
        orElse: () => null);
    return company == null
        ? noFlexUser()
        : Container(
            width: wScale(327),
            // height: hScale(40),
            padding: EdgeInsets.symmetric(
                vertical: hScale(16), horizontal: wScale(16)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  spreadRadius: 4,
                  blurRadius: 10,
                  offset: const Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleField(),
                const CustomSpacer(size: 6),
                flagEditable
                    ? editableField(companyProfile, countryInfo, company)
                    : nonEditableField(companyProfile, countryInfo, company)
              ],
            ));
  }

  Widget titleField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Company Profile',
            style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w600)),
        flagEditable
            ? const SizedBox()
            : SizedBox(
                width: wScale(16),
                height: wScale(16),
                child: TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color(0xffF5F5F5).withOpacity(0.4),
                      padding: const EdgeInsets.all(0),
                    ),
                    child: Image.asset('assets/green_edit.png',
                        fit: BoxFit.contain, width: wScale(16)),
                    onPressed: () {
                      handleEditProfile();
                    }),
              )
      ],
    );
  }

  Widget customDataField(label, value) {
    return SizedBox(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: fSize(12),
                fontWeight: FontWeight.w400,
                color: const Color(0xFF040415).withOpacity(0.4))),
        const CustomSpacer(size: 8),
        Text(value,
            style: TextStyle(
                fontSize: fSize(14),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF040415)))
      ],
    ));
  }

  Widget customEditField(hint, label, editable) {
    return Container(
        width: wScale(295),
        height: hScale(64),
        alignment: Alignment.center,
        child: TextField(
          readOnly: !editable,
          style: TextStyle(
              fontSize: fSize(14),
              fontWeight: FontWeight.w500,
              color:
                  editable ? const Color(0xFF040415) : const Color(0xFF7D7E80)),
          controller: hint == 'Company Phone Number'
              ? companyPhoneNumberCtl
              : hint == 'Contact Person'
                  ? contactPersonCtl
                  : hint == "Operating Address"
                      ? operatingAddressCtl
                      : hint == "Operating Postal Code"
                          ? operatingPostalCodeCtl
                          : hint == "Operating City"
                              ? operatingCityCtl
                              : TextEditingController()
            ..text = label,
          decoration: InputDecoration(
            filled: true,
            fillColor: editable
                ? Colors.white
                : const Color(0xFFBDBDBD).withOpacity(0.1),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: const Color(0xff040415).withOpacity(0.1),
                    width: 1.0)),
            hintText: hint,
            hintStyle: TextStyle(
                color: const Color(0xff040415).withOpacity(0.1),
                fontSize: fSize(14),
                fontWeight: FontWeight.w500),
            labelText: hint,
            labelStyle: TextStyle(
                color: const Color(0xff040415).withOpacity(0.4),
                fontSize: fSize(14),
                fontWeight: FontWeight.w500),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Color(0xff040415).withOpacity(0.1), width: 1.0)),
          ),
        ));
  }

  Widget customMultiEditField(label) {
    return Container(
        width: wScale(295),
        // height: hScale(56),
        alignment: Alignment.center,
        child: TextField(
          readOnly: true,
          style: TextStyle(
              fontSize: fSize(14),
              fontWeight: FontWeight.w500,
              color: Color(0xFF7D7E80)),
          controller: TextEditingController()..text = label,
          minLines: 3,
          maxLines: 7,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFBDBDBD).withOpacity(0.1),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: const Color(0xff040415).withOpacity(0.1),
                    width: 1.0)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Color(0xff040415).withOpacity(0.1), width: 1.0)),
          ),
        ));
  }

  Widget confirmChangeButton(companyProfile, runMutation) {
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
            handleConfirmChange(companyProfile, runMutation);
          },
          child: Text("Confirm Changes",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.bold)),
        ));
  }

  Widget mutationButton(companyProfile) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Mutation(
            options: MutationOptions(
              document: gql(updateOrganizationMutation),
              update: (GraphQLDataProxy cache, QueryResult? result) {
                return cache;
              },
              onCompleted: (resultData) {
                setState(() {
                  isLoading = false;
                });
                if (resultData != null &&
                    resultData['updateOrganization']['id'] ==
                        userStorage.getItem("orgId")) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: wScale(40)),
                            child: Dialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                                child: CustomResultModal(
                                  status: true,
                                  title: "Success",
                                  message: "Company Profile Updated!!!",
                                  handleOKClick: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop('dialog');
                                    setState(() {
                                      flagEditable = false;
                                    });
                                  },
                                )));
                      });
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: wScale(40)),
                            child: Dialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                                child: CustomResultModal(
                                    status: true,
                                    title: "Failed",
                                    message:
                                        "Company Profile Don't Updated!!!")));
                      });
                }
              },
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              return confirmChangeButton(companyProfile, runMutation);
            }));
  }

  Widget nonEditableField(companyProfile, countryInfo, company) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomSpacer(size: 14),
        customDataField('Company Name',
            companyProfile['name'] == null ? "" : companyProfile['name']),
        const CustomSpacer(size: 16),
        customDataField('Company Registration Number',
            companyProfile['crn'] == null ? "" : companyProfile['crn']),
        const CustomSpacer(size: 16),
        customDataField('Country',
            companyProfile['country'] == null ? "" : countryInfo['name']),
        const CustomSpacer(size: 16),
        customDataField(
            'Base Currency',
            companyProfile['baseCurrency'] == null
                ? ""
                : companyProfile['baseCurrency']),
        const CustomSpacer(size: 16),
        customDataField('Company Phone Number', companyPhoneNumberCtl.text),
        const CustomSpacer(size: 16),
        customDataField('Company Type',
            companyProfile['companyType'] == null ? "" : company['name']),
        const CustomSpacer(size: 16),
        customDataField('Contact Person', contactPersonCtl.text),
        const CustomSpacer(size: 16),
        customDataField(
            'Industry',
            companyProfile['industries'][0]['name'] == null
                ? ""
                : companyProfile['industries'][0]['name']),
        const CustomSpacer(size: 16),

        customDataField(
            '',
            companyProfile['industries'][0]['level5CodesAndNames'] == null
                ? ""
                : companyProfile['industries'][0]['level5CodesAndNames']),

        const CustomSpacer(size: 16),
        customDataField(
            'Company Address',
            companyProfile['orgAddress']['addressLine1'] == null
                ? ""
                : companyProfile['orgAddress']['addressLine1']),
        const CustomSpacer(size: 16),
        customDataField(
            'Postal Code',
            companyProfile['orgAddress']['postalCode'] == null
                ? ""
                : companyProfile['orgAddress']['postalCode']),
        const CustomSpacer(size: 16),
        customDataField(
            'City',
            companyProfile['orgAddress']['city'] == null
                ? ""
                : countryInfo['cities'].firstWhere((item) =>
                    item['id'].toString() ==
                    companyProfile['orgAddress']['city'])['name']),
        const CustomSpacer(size: 16),
        customDataField('Operating Address', operatingAddressCtl.text),
        const CustomSpacer(size: 16),
        customDataField('Operating Postal Code', operatingPostalCodeCtl.text),
        const CustomSpacer(size: 16),
        customDataField('Operating City', operatingCityCtl.text),
        // customEditField(companyNameCtl, const Color(0xFFBDBDBD).withOpacity(0.1), 'Global Ptv.Ltd', 'Company Name')
      ],
    );
  }

  Widget editableField(companyProfile, countryInfo, company) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomSpacer(size: 14),
        customEditField('Company Name', companyProfile['name'], false),
        const CustomSpacer(size: 16),
        customEditField(
            'Company Registration Number', companyProfile['crn'], false),
        const CustomSpacer(size: 16),
        customEditField('Country', countryInfo['name'], false),
        const CustomSpacer(size: 16),
        customEditField('Base Currency', companyProfile['baseCurrency'], false),
        const CustomSpacer(size: 16),
        customEditField(
            'Company Phone Number', companyPhoneNumberCtl.text, false),
        const CustomSpacer(size: 16),
        customEditField('Company Type', company['name'], false),
        const CustomSpacer(size: 16),
        customEditField('Contact Person', contactPersonCtl.text, false),
        // const CustomSpacer(size: 16),
        // customEditField('Company Email Address', 'terry@abc.co', true),
        const CustomSpacer(size: 16),

        customEditField(
            'Industry', companyProfile['industries'][0]['name'], false),
        const CustomSpacer(size: 16),

        customMultiEditField(
            companyProfile['industries'][0]['level5CodesAndNames']),

        const CustomSpacer(size: 16),
        customEditField('Company Address',
            companyProfile['orgAddress']['addressLine1'], false),
        const CustomSpacer(size: 16),
        customEditField(
            'Postal Code', companyProfile['orgAddress']['postalCode'], false),
        const CustomSpacer(size: 16),
        customEditField(
            'City',
            countryInfo['cities'].firstWhere((item) =>
                item['id'].toString() ==
                companyProfile['orgAddress']['city'])['name'],
            false),
        const CustomSpacer(size: 16),
        customEditField('Operating Address', operatingAddressCtl.text, true),
        const CustomSpacer(size: 16),
        customEditField(
            'Operating Postal Code', operatingPostalCodeCtl.text, true),
        const CustomSpacer(size: 16),
        Stack(children: [
          customEditField('Operating City', operatingCityCtl.text, true),
          Positioned(
              right: 0,
              top: 0,
              child: Container(
                  width: wScale(40),
                  height: hScale(64),
                  child: TextButton(
                      onPressed: () {
                        _showCardTypeModalDialog(
                            context, countryInfo['cities']);
                      },
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFFBFBFBF)))))
        ]),

        // customEditField(companyNameCtl, const Color(0xFFBDBDBD).withOpacity(0.1), 'Global Ptv.Ltd', 'Company Name')
      ],
    );
  }

  _showCardTypeModalDialog(context, arrData) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: wScale(40)),
              child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: SingleChildScrollView(
                      child: Column(
                          children: arrData.map<Widget>((item) {
                    return Container(
                        height: hScale(50),
                        child: TextButton(
                            style: TextButton.styleFrom(
                              primary: const Color(0xff515151),
                              padding: const EdgeInsets.all(0),
                            ),
                            onPressed: () {
                              setState(() {
                                selectedCity = arrData[arrData.indexOf(item)];
                                operatingCityCtl.text = item['name'];
                              });
                              Navigator.of(context, rootNavigator: true)
                                  .pop('dialog');
                            },
                            child: Container(
                                width: wScale(375),
                                alignment: Alignment.center,
                                child: Text(item['name']))));
                  }).toList()))));
        });
  }

  Widget noFlexUser() {
    return Container(
        child: Column(
      children: [
        Container(
            width: wScale(327),
            // height: hScale(320),
            alignment: Alignment.center,
            padding: EdgeInsets.all(hScale(24)),
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
                  color: Color(0xFF106549).withOpacity(0.1),
                  spreadRadius: 4,
                  blurRadius: 10,
                  offset: const Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.noflexbussinessaccount,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: fSize(12),
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF70828D))),
                  CustomSpacer(size: 18),
                  Image.asset('assets/empty_transaction.png',
                      fit: BoxFit.contain, width: wScale(159)),
                  CustomSpacer(size: 36),
                  Text(AppLocalizations.of(context)!.flexmobilesupportflex,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: fSize(12),
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF70828D))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          handleCreditline();
                        },
                        child: Text(AppLocalizations.of(context)!.clickhere,
                            style: TextStyle(
                                fontSize: fSize(12),
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF29C490))),
                      ),
                      Text(AppLocalizations.of(context)!.torequestfor,
                          style: TextStyle(
                              fontSize: fSize(12),
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF70828D))),
                    ],
                  )
                ]))
      ],
    ));
  }
}

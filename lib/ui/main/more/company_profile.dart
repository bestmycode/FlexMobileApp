import 'package:co/ui/widgets/custom_result_modal.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';

class CompanyProfile extends StatefulWidget {
  const CompanyProfile({Key? key}) : super(key: key);
  @override
  CompanyProfileState createState() => CompanyProfileState();
}

class CompanyProfileState extends State<CompanyProfile> {
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
  String getCompanySettingQuery = Queries.QUERY_GET_COMPANY_SETTING;
  String updateOrganizationMutation = FXRMutations.MUTATION_UPDATE_ORGANIZATION;

  handleEditProfile() {
    setState(() {
      flagEditable = true;
    });
  }

  handleConfirmChange(companyProfile, runMutation) {
    runMutation({
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
        "city": operatingCityCtl.text,
        "zipCode": operatingPostalCodeCtl.text
      },
    });
    setState(() {
      flagEditable = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    var orgId = userStorage.getItem('orgId');
    return Query(
        options: QueryOptions(
          document: gql(getCompanySettingQuery),
          variables: {'orgId': orgId},
          // pollInterval: const Duration(seconds: 10),
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF60C094))));
          }
          var companyProfile = result.data!['organization'];
          companyPhoneNumberCtl.text = companyProfile['phone'];
          contactPersonCtl.text = companyProfile['name'];
          operatingAddressCtl.text =
              companyProfile['orgOperatingAddress']['addressLine1'];
          operatingPostalCodeCtl.text =
              companyProfile['orgOperatingAddress']['postalCode'];
          operatingCityCtl.text =
              companyProfile['orgOperatingAddress']['country'];
          return mainHome(companyProfile);
        });
  }

  Widget mainHome(companyProfile) {
    return Column(children: [
      const CustomSpacer(size: 15),
      userProfileField(companyProfile),
      flagEditable ? const CustomSpacer(size: 30) : const SizedBox(),
      flagEditable ? mutationButton(companyProfile) : const SizedBox(),
      const CustomSpacer(size: 46)
    ]);
  }

  Widget userProfileField(companyProfile) {
    return Container(
        width: wScale(327),
        // height: hScale(40),
        padding:
            EdgeInsets.symmetric(vertical: hScale(16), horizontal: wScale(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleField(),
            const CustomSpacer(size: 6),
            flagEditable
                ? editableField(companyProfile)
                : nonEditableField(companyProfile)
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
                if (resultData['updateOrganization']['id'] ==
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
                                    message: "Company Profile Updated!!!")));
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

  Widget nonEditableField(companyProfile) {
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
            companyProfile['country'] == null ? "" : companyProfile['country']),
        const CustomSpacer(size: 16),
        customDataField(
            'Base Currency',
            companyProfile['baseCurrency'] == null
                ? ""
                : companyProfile['baseCurrency']),
        const CustomSpacer(size: 16),
        customDataField('Company Phone Number', companyPhoneNumberCtl.text),
        const CustomSpacer(size: 16),
        customDataField(
            'Company Type',
            companyProfile['companyType'] == null
                ? ""
                : companyProfile['companyType']),
        const CustomSpacer(size: 16),
        customDataField('Contact Person', contactPersonCtl.text),
        // const CustomSpacer(size: 16),
        // customDataField('Company Email Address', 'terry@abc.co'),
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
            companyProfile['orgAddress']['country'] == null
                ? ""
                : companyProfile['orgAddress']['country']),
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

  Widget editableField(companyProfile) {
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
        customEditField('Country', companyProfile['country'], false),
        const CustomSpacer(size: 16),
        customEditField('Base Currency', companyProfile['baseCurrency'], false),
        const CustomSpacer(size: 16),
        customEditField(
            'Company Phone Number', companyPhoneNumberCtl.text, false),
        const CustomSpacer(size: 16),
        customEditField('Company Type', companyProfile['companyType'], false),
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
        customEditField('City', companyProfile['orgAddress']['country'], false),
        const CustomSpacer(size: 16),
        customEditField('Operating Address', operatingAddressCtl.text, false),
        const CustomSpacer(size: 16),
        customEditField('Postal Code', operatingPostalCodeCtl.text, true),
        const CustomSpacer(size: 16),
        customEditField('City', operatingCityCtl.text, true),
        // customEditField(companyNameCtl, const Color(0xFFBDBDBD).withOpacity(0.1), 'Global Ptv.Ltd', 'Company Name')
      ],
    );
  }
}

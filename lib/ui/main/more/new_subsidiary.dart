import 'package:co/ui/main/more/complete_new_subsidiary.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_mobile_textfield.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:co/utils/validator.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';

class NewSubsidiary extends StatefulWidget {
  const NewSubsidiary({Key? key}) : super(key: key);
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

  final LocalStorage storage = LocalStorage('sign_up_info2');
  final LocalStorage tokenStorage = LocalStorage('token');
  Country _selectedDialogCountry =
      CountryPickerUtils.getCountryByPhoneCode('65');
  String industryFilteredQuery = Queries.QUERY_INDUSTRY_FILTERD;
  String listCompanyTypeQuery = Queries.QUERY_LIST_COMPANY_TYPE;
  String createOrganizationMutation = FXRMutations.MUTATION_CREATE_ORGANIZATION;

  final companyNameCtl = TextEditingController();
  final companyNumberCtl = TextEditingController();
  final countryCtl = TextEditingController();
  final companyTypeCtl = TextEditingController();
  final companyPhoneNumberCtl = TextEditingController();
  final companyAddressCtl = TextEditingController();
  final companyPostalCodeCtl = TextEditingController();
  final industryCtl = TextEditingController();
  bool flagAddress = false;
  bool showEmpty = false;

  handleConfirm(runMutation) {
    if (companyNameCtl.text != '' &&
        companyNumberCtl.text != '' &&
        countryCtl.text != '' &&
        companyTypeCtl.text != '' &&
        companyPhoneNumberCtl.text != '' &&
        companyAddressCtl.text != '' &&
        companyPostalCodeCtl.text != '' &&
        industryCtl.text != '') {
      runMutation({
        "baseCurrency": "SGD",
        "businessDescription": "",
        "city": "1880252",
        "companyType": "LC",
        "contactName": companyNameCtl.text,
        "contactNumber": companyNumberCtl.text,
        "country": storage.getItem("country"),
        "crn": "gb",
        "industries": [264, 2039, 1637],
        "name": companyNameCtl.text,
        "operatingAddress": {
          "addressLine1": companyAddressCtl.text,
          "addressLine2": "",
          "addressLine3": "",
          "addressLine4": "",
          "city": "1880252",
          "zipCode": companyPostalCodeCtl.text,
        },
        "phone": companyPhoneNumberCtl.text,
        "primaryAddress": {
          "addressLine1": companyAddressCtl.text,
          "addressLine2": "",
          "addressLine3": "",
          "addressLine4": "",
          "city": "1880252",
          "zipCode": "123123",
        },
        "proprietorPartner": false,
        "revenueGenerationDetail": "",
        "signupToken": null,
      });
      setState(() {
        showEmpty = false;
      });
    } else {
      setState(() {
        showEmpty = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = tokenStorage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    return Material(
        child: Scaffold(
            body: Query(
                options: QueryOptions(
                  document: gql(industryFilteredQuery),
                  variables: {"industryTerm": ""},
                  // pollInterval: const Duration(seconds: 10),
                ),
                builder: (QueryResult industryResult,
                    {VoidCallback? refetch, FetchMore? fetchMore}) {
                  if (industryResult.hasException) {
                    return Text(industryResult.exception.toString());
                  }

                  if (industryResult.isLoading) {
                    return mainHome([], []);
                  }
                  var industry = industryResult.data!['industriesFiltered'];
                  return Query(
                      options: QueryOptions(
                        document: gql(listCompanyTypeQuery),
                        variables: {},
                        // pollInterval: const Duration(seconds: 10),
                      ),
                      builder: (QueryResult listCompanyResult,
                          {VoidCallback? refetch, FetchMore? fetchMore}) {
                        if (listCompanyResult.hasException) {
                          return Text(listCompanyResult.exception.toString());
                        }

                        if (listCompanyResult.isLoading) {
                          return mainHome([], []);
                        }
                        var listCompany =
                            listCompanyResult.data!['LIST_COMPANY_TYPES'];

                        List<String> listCompanyArr = [];
                        listCompany.forEach((item) {
                          listCompanyArr.add(item['name']);
                        });

                        List<String> industryArr = [];
                        industry.forEach((item) {
                          industryArr.add(item['level5CodesAndNames']);
                        });

                        return mainHome(industryArr, listCompanyArr);
                      });
                })));
  }

  Widget mainHome(industryArr, listCompanyArr) {
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
              companyDetailSection(industryArr, listCompanyArr),
              const CustomSpacer(size: 15),
              registeredAddressField(),
              const CustomSpacer(size: 22),
              differentAddressField(),
              const CustomSpacer(size: 37),
              mutationButton(),
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

  Widget mutationButton() {
    return Mutation(
        options: MutationOptions(
          document: gql(createOrganizationMutation),
          update: (GraphQLDataProxy cache, QueryResult? result) {
            return cache;
          },
          onCompleted: (resultData) {
            if (resultData.data['createdOrganization'] == null) {
              print(resultData.errors[0]['message']);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        builder: (RunMutation runMutation, QueryResult? result) {
          return confirmButton(runMutation);
        });
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

  Widget companyDetailSection(industry, listCompany) {
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
          detailTitle('Company Detail'),
          const CustomSpacer(size: 22),
          CustomTextField(
              isError: showEmpty && companyNameCtl.text == '',
              ctl: companyNameCtl,
              hint: 'Enter Company Name',
              label: 'Company Name'),
          isValidateText(
              showEmpty && companyNameCtl.text == '', companyNameCtl.text),
          CustomTextField(
              isError: showEmpty && companyNumberCtl.text == '',
              ctl: companyNumberCtl,
              hint: 'Enter Company Registration Number',
              label: 'Company Registration Number'),
          isValidateText(
              showEmpty && companyNumberCtl.text == '', companyNumberCtl.text),
          // CustomTextField(ctl: countryCtl, hint: 'Select Country', label: 'Country'),
          countryField(),
          const CustomSpacer(size: 32),
          // CustomTextField(ctl: companyTypeCtl, hint: 'Select Company Type', label: 'Company Type'),
          companyTypeField(listCompany),
          isValidateText(
              showEmpty && companyTypeCtl.text == '', companyTypeCtl.text),
          // CustomTextField(ctl: companyIndustryCtl, hint: 'Select Company Type', label: 'Industry'),
          industryTypeField(industry),
          isValidateText(showEmpty && industryCtl.text == '', industryCtl.text),
          // CustomTextField(ctl: companyPhoneNumberCtl, hint: 'Enter Company Phone Number', label: 'Company Phone Number'),
          CustomMobileTextField(
              isError: showEmpty && companyPhoneNumberCtl.text == '',
              ctl: companyPhoneNumberCtl,
              hint: 'Enter Company Phone Number',
              label: 'Company Phone Number'),
          isValidateText(showEmpty && companyPhoneNumberCtl.text == '',
              companyPhoneNumberCtl.text),
        ],
      ),
    );
  }

  Widget isValidateText(flag, text) {
    String errorText = Validator().validateEmpty(text.toString()).toString();
    return flag == true
        ? Container(
            height: hScale(32),
            width: wScale(295),
            padding: EdgeInsets.only(top: hScale(5)),
            child: Text(errorText,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: fSize(12),
                    color: Color(0xFFEB5757),
                    fontWeight: FontWeight.w400)))
        : CustomSpacer(size: 32);
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
              border:
                  Border.all(color: const Color(0xFF040415).withOpacity(0.1))),
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
            child: Text('Country',
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFBFBFBF))),
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
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: const Color(0xff040415).withOpacity(0.1),
                      width: 1.0)),
              hintText: 'Search Country',
              hintStyle: TextStyle(
                  color: const Color(0xff040415).withOpacity(0.1),
                  fontSize: fSize(14),
                  fontWeight: FontWeight.w500),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff040415), width: 1.0),
              ),
            ),
            isSearchable: true,
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select a country',
                        style: TextStyle(
                            fontSize: fSize(20), fontWeight: FontWeight.w600)),
                    SizedBox(
                        width: wScale(20),
                        height: wScale(20),
                        child: TextButton(
                            style: TextButton.styleFrom(
                              primary: const Color(0xff000000),
                              padding: const EdgeInsets.all(0),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFFC8C4D9),
                              size: 20,
                            ),
                            onPressed: () {}))
                  ],
                ),
                const CustomSpacer(
                  size: 20,
                )
              ],
            ),
            onValuePicked: ((Country country) {
              storage.setItem('country', country.isoCode);
              setState(() => _selectedDialogCountry = country);
            }),
            itemBuilder: _showCountryDialogItem,
          ),
        ),
      );

  Widget _buildDialogItem(Country country) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(country.name,
              style: TextStyle(
                  fontSize: fSize(14),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF040415))),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: const Color(0xFFBFBFBF),
            size: wScale(15),
          )
        ],
      );

  Widget _showCountryDialogItem(Country country) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: wScale(24),
                height: hScale(16),
                child: CountryPickerUtils.getDefaultFlagImage(country),
              ),
              SizedBox(width: wScale(16)),
              SizedBox(
                  width: wScale(140),
                  child:
                      Text(country.name, style: TextStyle(fontSize: fSize(14))))
            ],
          ),
        ],
      );

  Widget companyTypeField(listCompanyArr) {
    return Stack(
      children: [
        Container(
          width: wScale(295),
          height: hScale(56),
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: hScale(8)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: showEmpty && companyTypeCtl.text == ''
                      ? const Color(0xFFEB5757)
                      : Color(0xffBFBFBF))),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: TextField(
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF040415)),
                controller: companyTypeCtl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 1.0)),
                  hintText: 'Select Company Type',
                  hintStyle: TextStyle(
                      color: showEmpty && companyTypeCtl.text == ''
                          ? const Color(0xFFEB5757)
                          : Color(0xffBFBFBF),
                      fontSize: fSize(14)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 1.0)),
                ),
              )),
              PopupMenuButton<String>(
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFFBFBFBF), size: wScale(15)),
                onSelected: (String value) {
                  companyTypeCtl.text = value;
                },
                itemBuilder: (BuildContext context) {
                  return listCompanyArr
                      .map<PopupMenuItem<String>>((String value) {
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
          top: fSize(0),
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text('Company Type',
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: showEmpty && companyTypeCtl.text == ''
                        ? const Color(0xFFEB5757)
                        : const Color(0xFFBFBFBF))),
          ),
        )
      ],
    );
  }

  Widget industryTypeField(industryArr) {
    return Stack(
      children: [
        Container(
          width: wScale(295),
          // height: hScale(56),
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: hScale(8)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: showEmpty && industryCtl.text == ''
                      ? Color(0xFFEB5757)
                      : Color(0xffBFBFBF))),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: TextField(
                readOnly: true,
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF040415)),
                controller: industryCtl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 1.0)),
                  hintText: 'Select Company Type',
                  hintStyle: TextStyle(
                      color: showEmpty && industryCtl.text == ''
                          ? const Color(0xFFEB5757)
                          : Color(0xffBFBFBF),
                      fontSize: fSize(14)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 1.0)),
                ),
              )),
              PopupMenuButton<String>(
                icon: Image.asset('assets/search_icon.png',
                    fit: BoxFit.contain, width: wScale(15)),
                onSelected: (String value) {
                  industryCtl.text = value;
                },
                itemBuilder: (BuildContext context) {
                  return industryArr.map<PopupMenuItem<String>>((String value) {
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
            child: Text('Industry',
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: showEmpty && industryCtl.text == ''
                        ? const Color(0xFFEB5757)
                        : Color(0xffBFBFBF))),
          ),
        )
      ],
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
              isError: showEmpty && companyAddressCtl.text == '',
              ctl: companyAddressCtl,
              hint: 'Enter Company Address',
              label: 'Company Address'),
          isValidateText(showEmpty && companyAddressCtl.text == '',
              companyAddressCtl.text),
          CustomTextField(
              isError: showEmpty && companyPostalCodeCtl.text == '',
              ctl: companyPostalCodeCtl,
              hint: 'Enter Company Address',
              label: 'Postal Code'),
          isValidateText(showEmpty && companyPostalCodeCtl.text == '',
              companyPostalCodeCtl.text),
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
                flagAddress = value!;
              });
            },
          ),
        ));
  }

  Widget confirmButton(runMutation) {
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
            handleConfirm(runMutation);
          },
          child: Text("Continue",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.bold)),
        ));
  }
}

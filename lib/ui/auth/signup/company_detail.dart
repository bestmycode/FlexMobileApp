import 'package:co/ui/auth/signup/registered_address.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:co/ui/widgets/custom_mobile_textfield.dart';
import 'package:co/ui/widgets/signup_progress_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/constants/constants.dart';
import 'package:co/utils/scale.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';

class CompanyDetailScreen extends StatefulWidget {
  const CompanyDetailScreen({Key? key}) : super(key: key);

  @override
  CompanyDetailScreenState createState() => CompanyDetailScreenState();
}

class CompanyDetailScreenState extends State<CompanyDetailScreen> {
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

  final companyNameCtl = TextEditingController();
  final companyNumberCtl = TextEditingController();
  final countryCtl = TextEditingController();
  final companyTypeCtl = TextEditingController();
  final companyIndustryCtl = TextEditingController();
  final companyPhoneNumberCtl = TextEditingController();
  int selectedListCompany = 0;
  int selectedIndustry = 0;

  handleContinue() {
    storage.setItem('companyName', companyNameCtl.text);
    storage.setItem('companyNumber', companyNumberCtl.text);
    // storage.setItem('country', countryCtl.text);
    storage.setItem('companyType', companyTypeCtl.text);
    storage.setItem('companyIndustry', companyIndustryCtl.text);
    storage.setItem('companyPhoneNumber', companyPhoneNumberCtl.text);

    // Navigator.of(context).pushReplacementNamed(REGISTERED_ADDRESS);
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => RegisteredAddressScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    companyNameCtl.text = storage.getItem('companyName');
    companyNumberCtl.text = storage.getItem('companyNumber');
    countryCtl.text = storage.getItem('country');
    companyTypeCtl.text = storage.getItem('companyType');
    companyIndustryCtl.text = storage.getItem('companyIndustry');
    companyPhoneNumberCtl.text = storage.getItem('companyPhoneNumber');
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
                    return CustomLoading();
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
                          return CustomLoading();
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

  Widget mainHome(industry, listCompany) {
    return SingleChildScrollView(
        child: Column(children: [
      const SignupProgressHeader(
        title: 'Company Detail',
        progress: 2,
        prev: MAIL_VERIFY,
      ),
      const CustomSpacer(size: 20),
      groupIcon(),
      const CustomSpacer(size: 15),
      groupTitle(),
      const CustomSpacer(size: 36),
      companyDetailSection(industry, listCompany),
      const CustomSpacer(size: 50),
      verifyButton(),
      const CustomSpacer(size: 35),
    ]));
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
          companyDetailTitle(),
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
          // CustomTextField(ctl: countryCtl, hint: 'Select Country', label: 'Country'),
          countryField(),
          const CustomSpacer(size: 32),
          // CustomTextField(ctl: companyTypeCtl, hint: 'Select Company Type', label: 'Company Type'),
          companyTypeField(listCompany),
          const CustomSpacer(size: 32),
          // CustomTextField(ctl: companyIndustryCtl, hint: 'Select Company Type', label: 'Industry'),
          industryTypeField(industry),
          const CustomSpacer(size: 32),
          // CustomTextField(ctl: companyPhoneNumberCtl, hint: 'Enter Company Phone Number', label: 'Company Phone Number'),
          CustomMobileTextField(
              ctl: companyPhoneNumberCtl,
              hint: 'Enter Company Phone Number',
              label: 'Company Phone Number'),
        ],
      ),
    );
  }

  Widget companyDetailTitle() {
    return SizedBox(
      width: wScale(295),
      child: Text("Company Detail",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: fSize(16),
            fontWeight: FontWeight.w600,
          )),
    );
  }

  Widget verifyButton() {
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
            handleContinue();
          },
          child: Text("Continue",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget validError(errorFlag) {
    return SizedBox(
      height: errorFlag ? 0 : hScale(18),
      child: Text("Verification code is invalid",
          style:
              TextStyle(fontSize: fSize(14), color: const Color(0xffEB5757))),
    );
  }

  Widget expireTitle() {
    return Text("This OTP expires in 30 minutes",
        style: TextStyle(fontSize: fSize(14), fontWeight: FontWeight.bold));
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
                controller: companyTypeCtl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
                  hintText: 'Select Company Type',
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
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text('Company Type',
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFBFBFBF))),
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
              border:
                  Border.all(color: const Color(0xFF040415).withOpacity(0.1))),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: TextField(
                readOnly: true,
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF040415)),
                controller: companyIndustryCtl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
                  hintText: 'Select Company Type',
                  hintStyle: TextStyle(
                      color: const Color(0xffBFBFBF), fontSize: fSize(14)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
                ),
              )),
              PopupMenuButton<String>(
                icon: Image.asset('assets/search_icon.png',
                    fit: BoxFit.contain, width: wScale(15)),
                onSelected: (String value) {
                  companyIndustryCtl.text = value;
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
                    color: const Color(0xFFBFBFBF))),
          ),
        )
      ],
    );
  }
}

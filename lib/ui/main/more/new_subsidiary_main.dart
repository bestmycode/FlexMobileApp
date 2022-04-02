import 'dart:ui';

import 'package:co/ui/main/more/new_subsidiary.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_mobile_textfield.dart';
import 'package:co/ui/widgets/custom_no_internet.dart';
import 'package:co/ui/widgets/custom_result_modal.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewSubsidiaryMain extends StatefulWidget {
  final industry;
  final listCompany;
  final userInfo;
  const NewSubsidiaryMain(
      {Key? key, this.industry, this.listCompany, this.userInfo})
      : super(key: key);
  @override
  NewSubsidiaryMainState createState() => NewSubsidiaryMainState();
}

class NewSubsidiaryMainState extends State<NewSubsidiaryMain> {
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
  String getCountryQuery = Queries.QUERY_GET_COUNTRY;
  String createOrganizationMutation = FXRMutations.MUTATION_CREATE_ORGANIZATION;
  String mainName = '';
  String mainMobile = '';

  final companyNameCtl = TextEditingController();
  final companyNumberCtl = TextEditingController();
  final countryCtl = TextEditingController();
  final companyTypeCtl = TextEditingController();
  final companyPhoneNumberCtl = TextEditingController();
  final companyAddressCtl = TextEditingController();
  final companyPostalCodeCtl = TextEditingController();
  final industryCtl = TextEditingController();
  final cityCtl = TextEditingController();
  final vnBuildingNameCtl = TextEditingController();
  final vnWardNumberCtl = TextEditingController();
  final vnDistrictCtl = TextEditingController();
  final operatingPostalCodeCtl = TextEditingController();
  final operatingCityCtl = TextEditingController();
  final operatingAddressCtl = TextEditingController();
  final operatingVnBuildingNameCtl = TextEditingController();
  final operatingVnWardNumberCtl = TextEditingController();
  final operatingVnDistrictCtl = TextEditingController();
  final mainContactNameCtl = TextEditingController();
  final mainContactMobileCtl = TextEditingController();
  var selectedIndustryArr = [];
  var industryTextArr = [];
  var selectedCity = {};
  var operatingSelectedCity = {};
  String selectedCompanyType = '';

  bool flagAddress = false;
  bool showEmpty = false;
  bool isLoading = false;
  bool showIndustryList = false;
  bool mainContactFlag = false;
  bool isPreview = false;

  handleConfirm(runMutation) {
    setState(() {
      isLoading = true;
    });
    var industies = [];
    selectedIndustryArr.forEach((element) {
      industies.add(element['id']);
    });
    var mutationValue = {
      "baseCurrency": "SGD",
      "businessDescription": "",
      "city": selectedCity['id'].toString(),
      "companyType": selectedCompanyType,
      "contactName": mainContactNameCtl.text,
      "contactNumber": mainContactMobileCtl.text,
      "country": storage.getItem("country"),
      "crn": companyNumberCtl.text,
      "industries": industies,
      "name": companyNameCtl.text,
      "primaryAddress": {
        "addressLine1": companyAddressCtl.text,
        "addressLine2": _selectedDialogCountry.isoCode == "VN"
            ? vnBuildingNameCtl.text
            : "",
        "addressLine3":
            _selectedDialogCountry.isoCode == "VN" ? vnWardNumberCtl.text : "",
        "addressLine4":
            _selectedDialogCountry.isoCode == "VN" ? vnDistrictCtl.text : "",
        "city": selectedCity['id'].toString(),
        "zipCode": companyPostalCodeCtl.text,
      },
      "phone":
          '+${_selectedDialogCountry.phoneCode}${companyPhoneNumberCtl.text}',
      "operatingAddress": {
        "addressLine1": operatingAddressCtl.text,
        "addressLine2": _selectedDialogCountry.isoCode == "VN"
            ? operatingVnBuildingNameCtl.text
            : "",
        "addressLine3": _selectedDialogCountry.isoCode == "VN"
            ? operatingVnWardNumberCtl.text
            : "",
        "addressLine4": _selectedDialogCountry.isoCode == "VN"
            ? operatingVnDistrictCtl.text
            : "",
        "city": operatingSelectedCity['id'].toString(),
        "zipCode": operatingPostalCodeCtl.text,
      },
      "proprietorPartner": false,
      "revenueGenerationDetail": "",
      "signupToken": null,
    };
    runMutation(mutationValue);

    setState(() {
      showEmpty = false;
    });
  }

  @override
  void initState() {
    super.initState();
    storage.setItem('country', _selectedDialogCountry.isoCode);
    List<String> temp_industryArr = [];
    widget.industry.forEach((item) {
      temp_industryArr.add("${item['id']} - ${item['name']}");
    });
    industryTextArr = temp_industryArr;
    mainName = "${widget.userInfo['firstName']} ${widget.userInfo['lastName']}";
    mainMobile = widget.userInfo['mobile'];
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
                child: Stack(
              children: [
                Opacity(
                    opacity: isLoading ? 0.5 : 1,
                    child: Column(children: [
                      const CustomSpacer(size: 44),
                      CustomMainHeader(
                          title: AppLocalizations.of(context)!
                              .createnewsubsidiary),
                      const CustomSpacer(size: 20),
                      groupIcon(),
                      const CustomSpacer(size: 15),
                      groupTitle(),
                      const CustomSpacer(size: 36),
                      isPreview ? editButtonField() : SizedBox(),
                      isPreview
                          ? companyDetailSectionPreview()
                          : companyDetailSection(
                              widget.industry, widget.listCompany),
                      const CustomSpacer(size: 15),
                      isPreview
                          ? registeredAddressFieldPreview(0)
                          : registeredAddressField(0),
                      isPreview ? SizedBox() : const CustomSpacer(size: 22),
                      isPreview ? SizedBox() : differentAddressField(),
                      const CustomSpacer(size: 22),
                      flagAddress
                          ? isPreview
                              ? registeredAddressFieldPreview(1)
                              : registeredAddressField(1)
                          : SizedBox(),
                      flagAddress ? const CustomSpacer(size: 22) : SizedBox(),
                      isPreview
                          ? mainContactPersonFieldPreview()
                          : mainContactPersonField(),
                      const CustomSpacer(size: 37),
                      mutationButton(),
                      const CustomSpacer(size: 24),
                      const CustomSpacer(size: 88),
                    ])),
                isLoading
                    ? Positioned(
                        top: 150,
                        child: Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF60C094)))))
                    : SizedBox()
              ],
            ))),
      ),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 14),
      )
    ])));
  }

  Widget mutationButton() {
    String accessToken = tokenStorage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Mutation(
            options: MutationOptions(
              document: gql(createOrganizationMutation),
              update: (GraphQLDataProxy cache, QueryResult? result) {
                return cache;
              },
              onError: (error) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Padding(
                          padding: EdgeInsets.symmetric(horizontal: wScale(40)),
                          child: Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: CustomResultModal(
                                status: true,
                                title: "Create Organization Failed",
                                titleColor: Color(0xFFEB5757),
                                message:
                                    "There is an existing organisation with this company registration no. Please contact our support team for assistance.",
                                handleOKClick: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop('dialog');
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                              )));
                    });
              },
              onCompleted: (resultData) {
                if (resultData != null &&
                    resultData['createdOrganization'] != null) {
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
                                  message:
                                      "New Subsidiary created successfully",
                                  handleOKClick: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop('dialog');
                                    Navigator.pop(context, true);
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                )));
                      });
                }
              },
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              return confirmButton(runMutation);
            }));
  }

  Widget groupIcon() {
    return Image.asset('assets/group.png',
        fit: BoxFit.contain, width: wScale(60));
  }

  Widget groupTitle() {
    return Text(AppLocalizations.of(context)!.tellusmoreaboutyourorganisation,
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
            color: Color(0xFF106549).withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          detailTitle(AppLocalizations.of(context)!.companydetail),
          const CustomSpacer(size: 22),
          CustomTextField(
              isError: showEmpty && companyNameCtl.text == '',
              ctl: companyNameCtl,
              hint: AppLocalizations.of(context)!.companyname,
              label: AppLocalizations.of(context)!.companyname),
          isValidateText(
              showEmpty && companyNameCtl.text == '', companyNameCtl.text),
          CustomTextField(
              isError: showEmpty && companyNumberCtl.text == '',
              ctl: companyNumberCtl,
              hint: AppLocalizations.of(context)!.companyregistrationnumber,
              label: AppLocalizations.of(context)!.companyregistrationnumber),
          isValidateText(
              showEmpty && companyNumberCtl.text == '', companyNumberCtl.text),
          countryField(),
          const CustomSpacer(size: 32),
          companyTypeField(listCompany),
          isValidateText(
              showEmpty && companyTypeCtl.text == '', companyTypeCtl.text),
          industryTypeField(industry),
          selectedIndustriesField(),
          showIndustryList ? industiesField() : SizedBox(),
          isValidateText(
              showEmpty && selectedIndustryArr.length == 0, industryCtl.text),
          selectedIndustryArr.length > 3
              ? isValidateIndustryText(selectedIndustryArr.length > 3)
              : SizedBox(),
          CustomMobileTextField(
              isError: showEmpty && companyPhoneNumberCtl.text == '',
              ctl: companyPhoneNumberCtl,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              hint: AppLocalizations.of(context)!.companyphonenumber,
              label: AppLocalizations.of(context)!.companyphonenumber),
          isValidateText(showEmpty && companyPhoneNumberCtl.text == '',
              companyPhoneNumberCtl.text),
        ],
      ),
    );
  }

  Widget isValidateText(flag, text) {
    return flag == true
        ? Container(
            height: hScale(32),
            width: wScale(295),
            padding: EdgeInsets.only(top: hScale(5)),
            child: Text(AppLocalizations.of(context)!.thisfieldisrequired,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: fSize(12),
                    color: Color(0xFFEB5757),
                    fontWeight: FontWeight.w400)))
        : CustomSpacer(size: 32);
  }

  Widget isValidateIndustryText(flag) {
    return flag == true
        ? Container(
            height: hScale(32),
            width: wScale(295),
            padding: EdgeInsets.only(top: hScale(5)),
            child: Text(
                AppLocalizations.of(context)!.thisfieldisrequiredindustry,
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
          // height: hScale(56),
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
            child: Text(AppLocalizations.of(context)!.country,
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
                            onPressed: () {
                              Navigator.of(context).pop();
                            }))
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
                width: wScale(20),
                height: wScale(12),
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

  Widget companyTypeField(listCompany) {
    List<String> listCompanyArr = [];
    listCompany.forEach((item) {
      listCompanyArr.add(item['name']);
    });

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
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 1.0)),
                  hintText: AppLocalizations.of(context)!.companytype,
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
              listCompanyArr.length == 0
                  ? SizedBox()
                  : PopupMenuButton<String>(
                      icon: Icon(Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFFBFBFBF), size: wScale(15)),
                      onSelected: (String value) {
                        companyTypeCtl.text = value;
                        var index = listCompanyArr.indexOf(value);
                        setState(() {
                          selectedCompanyType = listCompany[index]['id'];
                        });
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
            child: Text(AppLocalizations.of(context)!.companytype,
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
    List<String> temp_industryArr = [];
    industryArr.forEach((item) {
      var isExist = selectedIndustryArr.firstWhere(
          (element) => element['id'] == item['id'],
          orElse: () => null);
      if (isExist == null)
        temp_industryArr.add("${item['id']} - ${item['name']}");
    });
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
                  color: showEmpty && selectedIndustryArr.length == 0
                      ? Color(0xFFEB5757)
                      : Color(0xffBFBFBF))),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: TextField(
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF040415)),
                controller: industryCtl,
                onChanged: (text) {
                  var temp_industryTextArr = temp_industryArr
                      .where((item) =>
                          item.toLowerCase().contains(text.toLowerCase()))
                      .toList();
                  setState(() {
                    showIndustryList = text.length > 0 ? true : false;
                    industryTextArr = temp_industryTextArr;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 1.0)),
                  hintText: 'Select Company Type',
                  hintStyle: TextStyle(
                      color: showEmpty && selectedIndustryArr.length == 0
                          ? const Color(0xFFEB5757)
                          : Color(0xffBFBFBF),
                      fontSize: fSize(14)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 1.0)),
                ),
              )),
              industryArr.length == 0
                  ? SizedBox()
                  : Container(
                      width: wScale(40),
                      child: TextButton(
                          child: Image.asset('assets/search_icon.png',
                              fit: BoxFit.contain, width: wScale(15)),
                          onPressed: () {
                            setState(() {
                              showIndustryList = !showIndustryList;
                            });
                          }))
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text(AppLocalizations.of(context)!.industry,
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: showEmpty && selectedIndustryArr.length == 0
                        ? const Color(0xFFEB5757)
                        : Color(0xffBFBFBF))),
          ),
        )
      ],
    );
  }

  Widget industiesField() {
    return Container(
        width: wScale(295),
        height: hScale(350),
        child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: industryTextArr.map<Widget>((item) {
                  return TextButton(
                      style: TextButton.styleFrom(
                        // primary: const Color(0xff00).withOpacity(0.4),
                        padding: const EdgeInsets.all(0),
                      ),
                      onPressed: () {
                        industryCtl.text = '';
                        var id = item.split(" - ")[0];
                        var selecetedItem = widget.industry.firstWhere(
                            (element) =>
                                element['id'].toString() == id.toString(),
                            orElse: () => null);
                        setState(() {
                          selectedIndustryArr.add(selecetedItem);
                          industryTextArr
                              .removeAt(industryTextArr.indexOf(item));
                          showIndustryList = false;
                        });
                      },
                      child: Text(item,
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black)));
                }).toList())));
  }

  Widget detailTitle(title) {
    return SizedBox(
      width: wScale(295),
      child: Text(title,
          textAlign: TextAlign.start,
          style: TextStyle(
              fontSize: fSize(16),
              fontWeight: FontWeight.w600,
              color: isPreview ? Color(0xFF29c490) : Colors.black)),
    );
  }

  Widget registeredAddressField(index) {
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
            blurRadius: 10,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          detailTitle(index == 0
              ? AppLocalizations.of(context)!.registeredaddress
              : "Main Operating Address"),
          const CustomSpacer(size: 22),
          CustomTextField(
              isError: index == 0
                  ? showEmpty && companyAddressCtl.text == ''
                  : flagAddress && showEmpty && operatingAddressCtl.text == '',
              ctl: index == 0 ? companyAddressCtl : operatingAddressCtl,
              hint: AppLocalizations.of(context)!.street,
              label: AppLocalizations.of(context)!.street),
          index == 0
              ? isValidateText(showEmpty && companyAddressCtl.text == '',
                  companyAddressCtl.text)
              : flagAddress
                  ? isValidateText(showEmpty && operatingAddressCtl.text == '',
                      operatingAddressCtl.text)
                  : CustomSpacer(size: 32),
          _selectedDialogCountry.isoCode == "VN"
              ? Column(
                  children: [
                    CustomTextField(
                        ctl: index == 0
                            ? vnBuildingNameCtl
                            : operatingVnBuildingNameCtl,
                        hint: AppLocalizations.of(context)!.buidingname,
                        label: AppLocalizations.of(context)!.buidingname),
                    // isValidateText(showEmpty && vnBuildingNameCtl.text == '',
                    //     vnBuildingNameCtl.text),
                    SizedBox(height: hScale(32)),
                    CustomTextField(
                        isError: showEmpty && index == 0
                            ? vnWardNumberCtl.text == ''
                            : operatingVnWardNumberCtl.text == '',
                        ctl: index == 0
                            ? vnWardNumberCtl
                            : operatingVnWardNumberCtl,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        hint: AppLocalizations.of(context)!.wardnumber,
                        label: AppLocalizations.of(context)!.wardnumber),
                    isValidateText(
                        showEmpty && index == 0
                            ? vnWardNumberCtl.text == ''
                            : operatingVnWardNumberCtl.text == '',
                        index == 0
                            ? vnWardNumberCtl.text
                            : operatingVnWardNumberCtl.text),
                    CustomTextField(
                        isError: showEmpty && index == 0
                            ? vnDistrictCtl.text == ''
                            : operatingVnDistrictCtl.text == '',
                        ctl: vnDistrictCtl,
                        hint: AppLocalizations.of(context)!.district,
                        label: AppLocalizations.of(context)!.district),
                    isValidateText(
                        showEmpty && index == 0
                            ? vnDistrictCtl.text == ''
                            : operatingVnDistrictCtl.text == '',
                        index == 0
                            ? vnDistrictCtl.text
                            : operatingVnDistrictCtl.text),
                  ],
                )
              : SizedBox(),
          registeredAddressCityField(index),
          index == 0
              ? isValidateText(showEmpty && cityCtl.text == '', cityCtl.text)
              : isValidateText(showEmpty && operatingCityCtl.text == '',
                  operatingCityCtl.text),
          CustomTextField(
            isError: _selectedDialogCountry.isoCode == "VN"
                ? false
                : index == 0
                    ? showEmpty && companyPostalCodeCtl.text == ''
                    : flagAddress &&
                        showEmpty &&
                        operatingPostalCodeCtl.text == '',
            ctl: index == 0 ? companyPostalCodeCtl : operatingPostalCodeCtl,
            hint: AppLocalizations.of(context)!.postalcode,
            label: AppLocalizations.of(context)!.postalcode,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          _selectedDialogCountry.isoCode == "VN"
              ? SizedBox(height: hScale(32))
              : index == 0
                  ? isValidateText(showEmpty && companyPostalCodeCtl.text == '',
                      companyPostalCodeCtl.text)
                  : flagAddress
                      ? isValidateText(
                          showEmpty && operatingPostalCodeCtl.text == '',
                          operatingPostalCodeCtl.text)
                      : CustomSpacer(size: 32),
        ],
      ),
    );
  }

  Widget differentAddressField() {
    return Container(
      width: wScale(375),
      padding: EdgeInsets.only(left: wScale(40), right: wScale(24)),
      child: Row(children: [
        differentAddressCheckBox(),
        Container(
            width: wScale(268),
            child: Text(
                AppLocalizations.of(context)!
                    .mybusinessoperatesatadifferentaddress,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: fSize(14)))),
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
            if (companyNameCtl.text != '' &&
                companyNumberCtl.text != '' &&
                companyTypeCtl.text != '' &&
                companyPhoneNumberCtl.text != '' &&
                companyAddressCtl.text != '' &&
                companyPostalCodeCtl.text != '' &&
                cityCtl.text != '' &&
                selectedIndustryArr.length > 0 &&
                mainContactNameCtl.text != '' &&
                mainContactMobileCtl.text != '') {
              if (flagAddress) {
                if (operatingAddressCtl.text != '' &&
                    operatingPostalCodeCtl != '') {
                  isPreview == false
                      ? setState(() {
                          isPreview = true;
                        })
                      : handleConfirm(runMutation);
                }
              } else {
                isPreview == false
                    ? setState(() {
                        isPreview = true;
                      })
                    : handleConfirm(runMutation);
              }
            } else {
              setState(() {
                showEmpty = true;
              });
            }
          },
          child: Text(
              isPreview == false
                  ? AppLocalizations.of(context)!.ccontinue
                  : AppLocalizations.of(context)!.confirm,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.bold)),
        ));
  }

  Widget registeredAddressCityField(index) {
    return Query(
        options: QueryOptions(
          document: gql(getCountryQuery),
          variables: {"countryId": _selectedDialogCountry.isoCode},
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Scaffold(body: CustomNoInternet(handleTryAgain: () {
              Navigator.of(context)
                  .push(new MaterialPageRoute(
                      builder: (context) => NewSubsidiary()))
                  .then((value) => setState(() => {}));
            }));
          }
          if (result.isLoading) {
            return countryCityField([], index);
          }

          var countryData = result.data!['country'];

          return countryCityField(countryData, index);
        });
  }

  Widget countryCityField(countryData, select) {
    List<String> cityArr = [];
    countryData.length > 0
        ? countryData['cities'].forEach((item) {
            cityArr.add(item['name']);
          })
        : null;
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
                  color: (select == 0
                          ? showEmpty && cityCtl.text == ''
                          : flagAddress &&
                              showEmpty &&
                              operatingCityCtl.text == '')
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
                controller: select == 0 ? cityCtl : operatingCityCtl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 1.0)),
                  hintText: 'City',
                  hintStyle: TextStyle(
                      color: (select == 0
                              ? showEmpty && cityCtl.text == ''
                              : flagAddress &&
                                  showEmpty &&
                                  operatingCityCtl.text == '')
                          ? const Color(0xFFEB5757)
                          : Color(0xffBFBFBF),
                      fontSize: fSize(14)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 1.0)),
                ),
              )),
              cityArr.length == 0
                  ? SizedBox()
                  : PopupMenuButton<String>(
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFFBFBFBF),
                        size: wScale(15),
                      ),
                      onSelected: (String value) {
                        setState(() {
                          select == 0
                              ? cityCtl.text = value
                              : operatingCityCtl.text = value;
                          var index = cityArr.indexOf(value);
                          select == 0
                              ? selectedCity = countryData['cities'][index]
                              : operatingSelectedCity =
                                  countryData['cities'][index];
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return cityArr
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
            child: Text(AppLocalizations.of(context)!.city,
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: (select == 0
                            ? showEmpty && cityCtl.text == ''
                            : flagAddress &&
                                showEmpty &&
                                operatingCityCtl.text == '')
                        ? Color(0xFFEB5757)
                        : Color(0xffBFBFBF))),
          ),
        )
      ],
    );
  }

  Widget selectedIndustriesField() {
    return Container(
        width: wScale(295),
        padding: EdgeInsets.only(top: 5),
        child: Column(children: [
          for (var i = 0; i < selectedIndustryArr.length; i++)
            selectedIndustry(i, selectedIndustryArr[i])
        ]));
  }

  Widget selectedIndustry(index, item) {
    return Container(
      height: hScale(26),
      margin: EdgeInsets.only(top: hScale(5)),
      padding: EdgeInsets.all(hScale(5)),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EDEA),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Row(
        children: [
          Container(
              width: wScale(269),
              child: Text("${item['id']} - ${item['name']}",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: fSize(12),
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF040415)))),
          Container(
            width: wScale(16),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                setState(() {
                  selectedIndustryArr.removeAt(index);
                  if (selectedIndustryArr.length == 0) industryCtl.text = '';
                });
              },
              child:
                  Icon(Icons.close_rounded, color: Color(0xFF040415), size: 16),
            ),
          )
        ],
      ),
    );
  }

  Widget mainContactPersonField() {
    return Container(
      width: wScale(325),
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
            blurRadius: 10,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          detailTitle(AppLocalizations.of(context)!.maincontactperson),
          detailTitle(
              AppLocalizations.of(context)!.forcourierandmailingpurpose),
          const CustomSpacer(size: 10),
          mainContactpersonCheckField(),
          const CustomSpacer(size: 22),
          CustomTextField(
              isError: showEmpty && mainContactNameCtl.text == '',
              ctl: mainContactNameCtl,
              hint: AppLocalizations.of(context)!.fullname,
              label: AppLocalizations.of(context)!.fullname),
          isValidateText(showEmpty && mainContactNameCtl.text == '',
              mainContactNameCtl.text),
          CustomTextField(
              isError: showEmpty && mainContactMobileCtl.text == '',
              ctl: mainContactMobileCtl,
              hint: AppLocalizations.of(context)!.mobilenumberwithcountrycode,
              label: AppLocalizations.of(context)!.mobilenumberwithcountrycode),
          isValidateText(showEmpty && mainContactMobileCtl.text == '',
              mainContactMobileCtl.text),
        ],
      ),
    );
  }

  Widget mainContactpersonCheckField() {
    return Container(
      width: wScale(325),
      // padding: EdgeInsets.only(left: wScale(16), right: wScale(16)),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            mainContactCheckBox(),
            Text(AppLocalizations.of(context)!.iamthemaincontactpersonfor,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: fSize(14))),
          ]),
    );
  }

  Widget mainContactCheckBox() {
    return Container(
        width: hScale(14),
        height: hScale(24),
        margin: EdgeInsets.only(right: wScale(17)),
        child: Transform.scale(
          scale: 0.7,
          child: Checkbox(
            value: mainContactFlag,
            activeColor: const Color(0xff30E7A9),
            onChanged: (value) {
              setState(() {
                mainContactFlag = value!;
                mainContactNameCtl.text =
                    mainContactFlag ? mainName : mainContactNameCtl.text;
                mainContactMobileCtl.text =
                    mainContactFlag ? mainMobile : mainContactMobileCtl.text;
              });
            },
          ),
        ));
  }

  Widget previewTitle(title, value) {
    return Container(
        width: wScale(295),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: fSize(16),
              color: Colors.black,
            ),
            children: [
              TextSpan(text: "${title}: "),
              TextSpan(
                  text: value,
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: fSize(18))),
            ],
          ),
        ));
  }

  Widget companyDetailSectionPreview() {
    var selectedIndustyText = "";
    selectedIndustryArr.forEach((item) {
      selectedIndustyText += "${item['id']} - ${item['name']}";
      selectedIndustyText +=
          selectedIndustryArr.indexOf(item) != selectedIndustryArr.length - 1
              ? ", "
              : "";
    });
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
            color: Color(0xFF106549).withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          detailTitle(AppLocalizations.of(context)!.companydetail),
          const CustomSpacer(size: 22),
          previewTitle(
              AppLocalizations.of(context)!.companyname, companyNameCtl.text),
          const CustomSpacer(size: 10),
          previewTitle(AppLocalizations.of(context)!.companyregistrationnumber,
              companyNumberCtl.text),
          const CustomSpacer(size: 10),
          previewTitle(AppLocalizations.of(context)!.country,
              _selectedDialogCountry.name),
          const CustomSpacer(size: 10),
          previewTitle(
              AppLocalizations.of(context)!.companytype, companyTypeCtl.text),
          const CustomSpacer(size: 10),
          previewTitle(
              AppLocalizations.of(context)!.industry, selectedIndustyText),
          const CustomSpacer(size: 10),
          previewTitle(AppLocalizations.of(context)!.companyphonenumber,
              '+${_selectedDialogCountry.phoneCode} ${companyPhoneNumberCtl.text}'),
        ],
      ),
    );
  }

  Widget registeredAddressFieldPreview(index) {
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
            blurRadius: 10,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          detailTitle(index == 0
              ? AppLocalizations.of(context)!.registeredaddress
              : "Main Operating Address"),
          const CustomSpacer(size: 22),
          previewTitle(AppLocalizations.of(context)!.street,
              index == 0 ? companyAddressCtl.text : operatingAddressCtl.text),
          const CustomSpacer(size: 10),
          _selectedDialogCountry.isoCode == "VN"
              ? Column(
                  children: [
                    previewTitle(
                        AppLocalizations.of(context)!.buidingname,
                        index == 0
                            ? vnBuildingNameCtl.text
                            : operatingVnBuildingNameCtl.text),
                    const CustomSpacer(size: 10),
                    previewTitle(
                        AppLocalizations.of(context)!.wardnumber,
                        index == 0
                            ? vnWardNumberCtl.text
                            : operatingVnWardNumberCtl.text),
                    const CustomSpacer(size: 10),
                    previewTitle(
                        AppLocalizations.of(context)!.district,
                        index == 0
                            ? vnDistrictCtl.text
                            : operatingVnDistrictCtl.text),
                  ],
                )
              : SizedBox(),
          previewTitle(
              AppLocalizations.of(context)!.city,
              index == 0
                  ? selectedCity['name']
                  : operatingSelectedCity['name']),
          const CustomSpacer(size: 10),
          previewTitle(
              AppLocalizations.of(context)!.postalcode,
              index == 0
                  ? companyPostalCodeCtl.text
                  : operatingPostalCodeCtl.text),
        ],
      ),
    );
  }

  Widget mainContactPersonFieldPreview() {
    return Container(
      width: wScale(325),
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
            blurRadius: 10,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          detailTitle(AppLocalizations.of(context)!.maincontactperson),
          const CustomSpacer(size: 22),
          previewTitle(
              AppLocalizations.of(context)!.fullname, mainContactNameCtl.text),
          const CustomSpacer(size: 10),
          previewTitle(
              AppLocalizations.of(context)!.mobilenumberwithcountrycode,
              mainContactMobileCtl.text),
        ],
      ),
    );
  }

  Widget editButtonField() {
    return Container(
      width: wScale(325),
      alignment: Alignment.centerRight,
      child: TextButton(
        style: TextButton.styleFrom(
          primary: const Color(0xff000000),
          padding: EdgeInsets.all(0),
          textStyle:
              TextStyle(fontSize: fSize(16), fontStyle: FontStyle.italic),
        ),
        onPressed: () {
          setState(() {
            isPreview = false;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.mode_edit_outline_outlined,
              size: 12,
            ),
            Text(AppLocalizations.of(context)!.edit)
          ],
        ),
      ),
    );
  }
}

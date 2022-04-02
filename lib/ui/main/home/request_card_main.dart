import 'dart:ui';

import 'package:co/constants/constants.dart';
import 'package:co/ui/main/cards/name_on_card.dart';
import 'package:co/ui/widgets/custom_popup_list.dart';
import 'package:co/ui/widgets/custom_result_modal.dart';
import 'package:co/ui/widgets/new_name_physical_card.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'dart:math' as math;

class RequestCardMain extends StatefulWidget {
  final initData;
  final companyProfile;
  final eligibleUsers;
  final merchantUsers;
  const RequestCardMain(
      {Key? key,
      this.initData,
      this.companyProfile,
      this.eligibleUsers,
      this.merchantUsers})
      : super(key: key);
  @override
  RequestCardMainState createState() => RequestCardMainState();
}

class RequestCardMainState extends State<RequestCardMain> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  TextEditingController monthlyLimitCtl = TextEditingController();
  TextEditingController transactionLimitCtl =
      TextEditingController(text: '500');
  TextEditingController varianceLimitCtl = TextEditingController(text: '0%');
  TextEditingController remarksCtl = TextEditingController();
  TextEditingController companyNameCtl = TextEditingController();

  TextEditingController cardHolderNameCtl = TextEditingController();
  TextEditingController monthlySpendLimitCtl =
      TextEditingController(text: "500");

  var isSwitchedAdditional = true;
  var isSwitchedMerchant = true;
  var isSwitchedTransactionLimit = true;

  bool showTransactionHint = false;
  bool showVarianceHint = false;
  var isSwitchedArr = [
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true
  ];
  double transactionLimitValue = 100;
  double varianceLimitValue = 0;

  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String mutationRequestCardSpend = FXRMutations.MUTATION_REQUEST_CARD_SPEND;
  String updateCompanyNameMutation = FXRMutations.MUTATION_UPDATE_COMPANY_NAME;

  late var seletedEligible;
  var cardHolders = [];
  var cardNameHolders = [];
  bool errorCardHolder = false;
  bool errorMonthlySpend = false;
  bool checkCardName = false;
  bool cardHolderLimit = false;
  var companyname = '';
  bool isCompanyNameCtlEmpty = false;
  bool errorMonthlySpendLength = false;
  bool errorTransactionLimit = false;

  handleCloneSetting() {}

  handleSwitch(index, v) {
    setState(() {
      isSwitchedArr[index] = v;
    });
  }

  handleSave(runMutation) async {
    setState(() {
      errorMonthlySpendLength =
          monthlySpendLimitCtl.text.length > 10 ? true : false;
      errorMonthlySpend = monthlySpendLimitCtl.text == "" ? true : false;
      errorCardHolder = cardHolders.length == 0 ? true : false;
    });
    if (!errorMonthlySpend && !errorCardHolder && !errorMonthlySpendLength) {
      if (companyNameCtl.text == '') {
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return Padding(
                  padding: EdgeInsets.symmetric(horizontal: wScale(40)),
                  child: Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      child: CustomResultModal(
                        status: true,
                        title: "Missing Company Name",
                        message:
                            "Company Name on Card is Missing. Please enter the company name that will appear on your physical card(s).",
                      )));
            });
      } else {
        if (checkCardName == false) {
          _showCardNameModalDialog(context);
        } else {
          var runValue = !isSwitchedMerchant && !isSwitchedTransactionLimit
              ? {
                  "accountSubtype": "PHYSICAL",
                  "cardHolders": cardHolders,
                  "cardLimit": int.parse(monthlySpendLimitCtl.text),
                  "orgId": userStorage.getItem('orgId'),
                  "remarks": remarksCtl.text,
                  "renewalFrequency": "MONTHLY",
                }
              : !isSwitchedMerchant
                  ? {
                      "accountSubtype": "PHYSICAL",
                      "cardHolders": cardHolders,
                      "cardLimit": int.parse(monthlySpendLimitCtl.text),
                      "controls": {
                        "transactionLimit": (transactionLimitValue *
                                int.parse(monthlySpendLimitCtl.text) /
                                100)
                            .round(),
                        "variancePercentage": varianceLimitValue.round(),
                      },
                      "orgId": userStorage.getItem('orgId'),
                      "remarks": remarksCtl.text,
                      "renewalFrequency": "MONTHLY",
                    }
                  : !isSwitchedTransactionLimit
                      ? {
                          "accountSubtype": "PHYSICAL",
                          "cardHolders": cardHolders,
                          "cardLimit": int.parse(monthlySpendLimitCtl.text),
                          "controls": {
                            "allowedCategories": [
                              {
                                "categoryName": "AIRLINES",
                                "isAllowed": isSwitchedArr[0]
                              },
                              {
                                "categoryName": "CAR_RENTAL",
                                "isAllowed": isSwitchedArr[1]
                              },
                              {
                                "categoryName": "TRANSPORTATION",
                                "isAllowed": isSwitchedArr[2]
                              },
                              {
                                "categoryName": "HOTELS",
                                "isAllowed": isSwitchedArr[3]
                              },
                              {
                                "categoryName": "PETROL",
                                "isAllowed": isSwitchedArr[4]
                              },
                              {
                                "categoryName": "DEPARTMENT_STORES",
                                "isAllowed": isSwitchedArr[5]
                              },
                              {
                                "categoryName": "PARKING",
                                "isAllowed": isSwitchedArr[6]
                              },
                              {
                                "categoryName": "FOOD_AND_BEVERAGES",
                                "isAllowed": isSwitchedArr[7]
                              },
                              {
                                "categoryName": "TAXIS",
                                "isAllowed": isSwitchedArr[8]
                              },
                              {
                                "categoryName": "OTHERS",
                                "isAllowed": isSwitchedArr[9]
                              },
                            ],
                          },
                          "orgId": userStorage.getItem('orgId'),
                          "remarks": remarksCtl.text,
                          "renewalFrequency": "MONTHLY",
                        }
                      : {
                          "accountSubtype": "PHYSICAL",
                          "cardHolders": cardHolders,
                          "cardLimit": int.parse(monthlySpendLimitCtl.text),
                          "controls": {
                            "allowedCategories": [
                              {
                                "categoryName": "AIRLINES",
                                "isAllowed": isSwitchedArr[0]
                              },
                              {
                                "categoryName": "CAR_RENTAL",
                                "isAllowed": isSwitchedArr[1]
                              },
                              {
                                "categoryName": "TRANSPORTATION",
                                "isAllowed": isSwitchedArr[2]
                              },
                              {
                                "categoryName": "HOTELS",
                                "isAllowed": isSwitchedArr[3]
                              },
                              {
                                "categoryName": "PETROL",
                                "isAllowed": isSwitchedArr[4]
                              },
                              {
                                "categoryName": "DEPARTMENT_STORES",
                                "isAllowed": isSwitchedArr[5]
                              },
                              {
                                "categoryName": "PARKING",
                                "isAllowed": isSwitchedArr[6]
                              },
                              {
                                "categoryName": "FOOD_AND_BEVERAGES",
                                "isAllowed": isSwitchedArr[7]
                              },
                              {
                                "categoryName": "TAXIS",
                                "isAllowed": isSwitchedArr[8]
                              },
                              {
                                "categoryName": "OTHERS",
                                "isAllowed": isSwitchedArr[9]
                              },
                            ],
                            "transactionLimit": (transactionLimitValue *
                                    int.parse(monthlySpendLimitCtl.text) /
                                    100)
                                .round(),
                            "variancePercentage": varianceLimitValue.round(),
                          },
                          "orgId": userStorage.getItem('orgId'),
                          "remarks": remarksCtl.text,
                          "renewalFrequency": "MONTHLY",
                        };
          runMutation(runValue);
        }
      }
    }
  }

  handleEditCompanyName() {
    _showSimpleModalDialog(context);
  }

  handleAddCardHolderName() async {
    var cardNameHolders = [];
    cardHolders.forEach((element) {
      cardNameHolders
          .add({"id": element['userId'], 'name': element['preferredCardName']});
    });

    var result = await Navigator.of(context).push(
      CupertinoPageRoute(
          builder: (context) =>
              NameOnCard(cardNameHolders: cardNameHolders, cardType: 1)),
    );
    var tempCardHolders = [];
    cardHolders.forEach((item) {
      tempCardHolders.add({
        "userId": item['userId'],
        "preferredCardholderName": '',
        "preferredCardName": result[cardHolders.indexOf(item)]['name'],
        "applySpendControls": true
      });
    });

    setState(() {
      cardNameHolders = result;
      cardHolders = tempCardHolders;
      checkCardName = true;
      errorCardHolder = false;
    });
    // handleSave(runMutation);
  }

  handleCheckCardName() {
    setState(() {
      checkCardName = true;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.companyProfile == null ||
        widget.companyProfile['organizationAlias'] == null) {
      Future.delayed(Duration.zero, () {
        _showNewNameModalDialog(context);
      });
    } else {
      companyNameCtl.text = widget.companyProfile['organizationAlias'];
    }

    if (widget.initData != null) {
      monthlySpendLimitCtl.text =
          widget.initData['financeAccountLimits'][0]['limitValue'].toString();
      transactionLimitCtl.text =
          widget.initData['spendControlLimits']['transactionLimit'].toString();
      varianceLimitCtl.text = widget.initData['spendControlLimits']
                  ['variancePercentage']
              .toString() +
          "%";
      if (widget.initData['spendControlLimits']['transactionLimit'] != null) {
        transactionLimitValue = widget.initData['spendControlLimits']
                ['transactionLimit'] /
            widget.initData['financeAccountLimits'][0]['limitValue'] *
            100.toDouble();
        varianceLimitValue = (widget.initData['spendControlLimits']
                ['variancePercentage'])
            .toDouble();
      } else {
        setState(() {
          isSwitchedTransactionLimit = false;
        });
      }
      if (widget.initData['spendControlLimits']['allowedCategories'] != null &&
          widget.initData['spendControlLimits']['allowedCategories'].length !=
              0) {
        List<bool> temp_isSwitchedArr = [];
        widget.initData['spendControlLimits']['allowedCategories']
            .forEach((item) => {temp_isSwitchedArr.add(item['isAllowed'])});
        setState(() {
          isSwitchedArr = temp_isSwitchedArr;
        });
      } else {
        setState(() {
          isSwitchedMerchant = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Stack(children: [
      SingleChildScrollView(
          child: Column(children: [
        const CustomSpacer(size: 44),
        const CustomMainHeader(title: 'Request For Physical Card'),
        const CustomSpacer(size: 38),
        cardDetailField(),
        const CustomSpacer(size: 20),
        spendControlMainField(widget.eligibleUsers),
        const CustomSpacer(size: 15),
        additionalField(),
        const CustomSpacer(size: 16),
        buttonField(),
        const CustomSpacer(size: 16),
        const CustomSpacer(size: 88),
      ])),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 1),
      )
    ])));
  }

  Widget cardDetailField() {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(
          left: wScale(16),
          right: wScale(16),
          top: hScale(16),
          bottom: hScale(16)),
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Important Note: Your physical card \nwill be delivered in 7 working days.',
              style: TextStyle(
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A2831))),
          const CustomSpacer(size: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Company Name on Card',
                      style: TextStyle(
                          fontSize: fSize(12),
                          color: const Color(0xFF040415).withOpacity(0.4))),
                  const CustomSpacer(size: 8),
                  Text(companyNameCtl.text,
                      style: TextStyle(
                          fontSize: fSize(14),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF040415))),
                ],
              ),
              TextButton(
                  style: TextButton.styleFrom(
                    primary: const Color(0xffF5F5F5).withOpacity(0.4),
                    padding: const EdgeInsets.all(0),
                  ),
                  child: Image.asset('assets/edit.png',
                      fit: BoxFit.contain, width: wScale(14)),
                  onPressed: () {
                    handleEditCompanyName();
                  }),
            ],
          ),
          const CustomSpacer(size: 16),
          Text('Card Delivery Address',
              style: TextStyle(
                  fontSize: fSize(12),
                  color: const Color(0xFF040415).withOpacity(0.4))),
          const CustomSpacer(size: 8),
          Text(
              widget.companyProfile == null
                  ? ""
                  : '(${widget.companyProfile["name"]}) ${widget.companyProfile["orgOperatingAddress"]["addressLine1"]} ${widget.companyProfile["orgOperatingAddress"]["country"]} ${widget.companyProfile["orgOperatingAddress"]["postalCode"]}',
              style: TextStyle(
                  fontSize: fSize(14),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF040415))),
        ],
      ),
    );
  }

  Widget cardIssueFieldField() {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(
          left: wScale(16),
          right: wScale(16),
          top: hScale(16),
          bottom: hScale(16)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Physical Cards Issued',
              style: TextStyle(
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A2831))),
          const CustomSpacer(size: 20),
          Row(
            children: [
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: SizedBox(
                  width: hScale(88),
                  height: hScale(88),
                  child: CircularPercentIndicator(
                    radius: hScale(88),
                    lineWidth: wScale(8),
                    animation: true,
                    animationDuration: 5,
                    percent: 0.4,
                    circularStrokeCap: CircularStrokeCap.round,
                    backgroundColor: const Color(0xFFFAFBFC),
                    progressColor: const Color(0xFF30E7A9),
                  ),
                ),
              ),
              SizedBox(width: wScale(18)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('10 physical cards left.',
                      style: TextStyle(
                          fontSize: fSize(14),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF465158))),
                  Text(
                      '10/20 physical cards have been \nissued on your free subscription \nto Flex. ',
                      style: TextStyle(
                          fontSize: fSize(12),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF70828D))),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget spendControlMainField(eligibleUsers) {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(
          left: wScale(16),
          right: wScale(16),
          top: hScale(16),
          bottom: hScale(16)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spend Control Main',
              style: TextStyle(
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A2831))),
          const CustomSpacer(size: 22),
          cardHolderNameField(eligibleUsers),
          cardHolderLimit
              ? Text('You can only to issue up 20 virtual cards in a request',
                  style: TextStyle(color: Color(0xFFEB5757)))
              : SizedBox(),
          cardHolderArr(eligibleUsers),
          cardHolders.length > 0 ? const CustomSpacer(size: 10) : SizedBox(),
          cardHolders.length > 0
              ? cardNamesButton(cardNameHolders)
              : SizedBox(),
          errorCardHolder && cardHolders.length <= 0
              ? Container(
                  height: hScale(32),
                  width: wScale(295),
                  padding: EdgeInsets.only(top: hScale(5)),
                  child: Text("This field is required",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: fSize(12),
                          color: Color(0xFFEB5757),
                          fontWeight: FontWeight.w400)))
              : const CustomSpacer(size: 32),
          CustomTextField(
              ctl: monthlySpendLimitCtl,
              hint: 'Enter Monthly Spend Limit',
              label: 'Monthly Spend Limit',
              isError: errorMonthlySpend,
              onChanged: (text) {
                setState(() {
                  isSwitchedTransactionLimit = text.length == 0 ? false : true;
                  transactionLimitCtl.text = text;
                });
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: const TextInputType.numberWithOptions(
                  signed: true, decimal: true)),
          errorMonthlySpendLength
              ? Container(
                  width: wScale(295),
                  padding: EdgeInsets.only(top: hScale(5)),
                  child: Text(
                      "You have reached maximum limit of digits allowed",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: fSize(12),
                          color: Color(0xFFEB5757),
                          fontWeight: FontWeight.w400)))
              : SizedBox(),
          errorMonthlySpend
              ? Container(
                  height: hScale(32),
                  width: wScale(295),
                  padding: EdgeInsets.only(top: hScale(5)),
                  child: Text("This field is required",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: fSize(12),
                          color: Color(0xFFEB5757),
                          fontWeight: FontWeight.w400)))
              : const CustomSpacer(size: 15),
          monthlyCardsList()
        ],
      ),
    );
  }

  Widget cardHolderNameField(eligibleUsers) {
    var eligibleUserNames = [];
    eligibleUsers.forEach((item) {
      var isSelected =
          cardNameHolders.indexWhere((element) => element['id'] == item['id']);
      isSelected < 0 ? eligibleUserNames.add(item) : null;
    });
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
                  color: errorCardHolder && cardHolders.length <= 0
                      ? Color(0xFFEB5757)
                      : Color(0xFF040415).withOpacity(0.1))),
          child: TextButton(
              onPressed: () {
                _showEligibleModalDialog(context, eligibleUserNames);
              },
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    cardHolderNameCtl.text == ""
                        ? "Enter Cardholder Name"
                        : cardHolderNameCtl.text,
                    style: TextStyle(
                        fontSize: fSize(16),
                        fontWeight: FontWeight.w500,
                        color: errorCardHolder && cardHolders.length <= 0
                            ? Color(0xFFEB5757)
                            : cardHolderNameCtl.text == ""
                                ? Color(0xffBFBFBF)
                                : Color(0xFF040415)),
                  )),
                  widget.eligibleUsers.length == cardNameHolders.length
                      ? SizedBox()
                      : Container(
                          width: wScale(40),
                          child:
                              Icon(Icons.add, color: const Color(0xFFBFBFBF)))
                ],
              )),
        ),
        Positioned(
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text('Cardholder Name',
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: errorCardHolder && cardHolders.length <= 0
                        ? Color(0xFFEB5757)
                        : Color(0xFFBFBFBF))),
          ),
        )
      ],
    );
  }

  _showEligibleModalDialog(context, arrData) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: wScale(40)),
              child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: CustomPopUpList(
                    arrData: arrData,
                    onPress: (id) {
                      var selectedItem =
                          arrData.firstWhere((item) => item['id'] == id);
                      cardHolderNameCtl.text =
                          "${selectedItem['firstName']} ${selectedItem['lastName']}";
                      var isExist = cardNameHolders.firstWhere(
                          (element) => element['id'] == id,
                          orElse: () => null);
                      setState(() {
                        cardHolderLimit =
                            cardHolders.length == 20 ? true : false;
                      });
                      if (isExist == null && cardHolders.length < 19) {
                        setState(() {
                          cardHolders.add({
                            "userId": selectedItem['id'],
                            "preferredCardholderName": '',
                            "preferredCardName":
                                "${selectedItem['firstName']} ${selectedItem['lastName']}",
                            "applySpendControls": true
                          });
                          cardNameHolders.add({
                            "id": id,
                            'name':
                                "${selectedItem['firstName']} ${selectedItem['lastName']}"
                          });
                          errorCardHolder = true;
                        });
                      }
                    },
                  )));
        });
  }

  Widget cardHolderArr(eligibleUsers) {
    return Container(
        padding: EdgeInsets.only(top: 5),
        child: Wrap(spacing: 5, runSpacing: 5, children: [
          for (var i = 0; i < cardNameHolders.length; i++)
            cardholder(i, cardNameHolders[i]['name'])
        ]));
  }

  Widget cardholder(index, item) {
    return Row(
      children: [
        Container(
          height: hScale(26),
          padding: EdgeInsets.all(hScale(5)),
          decoration: BoxDecoration(
            color: const Color(0xFFE5EDEA),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Row(
            children: [
              Text(item,
                  style: TextStyle(
                      fontSize: fSize(12),
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF040415))),
              Container(
                width: wScale(12),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    setState(() {
                      cardHolderLimit = false;
                      cardHolders.removeAt(index);
                      cardNameHolders.removeAt(index);
                      if (cardHolders.length == 0) {
                        cardHolderNameCtl.text = '';
                        errorCardHolder = true;
                      }
                    });
                  },
                  child: Icon(Icons.close_rounded,
                      color: Color(0xFF040415), size: 12),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget monthlyCardsList() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(children: [
          monthlyCard('500'),
          monthlyCard('1000'),
          monthlyCard('5000'),
          monthlyCard('10000'),
        ]));
  }

  Widget monthlyCard(value) {
    return Container(
        width: wScale(90),
        height: hScale(40),
        // padding: EdgeInsets.all(wScale(9)),
        margin: EdgeInsets.only(right: wScale(7)),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
            color: Color(0xFFDEFEE9),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: TextButton(
            onPressed: () {
              monthlySpendLimitCtl.text = value;
              setState(() {
                if (double.parse(transactionLimitCtl.text.split(" ")[1]) >
                    double.parse(value)) {
                  transactionLimitValue = 100;
                  transactionLimitCtl.text = value;
                }
                transactionLimitValue =
                    double.parse(transactionLimitCtl.text.split(" ")[1]) /
                        double.parse(value) *
                        100;
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('SGD',
                    style: TextStyle(
                        fontSize: fSize(10),
                        fontWeight: FontWeight.w600,
                        height: 1,
                        color: const Color(0xFF30E7A9))),
                SizedBox(width: wScale(3)),
                Text(value,
                    style: TextStyle(
                        fontSize: fSize(14),
                        fontWeight: FontWeight.w600,
                        height: 1,
                        color: const Color(0xFF30E7A9))),
              ],
            )));
  }

  Widget additionalField() {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(
          left: wScale(16),
          right: wScale(16),
          top: hScale(16),
          bottom: hScale(16)),
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Additional Spend Control',
              style: TextStyle(
                  fontSize: fSize(16),
                  height: 1.8,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A2831))),
          Opacity(
              opacity: isSwitchedMerchant ? 1 : 0.4,
              child: Column(
                children: [
                  const CustomSpacer(size: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Merchant Category Blocking',
                          style: TextStyle(
                              fontSize: fSize(14),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1A2831))),
                      SizedBox(
                        width: wScale(32),
                        height: hScale(18),
                        child: Transform.scale(
                          scale: 0.5,
                          child: CupertinoSwitch(
                            trackColor: const Color(0xFFDFDFDF),
                            activeColor: const Color(0xFF3BD8A3),
                            value: isSwitchedMerchant,
                            onChanged: (v) =>
                                setState(() => isSwitchedMerchant = v),
                          ),
                        ),
                      )
                    ],
                  ),
                  const CustomSpacer(size: 10),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                          fontSize: fSize(14),
                          color: const Color(0xFF70828D),
                          fontWeight: FontWeight.w400),
                      children: const [
                        TextSpan(
                            text:
                                'Select the categories where spending will be '),
                        TextSpan(
                            text: 'blocked',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEB5757))),
                        TextSpan(
                            text:
                                '.  When making a purchase on unauthorized categories, the transaction will be rejected. All spending categories are'),
                        TextSpan(
                            text: ' allowed',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3BD8A3))),
                        TextSpan(text: ' by default.'),
                      ],
                    ),
                  ),
                  const CustomSpacer(size: 24),
                  customSwitchControl(0, 'assets/air_lines.png', 'Airlines'),
                  // const CustomSpacer(size: 20),
                  customSwitchControl(1, 'assets/car_rental.png', 'Car Rental'),
                  // const CustomSpacer(size: 20),
                  customSwitchControl(
                      2, 'assets/transportation.png', 'Transportation'),
                  // const CustomSpacer(size: 20),
                  customSwitchControl(3, 'assets/hotels.png', 'Hotels'),
                  // const CustomSpacer(size: 20),
                  customSwitchControl(4, 'assets/petrol.png', 'Petrol'),
                  // const CustomSpacer(size: 20),
                  customSwitchControl(
                      5, 'assets/department_stores.png', 'Department Stores'),
                  // const CustomSpacer(size: 20),
                  customSwitchControl(6, 'assets/parking.png', 'Parking'),
                  // const CustomSpacer(size: 20),
                  customSwitchControl(
                      7, 'assets/fandb.png', 'F&B (Restaurants & Groceries)'),
                  // const CustomSpacer(size: 20),
                  customSwitchControl(8, 'assets/taxis.png', 'Taxis'),
                  // const CustomSpacer(size: 20),
                  customSwitchControl(9, 'assets/others.png', 'Others'),
                  const CustomSpacer(size: 34),
                ],
              )),
          Opacity(
              opacity: isSwitchedTransactionLimit ? 1 : 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Text('Transaction Limit',
                            style: TextStyle(
                                fontSize: fSize(14),
                                color: const Color(0xFF1A2831))),
                        SizedBox(width: wScale(6)),
                        !showTransactionHint
                            ? Container(
                                height: hScale(16),
                                width: hScale(16),
                                child: IconButton(
                                  padding: EdgeInsets.all(0),
                                  icon: Image.asset('assets/info.png',
                                      fit: BoxFit.contain, height: hScale(16)),
                                  iconSize: hScale(16),
                                  onPressed: () {
                                    setState(() {
                                      showTransactionHint =
                                          !showTransactionHint;
                                    });
                                  },
                                ))
                            : SizedBox(),
                      ]),
                      TextButton(
                          onPressed: () {
                            setState(() => isSwitchedTransactionLimit =
                                !isSwitchedTransactionLimit);
                          },
                          child: Container(
                            width: wScale(32),
                            height: hScale(18),
                            child: Transform.scale(
                              scale: 0.5,
                              child: CupertinoSwitch(
                                trackColor: const Color(0xFFDFDFDF),
                                activeColor: const Color(0xFF3BD8A3),
                                value: isSwitchedTransactionLimit,
                                onChanged: (v) {},
                              ),
                            ),
                          ))
                    ],
                  ),
                  const CustomSpacer(size: 10),
                  showTransactionHint
                      ? Container(
                          width: wScale(300),
                          child: TextButton(
                              style: TextButton.styleFrom(
                                primary: const Color(0xffffffff),
                                textStyle: TextStyle(
                                    fontSize: fSize(14),
                                    color: const Color(0xffffffff)),
                              ),
                              onPressed: () {
                                setState(() {
                                  showTransactionHint = !showTransactionHint;
                                });
                              },
                              child: Text(
                                  'This amount is the maximum value a user can charge for every transaction. Transaction limit cannot exceed the monthly limit set above.',
                                  style: TextStyle(
                                      fontSize: fSize(12),
                                      color: const Color(0xFF1A2831)
                                          .withOpacity(0.8)))))
                      : SizedBox(),
                  const CustomSpacer(size: 18),
                  transactionField(transactionLimitCtl,
                      'Enter Transaction Limit', 'Transaction Limit'),
                  errorTransactionLimit
                      ? Container(
                          height: hScale(32),
                          width: wScale(295),
                          padding: EdgeInsets.only(top: hScale(5)),
                          child: Text(
                              "Minimum transaction limit is SGD 1. Switch off the toggle if transaction limit is not required.",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: fSize(12),
                                  color: Color(0xFFEB5757),
                                  fontWeight: FontWeight.w400)))
                      : const CustomSpacer(),
                  const CustomSpacer(size: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: hScale(12)),
                      overlayShape:
                          RoundSliderOverlayShape(overlayRadius: hScale(12)),
                    ),
                    child: Slider(
                      value: transactionLimitValue,
                      min: monthlySpendLimitCtl.text == ""
                          ? 1.0
                          : 1.0 / double.parse(monthlySpendLimitCtl.text) * 100,
                      max: 100.0,
                      divisions: 100,
                      activeColor: const Color(0xFF3BD8A3),
                      inactiveColor: const Color(0xFF1A2831).withOpacity(0.1),
                      onChanged: isSwitchedTransactionLimit
                          ? (double newValue) {
                              setState(() {
                                transactionLimitValue = newValue;
                                if (varianceLimitValue >
                                    (100 / newValue - 1) * 100) {
                                  varianceLimitValue =
                                      (100 / newValue - 1) * 100;
                                  varianceLimitCtl.text =
                                      varianceLimitValue.toStringAsFixed(0) +
                                          "%";
                                }
                                transactionLimitCtl.text = (newValue *
                                        int.parse(monthlySpendLimitCtl.text) /
                                        100)
                                    .toStringAsFixed(0);
                                transactionLimitCtl.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset:
                                            transactionLimitCtl.text.length));
                                varianceLimitCtl.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset:
                                            varianceLimitCtl.text.length - 1));
                              });
                            }
                          : null,
                    ),
                  ),
                  const CustomSpacer(size: 24),
                  Row(children: [
                    Text('Variance Limit',
                        style: TextStyle(
                            fontSize: fSize(14),
                            color: const Color(0xFF1A2831))),
                    SizedBox(width: wScale(6)),
                    !showVarianceHint
                        ? Container(
                            height: hScale(16),
                            width: hScale(16),
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Image.asset('assets/info.png',
                                  fit: BoxFit.contain, height: hScale(16)),
                              iconSize: hScale(16),
                              onPressed: () {
                                setState(() {
                                  showVarianceHint = !showVarianceHint;
                                });
                              },
                            ))
                        : SizedBox(),
                  ]),
                  const CustomSpacer(size: 10),
                  showVarianceHint
                      ? Container(
                          width: wScale(300),
                          child: TextButton(
                              style: TextButton.styleFrom(
                                primary: const Color(0xffffffff),
                                textStyle: TextStyle(
                                    fontSize: fSize(14),
                                    color: const Color(0xffffffff)),
                              ),
                              onPressed: () {
                                setState(() {
                                  showVarianceHint = !showVarianceHint;
                                });
                              },
                              child: Text(
                                  'Set a percentage that allows user to spend beyond the set transaction value.',
                                  style: TextStyle(
                                      fontSize: fSize(12),
                                      color: const Color(0xFF1A2831)
                                          .withOpacity(0.8)))))
                      : SizedBox(),
                  const CustomSpacer(size: 28),
                  varianceField(varianceLimitCtl, 'Enter Variance Limit',
                      'Variance Limit'),
                  const CustomSpacer(size: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: hScale(12)),
                      overlayShape:
                          RoundSliderOverlayShape(overlayRadius: hScale(12)),
                    ),
                    child: Slider(
                      value: varianceLimitValue,
                      min: 0.0,
                      max: 100.0,
                      divisions: 100,
                      activeColor: const Color(0xFF3BD8A3),
                      inactiveColor: const Color(0xFF1A2831).withOpacity(0.1),
                      onChanged: isSwitchedTransactionLimit &&
                              !errorTransactionLimit
                          ? (double newValue) {
                              setState(() {
                                varianceLimitValue = newValue;
                                if (transactionLimitValue >
                                    (100 / (100 + newValue) * 100)) {
                                  transactionLimitValue =
                                      (100 / (100 + newValue) * 100);
                                  transactionLimitCtl
                                      .text = (transactionLimitValue *
                                          int.parse(monthlySpendLimitCtl.text) /
                                          100)
                                      .toStringAsFixed(0);
                                }
                                varianceLimitCtl.text =
                                    newValue.toStringAsFixed(0) + '%';
                                varianceLimitCtl.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset:
                                            varianceLimitCtl.text.length - 1));
                                transactionLimitCtl.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset:
                                            transactionLimitCtl.text.length));
                              });
                            }
                          : null,
                    ),
                  ),
                  const CustomSpacer(size: 20),
                ],
              ))
        ],
      ),
    );
  }

  Widget customSwitchControl(index, image, title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        customSwitch(index),
        SizedBox(width: wScale(10)),
        Image.asset(image, width: hScale(16), fit: BoxFit.contain),
        SizedBox(width: wScale(9)),
        Container(
            width: wScale(220),
            child: Text(title,
                style: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A2831))))
      ],
    );
  }

  Widget customSwitch(index) {
    return Container(
        height: wScale(30),
        width: wScale(38),
        child: TextButton(
          onPressed: () {
            setState(() {
              isSwitchedArr[index] = !isSwitchedArr[index];
            });
          },
          child: Transform.scale(
            scale: 0.4,
            child: CupertinoSwitch(
                trackColor: const Color(0xFFEB5757),
                activeColor: const Color(0xFF3BD8A3),
                value: isSwitchedArr[index],
                onChanged: (v) {}),
          ),
        ));
  }

  Widget transactionField(ctl, hint, label) {
    return Stack(
      children: [
        Container(
          width: wScale(295),
          // height: hScale(56),
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: hScale(8)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Color(0xffBFBFBF))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: wScale(10)),
              Text('SGD',
                  style: TextStyle(
                      fontSize: fSize(16),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF040415))),
              SizedBox(width: wScale(5)),
              Expanded(
                  child: Focus(
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          if (transactionLimitCtl.text.length == 0)
                            transactionLimitCtl.text = "1";
                        }
                      },
                      child: TextField(
                        style: TextStyle(
                            fontSize: fSize(16),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF040415)),
                        controller: ctl,
                        readOnly: isSwitchedTransactionLimit ? false : true,
                        onEditingComplete: () {
                          if (transactionLimitCtl.text.length == 0)
                            transactionLimitCtl.text = "1";
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        onChanged: (text) {
                          setState(() {
                            errorTransactionLimit = text == '' ? true : false;
                            double temp_transactionValue =
                                text == "0" || text.length == 0
                                    ? 1
                                    : double.parse(text);
                            if (text == "0") {
                              transactionLimitCtl.text = '1';
                              transactionLimitValue = 1 /
                                  double.parse(monthlySpendLimitCtl.text) *
                                  100;
                              transactionLimitCtl.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: transactionLimitCtl.text.length));
                            }
                            if (temp_transactionValue >
                                double.parse(monthlySpendLimitCtl.text)) {
                              transactionLimitCtl.text =
                                  monthlySpendLimitCtl.text;
                            }

                            transactionLimitValue = temp_transactionValue /
                                        double.parse(
                                            monthlySpendLimitCtl.text) <
                                    1
                                ? temp_transactionValue /
                                    double.parse(monthlySpendLimitCtl.text) *
                                    100
                                : 100;

                            if (varianceLimitValue >
                                (100 / transactionLimitValue - 1) * 100) {
                              varianceLimitValue =
                                  (100 / transactionLimitValue - 1) * 100;
                              varianceLimitCtl.text =
                                  "${varianceLimitValue.toStringAsFixed(0)}%";
                            }
                          });
                          transactionLimitCtl.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: transactionLimitCtl.text.length));
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        decoration: InputDecoration(
                          filled: true,
                          contentPadding: EdgeInsets.zero,
                          fillColor: Colors.white,
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 1.0)),
                          hintText: 'Enter ${label}',
                          hintStyle: TextStyle(
                              color: Color(0xffBFBFBF), fontSize: fSize(14)),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 1.0)),
                        ),
                      ))),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text(label,
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: Color(0xffBFBFBF))),
          ),
        )
      ],
    );
  }

  Widget varianceField(ctl, hint, label) {
    return Stack(
      children: [
        Container(
          width: wScale(295),
          // height: hScale(56),
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: hScale(8)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Color(0xffBFBFBF))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: wScale(10)),
              Expanded(
                  child: TextField(
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF040415)),
                controller: ctl,
                readOnly: isSwitchedTransactionLimit ? false : true,
                onChanged: (text) {
                  setState(() {
                    ctl.text = "${text}%";
                    if (text.length == 0) {
                      varianceLimitCtl.text = "0%";
                    }
                    if (text.length == 2 && text[0] == "0") {
                      varianceLimitCtl.text =
                          "${text.substring(1, text.length)}%";
                    }
                    if (double.parse(text.split("%")[0] == ""
                            ? "0"
                            : text.split("%")[0]) >
                        100) {
                      varianceLimitValue = 100;
                      varianceLimitCtl.text = "100%";
                    } else {
                      varianceLimitValue = text.split("%")[0] == ""
                          ? 0
                          : double.parse(text.split("%")[0]);
                    }
                    if (transactionLimitValue >
                        (100 / (100 + varianceLimitValue) * 100)) {
                      transactionLimitValue =
                          (100 / (100 + varianceLimitValue) * 100);
                      transactionLimitCtl.text = (transactionLimitValue *
                              int.parse(monthlySpendLimitCtl.text) /
                              100)
                          .toStringAsFixed(0);
                    }
                  });
                  varianceLimitCtl.selection = TextSelection.fromPosition(
                      TextPosition(offset: varianceLimitCtl.text.length - 1));
                },
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: const TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                decoration: InputDecoration(
                  filled: true,
                  contentPadding: EdgeInsets.zero,
                  fillColor: Colors.white,
                  enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 1.0)),
                  hintText: 'Enter ${label}',
                  hintStyle:
                      TextStyle(color: Color(0xffBFBFBF), fontSize: fSize(14)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 1.0)),
                ),
              )),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text(label,
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: Color(0xffBFBFBF))),
          ),
        )
      ],
    );
  }

  Widget remarksField() {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(
          left: wScale(16),
          right: wScale(16),
          top: hScale(16),
          bottom: hScale(16)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Remarks',
              style: TextStyle(
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A2831))),
          const CustomSpacer(size: 22),
          remarkTextFiled(remarksCtl, 'Type Remarks', 'Remarks (Optional)')
        ],
      ),
    );
  }

  Widget remarkTextFiled(ctl, hint, label) {
    return Container(
        width: wScale(295),
        // height: hScale(56),
        alignment: Alignment.center,
        child: TextField(
          controller: ctl,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: const Color(0xff040415).withOpacity(0.1),
                    width: 1.0)),
            hintText: hint,
            hintStyle: TextStyle(
                color: const Color(0xff040415).withOpacity(0.1),
                fontSize: fSize(14),
                fontWeight: FontWeight.w500),
            labelText: label,
            labelStyle: TextStyle(
                color: const Color(0xff040415).withOpacity(0.4),
                fontSize: fSize(14),
                fontWeight: FontWeight.w500),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff040415), width: 1.0)),
          ),
        ));
  }

  Widget buttonField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [backButton('Cancel'), mutationButton('Request for Card')],
    );
  }

  Widget backButton(title) {
    return Container(
        width: wScale(156),
        height: hScale(56),
        margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xFFe8e9ea),
            side: BorderSide(width: 0, color: Color(0xffe8e9ea)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(title,
              style: TextStyle(
                  color: Color(0xFF1A2831),
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget saveButton(title, runMutation) {
    return Container(
        width: wScale(156),
        height: hScale(56),
        margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            handleSave(runMutation);
          },
          child: Text(title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget mutationButton(title) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Mutation(
            options: MutationOptions(
              document: gql(mutationRequestCardSpend),
              update: (GraphQLDataProxy cache, QueryResult? result) {
                return cache;
              },
              onCompleted: (resultData) {
                resultData['createFinanceAccountFLASpendControl']
                    ? showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: wScale(40)),
                              child: Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.0)),
                                  child: CustomResultModal(
                                    status: true,
                                    title: "Request sent successfully",
                                    message:
                                        "You have successfully requested physical card(s). Please expect your card to be delivered within 7 working days.",
                                    handleOKClick: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop('dialog');
                                      Navigator.of(context)
                                          .pushReplacementNamed(HOME_SCREEN);
                                    },
                                  )));
                        })
                    : showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: wScale(40)),
                              child: Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.0)),
                                  child: CustomResultModal(
                                      status: true,
                                      title: "Request sent faild",
                                      message: "")));
                        });
              },
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              return saveButton(title, runMutation);
            }));
  }

  _showSimpleModalDialog(context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              insetPadding: EdgeInsets.all(hScale(0)),
              child: ModalField(
                  companyNameCtl: companyNameCtl,
                  // companyNameText: companyNameText,
                  setCompanyNameText: (text) {
                    setState(() {
                      companyNameCtl.text = text;
                    });
                  }));
        });
  }

  _showNewNameModalDialog(context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              insetPadding: EdgeInsets.all(hScale(0)),
              child: RequestPhysicalNewNameModalField(
                  companyNameCtl: companyNameCtl,
                  // companyNameText: companyNameText,
                  setCompanyNameText: (text) {
                    setState(() {
                      companyNameCtl.text = text;
                    });
                  }));
        });
  }

  Widget cardNamesButton(cardNameHolders) {
    return Container(
        // width: wScale(141),
        height: hScale(56),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: wScale(16)),
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            handleAddCardHolderName();
          },
          child: Text('Preferred Name on Card',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  _showCardNameModalDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: wScale(40)),
              child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: cardNameModalField()));
        });
  }

  Widget cardNameModalField() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
          padding: EdgeInsets.symmetric(
              vertical: hScale(25), horizontal: wScale(16)),
          child: Column(children: [
            Image.asset('assets/warning_icon.png',
                fit: BoxFit.contain, height: wScale(30)),
            const CustomSpacer(size: 15),
            Text(
              'You have not indicated preferred names',
              style:
                  TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const CustomSpacer(size: 10),
            Text(
              'Names that will appear on the physical cards will be extracted from user settings by default. Some truncation might occur. Do you wish to proceed without making these changes.',
              style:
                  TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ])),
      Container(height: 1, color: const Color(0xFFD5DBDE)),
      Container(
          height: hScale(50),
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color(0xff30E7A9),
                      textStyle: TextStyle(
                          fontSize: fSize(16), color: const Color(0xff30E7A9)),
                    ),
                    onPressed: () => Navigator.of(context, rootNavigator: true)
                        .pop('dialog'),
                    child: const Text('Cancel'),
                  )),
              Container(width: 1, color: const Color(0xFFD5DBDE)),
              Expanded(
                  flex: 1,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color(0xff30E7A9),
                      textStyle: TextStyle(
                          fontSize: fSize(16), color: const Color(0xff30E7A9)),
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      handleAddCardHolderName();
                    },
                    child: const Text('Proceed'),
                  ))
            ],
          ))
    ]);
  }
}

class ModalField extends StatefulWidget {
  ModalField({
    required this.companyNameCtl,
    required this.setCompanyNameText,
  });
  final setCompanyNameText;
  final TextEditingController companyNameCtl;

  @override
  State<StatefulWidget> createState() {
    return ModalFieldState();
  }
}

class ModalFieldState extends State<ModalField> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String updateCompanyNameMutation = FXRMutations.MUTATION_UPDATE_COMPANY_NAME;
  var iisCompanyNameCtlEmpty = false;

  @override
  void initState() {
    super.initState();
    if (widget.companyNameCtl.text == "") {
      setState(() {
        iisCompanyNameCtlEmpty = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    return Container(
        width: wScale(327),
        padding:
            EdgeInsets.symmetric(horizontal: wScale(16), vertical: hScale(16)),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Edit Company Name',
                    style: TextStyle(
                        fontSize: fSize(14),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A2831))),
                SizedBox(
                    width: wScale(20),
                    child: TextButton(
                        style: TextButton.styleFrom(
                          primary: const Color(0xff000000),
                          padding: const EdgeInsets.all(0),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFFC8C4D9),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }))
              ]),
              Text('This is what will be displayed on your physical card',
                  style: TextStyle(
                      fontSize: fSize(12),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF70828D))),
              CustomSpacer(size: 32),
              CustomTextField(
                ctl: widget.companyNameCtl,
                hint: 'Type Company Name',
                label: 'Company Name',
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20),
                ],
                onChanged: (text) {
                  setState(() {
                    iisCompanyNameCtlEmpty = text.isEmpty;
                  });
                },
              ),
              CustomSpacer(size: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  modalBackButton('Back'),
                  // modalSaveButton('Update', iisCompanyNameCtlEmpty)
                  mutationButton('Update', iisCompanyNameCtlEmpty)
                ],
              )
            ]));
  }

  Widget modalBackButton(title) {
    return SizedBox(
        width: wScale(141),
        height: hScale(56),
        // margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            primary: const Color(0xff1A2831).withOpacity(0.1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(title,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget mutationButton(title, isCompanyNameCtlEmpty) {
    return Mutation(
        options: MutationOptions(
          document: gql(updateCompanyNameMutation),
          update: (GraphQLDataProxy cache, QueryResult? result) {
            return cache;
          },
          onCompleted: (resultData) {
            if (resultData['updateOrganizationAlias']['id'] > 0) {
              setState(() {
                widget.setCompanyNameText(
                    widget.companyNameCtl.text.toUpperCase());
              });
              Navigator.of(context).pop();
              _showResultModalDialog(context);
            }
          },
        ),
        builder: (RunMutation runMutation, QueryResult? result) {
          return modalSaveButton(runMutation, title, isCompanyNameCtlEmpty);
        });
  }

  _showResultModalDialog(context) {
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
                      title: "Company Name Confirmed",
                      message:
                          "The company name that will appear on all physical cards issued has been confirmed.",
                      handleOKClick: () {
                        Navigator.of(context).pop();
                      })));
        });
  }

  Widget modalSaveButton(runMutation, title, isCompanyNameCtlEmpty) {
    return Opacity(
        opacity: isCompanyNameCtlEmpty ? 0.5 : 1,
        child: SizedBox(
            width: wScale(141),
            height: hScale(56),
            // margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                primary: const Color(0xff1A2831),
                side: const BorderSide(width: 0, color: Color(0xff1A2831)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                isCompanyNameCtlEmpty
                    ? null
                    : runMutation({
                        'orgId': userStorage.getItem('orgId'),
                        'organizationAlias':
                            widget.companyNameCtl.text.toUpperCase()
                      });
              },
              child: Text(title,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fSize(16),
                      fontWeight: FontWeight.w700)),
            )));
  }
}

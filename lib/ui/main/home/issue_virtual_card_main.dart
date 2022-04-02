import 'dart:ui';

import 'package:co/ui/main/cards/name_on_card.dart';
import 'package:co/ui/main/home/issue_spend_control_main.dart';
import 'package:co/ui/widgets/custom_result_modal.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class IssueVirtaulCardMain extends StatefulWidget {
  final eligibleUsers;
  final merchantUsers;
  const IssueVirtaulCardMain({Key? key, this.eligibleUsers, this.merchantUsers})
      : super(key: key);
  @override
  IssueVirtaulCardMainState createState() => IssueVirtaulCardMainState();
}

class IssueVirtaulCardMainState extends State<IssueVirtaulCardMain> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final monthlyLimitCtl = TextEditingController();
  final transactionLimitCtl = TextEditingController(text: '0');
  final varianceLimitCtl = TextEditingController(text: '0%');
  final remarksCtl = TextEditingController();
  final companyNameCtl = TextEditingController();

  final cardHolderNameCtl = TextEditingController();
  final cardTypeCtl = TextEditingController(text: "Fixed Card");
  final monthlySpendLimitCtl = TextEditingController();
  final limitRefreshCtl = TextEditingController();
  final expiryDateCtl = TextEditingController();

  bool isSwitchedMerchant = false;
  bool isMerchantChange = false;
  bool isSwitchedTransactionLimit = false;
  bool isTransactionLimitChange = false;
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
  var cardTypeArr = ["Fixed Card", "Recurring Card"];
  double transactionLimitValue = 1.0;
  double varianceLimitValue = 0;

  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String mutationIssueVirtaulCardSpend =
      FXRMutations.MUTATION_REQUEST_CARD_SPEND;
  late var seletedEligible;
  String companyNameText = '';
  var cardHolders = [];
  var cardNameHolders = [];
  bool showCardDetail = false;
  int cardType = 0; // 0 => Fixed Card, 1 => Recurring Card
  bool errorCardHolder = false;
  bool errorExpireDate = false;
  bool errorLimitRefresh = false;
  bool errorMonthlySpend = false;
  bool errorMonthlySpendLength = false;
  bool errorTransactionLimit = false;
  bool checkCardName = false;
  bool isLoading = false;

  handleSwitch(index, v) {
    setState(() {
      isSwitchedArr[index] = v;
    });
  }

  handleIsSwitchedMerchant(value) {
    setState(() {
      isSwitchedMerchant = value;
      isMerchantChange = value;
    });
  }

  handleIisSwitchedTransactionLimit(value) {
    setState(() {
      isSwitchedTransactionLimit = value.length == 0 ? false : true;
      transactionLimitCtl.text = value;
      transactionLimitValue = 100;
      isTransactionLimitChange = value.length == 0 ? false : true;
    });
  }

  callbackCardHolder(data) {
    setState(() {
      cardHolders = data;
      errorCardHolder = data.length > 0 ? false : true;
    });
  }

  handleSave(runMutation) {
    setState(() {
      errorExpireDate = expiryDateCtl.text == '' ? true : false;
      errorLimitRefresh = limitRefreshCtl.text == '' ? true : false;
      errorMonthlySpend = monthlySpendLimitCtl.text == "" ? true : false;
      errorCardHolder = cardHolders.length == 0 ? true : false;
      errorMonthlySpendLength =
          monthlySpendLimitCtl.text.length > 10 ? true : false;
    });
    bool isNoError = (cardType == 0
            ? expiryDateCtl.text != ''
            : limitRefreshCtl.text != '') &&
        monthlySpendLimitCtl.text != "" &&
        cardHolders.length != 0 &&
        monthlySpendLimitCtl.text.length <= 10;

    if (isNoError) {
      if (checkCardName == false) {
        if (int.parse(transactionLimitCtl.text) >
            int.parse(monthlySpendLimitCtl.text)) {
          transactionLimitCtl.text = monthlySpendLimitCtl.text;
          transactionLimitValue = 100;
          varianceLimitCtl.text = "0%";
          varianceLimitValue = 0;
        }
        if (int.parse(varianceLimitCtl.text.split("%")[0]) > 100) {
          transactionLimitCtl.text =
              (int.parse(monthlySpendLimitCtl.text) / 2).toStringAsFixed(0);
          transactionLimitValue = 50;
          varianceLimitCtl.text = "100%";
          varianceLimitValue = 100;
        }
        _showCardNameModalDialog(context, runMutation);
      } else {
        var isEmptyCardHolderName = cardHolders.firstWhere(
            (element) => element['preferredCardName'] == "",
            orElse: () => null);
        if (isEmptyCardHolderName != null) {
          _showEmptyCardNameModalDialog(context, runMutation);
        } else {
          setState(() {
            isLoading = true;
          });
          if (cardType == 0) {
            var expiryDate =
                '${expiryDateCtl.text.split("/")[2]}-${expiryDateCtl.text.split("/")[1]}-${expiryDateCtl.text.split("/")[0]}';
            var runValue = !isSwitchedMerchant && !isSwitchedTransactionLimit
                ? {
                    "accountSubtype": "VIRTUAL",
                    "cardHolders": cardHolders,
                    "cardLimit": int.parse(monthlySpendLimitCtl.text),
                    "cardType": "ONE-TIME",
                    "expiryDate": expiryDate,
                    "orgId": userStorage.getItem('orgId'),
                    "remarks": remarksCtl.text,
                  }
                : !isSwitchedMerchant
                    ? {
                        "accountSubtype": "VIRTUAL",
                        "cardHolders": cardHolders,
                        "cardLimit": int.parse(monthlySpendLimitCtl.text),
                        "cardType": "ONE-TIME",
                        "controls": {
                          "transactionLimit": (transactionLimitValue *
                                  int.parse(monthlySpendLimitCtl.text) /
                                  100)
                              .round(),
                          "variancePercentage": varianceLimitValue.round(),
                        },
                        "expiryDate": expiryDate,
                        "orgId": userStorage.getItem('orgId'),
                        "remarks": remarksCtl.text,
                      }
                    : !isSwitchedTransactionLimit
                        ? {
                            "accountSubtype": "VIRTUAL",
                            "cardHolders": cardHolders,
                            "cardLimit": int.parse(monthlySpendLimitCtl.text),
                            "cardType": "ONE-TIME",
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
                            "expiryDate": expiryDate,
                            "orgId": userStorage.getItem('orgId'),
                            "remarks": remarksCtl.text,
                          }
                        : {
                            "accountSubtype": "VIRTUAL",
                            "cardHolders": cardHolders,
                            "cardLimit": int.parse(monthlySpendLimitCtl.text),
                            "cardType": "ONE-TIME",
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
                            "expiryDate": expiryDate,
                            "orgId": userStorage.getItem('orgId'),
                            "remarks": remarksCtl.text,
                          };
            runMutation(runValue);
          } else {
            var runValue = !isSwitchedMerchant && !isSwitchedTransactionLimit
                ? {
                    "accountSubtype": "VIRTUAL",
                    "cardHolders": cardHolders,
                    "cardLimit": int.parse(monthlySpendLimitCtl.text),
                    "cardType": "RECURRING",
                    "orgId": userStorage.getItem('orgId'),
                    "remarks": remarksCtl.text,
                    "renewalFrequency": "MONTHLY",
                  }
                : !isSwitchedMerchant
                    ? {
                        "accountSubtype": "VIRTUAL",
                        "cardHolders": cardHolders,
                        "cardLimit": int.parse(monthlySpendLimitCtl.text),
                        "cardType": "RECURRING",
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
                            "accountSubtype": "VIRTUAL",
                            "cardHolders": cardHolders,
                            "cardLimit": int.parse(monthlySpendLimitCtl.text),
                            "cardType": "RECURRING",
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
                            "accountSubtype": "VIRTUAL",
                            "cardHolders": cardHolders,
                            "cardLimit": int.parse(monthlySpendLimitCtl.text),
                            "cardType": "RECURRING",
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
  }

  handleEditCompanyName() {
    _showSimpleModalDialog(context);
  }

  handleNamesOnCard(initType, runMutation) async {
    var cardNameHolders = [];
    cardHolders.forEach((element) {
      cardNameHolders
          .add({"id": element['userId'], 'name': element['preferredCardName']});
    });

    var result = await Navigator.of(context).push(
      CupertinoPageRoute(
          builder: (context) => NameOnCard(
              cardNameHolders: cardNameHolders,
              initType: initType,
              cardType: 0)),
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
    });

    initType == 1 ? handleSave(runMutation) : null;
  }

  handleCheckCardName(data) {
    setState(() {
      checkCardName = true;
      cardHolders = data;
    });
  }

  handleCardType(type) {
    setState(() {
      cardType = type;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Stack(alignment: Alignment.center, children: [
      Opacity(
          opacity: isLoading ? 0.5 : 1,
          child: SingleChildScrollView(
              child: Column(children: [
            const CustomSpacer(size: 44),
            const CustomMainHeader(title: 'Issue Virtual Card'),
            const CustomSpacer(size: 38),
            cardDetailField(),
            const CustomSpacer(size: 20),
            IssueSpendControlMain(
                eligibleUsers: widget.eligibleUsers,
                monthlySpendLimitCtl: monthlySpendLimitCtl,
                limitRefreshCtl: limitRefreshCtl,
                expiryDateCtl: expiryDateCtl,
                errorCardHolder: errorCardHolder,
                errorExpireDate: errorExpireDate,
                errorLimitRefresh: errorLimitRefresh,
                errorMonthlySpend: errorMonthlySpend,
                callbackCardHolder: callbackCardHolder,
                handleCardType: handleCardType,
                handleIsSwitchedMerchant: handleIsSwitchedMerchant,
                handleIisSwitchedTransactionLimit:
                    handleIisSwitchedTransactionLimit,
                handleCheckCardName: handleCheckCardName,
                errorMonthlySpendLength: errorMonthlySpendLength),
            const CustomSpacer(size: 15),
            additionalField(),
            // Opacity(
            //     opacity: isSwitchedMerchant ? 1 : 0.4,
            //     child: Column(
            //       children: [
            //         const CustomSpacer(size: 20),
            //         remarksField(),
            //         const CustomSpacer(size: 30),
            //       ],
            //     )),
            const CustomSpacer(size: 16),
            buttonField(),
            const CustomSpacer(size: 16),
            const CustomSpacer(size: 88),
          ]))),
      isLoading
          ? Positioned(
              top: 150,
              child: Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF60C094)))))
          : SizedBox(),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  width: wScale(250),
                  child: Text('Smarter payments with Flex Virtual Cards',
                      style: TextStyle(
                          fontSize: fSize(16),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A2831)))),
              // TextButton(
              //     onPressed: () {},
              //     child: Text("Learn More",
              //         style: TextStyle(
              //             fontSize: fSize(12),
              //             fontWeight: FontWeight.w600,
              //             color: Color(0xFF60C094),
              //             decoration: TextDecoration.underline)))
            ],
          ),
          // const CustomSpacer(size: 12),
          // Text('Unlimited virtual cards for users on advanced subscription.',
          //     style: TextStyle(fontSize: fSize(12), color: Color(0xFF70828D))),
          const CustomSpacer(size: 12),
          cardField(),
        ],
      ),
    );
  }

  Widget cardField() {
    return Container(
        width: wScale(295),
        height: wScale(187),
        padding: EdgeInsets.all(hScale(16)),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/virtual_card.png"),
            fit: BoxFit.contain,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: SizedBox());
  }

  Widget eyeIconField() {
    return Container(
        height: hScale(34),
        width: hScale(34),
        // padding: EdgeInsets.all(hScale(17)),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(hScale(17)),
              topRight: Radius.circular(hScale(17)),
              bottomLeft: Radius.circular(hScale(17)),
              bottomRight: Radius.circular(hScale(17)),
            )),
        child: IconButton(
          padding: const EdgeInsets.all(0),
          // icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xff30E7A9),),
          icon: Image.asset(
              showCardDetail ? 'assets/hide_eye.png' : 'assets/show_eye.png',
              fit: BoxFit.contain,
              height: hScale(16)),
          iconSize: hScale(17),
          onPressed: () {
            setState(() {
              showCardDetail = !showCardDetail;
            });
          },
        ));
  }

  Widget cardHolderArr() {
    return Container(
        padding: EdgeInsets.only(top: 5),
        child: Wrap(spacing: 5, runSpacing: 5, children: [
          for (var i = 0; i < cardHolders.length; i++)
            cardholder(i, cardHolders[i])
        ]));
  }

  Widget cardholder(index, item) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Container(
          height: hScale(26),
          padding: EdgeInsets.all(hScale(5)),
          decoration: BoxDecoration(
            color: const Color(0xFFE5EDEA),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Row(
            children: [
              Text(item['preferredCardName'],
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
                      cardHolders.removeAt(index);
                    });
                  },
                  child: Icon(Icons.close_rounded,
                      color: Color(0xFF040415), size: 12),
                ),
              )
            ],
          ),
        )
      ])
    ]);
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
          Row(
            children: [
              Text('Additional Spend Control',
                  style: TextStyle(
                      fontSize: fSize(16),
                      height: 1.8,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A2831))),
              // SizedBox(width: 5),
              // Image.asset('assets/flex_pro.png',
              //     fit: BoxFit.contain, width: wScale(22))
            ],
          ),
          cardHolderArr(),
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
                      TextButton(
                        onPressed: () {
                          isMerchantChange
                              ? setState(() =>
                                  isSwitchedMerchant = !isSwitchedMerchant)
                              : null;
                        },
                        child: Container(
                            width: wScale(32),
                            height: hScale(18),
                            child: Transform.scale(
                              scale: 0.5,
                              child: CupertinoSwitch(
                                trackColor: const Color(0xFFDFDFDF),
                                activeColor: const Color(0xFF3BD8A3),
                                value: isSwitchedMerchant,
                                onChanged: (v) {},
                              ),
                            )),
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
                  const CustomSpacer(size: 20),
                  customSwitchControl(0, 'assets/air_lines.png', 'Airlines'),
                  // const CustomSpacer(size: 14),
                  customSwitchControl(1, 'assets/car_rental.png', 'Car Rental'),
                  // const CustomSpacer(size: 14),
                  customSwitchControl(
                      2, 'assets/transportation.png', 'Transportation'),
                  // const CustomSpacer(size: 14),
                  customSwitchControl(3, 'assets/hotels.png', 'Hotels'),
                  // const CustomSpacer(size: 14),
                  customSwitchControl(4, 'assets/petrol.png', 'Petrol'),
                  // const CustomSpacer(size: 14),
                  customSwitchControl(
                      5, 'assets/department_stores.png', 'Department Stores'),
                  // const CustomSpacer(size: 14),
                  customSwitchControl(6, 'assets/parking.png', 'Parking'),
                  // const CustomSpacer(size: 14),
                  customSwitchControl(
                      7, 'assets/fandb.png', 'F&B (Restaurants & Groceries)'),
                  // const CustomSpacer(size: 14),
                  customSwitchControl(8, 'assets/taxis.png', 'Taxis'),
                  // const CustomSpacer(size: 14),
                  customSwitchControl(9, 'assets/others.png', 'Others'),
                  const CustomSpacer(size: 30),
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
                      SizedBox(
                        width: wScale(32),
                        height: hScale(18),
                        child: Transform.scale(
                          scale: 0.5,
                          child: CupertinoSwitch(
                            trackColor: const Color(0xFFDFDFDF),
                            activeColor: const Color(0xFF3BD8A3),
                            value: isSwitchedTransactionLimit,
                            onChanged: (v) => isTransactionLimitChange
                                ? setState(() => isSwitchedTransactionLimit = v)
                                : null,
                          ),
                        ),
                      )
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
                                      "${varianceLimitValue.toStringAsFixed(0)}%";
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
                  const CustomSpacer(size: 18),
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
                                    "${newValue.toStringAsFixed(0)}%";
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

  Widget customSwitchControl(isSwitched, image, title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        customSwitch(isSwitched),
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
            isMerchantChange
                ? setState(() => isSwitchedArr[index] = !isSwitchedArr[index])
                : null;
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
      children: [backButton('Cancel'), mutationButton('Issue Card')],
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
            side: const BorderSide(width: 0, color: Color(0xFFe8e9ea)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(title,
              style: TextStyle(
                  color: Color(0xff1A2831),
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
              document: gql(mutationIssueVirtaulCardSpend),
              update: (GraphQLDataProxy cache, QueryResult? result) {
                return cache;
              },
              onCompleted: (resultData) async {
                setState(() {
                  isLoading = false;
                });
                if (resultData['createFinanceAccountFLASpendControl']) {
                  var result = await showDialog(
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
                                  title: "Request sent successfully",
                                  message:
                                      "Your request has been sent. You will receive a confirmation e-mail shortly.",
                                )));
                      });

                  result == 'dialog' ? Navigator.of(context).pop() : null;
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
                                    title: "Request sent faild",
                                    message: "")));
                      });
                }
              },
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              return saveButton(title, runMutation);
            }));
  }

  _showSimpleModalDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              insetPadding: EdgeInsets.all(hScale(0)),
              child: modalField());
        });
  }

  _showCardNameModalDialog(context, runMutation) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: wScale(40)),
              child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: cardNameModalField(runMutation)));
        });
  }

  _showEmptyCardNameModalDialog(context, runMutation) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: wScale(40)),
              child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: emptyCardNameModalField(runMutation)));
        });
  }

  Widget modalField() {
    return Container(
        width: wScale(327),
        padding:
            EdgeInsets.symmetric(horizontal: wScale(16), vertical: hScale(16)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
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
              ctl: companyNameCtl,
              hint: 'Type Company Name',
              label: 'Company Name'),
          CustomSpacer(size: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [modalBackButton('Back'), modalSaveButton('Update')],
          )
        ]));
  }

  Widget cardNameModalField(runMutation) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
          padding: EdgeInsets.symmetric(
              vertical: hScale(25), horizontal: wScale(16)),
          child: Column(children: [
            Image.asset('assets/warning_icon.png',
                fit: BoxFit.contain, height: wScale(30)),
            const CustomSpacer(size: 15),
            Text('You have not indicated Card Name(s)',
                style: TextStyle(
                    fontSize: fSize(14), fontWeight: FontWeight.w700)),
            const CustomSpacer(size: 10),
            Text(
              'If you wish to name your virtual cards, please select Card Name(s) before you select Issue Card.',
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
                      handleNamesOnCard(1, runMutation);
                    },
                    child: const Text('Proceed'),
                  ))
            ],
          ))
    ]);
  }

  Widget emptyCardNameModalField(runMutation) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
          padding: EdgeInsets.symmetric(
              vertical: hScale(25), horizontal: wScale(16)),
          child: Column(children: [
            Image.asset('assets/warning_icon.png',
                fit: BoxFit.contain, height: wScale(30)),
            const CustomSpacer(size: 15),
            Text('You have missing card names',
                style: TextStyle(
                    fontSize: fSize(14), fontWeight: FontWeight.w700)),
            const CustomSpacer(size: 10),
            Text(
              'One or more card name is missing. Please ensure that all names have been filled before proceeding.',
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
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      handleNamesOnCard(0, runMutation);
                    },
                    child: const Text('Okay'),
                  ))
            ],
          ))
    ]);
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
                  color: Color(0xFF1A2831),
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget modalSaveButton(title) {
    return SizedBox(
        width: wScale(141),
        height: hScale(56),
        // margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            setState(() {
              companyNameText = companyNameCtl.text;
            });
            Navigator.of(context).pop();
          },
          child: Text(title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }
}

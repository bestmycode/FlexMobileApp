import 'package:co/ui/main/cards/manage_limits_additional.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_result_modal.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';

class ManageLimitsMain extends StatefulWidget {
  final data;
  final financeAccount;
  final handlePopNavigator;
  const ManageLimitsMain(
      {Key? key, this.data, this.financeAccount, this.handlePopNavigator})
      : super(key: key);
  @override
  ManageLimitsMainState createState() => ManageLimitsMainState();
}

class ManageLimitsMainState extends State<ManageLimitsMain> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final cardTypeCtl = TextEditingController();
  int cardType = 0; // 0 => Fixed Card, 1 => Recurring Card
  var cardTypeArr = ["Fixed Card", "Recurring Card"];
  final cardLimitCtl = TextEditingController();
  final limitRefreshCtl = TextEditingController();
  final expiryDateCtl = TextEditingController();
  final transactionLimitCtl = TextEditingController(text: 'SGD 1.0');
  final varianceLimitCtl = TextEditingController(text: '0%');

  bool isSwitchedMerchant = true;
  bool isSwitchedTransactionLimit = true;
  List isSwitchedArr = [
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
  double transactionLimitValue = 1;
  double varianceLimitValue = 0;

  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String mutationFinanceAccountLimit =
      FXRMutations.MUTATION_FINANCE_ACCOUNT_LIMIT;
  bool showCardLimitLength = false;
  bool showCardLimitEmpty = false;
  bool isLoading = false;

  handleCloneSetting() {}

  handleSwitch(arr) {
    setState(() {
      isSwitchedArr = arr;
    });
  }

  setTransactionLimitValue(newValue) {
    setState(() {
      transactionLimitValue = newValue;
    });
  }

  setVarianceLimitValue(newValue) {
    setState(() {
      varianceLimitValue = newValue;
    });
  }

  setIsSwitchedMerchant(value) {
    setState(() {
      isSwitchedMerchant = value;
    });
  }

  setIsSwitchedTransactionLimit(value) {
    setState(() {
      isSwitchedTransactionLimit = value;
    });
  }

  handleSave(runMutation) {
    if (cardLimitCtl.text.length > 10) {
      setState(() {
        showCardLimitLength = true;
      });
    } else if (cardLimitCtl.text.length == 0) {
      setState(() {
        showCardLimitEmpty = true;
      });
    } else {
      var runValue = isSwitchedMerchant && isSwitchedTransactionLimit
          ? {
              "financeAccountId": widget.data['id'],
              "limitValue": int.parse(cardLimitCtl.text),
              "orgId": widget.data['orgId'],
              "controls": {
                "transactionLimit": transactionLimitValue.round(),
                "variancePercentage": varianceLimitValue.toInt(),
                "allowedCategories": [
                  {"categoryName": "AIRLINES", "isAllowed": isSwitchedArr[0]},
                  {"categoryName": "CAR_RENTAL", "isAllowed": isSwitchedArr[1]},
                  {
                    "categoryName": "TRANSPORTATION",
                    "isAllowed": isSwitchedArr[2]
                  },
                  {"categoryName": "HOTELS", "isAllowed": isSwitchedArr[3]},
                  {"categoryName": "PETROL", "isAllowed": isSwitchedArr[4]},
                  {
                    "categoryName": "DEPARTMENT_STORES",
                    "isAllowed": isSwitchedArr[5]
                  },
                  {"categoryName": "PARKING", "isAllowed": isSwitchedArr[6]},
                  {
                    "categoryName": "FOOD_AND_BEVERAGES",
                    "isAllowed": isSwitchedArr[7]
                  },
                  {"categoryName": "TAXIS", "isAllowed": isSwitchedArr[8]},
                  {"categoryName": "OTHERS", "isAllowed": isSwitchedArr[9]}
                ]
              }
            }
          : isSwitchedTransactionLimit
              ? {
                  "financeAccountId": widget.data['id'],
                  "limitValue": int.parse(cardLimitCtl.text),
                  "orgId": widget.data['orgId'],
                  "controls": {
                    "transactionLimit": transactionLimitValue.round(),
                    "variancePercentage": varianceLimitValue.toInt(),
                  }
                }
              : isSwitchedMerchant
                  ? {
                      "financeAccountId": widget.data['id'],
                      "limitValue": int.parse(cardLimitCtl.text),
                      "orgId": widget.data['orgId'],
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
                          }
                        ]
                      }
                    }
                  : {
                      "financeAccountId": widget.data['id'],
                      "limitValue": int.parse(cardLimitCtl.text),
                      "orgId": widget.data['orgId']
                    };
      runMutation(runValue);
      setState(() {
        isLoading = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    List temp_isSwitchedArr = [];
    widget.financeAccount['spendControlLimits']['allowedCategories']
        .forEach((item) {
      temp_isSwitchedArr.add(item['isAllowed']);
    });
    setState(() {
      isSwitchedArr = temp_isSwitchedArr;
      isSwitchedMerchant = widget
                  .financeAccount['spendControlLimits']['allowedCategories']
                  .length ==
              0
          ? false
          : true;
      isSwitchedTransactionLimit = widget.financeAccount['spendControlLimits']
                  ['transactionLimit'] ==
              null
          ? false
          : true;
      cardLimitCtl.text = widget.financeAccount['financeAccountLimits'][0]
              ['limitValue']
          .toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Stack(children: [
      Container(
          height: hScale(812),
          child: SingleChildScrollView(
            child: Column(children: [
              const CustomSpacer(size: 44),
              const CustomMainHeader(title: 'Manage Limits'),
              const CustomSpacer(size: 38),
              isLoading
                  ? Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: hScale(30)),
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF60C094))))
                  : Column(
                      children: [
                        cardDetailField(widget.data),
                        const CustomSpacer(size: 20),
                        ManageLimitsAdditional(
                            data: widget.financeAccount == null
                                ? null
                                : widget.financeAccount['spendControlLimits'],
                            availableLimitValue: widget.financeAccount == null
                                ? 1.0
                                : double.parse(cardLimitCtl.text),
                            transactionLimitValue: widget.financeAccount == null
                                ? 1.0
                                : widget.financeAccount['spendControlLimits']
                                            ['transactionLimit'] ==
                                        null
                                    ? 1.0
                                    : widget
                                        .financeAccount['spendControlLimits']
                                            ['transactionLimit']
                                        .toDouble(),
                            varianceLimitValue: widget.financeAccount == null
                                ? 0.0
                                : widget.financeAccount['spendControlLimits']
                                            ['variancePercentage'] ==
                                        null
                                    ? 0.0
                                    : widget
                                        .financeAccount['spendControlLimits']
                                            ['variancePercentage']
                                        .toDouble(),
                            isSwitchedArr: isSwitchedArr,
                            handleSwitch: handleSwitch,
                            setIsSwitchedMerchant: setIsSwitchedMerchant,
                            setIsSwitchedTransactionLimit:
                                setIsSwitchedTransactionLimit,
                            isSwitchedMerchant: isSwitchedMerchant,
                            setTransactionLimitValue: setTransactionLimitValue,
                            isSwitchedTransactionLimit:
                                isSwitchedTransactionLimit,
                            setVarianceLimitValue: setVarianceLimitValue),
                        const CustomSpacer(size: 16),
                        buttonField(),
                        const CustomSpacer(size: 16),
                      ],
                    ),
              const CustomSpacer(size: 88),
            ]),
          )),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 1),
      )
    ])));
  }

  Widget cardDetailField(data) {
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
          cardTitle(),
          const CustomSpacer(size: 22),
          cardTypeField(data == null ? "" : data['cardType']),
          const CustomSpacer(size: 22),
          CustomTextField(
              ctl: cardLimitCtl,
              hint: 'Enter Card Limit',
              label: 'Card Limit',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (text) {
                setState(() {
                  // isSwitchedTransactionLimit = isSwitchedMerchant && text.length > 0 ? true : false;
                  cardLimitCtl.text =
                      (text.length == 0 || text == "0") ? "1" : text;
                });
                cardLimitCtl.selection = TextSelection.fromPosition(
                    TextPosition(offset: cardLimitCtl.text.length));
              },
              keyboardType: const TextInputType.numberWithOptions(
                  signed: true, decimal: true)),
          showCardLimitLength
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
          showCardLimitEmpty
              ? Container(
                  height: hScale(22),
                  width: wScale(295),
                  padding: EdgeInsets.only(top: hScale(5)),
                  child: Text("This field is required",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: fSize(12),
                          color: Color(0xFFEB5757),
                          fontWeight: FontWeight.w400)))
              : const CustomSpacer(size: 22),

          // cardType == 0 ? dateField() : limitRefreshField(),
          limitRefreshField(),
          const CustomSpacer(size: 15),
        ],
      ),
    );
  }

  //  Widget dateField() {
  //   return Stack(
  //     children: [
  //       Container(
  //         width: wScale(295),
  //         height: hScale(56),
  //         alignment: Alignment.center,
  //         margin: EdgeInsets.only(top: hScale(8)),
  //         decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(4),
  //             border: Border.all(
  //                 color: widget.errorExpireDate
  //                     ? Color(0xFFEB5757)
  //                     : Color(0xFF040415).withOpacity(0.1))),
  //         child: TextButton(
  //             style: TextButton.styleFrom(
  //               // primary: const Color(0xffF5F5F5).withOpacity(0.4),
  //               padding: const EdgeInsets.all(0),
  //             ),
  //             onPressed: () {
  //               _openDatePicker();
  //             },
  //             child: Row(
  //               children: <Widget>[
  //                 Expanded(
  //                     child: TextField(
  //                   style: TextStyle(
  //                       fontSize: fSize(16),
  //                       fontWeight: FontWeight.w500,
  //                       color: const Color(0xFF040415)),
  //                   controller: widget.expiryDateCtl,
  //                   decoration: InputDecoration(
  //                     filled: true,
  //                     fillColor: Colors.white,
  //                     enabledBorder: const OutlineInputBorder(
  //                         borderSide:
  //                             BorderSide(color: Colors.white, width: 1.0)),
  //                     hintText: 'DD/MM/YYYY',
  //                     hintStyle: TextStyle(
  //                         color: widget.errorExpireDate
  //                             ? Color(0xFFEB5757)
  //                             : Color(0xffBFBFBF),
  //                         fontSize: fSize(14)),
  //                     focusedBorder: const OutlineInputBorder(
  //                         borderSide:
  //                             BorderSide(color: Colors.white, width: 1.0)),
  //                   ),
  //                   readOnly: true,
  //                   onTap: () {
  //                     _openDatePicker();
  //                   },
  //                 )),
  //                 Container(
  //                     // margin: EdgeInsets.only(right: wScale(20)),
  //                     padding: EdgeInsets.symmetric(horizontal: wScale(10)),
  //                     child: Image.asset('assets/calendar.png',
  //                         fit: BoxFit.contain, width: wScale(18)))
  //               ],
  //             )),
  //       ),
  //       Positioned(
  //         top: 0,
  //         left: wScale(10),
  //         child: Container(
  //           padding: EdgeInsets.symmetric(horizontal: wScale(8)),
  //           color: Colors.white,
  //           child: Text('Expiry Date',
  //               style: TextStyle(
  //                   fontSize: fSize(12),
  //                   fontWeight: FontWeight.w400,
  //                   color: widget.errorExpireDate
  //                       ? Color(0xFFEB5757)
  //                       : Color(0xFFBFBFBF))),
  //         ),
  //       )
  //     ],
  //   );
  // }

  Widget cardTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Spend Control Main',
            style: TextStyle(
                fontSize: fSize(16),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2831))),
      ],
    );
  }

  Widget cardTypeField(cardtype) {
    cardTypeCtl.text = cardtype == 'RECURRING'
        ? 'Recurring'
        : cardtype == 'ONE-TIME'
            ? 'Fixed'
            : '';
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
                readOnly: true,
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF040415).withOpacity(0.5)),
                controller: cardTypeCtl,
                enabled: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
                  hintText: 'Select Card Types',
                  hintStyle: TextStyle(
                      color: const Color(0xffBFBFBF), fontSize: fSize(14)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
                ),
              )),
              Icon(Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFFBFBFBF))
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text('Card Type*',
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFBFBFBF))),
          ),
        )
      ],
    );
  }

  Widget limitRefreshField() {
    limitRefreshCtl.text = "Monthly";
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
                readOnly: true,
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF040415).withOpacity(0.5)),
                controller: limitRefreshCtl,
                enabled: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
                  hintText: 'Enter Limit Refresh',
                  hintStyle: TextStyle(
                      color: const Color(0xffBFBFBF), fontSize: fSize(14)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
                ),
              )),
              Icon(Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFFBFBFBF))
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text('Limit Refresh',
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFBFBFBF))),
          ),
        )
      ],
    );
  }

  Widget mutationSaveButton() {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Mutation(
            options: MutationOptions(
              document: gql(mutationFinanceAccountLimit),
              update: (GraphQLDataProxy cache, QueryResult? result) {
                return cache;
              },
              onCompleted: (resultData) {
                setState(() {
                  isLoading = false;
                });
                resultData['updateFinanceAccountLimit']
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
                                      title:
                                          "Spend Control Settings Saved Succesfully",
                                      message:
                                          "You’ve succesfully saved spend control settings.",
                                      handleOKClick: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop('dialog');
                                        widget.handlePopNavigator();
                                      })));
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
              return saveButton(runMutation);
            }));
  }

  Widget buttonField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [backButton(), mutationSaveButton()],
    );
  }

  Widget backButton() {
    return Container(
        width: wScale(156),
        height: hScale(56),
        margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831).withOpacity(0.1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Back",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget saveButton(runMutation) {
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
            handleSave(runMutation);
          },
          child: Text("Save",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }
}

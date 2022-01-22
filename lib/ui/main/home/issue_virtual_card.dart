import 'dart:ui';

import 'package:co/ui/main/cards/name_on_card.dart';
import 'package:co/ui/main/cards/virtual_card.dart';
import 'package:co/ui/main/home/issue_spend_control_main.dart';
import 'package:co/ui/widgets/custom_result_modal.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class IssueVirtaulCard extends StatefulWidget {
  const IssueVirtaulCard({Key? key}) : super(key: key);
  @override
  IssueVirtaulCardState createState() => IssueVirtaulCardState();
}

class IssueVirtaulCardState extends State<IssueVirtaulCard> {
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
  final transactionLimitCtl = TextEditingController(text: 'SGD 0');
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
  double transactionLimitValue = 0;
  double varianceLimitValue = 0;

  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String queryListMerchantGroup = Queries.QUERY_LIST_MERCHANT_GROUP;
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
  bool checkCardName = false;

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
      transactionLimitCtl.text = "SGD " + value;
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
    });
    bool isNoError = (cardType == 0
            ? expiryDateCtl.text != ''
            : limitRefreshCtl.text != '') &&
        monthlySpendLimitCtl.text != "" &&
        cardHolders.length != 0;

    if (isNoError) {
      if (checkCardName == false) {
        _showCardNameModalDialog(context);
      } else {
        if (cardType == 0) {
          var expiryDate =
              '${expiryDateCtl.text.split("/")[2]}-${expiryDateCtl.text.split("/")[1]}-${expiryDateCtl.text.split("/")[0]}';
          runMutation({
            "accountSubtype": "VIRTUAL",
            "cardHolders": cardHolders,
            "cardLimit": int.parse(monthlySpendLimitCtl.text),
            "cardType": "ONE-TIME",
            "controls": {
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
                {"categoryName": "OTHERS", "isAllowed": isSwitchedArr[9]},
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
          });
        } else {
          print('0000000000000');
          runMutation({
            "accountSubtype": "VIRTUAL",
            "cardHolders": cardHolders,
            "cardLimit": int.parse(monthlySpendLimitCtl.text),
            "cardType": "RECURRING",
            "controls": {
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
                {"categoryName": "OTHERS", "isAllowed": isSwitchedArr[9]},
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
          });
        }
      }
    }
  }

  handleEditCompanyName() {
    _showSimpleModalDialog(context);
  }

  handleNamesOnCard() async {
    var cardNameHolders = [];
    cardHolders.forEach((element) {
      cardNameHolders.add(element['preferredCardName']);
    });

    var result = await Navigator.of(context).push(
      CupertinoPageRoute(
          builder: (context) => NameOnCard(cardNameHolders: cardNameHolders)),
    );
    var tempCardHolders = [];
    cardHolders.forEach((item) {
      tempCardHolders.add({
        "userId": item['userId'],
        "preferredCardholderName": '',
        "preferredCardName": result[cardHolders.indexOf(item)],
        "applySpendControls": true
      });
    });

    setState(() {
      cardNameHolders = result;
      cardHolders = tempCardHolders;
      checkCardName = true;
    });
  }

  handleCheckCardName() {
    setState(() {
      checkCardName = true;
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
            body: Stack(children: [
      SingleChildScrollView(
          child: Column(children: [
        const CustomSpacer(size: 44),
        const CustomMainHeader(title: 'Issue Virtual Card'),
        const CustomSpacer(size: 38),
        cardDetailField(),
        const CustomSpacer(size: 20),
        IssueSpendControlMain(
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
            handleCheckCardName: handleCheckCardName),
        const CustomSpacer(size: 15),
        getAdditionalField(),
        Opacity(
            opacity: isSwitchedMerchant ? 1 : 0.4,
            child: Column(
              children: [
                const CustomSpacer(size: 20),
                remarksField(),
                const CustomSpacer(size: 30),
              ],
            )),
        const CustomSpacer(size: 30),
        buttonField(),
        const CustomSpacer(size: 46),
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
            color: Colors.grey.withOpacity(0.25),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Smarter payments with \nFlex Virtual Cards',
                  style: TextStyle(
                      fontSize: fSize(16),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A2831))),
              TextButton(
                  onPressed: () {},
                  child: Text("Learn More",
                      style: TextStyle(
                          fontSize: fSize(12),
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF60C094),
                          decoration: TextDecoration.underline)))
            ],
          ),
          const CustomSpacer(size: 12),
          Text('Unlimited virtual cards for users on advanced subscription.',
              style: TextStyle(fontSize: fSize(12), color: Color(0xFF70828D))),
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
            image: AssetImage("assets/virtual_card_detail.png"),
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

  Widget getAdditionalField() {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Query(
            options: QueryOptions(
              document: gql(queryListMerchantGroup),
              variables: {"countryCode": "SG"},
              // pollInterval: const Duration(seconds: 10),
            ),
            builder: (QueryResult merchantUser,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (merchantUser.hasException) {
                return Text(merchantUser.exception.toString());
              }

              if (merchantUser.isLoading) {
                return additionalField();
              }

              var merchantUsers =
                  merchantUser.data!['listMerchantGroups']['merchantGroup'];

              return additionalField();
            }));
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
            color: Colors.grey.withOpacity(0.25),
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
          Row(
            children: [
              Text('Additional Spend Control',
                  style: TextStyle(
                      fontSize: fSize(16),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A2831))),
              SizedBox(width: 5),
              Image.asset('assets/flex_pro.png',
                  fit: BoxFit.contain, width: wScale(22))
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
                          fontSize: fSize(12),
                          color: const Color(0xFF70828D),
                          fontWeight: FontWeight.w400),
                      children: const [
                        TextSpan(
                            text:
                                'Select the categories where spending will be \n'),
                        TextSpan(
                            text: 'Blocked',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEB5757))),
                        TextSpan(
                            text:
                                '.  When making a purchase on unauthorized\ncategories, the transaction will be rejected. All\nspending categories are'),
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
                      Text('Transaction Limit',
                          style: TextStyle(
                              fontSize: fSize(14),
                              color: const Color(0xFF1A2831))),
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
                  const CustomSpacer(size: 28),
                  readonlyTextFiled(transactionLimitCtl,
                      'Enter Transaction Limit', 'Transaction Limit'),
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
                      min: 0.0,
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
                                transactionLimitCtl.text = 'SGD ' +
                                    (newValue *
                                            int.parse(
                                                monthlySpendLimitCtl.text) /
                                            100)
                                        .toStringAsFixed(0);
                              });
                            }
                          : null,
                    ),
                  ),
                  const CustomSpacer(size: 24),
                  Text('Variance Limit',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: fSize(14), color: const Color(0xFF1A2831))),
                  const CustomSpacer(size: 28),
                  readonlyTextFiled(varianceLimitCtl, 'Enter Variance Limit',
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
                      onChanged: isSwitchedTransactionLimit
                          ? (double newValue) {
                              setState(() {
                                varianceLimitValue = newValue;
                                if (transactionLimitValue >
                                    (100 / (100 + newValue) * 100)) {
                                  transactionLimitValue =
                                      (100 / (100 + newValue) * 100);
                                  transactionLimitCtl.text = 'SGD ' +
                                      (transactionLimitValue *
                                              int.parse(
                                                  monthlySpendLimitCtl.text) /
                                              100)
                                          .toStringAsFixed(0);
                                }
                                varianceLimitCtl.text =
                                    newValue.toStringAsFixed(0) + '%';
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
        SizedBox(width: wScale(20)),
        Image.asset(image, width: hScale(16), fit: BoxFit.contain),
        SizedBox(width: wScale(9)),
        Text(title,
            style: TextStyle(
                fontSize: fSize(16),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2831)))
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

  Widget readonlyTextFiled(ctl, hint, label) {
    return Container(
        width: wScale(295),
        height: hScale(56),
        alignment: Alignment.center,
        child: TextField(
          controller: ctl,
          readOnly: true,
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
            color: Colors.grey.withOpacity(0.25),
            spreadRadius: 4,
            blurRadius: 20,
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
            primary: const Color(0xffc9c9c9).withOpacity(0.1),
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

                  result == 'dialog'
                      ? Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => const VirtualCards()))
                      : null;
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

  Widget cardNameModalField() {
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
                      handleNamesOnCard();
                    },
                    child: const Text('Proceed'),
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
            primary: const Color(0xffc9c9c9).withOpacity(0.1),
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

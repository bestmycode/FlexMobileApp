import 'dart:ui';

import 'package:co/ui/main/cards/name_on_card.dart';
import 'package:co/ui/widgets/custom_result_modal.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/queries.dart';
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

class RequestCard extends StatefulWidget {
  const RequestCard({Key? key}) : super(key: key);
  @override
  RequestCardState createState() => RequestCardState();
}

class RequestCardState extends State<RequestCard> {
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
  final transactionLimitCtl = TextEditingController(text: 'SGD 1000.00');
  final varianceLimitCtl = TextEditingController(text: '30%');
  final remarksCtl = TextEditingController();
  final companyNameCtl = TextEditingController();

  final cardHolderNameCtl = TextEditingController();
  final monthlySpendLimitCtl = TextEditingController(text: "0");

  bool isSwitchedAdditional = true;
  bool isSwitchedMerchant = true;
  bool isSwitchedTransactionLimit = true;
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
  double transactionLimitValue = 10;
  double varianceLimitValue = 30;

  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String queryGetCompanySetting = Queries.QUERY_GET_COMPANY_SETTING;
  String queryListEligibleUserCard = Queries.QUERY_LIST_ELIGIBLE_USER_CARD;
  String queryListMerchantGroup = Queries.QUERY_LIST_MERCHANT_GROUP;
  String mutationRequestCardSpend = FXRMutations.MUTATION_REQUEST_CARD_SPEND;
  late var seletedEligible;
  String companyNameText = '';
  var cardHolders = [];

  handleCloneSetting() {}

  handleSwitch(index, v) {
    setState(() {
      isSwitchedArr[index] = v;
    });
  }

  handleSave(runMutation) {
    if (cardHolders.length != 0) {
      runMutation({
        "accountSubtype": "PHYSICAL",
        "cardHolders": cardHolders,
        "cardLimit": int.parse(monthlySpendLimitCtl.text),
        "controls": {
          "allowedCategories": [
            {"categoryName": "AIRLINES", "isAllowed": isSwitchedArr[0]},
            {"categoryName": "CAR_RENTAL", "isAllowed": isSwitchedArr[1]},
            {"categoryName": "TRANSPORTATION", "isAllowed": isSwitchedArr[2]},
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
          "transactionLimit": transactionLimitValue *
              int.parse(monthlySpendLimitCtl.text) /
              100,
          "variancePercentage": varianceLimitValue,
        },
        "orgId": userStorage.getItem('orgId'),
        "remarks": remarksCtl.text,
        "renewalFrequency": "MONTHLY",
      });
    }
  }

  handleEditCompanyName() {
    _showSimpleModalDialog(context);
  }

  handleAddCardHolderName() {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => const NameOnCard()),
    );
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
        const CustomMainHeader(title: 'Request For Physical Card'),
        const CustomSpacer(size: 38),
        getCardDetailField(),
        const CustomSpacer(size: 20),
        cardIssueFieldField(),
        const CustomSpacer(size: 20),
        getSpendControlMainField(),
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

  Widget getCardDetailField() {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Query(
            options: QueryOptions(
                document: gql(queryGetCompanySetting),
                variables: {'orgId': userStorage.getItem("orgId")}
                // pollInterval: const Duration(seconds: 10),
                ),
            builder: (QueryResult result,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.hasException) {
                return Text(result.exception.toString());
              }

              if (result.isLoading) {
                return cardDetailField(null);
              }
              var companyProfile = result.data!['organization'];
              return cardDetailField(companyProfile);
            }));
  }

  Widget cardDetailField(companyProfile) {
    companyNameCtl.text =
        companyProfile == null ? "" : companyProfile['organizationAlias'];
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
                  Text(
                      companyNameText == ''
                          ? companyNameCtl.text
                          : companyNameText,
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
              companyProfile == null
                  ? ""
                  : '(${companyProfile["name"]}) ${companyProfile["orgOperatingAddress"]["addressLine1"]} ${companyProfile["orgOperatingAddress"]["country"]} ${companyProfile["orgOperatingAddress"]["postalCode"]}',
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

  Widget getSpendControlMainField() {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Query(
            options: QueryOptions(
              document: gql(queryListEligibleUserCard),
              variables: {
                'orgId': userStorage.getItem('orgId'),
                "accountSubtype": "PHYSICAL"
              },
              // pollInterval: const Duration(seconds: 10),
            ),
            builder: (QueryResult eligibleResult,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (eligibleResult.hasException) {
                return Text(eligibleResult.exception.toString());
              }

              if (eligibleResult.isLoading) {
                return spendControlMainField([]);
              }

              var eligibleUsers = eligibleResult
                  .data!['listEligibleUsersForCard']['eligibleUsers'];
              return spendControlMainField(eligibleUsers);
            }));
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
          Text('Spend Control Main',
              style: TextStyle(
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A2831))),
          const CustomSpacer(size: 22),
          cardHolderNameField(eligibleUsers),
          cardHolderArr(eligibleUsers),
          const CustomSpacer(size: 32),
          CustomTextField(
              ctl: monthlySpendLimitCtl,
              hint: 'Enter Monthly Spend Limit',
              label: 'Monthly Spend Limit',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          const CustomSpacer(size: 15),
          monthlyCardsList()
        ],
      ),
    );
  }

  Widget cardHolderNameField(eligibleUsers) {
    List<String> eligibleUserArr = [];
    eligibleUsers.forEach((item) {
      eligibleUserArr.add("${item['firstName']} ${item['lastName']}");
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
                controller: cardHolderNameCtl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
                  hintText: 'Enter Cardholder Name',
                  hintStyle: TextStyle(
                      color: const Color(0xffBFBFBF), fontSize: fSize(14)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
                ),
              )),
              PopupMenuButton<String>(
                icon: Icon(Icons.add, color: const Color(0xFFBFBFBF)),
                onSelected: (String value) {
                  cardHolderNameCtl.text = value;
                  var index = eligibleUserArr.indexOf(value);
                  setState(() {
                    cardHolders.add({
                      "userId": eligibleUsers[index]['id'],
                      "preferredCardholderName":
                          '${eligibleUsers[index]['firstName']} ${eligibleUsers[index]['firstName']}',
                      "preferredCardName": ""
                    });
                  });
                },
                itemBuilder: (BuildContext context) {
                  return eligibleUserArr
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

  Widget cardHolderArr(eligibleUsers) {
    return eligibleUsers.length == 0
        ? SizedBox()
        : Container(
            padding: EdgeInsets.only(top: 5),
            child: Wrap(
                spacing: 5,
                runSpacing: 5,
                children: cardHolders.map<Widget>((item) {
                  return cardholder(cardHolders.indexOf(item), item);
                }).toList()));
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
              Text(item['preferredCardholderName'],
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
                  transactionLimitCtl.text = 'SGD ${value}';
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
          Text('Additional Spend Control',
              style: TextStyle(
                  fontSize: fSize(16),
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
                  const CustomSpacer(size: 24),
                  customSwitchControl(0, 'assets/air_lines.png', 'Airlines'),
                  const CustomSpacer(size: 20),
                  customSwitchControl(1, 'assets/car_rental.png', 'Car Rental'),
                  const CustomSpacer(size: 20),
                  customSwitchControl(
                      2, 'assets/transportation.png', 'Transportation'),
                  const CustomSpacer(size: 20),
                  customSwitchControl(3, 'assets/hotels.png', 'Hotels'),
                  const CustomSpacer(size: 20),
                  customSwitchControl(4, 'assets/petrol.png', 'Petrol'),
                  const CustomSpacer(size: 20),
                  customSwitchControl(
                      5, 'assets/department_stores.png', 'Department Stores'),
                  const CustomSpacer(size: 20),
                  customSwitchControl(6, 'assets/parking.png', 'Parking'),
                  const CustomSpacer(size: 20),
                  customSwitchControl(
                      7, 'assets/fandb.png', 'F&B (Restaurants & Groceries)'),
                  const CustomSpacer(size: 20),
                  customSwitchControl(8, 'assets/taxis.png', 'Taxis'),
                  const CustomSpacer(size: 20),
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
                            onChanged: (v) =>
                                setState(() => isSwitchedTransactionLimit = v),
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
                                transactionLimitCtl.text = 'SGD ' +
                                    (newValue *
                                            int.parse(
                                                monthlySpendLimitCtl.text) /
                                            100)
                                        .toStringAsFixed(2);
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
                                varianceLimitCtl.text =
                                    newValue.toStringAsFixed(2) + '%';
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
        Container(
          width: wScale(220),
          child: Text(title,
            style: TextStyle(
                fontSize: fSize(16),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2831)))
        )
      ],
    );
  }

  Widget customSwitch(index) {
    return SizedBox(
      width: wScale(26),
      height: hScale(15),
      child: Transform.scale(
        scale: 0.4,
        child: CupertinoSwitch(
            trackColor: const Color(0xFFEB5757),
            activeColor: const Color(0xFF3BD8A3),
            value: isSwitchedArr[index],
            onChanged: (v) => handleSwitch(index, v)),
      ),
    );
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
                                          "You have successfully requested physical card(s). Please expect your card to be delivered within 7 working days.")));
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
                print(resultData);
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

import 'dart:ui';

import 'package:co/ui/main/cards/name_on_card.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

class IssueSpendControlMain extends StatefulWidget {
  final monthlySpendLimitCtl;
  final limitRefreshCtl;
  final expiryDateCtl;
  final callBack;
  final errorCardHolder;
  final errorExpireDate;
  final errorLimitRefresh;
  final errorMonthlySpend;
  final callbackCardHolder;
  final handleCardType;
  final handleIsSwitchedMerchant;
  final handleIisSwitchedTransactionLimit;
  final handleCheckCardName;
  const IssueSpendControlMain(
      {Key? key,
      this.monthlySpendLimitCtl,
      this.limitRefreshCtl,
      this.expiryDateCtl,
      this.callBack,
      this.errorCardHolder,
      this.errorExpireDate,
      this.errorLimitRefresh,
      this.errorMonthlySpend,
      this.callbackCardHolder,
      this.handleCardType,
      this.handleIsSwitchedMerchant,
      this.handleIisSwitchedTransactionLimit,
      this.handleCheckCardName})
      : super(key: key);
  @override
  IssueSpendControlMainState createState() => IssueSpendControlMainState();
}

class IssueSpendControlMainState extends State<IssueSpendControlMain> {
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
  String queryListEligibleUserCard = Queries.QUERY_LIST_ELIGIBLE_USER_CARD;

  final cardHolderNameCtl = TextEditingController();
  final cardTypeCtl = TextEditingController(text: "Fixed Card");
  final monthlySpendLimitCtl = TextEditingController();
  final limitRefreshCtl = TextEditingController();
  final expiryDateCtl = TextEditingController();
  var cardTypeArr = ["Fixed Card", "Recurring Card"];
  var cardHolders = [];
  var cardNameHolders = [];
  int cardType = 0;

  handleAddCardHolderName() async {
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
    });
    widget.handleCheckCardName();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Query(
            options: QueryOptions(
              document: gql(queryListEligibleUserCard),
              variables: {
                'orgId': userStorage.getItem('orgId'),
                "accountSubtype": "VIRTUAL"
              },
              // pollInterval: const Duration(seconds: 10),
            ),
            builder: (QueryResult eligibleResult,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (eligibleResult.hasException) {
                return Text(eligibleResult.exception.toString());
              }

              if (eligibleResult.isLoading) {
                return home([]);
              }

              var eligibleUsers = eligibleResult
                  .data!['listEligibleUsersForCard']['eligibleUsers'];
              return home(eligibleUsers);
            }));
  }

  Widget home(eligibleUsers) {

    print(cardHolders.length);
    
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
          widget.errorCardHolder
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
              : SizedBox(),
              Column(
                  children: [
                    const CustomSpacer(size: 16),
                    cardHolders.length == 0
                        ? const CustomSpacer(size: 0)
                        : cardNamesButton(cardNameHolders),
                    const CustomSpacer(size: 16),
                  ],
                ),
          cardTypeField(),
          const CustomSpacer(size: 32),
          CustomTextField(
              ctl: widget.monthlySpendLimitCtl,
              hint: 'Enter Monthly Spend Limit',
              label: 'Monthly Spend Limit',
              onChanged: (text) {
                widget.handleIisSwitchedTransactionLimit(text);
              },
              isError: widget.errorMonthlySpend,
              keyboardType: TextInputType.number),
          widget.errorMonthlySpend
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
          cardType == 0 ? dateField() : limitRefreshField(),
          (cardType == 0 ? widget.errorExpireDate : widget.errorLimitRefresh)
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
              border: Border.all(
                  color: widget.errorCardHolder
                      ? Color(0xFFEB5757)
                      : Color(0xFF040415).withOpacity(0.1))),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: TextField(
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF040415)),
                controller: cardHolderNameCtl,
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
                  hintText: 'Enter Cardholder Name',
                  hintStyle: TextStyle(
                      color: widget.errorCardHolder
                          ? Color(0xFFEB5757)
                          : Color(0xffBFBFBF),
                      fontSize: fSize(14)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
                ),
              )),
              PopupMenuButton<String>(
                icon: eligibleUserArr.length == 0
                    ? SizedBox()
                    : Icon(Icons.add, color: const Color(0xFFBFBFBF)),
                onSelected: (String value) {
                  cardHolderNameCtl.text = value;
                  var index = eligibleUserArr.indexOf(value);
                  var isExist = cardNameHolders.firstWhere(
                      (element) =>
                          element ==
                          '${eligibleUsers[index]['firstName']} ${eligibleUsers[index]['lastName']}',
                      orElse: () => null);
                  if (isExist == null) {
                    setState(() {
                      cardHolders.add({
                        "userId": eligibleUsers[index]['id'],
                        "preferredCardholderName": '',
                        "preferredCardName":
                            "${eligibleUsers[index]['firstName']} ${eligibleUsers[index]['lastName']}",
                        "applySpendControls": true
                      });
                      cardNameHolders.add(value);
                    });
                    cardNameHolders.length > 0
                        ? widget.handleIsSwitchedMerchant(true)
                        : widget.handleIsSwitchedMerchant(false);
                    widget.callbackCardHolder(cardHolders);
                  }
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
            child: Text('Cardholder Name',
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: widget.errorCardHolder
                        ? Color(0xFFEB5757)
                        : Color(0xFFBFBFBF))),
          ),
        )
      ],
    );
  }

  Widget cardHolderArr(eligibleUsers) {
    return Container(
        padding: EdgeInsets.only(top: 5),
        child: Wrap(spacing: 5, runSpacing: 5, children: [
          for (var i = 0; i < cardNameHolders.length; i++)
            cardholder(i, cardNameHolders[i])
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
              Text(item,
                  style: TextStyle(
                      fontSize: fSize(12),
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF040415))),
              Container(
                width: wScale(16),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    setState(() {
                      cardNameHolders.removeAt(index);
                      index < cardHolders.length ? cardHolders.removeAt(index): null;
                      if (cardHolders.length == 0) cardHolderNameCtl.text = '';
                      cardNameHolders.length > 0
                          ? widget.handleIsSwitchedMerchant(true)
                          : widget.handleIsSwitchedMerchant(false);
                    });
                    widget.callbackCardHolder(cardHolders);
                  },
                  child: Icon(Icons.close_rounded,
                      color: Color(0xFF040415), size: 16),
                ),
              )
            ],
          ),
        )
      ])
    ]);
  }

  Widget cardNamesButton(cardNameHolders) {
    return Container(
        width: wScale(141),
        height: hScale(56),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            handleAddCardHolderName();
          },
          child: Text('Card Name(s)',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget cardTypeField() {
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
                    color: const Color(0xFF040415)),
                controller: cardTypeCtl,
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
              PopupMenuButton<String>(
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFFBFBFBF)),
                onSelected: (String value) {
                  cardTypeCtl.text = value;
                  setState(() {
                    cardType = value == "Fixed Card" ? 0 : 1;
                    widget.handleCardType(cardType);
                  });
                },
                itemBuilder: (BuildContext context) {
                  return cardTypeArr.map<PopupMenuItem<String>>((String value) {
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
                    color: const Color(0xFF040415)),
                controller: widget.limitRefreshCtl,
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
              PopupMenuButton<String>(
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFFBFBFBF)),
                onSelected: (String value) {
                  widget.limitRefreshCtl.text = value;
                },
                itemBuilder: (BuildContext context) {
                  return ["Monthly"].map<PopupMenuItem<String>>((String value) {
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

  Widget dateField() {
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
                  color: widget.errorExpireDate
                      ? Color(0xFFEB5757)
                      : Color(0xFF040415).withOpacity(0.1))),
          child: TextButton(
              style: TextButton.styleFrom(
                // primary: const Color(0xffF5F5F5).withOpacity(0.4),
                padding: const EdgeInsets.all(0),
              ),
              onPressed: () {
                _openDatePicker();
              },
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    style: TextStyle(
                        fontSize: fSize(16),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF040415)),
                    controller: widget.expiryDateCtl,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 1.0)),
                      hintText: 'DD/MM/YYYY',
                      hintStyle: TextStyle(
                          color: widget.errorExpireDate
                              ? Color(0xFFEB5757)
                              : Color(0xffBFBFBF),
                          fontSize: fSize(14)),
                      focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 1.0)),
                    ),
                    readOnly: true,
                    onTap: () {
                      _openDatePicker();
                    },
                  )),
                  Container(
                      // margin: EdgeInsets.only(right: wScale(20)),
                      padding: EdgeInsets.symmetric(horizontal: wScale(10)),
                      child: Image.asset('assets/calendar.png',
                          fit: BoxFit.contain, width: wScale(18)))
                ],
              )),
        ),
        Positioned(
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text('Expiry Date',
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: widget.errorExpireDate
                        ? Color(0xFFEB5757)
                        : Color(0xFFBFBFBF))),
          ),
        )
      ],
    );
  }

  void _openDatePicker() async {
    DateTime now = new DateTime.now();
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime(now.year, now.month + 1, now.day + 1),
        firstDate: DateTime(now.year, now.month + 1, now.day + 1),
        lastDate: DateTime(2101));

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      setState(() {
        widget.expiryDateCtl.text = formattedDate;
      });
    } else {
      print("Date is not selected");
    }
  }
}

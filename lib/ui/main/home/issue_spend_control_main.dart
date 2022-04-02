import 'dart:ui';

import 'package:co/ui/main/cards/name_on_card.dart';
import 'package:co/ui/widgets/custom_cardtype_popup_list.dart';
import 'package:co/ui/widgets/custom_popup_list.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class IssueSpendControlMain extends StatefulWidget {
  final eligibleUsers;
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
  final errorMonthlySpendLength;
  const IssueSpendControlMain(
      {Key? key,
      this.eligibleUsers,
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
      this.handleCheckCardName,
      this.errorMonthlySpendLength})
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

  final cardHolderNameCtl = TextEditingController();
  final cardTypeCtl = TextEditingController(text: "Fixed Card");
  final monthlySpendLimitCtl = TextEditingController();
  final limitRefreshCtl = TextEditingController();
  final expiryDateCtl = TextEditingController();
  var cardTypeArr = ["Fixed Card", "Recurring Card"];
  var cardHolders = [];
  var cardNameHolders = [];
  int cardType = 0;
  bool cardHolderLimit = false;

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
        "preferredCardName": result[cardHolders.indexOf(item)]['name'],
        "applySpendControls": true
      });
    });

    setState(() {
      cardNameHolders = result;
      cardHolders = tempCardHolders;
    });
    widget.handleCheckCardName(cardHolders);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          cardHolderNameField(widget.eligibleUsers),
          cardHolderLimit
              ? Text('You can only to issue up 20 virtual cards in a request',
                  style: TextStyle(color: Color(0xFFEB5757)))
              : SizedBox(),
          cardHolderArr(widget.eligibleUsers),
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: const TextInputType.numberWithOptions(
                  signed: true, decimal: true)),
          widget.errorMonthlySpendLength
              ? Container(
                  width: wScale(295),
                  padding: EdgeInsets.only(top: hScale(5)),
                  child: Text("You have reached maximum limit of digits allowed",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: fSize(12),
                          color: Color(0xFFEB5757),
                          fontWeight: FontWeight.w400)))
              : SizedBox(),
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
                      if (isExist == null && cardHolders.length < 20) {
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
                        });
                        cardNameHolders.length > 0
                            ? widget.handleIsSwitchedMerchant(true)
                            : widget.handleIsSwitchedMerchant(false);
                        widget.callbackCardHolder(cardHolders);
                      }
                    },
                  )));
        });
  }

  _showCardTypeModalDialog(context, arrData) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: wScale(40)),
              child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: CustomCardTypePopUpList(
                    arrData: arrData,
                    onPress: (index) {
                      cardTypeCtl.text =
                          index == 0 ? "Fixed Card" : "Recurring Card";
                      setState(() {
                        cardType = index;
                        widget.handleCardType(cardType);
                      });
                    },
                  )));
        });
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
                  color: widget.errorCardHolder
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
                        color: widget.errorCardHolder
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
            cardholder(i, cardNameHolders[i]['name'])
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
                      cardHolderLimit = false;
                      cardNameHolders.removeAt(index);
                      index < cardHolders.length
                          ? cardHolders.removeAt(index)
                          : null;
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
          child: TextButton(
              onPressed: () {
                _showCardTypeModalDialog(context, cardTypeArr);
              },
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Text(
                    cardTypeCtl.text,
                    style: TextStyle(
                        fontSize: fSize(16),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF040415)),
                  )),
                  Container(
                      width: wScale(40),
                      child: Icon(Icons.add, color: const Color(0xFFBFBFBF)))
                ],
              )),
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

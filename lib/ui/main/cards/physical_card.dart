import 'package:co/ui/main/cards/physical_my_card.dart';
import 'package:co/ui/main/cards/physical_team_card.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/queries.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:localstorage/localstorage.dart';

class PhysicalCards extends StatefulWidget {
  final defaultType;
  const PhysicalCards({Key? key, this.defaultType = 0}) : super(key: key);
  @override
  PhysicalCardsState createState() => PhysicalCardsState();
}

class PhysicalCardsState extends State<PhysicalCards> {
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
  String getBusinessAccountSummary = Queries.QUERY_BUSINESS_ACCOUNT_SUMMARY;
  String getUserAccountSummary = Queries.QUERY_USER_ACCOUNT_SUMMARY;
  String getRecentTransactions = Queries.QUERY_RECENT_TRANSACTIONS;

  int cardType = 0;

  handleCardType(type) {
    setState(() {
      cardType = type;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      cardType = widget.defaultType;
    });
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
                child: Column(children: [
              const CustomSpacer(size: 44),
              const CustomMainHeader(title: 'Physical Card'),
              const CustomSpacer(size: 38),
              cardGroupField(),
              cardType == 0 ? PhysicalMyCards() : PhysicalTeamCards(),
              const CustomSpacer(size: 88),
            ]))),
      ),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 1),
      )
    ])));
  }

  Widget backButton() {
    return Container(
      width: hScale(40),
      height: hScale(40),
      padding: EdgeInsets.zero,
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
      child: TextButton(
          style: TextButton.styleFrom(
            primary: const Color(0xff70828D),
            padding: const EdgeInsets.all(0),
          ),
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
            size: 12,
          ),
          onPressed: () async {
            // widget.controller.index = 0;
            // // Future.delayed(const Duration(seconds: 1), () {});
            // widget.navigatorKey.currentState!.popUntil((route) => route.isFirst);
          }),
    );
  }

  Widget cardGroupField() {
    return Container(
      width: wScale(327),
      height: hScale(40),
      padding: EdgeInsets.all(hScale(2)),
      decoration: BoxDecoration(
        color: const Color(0xfff5f5f6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(hScale(20)),
          topRight: Radius.circular(hScale(20)),
          bottomLeft: Radius.circular(hScale(20)),
          bottomRight: Radius.circular(hScale(20)),
        ),
      ),
      child: Row(children: [
        cardGroupButton('My Card', 0),
        cardGroupButton('Team Cards', 1),
      ]),
    );
  }

  Widget cardGroupButton(cardName, type) {
    return type == cardType
        ? Container(
            width: wScale(160),
            height: hScale(35),
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(260),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF040415).withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: TextButton(
                style: TextButton.styleFrom(
                  primary: const Color(0xFFFFFFFF),
                  padding: const EdgeInsets.all(0),
                ),
                child: Text(
                  cardName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: fSize(14), color: const Color(0xff1A2831)),
                ),
                onPressed: () {
                  handleCardType(type);
                }),
          )
        : TextButton(
            style: TextButton.styleFrom(
              primary: const Color(0xff70828D),
              padding: const EdgeInsets.all(0),
              textStyle: TextStyle(
                  fontSize: fSize(14), color: const Color(0xff70828D)),
            ),
            onPressed: () {
              handleCardType(type);
            },
            child: Container(
              width: wScale(160),
              height: hScale(35),
              alignment: Alignment.center,
              child: Text(
                cardName,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: fSize(14), color: const Color(0xff70828D)),
              ),
            ),
          );
  }
}

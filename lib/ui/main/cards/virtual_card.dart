import 'package:flexflutter/ui/main/cards/physical_team_card.dart';
import 'package:flexflutter/ui/main/cards/virtual_my_transaction.dart';
import 'package:flexflutter/ui/main/cards/virtual_team_card.dart';
import 'package:flexflutter/ui/widgets/custom_bottom_bar.dart';
import 'package:flexflutter/ui/widgets/custom_header.dart';
import 'package:flexflutter/ui/widgets/custom_main_header.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

class VirtualCards extends StatefulWidget {
  // final CupertinoTabController controller;
  // final GlobalKey<NavigatorState> navigatorKey;

  // const VirtualCards({Key? key,  required this.controller, required this.navigatorKey}) : super(key: key);
  const VirtualCards({Key? key}) : super(key: key);
  @override
  VirtualCardsState createState() => VirtualCardsState();
}

class VirtualCardsState extends State<VirtualCards> {

  hScale(double scale) {
    return Scale().hScale(context, scale);
  }
  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  int cardType = 1;

  handleBack() {
    DefaultTabController.of(context)!.animateTo(1);
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
            body: Stack(
                children:[
                  SingleChildScrollView(
                      child: Column(
                          children: [
                            const CustomSpacer(size: 44),
                            // Row(
                            //     children: [
                            //       SizedBox(width: wScale(20)),
                            //       backButton(),
                            //       SizedBox(width: wScale(20)),
                            //       Text('Virtual Cards', style: TextStyle(fontSize: fSize(20), fontWeight: FontWeight.w600))
                            //     ]
                            // ),
                            const CustomMainHeader(title: 'Virtual Cards'),
                            const CustomSpacer(size: 38),
                            cardGroupField(),
                            const CustomSpacer(size: 10),
                            cardType == 1 ? const VirtualMyTransactions() : cardType == 2 ? const VirtualTeamCards(): const PhysicalTeamCards(),
                            const CustomSpacer(size: 88),
                          ]
                      )
                  ),
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    child: CustomBottomBar(active: 11),
                  )
                ]
            )
        )
    );
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
          child: const Icon( Icons.arrow_back_ios_rounded, color: Colors.black, size: 12,),
          onPressed: () async {
            // widget.controller.index = 0;
            // // await Future.delayed(const Duration(seconds: 1), () {});
            // widget.navigatorKey.currentState!.popUntil((route) => route.isFirst);
          }),
    );
  }

  Widget cardGroupField() {
    return Container(
      width: wScale(327),
      height: hScale(46),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(
            children: [
              cardGroupButton('My Transactions', 1),
              cardGroupButton('My Cards', 2),
              cardGroupButton('Team Cards', 3),
            ]
        )
      )
    );
  }
  Widget cardGroupButton(cardName, type) {
    return type == cardType ?
    Container(
      width: wScale(130),
      height: hScale(35),
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(260),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 20,
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
                fontSize: fSize(14),
                color: const Color(0xff1A2831)),
          ),
          onPressed: () { handleCardType(type); }),
    ): TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff70828D),
        padding: const EdgeInsets.all(0),
        textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
      ),
      onPressed: () { handleCardType(type); },
      child: Container(
        width: wScale(130),
        height: hScale(35),
        alignment: Alignment.center,
        child: Text(
          cardName,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(14),
              color: const Color(0xff70828D)),
        ),
      ),
    );
  }

}
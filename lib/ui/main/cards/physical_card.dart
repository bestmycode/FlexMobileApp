import 'package:co/ui/main/cards/my_card.dart';
import 'package:co/ui/main/cards/physical_my_card.dart';
import 'package:co/ui/main/cards/physical_team_card.dart';
import 'package:co/ui/main/cards/team_card.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_no_internet.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
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

  int cardType = 0;
  bool noInternet = false;
  bool freezeMode = false;
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String getUserInfoQuery = Queries.QUERY_DASHBOARD_LAYOUT;

  handleCardType(type) {
    setState(() {
      cardType = type;
    });
  }

  setNoInternet() {
    setState(() {
      noInternet = true;
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
            child: Column(children: [
              const CustomSpacer(size: 40),
              const CustomMainHeader(title: 'Physical Card'),
              const CustomSpacer(size: 20),
              // cardGroupField(),
              // cardType == 0 ? PhysicalMyCards() : PhysicalTeamCards(),
              tabView(),
              const CustomSpacer(size: 88),
            ])),
      ),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 1),
      )
    ])));
  }

  Widget tabView() {
    return DefaultTabController(
      length: 2,
      child: Container(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
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
                child: TabBar(
                  unselectedLabelColor: const Color(0xff70828D),
                  labelPadding: const EdgeInsets.all(1),
                  labelStyle: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  labelColor: Color(0xff1A2831),
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(260),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF040415).withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset:
                            const Offset(0, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  indicatorPadding: const EdgeInsets.all(1),
                  indicatorWeight: 1,
                  tabs: [
                    Tab(
                      text: 'My Card',
                    ),
                    Tab(
                      text: 'Team Cards',
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: hScale(584),
              width: double.maxFinite,
              child: TabBarView(
                children: [PhysicalMyCards(), PhysicalTeamCards()],
              ),
            ),
          ],
        ),
      ),
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
            color: Color(0xFF106549).withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 10,
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

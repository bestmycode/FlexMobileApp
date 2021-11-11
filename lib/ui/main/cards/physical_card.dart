import 'package:flexflutter/ui/main/cards/physical_my_card.dart';
import 'package:flexflutter/ui/main/cards/physical_team_card.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

class PhysicalCards extends StatefulWidget {

  final CupertinoTabController controller;
  final GlobalKey<NavigatorState> navigatorKey;

  const PhysicalCards({Key? key, required this.controller, required this.navigatorKey}) : super(key: key);

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

  int cardType = 1;

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
            body: SingleChildScrollView(
                child: Column(
                    children: [
                      const CustomSpacer(size: 44),
                      Row(
                          children: [
                            SizedBox(width: wScale(20)),
                            IconButton(
                              icon: const Icon( Icons.arrow_back_ios_rounded, color: Colors.black, size: 20.0 ),
                              onPressed: () {
                                widget.controller.index = 0;
                                // Future.delayed(const Duration(seconds: 1), () {});
                                widget.navigatorKey.currentState!.popUntil((route) => route.isFirst);
                              }),
                            SizedBox(width: wScale(30)),
                            Text('Physical Card', style: TextStyle(fontSize: fSize(20), fontWeight: FontWeight.w600))
                          ]
                      ),
                      const CustomSpacer(size: 38),
                      cardGroupField(),
                      const CustomSpacer(size: 31),
                      cardType == 1 ? const PhysicalMyCards() : const PhysicalTeamCards(),
                      const CustomSpacer(size: 70),
                    ]
                )
            )
        )
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
      child: Row(
          children: [
            cardGroupButton('My Card', 1),
            cardGroupButton('Team Cards', 2),
          ]
      ),
    );
  }

  Widget cardGroupButton(cardName, type) {
    return type == cardType ?
    ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          primary: const Color(0xffffffff),
          side: const BorderSide(width: 0,color: Color(0xffffffff)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
        ),
        onPressed: () { handleCardType(type); },
        child: Container(
          width: wScale(160),
          height: hScale(35),
          alignment: Alignment.center,
          child: Text(
            cardName,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: fSize(14),
                color: const Color(0xff1A2831)),
          ),
        )
    ) : TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff70828D),
        padding: const EdgeInsets.all(0),
        textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
      ),
      onPressed: () { handleCardType(type); },
      child: Container(
        width: wScale(160),
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
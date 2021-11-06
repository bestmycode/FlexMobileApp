import 'package:flexflutter/ui/widgets/custom_header.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

class Cards extends StatefulWidget {
  const Cards({Key? key}) : super(key: key);

  @override
  CardsState createState() => CardsState();
}

class CardsState extends State<Cards> {

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
            body: Align(
                child: Column(
                    children: [
                      const CustomSpacer(size: 44),
                      const CustomHeader(title: 'Physical Card'),
                      const CustomSpacer(size: 38),
                      cardGroupField(),
                      const CustomSpacer(size: 31),
                      // cardField()
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
            cardGroupButton('Company Cards', 2),
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
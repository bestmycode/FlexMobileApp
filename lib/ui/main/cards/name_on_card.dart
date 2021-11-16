import 'dart:ui';

import 'package:flexflutter/ui/widgets/custom_bottom_bar.dart';
import 'package:flexflutter/ui/widgets/custom_header.dart';
import 'package:flexflutter/ui/widgets/custom_main_header.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flexflutter/ui/widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

class NameOnCard extends StatefulWidget {

  // final CupertinoTabController controller;
  // final GlobalKey<NavigatorState> navigatorKey;

  // const PhysicalCards({Key? key, required this.controller, required this.navigatorKey}) : super(key: key);

  const NameOnCard({Key? key}) : super(key: key);
  @override
  NameOnCardState createState() => NameOnCardState();
}

class NameOnCardState extends State<NameOnCard> {

  hScale(double scale) {
    return Scale().hScale(context, scale);
  }
  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final List<TextEditingController> _controller = List.generate(10, (i) => TextEditingController());

  handleSave() {

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
                            const CustomMainHeader(title: 'Preferred Name on Card'),
                            preferredNameOnCard(),
                            const CustomSpacer(size: 30),
                            buttonField(),
                            const CustomSpacer(size: 46),
                            const CustomSpacer(size: 88),
                          ]
                      )
                  ),
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    child: CustomBottomBar(active: 1),
                  )
                ]
            )
        )
    );
  }

  Widget preferredNameOnCard() {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(left: wScale(16), right: wScale(16), top: hScale(16), bottom: hScale(16)),
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
          Text('Preferred Name on Card', style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w600, color: const Color(0xFF1A2831))),
          const CustomSpacer(size: 22),
          customCardName(0, '11/16'),
          const CustomSpacer(size: 22),
          customCardName(1, '12/16'),
          const CustomSpacer(size: 22),
          customCardName(2, '11/16'),
          const CustomSpacer(size: 22),
          customCardName(3, '12/16'),
          const CustomSpacer(size: 22),
          customCardName(4, '11/16'),
          const CustomSpacer(size: 22),
          customCardName(5, '12/16'),
          const CustomSpacer(size: 22),
          customCardName(6, '11/16'),
          const CustomSpacer(size: 22),
          customCardName(7, '11/16'),
          const CustomSpacer(size: 22),
          customCardName(8, '12/16'),
          const CustomSpacer(size: 22),
          customCardName(9, '11/16'),
        ],
      ),
    );
  }

  Widget customCardName(index, rightText) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomTextField(ctl: _controller[index], hint: 'Enter Preferred Name', label: 'Preferred Name'),
        Positioned(
          right: 20,
          child: Text(rightText, style:TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w500))
          ),
      ],
    );
  }

  Widget buttonField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        backButton('Cancel'),
        saveButton('Save')
      ],
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
            ),
          ),
          onPressed: () { Navigator.of(context).pop(); },
          child: Text(
              title,
              style: TextStyle(color: Colors.black, fontSize: fSize(16), fontWeight: FontWeight.w700 )),
        )
    );
  }

  Widget saveButton(title) {
    return Container(
        width: wScale(156),
        height: hScale(56),
        margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
            ),
          ),
          onPressed: () { handleSave(); },
          child: Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: fSize(16), fontWeight: FontWeight.w700 )),
        )
    );
  }

}
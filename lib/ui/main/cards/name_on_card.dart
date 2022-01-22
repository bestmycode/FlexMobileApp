import 'dart:ui';

import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:flutter/services.dart';

class NameOnCard extends StatefulWidget {
  final cardNameHolders;
  const NameOnCard({Key? key, this.cardNameHolders}) : super(key: key);
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

  final List<TextEditingController> _controller =
      List.generate(20, (i) => TextEditingController());
  final List<int> _controllerLength = List.generate(20, (i) => 0);
  int type = 0;
  bool setAllSameName = false;

  handleSave() {
    if (type == 0) {
      setState(() {
        type = 1;
      });
    } else {
      var returnValue = [];
      widget.cardNameHolders.forEach((item) {
        returnValue.add(setAllSameName
            ? _controller[0].text
            : _controller[widget.cardNameHolders.indexOf(item)].text);
      });
      Navigator.pop(context, returnValue);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Container(
                height: hScale(812),
                child: Stack(children: [
                  SingleChildScrollView(
                      child: Column(children: [
                    const CustomSpacer(size: 44),
                    const CustomMainHeader(title: 'Preferred Name on Card'),
                    const CustomSpacer(size: 16),
                    setAllSameNameField(),
                    const CustomSpacer(size: 16),
                    preferredNameOnCard(),
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
                ]))));
  }

  Widget preferredNameOnCard() {
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
            Text('Preferred Name on Card',
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A2831))),
            setAllSameName ? CustomSpacer(size: 16) : SizedBox(),
            setAllSameName
                ? type == 0
                    ? customCardName(0, 'Card Name')
                    : customSavedCardName(0)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.cardNameHolders.map<Widget>((item) {
                      return Column(children: [
                        const CustomSpacer(size: 22),
                        type == 0
                            ? customCardName(
                                widget.cardNameHolders.indexOf(item), item)
                            : customSavedCardName(
                                widget.cardNameHolders.indexOf(item)),
                      ]);
                    }).toList())
          ],
        ));
  }

  Widget customCardName(index, item) {
    var rightText = "${item.length}/20";
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomTextField(
            ctl: _controller[index]..text = item,
            inputFormatters: [
              LengthLimitingTextInputFormatter(20),
            ],
            hint: 'Enter Card Name',
            label: item),
        Positioned(
            right: 20,
            child: Text(rightText,
                style: TextStyle(
                    fontSize: fSize(14), fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget customSavedCardName(index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_controller[index].text,
            style: TextStyle(
                fontSize: fSize(14),
                fontWeight: FontWeight.w500,
                color: Color(0xFF040415).withOpacity(0.4))),
        CustomSpacer(size: hScale(8)),
        Text(_controller[index].text,
            style: TextStyle(
                fontSize: fSize(16),
                fontWeight: FontWeight.w500,
                color: Color(0xFF040415))),
      ],
    );
  }

  Widget buttonField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        backButton('Cancel'),
        saveButton(type == 0 ? 'Save' : 'Confirm')
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            if (type == 0) {
              Navigator.pop(context, "hello");
            } else {
              setState(() {
                type = 0;
              });
            }
          },
          child: Text(title,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            handleSave();
          },
          child: Text(title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget setAllSameNameField() {
    return Container(
        width: wScale(327),
        child: TextButton(
          style: TextButton.styleFrom(
            primary: const Color(0xFFFFFFFF),
            padding: const EdgeInsets.all(0),
          ),
          child: Row(
            children: [
              SizedBox(
                  width: hScale(28),
                  height: hScale(28),
                  child: Transform.scale(
                    scale: 1,
                    child: Checkbox(
                      value: setAllSameName,
                      activeColor: const Color(0xff30E7A9),
                      onChanged: (value) {
                        setState(() {
                          setAllSameName = value!;
                        });
                      },
                    ),
                  )),
              Text('Apply same card name for ',
                  style: TextStyle(
                      fontSize: fSize(16), color: const Color(0xFF515151))),
              Text('all cardholders.',
                  style: TextStyle(
                      fontSize: fSize(16),
                      color: const Color(0xFF515151),
                      fontWeight: FontWeight.bold)),
            ],
          ),
          onPressed: () {
            setState(() {
              setAllSameName = !setAllSameName;
            });
          },
        ));
  }
}

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
  final initType;
  final cardType; //0: virtual 1: physical
  const NameOnCard(
      {Key? key, this.cardNameHolders, this.initType = 0, this.cardType = 0})
      : super(key: key);
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
  final List<bool> _isControllerEmpty = List.generate(20, (i) => false);
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
            ? {"id": item["id"], "name": _controller[0].text}
            : {
                "id": item["id"],
                "name": _controller[widget.cardNameHolders.indexOf(item)].text
              });
      });
      Navigator.pop(context, returnValue);
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      type = widget.initType;
      widget.cardNameHolders.forEach((item) {
        _controller[widget.cardNameHolders.indexOf(item)].text = item['name'];
        _controllerLength[widget.cardNameHolders.indexOf(item)] =
            item['name'].length;
      });
    });
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
                    CustomMainHeader(
                        title: widget.cardType == 0
                            ? 'Issue Virtual Card'
                            : 'Preferred Name on Card'),
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
            Text('Name on Card',
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A2831))),
            const CustomSpacer(size: 16),
            widget.cardType == 0
                ? type == 0
                    ? setAllSameNameField()
                    : SizedBox()
                : preferredCardDetail(),
            setAllSameName ? CustomSpacer(size: 16) : SizedBox(),
            setAllSameName
                ? type == 0
                    ? customCardName(0, '')
                    : customSavedCardName(0)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.cardNameHolders.map<Widget>((item) {
                      return Column(children: [
                        const CustomSpacer(size: 22),
                        type == 0
                            ? customCardName(
                                widget.cardNameHolders.indexOf(item),
                                item['name'])
                            : customSavedCardName(
                                widget.cardNameHolders.indexOf(item)),
                      ]);
                    }).toList())
          ],
        ));
  }

  Widget customCardName(index, item) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomTextField(
          ctl: _controller[index],
          inputFormatters: [
            LengthLimitingTextInputFormatter(20),
          ],
          hint: 'Enter Card Name',
          label: item == "" ? "Card Name" : item,
          onChanged: (text) {
            setState(() {
              _isControllerEmpty[index] = text.length == 0 ? true : false;
              _controllerLength[index] = text.length;
            });
          },
        ),
        Positioned(
            right: 20,
            child: Text("${_controllerLength[index]}/20",
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
            primary: const Color(0xff1A2831).withOpacity(0.1),
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
    bool isEmptyName = false;
    // _isControllerEmpty.forEach((e) {
    //   if (e) isEmptyName = true;
    // });
    // if (setAllSameName) isEmptyName = _isControllerEmpty[0];
    return Opacity(
        opacity: isEmptyName ? 0.5 : 1,
        child: Container(
            width: wScale(156),
            height: hScale(56),
            margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                primary: const Color(0xff1A2831),
                side: const BorderSide(width: 0, color: Color(0xff1A2831)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                isEmptyName ? null : handleSave();
              },
              child: Text(title,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fSize(16),
                      fontWeight: FontWeight.w700)),
            )));
  }

  Widget setAllSameNameField() {
    return Container(
        width: wScale(327),
        // padding: EdgeInsets.only(left: wScale(10)),
        child: TextButton(
          style: TextButton.styleFrom(
            primary: const Color(0xFFFFFFFF),
            padding: const EdgeInsets.all(0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          if (setAllSameName) {
                            _controller[0].text = "";
                            _isControllerEmpty[0] = true;
                          }
                        });
                      },
                    ),
                  )),
              Container(
                  width: wScale(264),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        height: 1.5,
                        fontSize: hScale(16),
                        color: Color(0xFF515151),
                      ),
                      children: [
                        TextSpan(text: 'Apply same card name for '),
                        TextSpan(
                            text: 'all cardholders.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  )),
            ],
          ),
          onPressed: () {
            setState(() {
              setAllSameName = !setAllSameName;
              if (setAllSameName) {
                _controller[0].text = "";
                _isControllerEmpty[0] = true;
              }
            });
          },
        ));
  }

  Widget preferredCardDetail() {
    return Container(
        width: wScale(327),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: fSize(16),
              color: Color(0xFF515151),
            ),
            children: const [
              TextSpan(
                  text:
                      '*Preferred Name will appear in uppercase on your card.'),
            ],
          ),
        ));
  }
}

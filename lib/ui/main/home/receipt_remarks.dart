// ignore_for_file: prefer_const_constructors

import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

class ReceiptRemarks extends StatefulWidget {
  const ReceiptRemarks({Key? key}) : super(key: key);

  @override
  ReceiptRemarksState createState() => ReceiptRemarksState();
}

class ReceiptRemarksState extends State<ReceiptRemarks> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  bool flagRemarks = false;
  var remarkArr = [
    {
      'name': 'John Tan',
      'date': '20 Dec 2021 | 8:40 PM',
      'detail':
          'I think we need to lorem ipsum dolor sit \namet, consectetur adipiscing elit, sed do \neiusmod tempor incididunt?'
    }
  ];

  handleAddRemark() {
    setState(() {
      flagRemarks = true;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return flagRemarks == false ? emptyRemarkField() : remarkField();
  }

  Widget emptyRemarkField() {
    return Column(children: [
      const CustomSpacer(size: 46),
      Text('No Remarks!',
          style: TextStyle(
              fontSize: fSize(12),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF70828D))),
      const CustomSpacer(size: 400),
      addRemarkButton()
    ]);
  }

  Widget remarkField() {
    return Column(
        children: remarkArr.map<Widget>((item) {
      return remarkDetail(item['name'], item['date'], item['detail']);
    }).toList());
  }

  Widget remarkDetail(name, date, detail) {
    return Container(
        width: wScale(327),
        margin: EdgeInsets.only(top: hScale(15)),
        padding:
            EdgeInsets.symmetric(horizontal: wScale(18), vertical: hScale(26)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2831))),
            CustomSpacer(size: 6),
            Text(date,
                style: TextStyle(
                    fontSize: fSize(10),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF29C490))),
            CustomSpacer(size: 20),
            Text(detail,
                style: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF70828D))),
          ],
        ));
  }

  Widget addRemarkButton() {
    return SizedBox(
        width: wScale(295),
        height: hScale(56),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            handleAddRemark();
          },
          child: Text("Add Remarks",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }
}

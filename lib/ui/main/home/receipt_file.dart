import 'dart:io';

import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class ReceiptFile extends StatefulWidget {
  const ReceiptFile({Key key}) : super(key: key);

  // final File imageFile;
  // const ReceiptFile({Key key, this.imageFile}) : super(key: key);

  @override
  ReceiptFileState createState() => ReceiptFileState();
}

class ReceiptFileState extends State<ReceiptFile> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [const CustomSpacer(size: 30), imageField()]);
  }

  Widget imageField() {
    return Stack(
      overflow: Overflow.visible,
      children: [
        Container(
            width: wScale(301),
            height: hScale(519),
            margin: EdgeInsets.only(right: wScale(27)),
            decoration: const BoxDecoration(
                color: Color(0xFFF9F9F9),
                image: DecorationImage(
                    image: AssetImage('assets/img_bill_scanned.png'),
                    fit: BoxFit.cover))),
        Positioned(
            top: wScale(-17),
            right: wScale(8),
            child: Column(
              children: [
                handleButton(0),
                const CustomSpacer(size: 12),
                handleButton(1),
              ],
            ))
      ],
    );
  }

  Widget handleButton(type) {
    return Container(
        width: wScale(35),
        height: wScale(35),
        padding: EdgeInsets.all(wScale(8)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(hScale(8)),
          color: type == 0 ? const Color(0xffFFF2F2) : Colors.white,
        ),
        child: TextButton(
            style: TextButton.styleFrom(
              primary: const Color(0xff29c490),
              padding: const EdgeInsets.all(0),
            ),
            onPressed: () {},
            child: Image.asset(
              type == 0 ? 'assets/red_delete.png' : 'assets/green_download.png',
              fit: BoxFit.contain,
              width: wScale(20),
            )));
  }
}

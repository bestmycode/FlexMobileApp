import 'package:co/ui/main/home/receipt_details.dart';
import 'package:co/ui/main/home/receipt_file.dart';
import 'package:co/ui/main/home/receipt_remarks.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/scale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ReceiptTransactionType extends StatefulWidget {
  final data;
  final accountID;
  final transactionID;
  final initTransactionType;
  const ReceiptTransactionType(
      {Key? key, this.data, this.accountID, this.transactionID, this.initTransactionType})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ReceiptTransactionType();
  }
}

class _ReceiptTransactionType extends State<ReceiptTransactionType> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  int transactionType = 1;
  bool isRemoved = false;

  handleRemoved() {
    setState(() {
      isRemoved = true;
    });
  }

  handleTransactionType(type) {
    setState(() {
      transactionType = type;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      transactionType = widget.initTransactionType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: wScale(24)),
        child: Column(
          children: [
            transactionTypeField(),
            transactionType == 1
                ? ReceiptFile(data: widget.data, isRemoved: isRemoved, handleRemoved: handleRemoved)
                : transactionType == 2
                    ? ReceiptDetails(data: widget.data)
                    : ReceiptRemarks(data: widget.data['remarkData'], sourceTransactionId: widget.data['sourceTransactionId'], accountID: widget.accountID, transactionID: widget.transactionID),
            const CustomSpacer(size: 15),
            const CustomSpacer(size: 88),
          ],
        ));
  }

  Widget transactionTypeField() {
    return Container(
      alignment: Alignment.topCenter,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        activeButton('Receipt File', 1),
        activeButton('Details', 2),
        activeButton('Remarks', 3),
      ]),
    );
  }

  Widget activeButton(title, type) {
    return Container(
      width: wScale(102),
      height: hScale(36),
      // padding: EdgeInsets.only(left: wScale(6),right: wScale(6)),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: type == transactionType
                      ? const Color(0xFF29C490)
                      : const Color(0xFFEEEEEE),
                  width: type == transactionType ? hScale(2) : hScale(1)))),
      alignment: Alignment.center,
      child: TextButton(
        style: TextButton.styleFrom(
          primary: const Color(0xff70828D),
          padding: const EdgeInsets.all(0),
        ),
        onPressed: () {
          handleTransactionType(type);
        },
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(12),
              fontWeight: FontWeight.w600,
              color: type == transactionType
                  ? const Color(0xff1A2831)
                  : const Color(0xFF70828D)),
        ),
      ),
    );
  }
}

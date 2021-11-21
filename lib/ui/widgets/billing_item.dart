// ignore: file_names
// ignore: file_names

import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

class BillingItem extends StatefulWidget {
  final String statementDate;
  final String totalAmount;
  final String dueDate;
  final int status; // 0: unpaid, 1: overdue, 2: paid

  const BillingItem({Key? key,
    this.statementDate='30 Jan 2021',
    this.totalAmount='0.00',
    this.dueDate='05 Mar 2021',
    this.status = 0,
  }) : super(key: key);
  @override
  BillingItemState createState() => BillingItemState();

}

class BillingItemState extends State<BillingItem> {

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
  Widget build(BuildContext context) {
    return Container(
      width: wScale(327),
      // padding: EdgeInsets.only(left: wScale(16), right: wScale(16), top: hScale(16), bottom: hScale(16)),
      margin: EdgeInsets.only(bottom: hScale(16)),
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
          children: [
            detailField('Statement Date', widget.statementDate, const Color(0xFF1A2831)),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            amountDetailField('Total Amount', widget.totalAmount, widget.status == 1 ? const Color(0xFFEB5757): const Color(0xFF1A2831)),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            detailField('Due Date', widget.dueDate, widget.status == 1 ? const Color(0xFFEB5757): const Color(0xFF1A2831)),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            statusField(widget.status),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            downloadField()
          ]
      ),
    );
  }

  Widget detailField(title, value, valueColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: hScale(6), horizontal: wScale(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w500, color: Color(0xFF70828D), height: 1.7)),
          Text(value, style: TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w500,color: valueColor),)
        ],
      ),
    );
  }

  Widget amountDetailField(title, value, valueColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: hScale(6), horizontal: wScale(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w500, color: const Color(0xFF70828D), height: 1.7)),
          Row(
            children: [
              Text('SGD ', style: TextStyle(fontSize: fSize(8), fontWeight: FontWeight.w500,color: valueColor, height: 1.2)),
              Text(value, style: TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w500,color: valueColor))
            ],
          )

        ],
      ),
    );
  }

  Widget statusField(status) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: hScale(6), horizontal: wScale(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF70828D))),
          Container(
            padding: EdgeInsets.symmetric(vertical: hScale(4), horizontal: wScale(11)),
            // color: status == 0 ? const Color(0xFFC9E8FB) : status == 1 ? const Color(0xFFFFDFD4): const Color(0xFFE1FFEF),
            decoration: BoxDecoration(
              color: status == 0 ? const Color(0xFFC9E8FB) : status == 1 ? const Color(0xFFFFDFD4): const Color(0xFFE1FFEF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(hScale(100)),
                topRight: Radius.circular(hScale(100)),
                bottomLeft: Radius.circular(hScale(100)),
                bottomRight: Radius.circular(hScale(100)),
              ),
            ),
            child: Text(
              status == 0 ? 'Unpaid' : status == 1 ? 'Overdue': 'Paid',
              style: TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w500,
                color: status == 0 ? const Color(0xFF2F7BFA) : status == 1 ? const Color(0xFFEB5757): const Color(0xFF2ED47A),),
            ),
          )
          // Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,color: valueColor),)
        ],
      ),
    );
  }

  Widget downloadField() {
    return TextButton(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: hScale(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset( 'assets/paper_download.png', fit: BoxFit.cover, width: wScale(10)),
            SizedBox(width: wScale(8)),
            const Text('Statement Download', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1DA7FF))),
          ],
        )
      ),
      onPressed: () { }
    );
  }

}

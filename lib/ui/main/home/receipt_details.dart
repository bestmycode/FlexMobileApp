// ignore_for_file: prefer_const_constructors

import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:intl/intl.dart';

class ReceiptDetails extends StatefulWidget {
  final data;
  const ReceiptDetails({Key? key, this.data}) : super(key: key);

  @override
  ReceiptDetailsState createState() => ReceiptDetailsState();
}

class ReceiptDetailsState extends State<ReceiptDetails> {
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
    return Column(children: [
      const CustomSpacer(size: 15),
      transactionDetail(),
    ]);
  }

  Widget transactionDetail() {
    return Column(
      children: [
        titleField('assets/green_transaction.png', 'Transaction Details'),
        SizedBox(height: hScale(10)),
        detailField(0),
        SizedBox(height: hScale(20)),
        titleField('assets/invite_user.png', 'User Details'),
        SizedBox(height: hScale(10)),
        detailField(1),
        SizedBox(height: hScale(20)),
        widget.data['receiptData']['uploadedAt'] == null
            ? SizedBox()
            : titleField('assets/paper.png', 'Receipt Details'),
        widget.data['receiptData']['uploadedAt'] == null
            ? SizedBox()
            : SizedBox(height: hScale(10)),
        widget.data['receiptData']['uploadedAt'] == null
            ? SizedBox()
            : detailField(2),
      ],
    );
  }

  Widget titleField(image, title) {
    return Row(
      children: [
        Image.asset(
          image,
          fit: BoxFit.contain,
          width: wScale(24),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
              fontSize: fSize(14),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2831)),
        )
      ],
    );
  }

  Widget detailField(type) {
    return Container(
        width: wScale(327),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF106549).withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 10,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: type == 0
            ? transactionDetailField()
            : type == 1
                ? userDetailField()
                : receiptDetailField());
  }

  Widget transactionDetailField() {
    return Column(
      children: [
        detail(
            'Purchased On',
            DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(
                widget.data['transactionDate']))),
        Container(height: 1, color: Color(0xFFF1F1F1)),
        detail('Description', widget.data['description']),
        Container(height: 1, color: Color(0xFFF1F1F1)),
        detail('Amount',
            "${widget.data['fxrBillAmount'].toStringAsFixed(2)} ${widget.data['billCurrency']}"),
        Container(height: 1, color: Color(0xFFF1F1F1)),
        detail('Merchant Name', "${widget.data['merchantName']}"),
        Container(height: 1, color: Color(0xFFF1F1F1)),
        statusDetail('Status', widget.data['status'])
      ],
    );
  }

  Widget userDetailField() {
    return Column(
      children: [
        detail('Name', widget.data['userName']),
        Container(height: 1, color: Color(0xFFF1F1F1)),
        detail('Payment Method', widget.data['paymentMethod']),
        Container(height: 1, color: Color(0xFFF1F1F1)),
        detail('Card Number',
            "************${widget.data['pan'].split('******')[1]}"),
      ],
    );
  }

  Widget receiptDetailField() {
    String date =
        "${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(widget.data['receiptData']['uploadedAt']))}  |  ${DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(widget.data['receiptData']['uploadedAt']))}";
    String name = widget.data['receiptData']['uploadedByName'];
    return Column(
      children: [
        detail('Uploaded by', name),
        Container(height: 1, color: Color(0xFFF1F1F1)),
        detail('Uploaded on', date),
      ],
    );
  }

  Widget detail(title, value) {
    return Padding(
        padding:
            EdgeInsets.symmetric(horizontal: wScale(16), vertical: hScale(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF70828D))),
            SizedBox(
                width: wScale(189),
                child: Text(value,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: fSize(12),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A2831))))
          ],
        ));
  }

  Widget statusDetail(title, value) {
    return Padding(
        padding:
            EdgeInsets.symmetric(horizontal: wScale(16), vertical: hScale(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF70828D))),
            Container(
                padding: EdgeInsets.symmetric(
                    vertical: hScale(4), horizontal: wScale(8)),
                decoration: BoxDecoration(
                  color: Color(0xFFE1FFEF),
                  borderRadius: BorderRadius.all(const Radius.circular(100)),
                ),
                child: Text(value,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: fSize(12),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2ED47A))))
          ],
        ));
  }
}

import 'package:co/ui/main/home/receipt_capture.dart';
import 'package:co/ui/main/home/receipt_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class TransactionItem extends StatefulWidget {
  final String? accountId;
  final String? transactionId;
  final String date;
  final String transactionName;
  final String subTransactionName;
  final String status;
  final String userName;
  final String cardNum;
  final String value;
  final int receiptStatus;
  final bool mobileVerified;

  const TransactionItem(
      {Key? key,
      this.accountId,
      this.transactionId,
      this.date = '9 Nov 2021',
      this.transactionName = 'Flex Transaction Name',
      this.subTransactionName = '',
      this.status = 'complete',
      this.userName = 'Justin Curtis',
      this.cardNum = '0000',
      this.value = '0.00',
      this.receiptStatus = 0,
      this.mobileVerified = true})
      : super(key: key);
  @override
  TransactionItemState createState() => TransactionItemState();
}

class TransactionItemState extends State<TransactionItem> {
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
    print(widget.subTransactionName);
    return Container(
        width: wScale(327),
        padding: EdgeInsets.all(hScale(16)),
        margin: EdgeInsets.only(bottom: hScale(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              spreadRadius: 4,
              blurRadius: 20,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: wScale(270),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    transactionTimeField(widget.date),
                    transactionStatus(widget.transactionName, widget.status),
                    widget.subTransactionName != "" ? transactionStatus('', widget.subTransactionName): SizedBox(),
                    transactionUser(widget.userName, widget.cardNum),
                    moneyValue(
                        '',
                        widget.value,
                        14.0,
                        FontWeight.w700,
                        widget.status != 4 && double.parse(widget.value) >= 0
                            ? const Color(0xff60C094)
                            : const Color(0xFF1A2831)),
                  ],
                )),
            SizedBox(
                width: wScale(16),
                height: hScale(18),
                child: widget.receiptStatus == 0
                    ? SizedBox()
                    : widget.receiptStatus == 1
                        ? TextButton(
                            style: TextButton.styleFrom(
                                primary: const Color(0xffffffff),
                                padding: const EdgeInsets.all(0)),
                            onPressed: () {
                              widget.mobileVerified ? Navigator.of(context).push(CupertinoPageRoute(
                                  builder: (context) => ReceiptCapture(
                                      accountID: widget.accountId,
                                      transactionID: widget.transactionId))): null;
                            },
                            child: Image.asset('assets/add_transaction.png',
                                fit: BoxFit.contain, width: wScale(16)))
                        : TextButton(
                            style: TextButton.styleFrom(
                                primary: const Color(0xffffffff),
                                padding: const EdgeInsets.all(0)),
                            onPressed: () {
                              widget.mobileVerified ? Navigator.of(context).push(CupertinoPageRoute(
                                  builder: (context) => ReceiptScreen(
                                      accountID: widget.accountId,
                                      transactionID: widget.transactionId))): null;
                            },
                            child: Image.asset('assets/check_transaction.png',
                                fit: BoxFit.contain, width: wScale(16))))
          ],
        ));
  }

  Widget transactionTimeField(date) {
    return Text(date,
        style: TextStyle(
            fontSize: fSize(10),
            fontWeight: FontWeight.w500,
            color: const Color(0xff70828D)));
  }

  Widget transactionStatus(name, status) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fSize(16),
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        children: [
          TextSpan(text: name),
          TextSpan(
            text: status == '' ? '' : ' (${status == "FCA_APPROVED" ? "PENDING" : status})',
            style: TextStyle(
                fontSize: fSize(12),
                fontStyle: FontStyle.italic,
                color: const Color(0xFF70828D)),
          ),
        ],
      ),
    );
  }

  Widget transactionUser(name, cardNum) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fSize(12),
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        children: [
          TextSpan(text: name),
          TextSpan(
            text: cardNum == '' || cardNum == null ? '' : ' ($cardNum) ',
            style: const TextStyle(color: Color(0xff70828D)),
          ),
        ],
      ),
    );
  }

  Widget moneyValue(title, value, size, weight, color) {
    return SizedBox(
        width: wScale(263),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title,
                style: TextStyle(fontSize: fSize(12), color: Colors.white)),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("SGD  ",
                  style: TextStyle(
                      fontSize: fSize(12),
                      fontWeight: weight,
                      color: color,
                      height: 1)),
              Text(value,
                  style: TextStyle(
                      fontSize: fSize(size),
                      fontWeight: weight,
                      color: color,
                      height: 1,
                      decoration: widget.status == 4
                          ? TextDecoration.lineThrough
                          : TextDecoration.none)),
            ])
          ],
        ));
  }
}

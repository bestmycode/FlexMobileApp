import 'package:co/ui/main/home/receipt_capture.dart';
import 'package:co/ui/main/home/receipt_screen.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:timezone/standalone.dart' as tz;

class TransactionItem extends StatefulWidget {
  final String whichTab;
  final String? accountId;
  final String? transactionId;
  final int date;
  final String transactionName;
  final String subTransactionName;
  final String status;
  final String userName;
  final String cardNum;
  final int receiptStatus;
  final bool mobileVerified;
  final String qualifiers;
  final String transactionType;
  final billCurrency;
  final fxrBillAmount;
  final transactionCurrency;
  final transactionAmount;

  const TransactionItem(
      {Key? key,
      this.whichTab = "",
      this.accountId,
      this.transactionId,
      this.date = 0,
      this.transactionName = 'Flex Transaction Name',
      this.subTransactionName = '',
      this.status = 'complete',
      this.userName = 'Justin Curtis',
      this.cardNum = '0000',
      this.transactionType = "",
      this.qualifiers = "",
      this.billCurrency,
      this.fxrBillAmount,
      this.transactionCurrency,
      this.transactionAmount,
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

  final LocalStorage userStorage = LocalStorage('user_info');

  convertLocalToDetroit() {
    final detroit = tz.getLocation(userStorage.getItem("org_timezone"));
    final localizedDt = tz.TZDateTime.from(
        DateTime.fromMillisecondsSinceEpoch(widget.date), detroit);
    return '${DateFormat.yMMMd().format(localizedDt)}  |  ${DateFormat('hh:mm a').format(localizedDt)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: wScale(327),
        padding: EdgeInsets.all(hScale(16)),
        margin: EdgeInsets.only(bottom: hScale(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF106549).withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 10,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: wScale(277),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    transactionTimeField(convertLocalToDetroit()),
                    CustomSpacer(size: 5),
                    transactionStatus(widget.transactionName, widget.status),
                    CustomSpacer(size: 5),
                    widget.subTransactionName != ""
                        ? transactionStatus('', widget.subTransactionName)
                        : SizedBox(),
                    transactionUser(widget.userName, widget.cardNum),
                    CustomSpacer(size: 10),
                    widget.status == "COMPLETED"
                        ? completedMoneyValue(
                            widget.fxrBillAmount,
                            widget.billCurrency,
                            -1 * widget.transactionAmount,
                            widget.transactionCurrency,
                            double.parse(widget.fxrBillAmount.toString()) >= 0
                                ? 0xff60C094
                                : 0xFF1A2831,
                          )
                        : moneyValue(
                            widget.billCurrency == null
                                ? widget.fxrBillAmount
                                : widget.transactionCurrency ==
                                        widget.billCurrency
                                    ? widget.fxrBillAmount
                                    : -1 * widget.transactionAmount,
                            double.parse(widget.fxrBillAmount.toString()) >= 0
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
                        // ? TextButton(
                        //     style: TextButton.styleFrom(
                        //         primary: const Color(0xffffffff),
                        //         padding: const EdgeInsets.all(0)),
                        //     onPressed: () {
                        //       widget.mobileVerified
                        //           ? Navigator.of(context).push(
                        //               CupertinoPageRoute(
                        //                   builder: (context) => ReceiptCapture(
                        //                       accountID: widget.accountId,
                        //                       transactionID:
                        //                           widget.transactionId)))
                        //           : null;
                        //     },
                        //     child: Image.asset('assets/add_transaction.png',
                        //         fit: BoxFit.contain, width: wScale(16)))
                        ? SizedBox()
                        : TextButton(
                            style: TextButton.styleFrom(
                                primary: const Color(0xffffffff),
                                padding: const EdgeInsets.all(0)),
                            onPressed: () {
                              widget.mobileVerified
                                  ? Navigator.of(context).push(
                                      CupertinoPageRoute(
                                          builder: (context) => ReceiptScreen(
                                              accountID: widget.accountId,
                                              transactionID:
                                                  widget.transactionId)))
                                  : null;
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
    var status_text = widget.qualifiers != ""
        ? widget.qualifiers.indexOf("=") >= 0
            ? ' (${widget.qualifiers.split("=")[1]})'
            : ' (${widget.qualifiers})'
        : status == ''
            ? ''
            : status == "COMPLETED" &&
                    widget.transactionType == "FINANCIAL_REVERSAL"
                ? " (Reversal)"
                : status == "COMPLETED" &&
                        widget.transactionType == "FINANCIAL_REFUND"
                    ? " (Refund)"
                    : ' (${status == "FCA_APPROVED" ? widget.transactionType == "FCA_AUTHORIZATION_REVERSAL" ? "UNBILLED" : "PENDING" : status == "APPROVED" ? widget.transactionType == "FCA_AUTHORIZATION_REVERSAL" ? "UNBILLED" : "PENDING" : status})';
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
                width: wScale(" (${widget.whichTab.toLowerCase()})" !=
                        status_text.toLowerCase()
                    ? 170
                    : 255),
                child: Text(name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: fSize(16),
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ))),
            SizedBox(width: wScale(20)),
            " (${widget.whichTab.toLowerCase()})" !=
                        status_text.toLowerCase() &&
                    !(widget.qualifiers != "" &&
                        widget.qualifiers.indexOf("=") < 0)
                ? Text(status_text,
                    style: TextStyle(
                        fontSize: fSize(12),
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF70828D)))
                : SizedBox(),
          ],
        ),
        widget.qualifiers != "" && widget.qualifiers.indexOf("=") < 0
            ? Text(status_text,
                style: TextStyle(
                    fontSize: fSize(12),
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF70828D)))
            : SizedBox()
      ],
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
            text: cardNum == '' || cardNum == null
                ? ''
                : ' (**** **** **** ${cardNum.substring(cardNum.length - 4, cardNum.length)})',
            style: const TextStyle(color: Color(0xff70828D)),
          ),
        ],
      ),
    );
  }

  Widget moneyValue(value, color) {
    return SizedBox(
        width: wScale(263),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("${widget.transactionCurrency}  ",
                  style: TextStyle(
                      fontSize: fSize(12),
                      fontWeight: FontWeight.w700,
                      color: color,
                      height: 1)),
              Text("${value.toStringAsFixed(2)}",
                  style: TextStyle(
                      fontSize: fSize(14),
                      fontWeight: FontWeight.w700,
                      color: color,
                      height: 1,
                      decoration: widget.qualifiers != ''
                          ? TextDecoration.lineThrough
                          : TextDecoration.none)),
            ])
          ],
        ));
  }

  Widget completedMoneyValue(value1, currency1, value2, currency2, color) {
    return SizedBox(
        width: wScale(263),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("${currency1}  ",
                      style: TextStyle(
                          fontSize: fSize(12),
                          fontWeight: FontWeight.w700,
                          color: Color(color),
                          height: 1)),
                  Text("${value1.toStringAsFixed(2)}",
                      style: TextStyle(
                          fontSize: fSize(14),
                          fontWeight: FontWeight.w700,
                          color: Color(color),
                          height: 1,
                          decoration: widget.qualifiers != ''
                              ? TextDecoration.lineThrough
                              : TextDecoration.none)),
                ]),
                SizedBox(width: wScale(currency1 != currency2 ? 6 : 0)),
                currency1 != currency2
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text("${currency2}  ",
                                style: TextStyle(
                                    fontSize: fSize(12),
                                    fontWeight: FontWeight.w700,
                                    color: Color(color).withOpacity(0.5),
                                    height: 1)),
                            Text("${value2.toStringAsFixed(2)}",
                                style: TextStyle(
                                    fontSize: fSize(14),
                                    fontWeight: FontWeight.w700,
                                    color: Color(color).withOpacity(0.5),
                                    height: 1,
                                    decoration: widget.qualifiers != ''
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none)),
                          ])
                    : SizedBox()
              ],
            )
          ],
        ));
  }
}

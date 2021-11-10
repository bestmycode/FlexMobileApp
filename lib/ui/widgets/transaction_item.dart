// ignore: file_names
// ignore: file_names

import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

class TransactionItem extends StatefulWidget {
  final String date;
  final String time;
  final String transactionName;
  final String status;
  final String userName;
  final String cardNum;
  final String value;

  const TransactionItem({Key? key,
    this.date='9 Nov 2021',
    this.time='12:00 AM',
    this.transactionName='Flex Transaction Name',
    this.status = 'Deposit',
    this.userName = 'Justin Curtis',
    this.cardNum = '0000',
    this.value = '0.00'
  }) : super(key: key);
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
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(left: wScale(16), right: wScale(16), top: hScale(16), bottom: hScale(16)),
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          transactionTimeField(widget.date, widget.time),
          transactionStatus(widget.transactionName, widget.status),
          transactionUser(widget.userName, widget.cardNum),
          moneyValue('', widget.value, 14.0, FontWeight.w700, const Color(0xffADD2C8)),
        ],
      ),
    );
  }

  Widget transactionTimeField(date, time) {
    return Text('$date  |  $time',
        style: TextStyle(fontSize: fSize(10), fontWeight: FontWeight.w500, color: const Color(0xff70828D)));
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
          TextSpan(text: ' ($status)', style: TextStyle(fontSize: fSize(12), fontStyle: FontStyle.italic),),
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
          TextSpan(text: ' (**** **** **** $cardNum)', style: const TextStyle(color: Color(0xff70828D)),),
        ],
      ),
    );
  }

  Widget moneyValue(title, value, size, weight, color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
            title,
            style: TextStyle(fontSize: fSize(12), color: Colors.white)),
        Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Text("SGD  ",
                  style: TextStyle(fontSize: fSize(12), fontWeight: weight, color: color)),
              Text(value,
                  style: TextStyle(fontSize: fSize(size), fontWeight: weight, color: color)),
            ]
        )
      ],
    );
  }
}

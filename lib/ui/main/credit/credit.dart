import 'package:flexflutter/ui/widgets/billing_item.dart';
import 'package:flexflutter/ui/widgets/custom_bottom_bar.dart';
import 'package:flexflutter/ui/widgets/custom_header.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flexflutter/ui/widgets/transaction_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

import 'credit_payment.dart';

class CreditScreen extends StatefulWidget {

  // final CupertinoTabController controller;
  // final GlobalKey<NavigatorState> navigatorKey;
  // const Credit({Key? key, required this.controller, required this.navigatorKey}) : super(key: key);
  const CreditScreen({Key? key}) : super(key: key);

  @override
  CreditScreenState createState() => CreditScreenState();
}

class CreditScreenState extends State<CreditScreen> {

  hScale(double scale) {
    return Scale().hScale(context, scale);
  }
  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }
  int FPL_enhancement = 1; // 1: active, 2: suspended, 3: closed
  int transactionType = 1;
  int billedType = 1;
  var transactionArr = [
    {'date':'21 June 2021', 'time':'03:45 AM', 'transactionName':'Business Services1', 'status':0, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'22 June 2021', 'time':'03:45 AM', 'transactionName':'Business Services2', 'status':1, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'23 June 2021', 'time':'03:45 AM', 'transactionName':'Business Services3', 'status':2, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'24 June 2021', 'time':'03:45 AM', 'transactionName':'Business Services4', 'status':3, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'25 June 2021', 'time':'03:45 AM', 'transactionName':'Business Services5', 'status':4, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'26 June 2021', 'time':'03:45 AM', 'transactionName':'Business Services6', 'status':0, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'27 June 2021', 'time':'03:45 AM', 'transactionName':'Business Services7', 'status':1, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'}
  ];

  var billingArr = [
    {'statementDate':'30 Jan 2021', 'totalAmount':'480.00', 'dueDate':'05 Mar 2021', 'status':0},
    {'statementDate':'30 Jan 2021', 'totalAmount':'480.00', 'dueDate':'05 Mar 2021', 'status':1},
    {'statementDate':'30 Jan 2021', 'totalAmount':'480.00', 'dueDate':'05 Mar 2021', 'status':2},
    {'statementDate':'30 Jan 2021', 'totalAmount':'480.00', 'dueDate':'05 Mar 2021', 'status':0},
    {'statementDate':'30 Jan 2021', 'totalAmount':'480.00', 'dueDate':'05 Mar 2021', 'status':1},
    {'statementDate':'30 Jan 2021', 'totalAmount':'480.00', 'dueDate':'05 Mar 2021', 'status':2},
  ];

  handleDepositFunds(flag) {
    if(flag == 'payment') {
      Navigator.of(context).push(
        CupertinoPageRoute (
            builder: (context) => const CreditPaymentScreen()
        ),
      );
    } else if(flag == 'deposit') {

    }
  }

  handleTransactionType(type) {
    setState(() {
      transactionType = type;
    });
  }

  handleBilledType(type) {
    setState(() {
      billedType = type;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body:Stack(
                children:[
                  SingleChildScrollView(
                      child: Column(
                          children: [
                            const CustomSpacer(size: 44),
                            // const CustomHeader(title: 'Flex PLUS Credit'),
                            Row(
                                children: [
                                  SizedBox(width: wScale(20)),
                                  backButton(),
                                  SizedBox(width: wScale(20)),
                                  Text('Flex PLUS Credit', style: TextStyle(fontSize: fSize(20), fontWeight: FontWeight.w600))
                                ]
                            ),
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: wScale(24)),
                                child: Column(
                                  children: [
                                    const CustomSpacer(size: 20),
                                    titleField(),
                                    FPL_enhancement == 2 ? const CustomSpacer(size: 15): const SizedBox(),
                                    FPL_enhancement == 2 ? suspendedField() : const SizedBox(),
                                    const CustomSpacer(size: 16),
                                    cardAvailableValanceField(),
                                    const CustomSpacer(size: 10),
                                    cardTotalValanceField(),
                                    FPL_enhancement == 1 ? const CustomSpacer(size: 30) : const SizedBox(),
                                    FPL_enhancement == 1 ? welcomeHandleField('assets/deposit_funds.png', 27.0, "Increase Credit Line", 'deposit' ) : const SizedBox(),
                                    const CustomSpacer(size: 10),
                                    welcomeHandleField('assets/green_card.png', 21.0, FPL_enhancement == 3 ? "Get Credit Line" : "Payment", 'payment'),
                                    const CustomSpacer(size: 26),
                                    transactionTypeField(),
                                    transactionType == 1
                                        ? const CustomSpacer(size: 15)
                                        : const SizedBox(),
                                    transactionType == 1
                                        ? billedTypeField()
                                        : const SizedBox(),
                                    const CustomSpacer(size: 15),
                                    transactionType == 1
                                        ? getTransactionArrWidgets(transactionArr)
                                        : getBillingArrWidgets(billingArr),
                                    const CustomSpacer(size: 88),
                                  ],
                                )
                            ),
                          ]
                      )
                  ),
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    child: CustomBottomBar(active: 3),
                  )
                ]
            )
        )
    );
  }

  Widget backButton() {
    return Container(
      width: hScale(40),
      height: hScale(40),
      padding: EdgeInsets.zero,
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
      child: TextButton(
          style: TextButton.styleFrom(
            primary: const Color(0xff70828D),
            padding: const EdgeInsets.all(0),
          ),
          child: const Icon( Icons.arrow_back_ios_rounded, color: Colors.black, size: 12,),
          onPressed: () async {
            // widget.controller.index = 0;
            // // Future.delayed(const Duration(seconds: 1), () {});
            // widget.navigatorKey.currentState!.popUntil((route) => route.isFirst);
          }),
    );
  }

  Widget titleField() {
    return Container(
      width: wScale(327),
      alignment: Alignment.centerLeft,
      child: Text('Flex PLUS Account 123456', style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w600, color: const Color(0xFF1A2831))),
    );
  }

  Widget cardAvailableValanceField() {
    return Stack(
      children: [
        Container(
          width: wScale(327),
            height: hScale(150),
            padding: EdgeInsets.all(hScale(24)),
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(hScale(10)),
                image: const DecorationImage(
                  image: AssetImage("assets/dashboard_header.png"),
                  fit: BoxFit.cover,
                )
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  moneyValue('Available Credit', 'SGD', '1,800.00', 20.0, FontWeight.bold, const Color(0xff30E7A9)),
                  moneyValue('Total Credit Line','SGD', '3,000.00', 16.0, FontWeight.w600, const Color(0xffADD2C8)),
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: LinearProgressIndicator( value: 18/30, backgroundColor: const Color(0xFFF4F4F4), color: const Color(0xFF30E7A9), minHeight: hScale(10),),
                  ),
                ]
            )
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: wScale(327),
            height: hScale(150),
            decoration: BoxDecoration(
                color: FPL_enhancement == 2 ? Colors.black.withOpacity(0.5) : Colors.transparent,
                borderRadius: BorderRadius.circular(hScale(10)),
            ),
          )
        )
      ],
    );
  }

  Widget cardTotalValanceField() {
    return Container(
        padding: EdgeInsets.all(hScale(24)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(hScale(10)),
          image: const DecorationImage(
            image: AssetImage("assets/dashboard_header.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
            children: [
              moneyValue('Total Amount Due', 'SGD', '800.00', 20.0, FontWeight.bold, const Color(0xff30E7A9)),
              const CustomSpacer(size: 8),
              moneyValue('Due Date','', '6 April 2021', 16.0, FontWeight.w600, const Color(0xffADD2C8)),
              const CustomSpacer(size: 14),
              moneyValue('Unbilled Amount','SGD', '300.00', 16.0, FontWeight.w600, const Color(0xffADD2C8)),
            ]
        )
    );
  }

  Widget moneyValue(title, unit, value, size, weight, color) {
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
              Text('$unit  ',
                  style: TextStyle(fontSize: fSize(12), fontWeight: weight, color: color)),
              Text(value,
                  style: TextStyle(fontSize: fSize(size), fontWeight: weight, color: color)),
            ]
        )
      ],
    );
  }

  Widget welcomeHandleField(imageURL, imageScale, title, funcFlag) {
    return SizedBox(
        height: hScale(63),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: const Color(0xffffffff),
              side: const BorderSide(width: 0, color: Color(0xffffffff)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
            ),
            onPressed: () { handleDepositFunds(funcFlag); },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                    children:[
                      SizedBox(
                        width: hScale(22),
                        child: Image.asset( imageURL, fit: BoxFit.contain, width: wScale(imageScale))
                      ),
                      SizedBox(width: wScale(18)),
                      Text(title, style: TextStyle(fontSize: fSize(12), color: const Color(0xff465158))),
                    ]
                ),
                const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xff70828D),
                    size: 24.0
                ),
              ],
            )
        )
    );
  }

  Widget transactionTypeField() {
    return Container(
      alignment: Alignment.topCenter,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
              activeButton('Transactions', 1),
              activeButton('Billing Statements', 2),
          ]
      ),
    );
  }

  Widget activeButton(title, type) {
    return Container(
        width: wScale(163),
        // padding: EdgeInsets.only(left: wScale(6),right: wScale(6)),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(
                color: type == transactionType ? const Color(0xFF29C490): const Color(0xFFEEEEEE),
                width: type == transactionType ? hScale(2): hScale(1)))
        ),
        alignment: Alignment.center,
        child: TextButton(
          style: TextButton.styleFrom(
            primary: const Color(0xff70828D),
            padding: const EdgeInsets.all(0),
            textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
          ),
          onPressed: () { handleTransactionType(type); },
          child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(14),
              color: type == transactionType ? const Color(0xff1A2831) :  const Color(0xFF70828D)),
        ),
      ),
    );
  }

  Widget billedTypeField() {
    return Container(
      width: wScale(327),
      height: hScale(40),
      padding: EdgeInsets.all(hScale(2)),
      decoration: BoxDecoration(
        color: const Color(0xfff5f5f6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(hScale(20)),
          topRight: Radius.circular(hScale(20)),
          bottomLeft: Radius.circular(hScale(20)),
          bottomRight: Radius.circular(hScale(20)),
        ),
      ),
      child: Row(
          children: [
            cardGroupButton('Unbilled', 1),
            cardGroupButton('Billed', 2),
          ]
      ),
    );
  }

  Widget cardGroupButton(cardName, type) {
    return type == billedType ?
    Container(
      width: wScale(160),
      height: hScale(35),
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(260),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 20,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: TextButton(
          style: TextButton.styleFrom(
            primary: const Color(0xFFFFFFFF),
            padding: const EdgeInsets.all(0),
          ),
          child: Text(
            cardName,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: fSize(14),
                color: const Color(0xff1A2831)),
          ),
          onPressed: () { handleBilledType(type); }),
    ): TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff70828D),
        padding: const EdgeInsets.all(0),
        textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
      ),
      onPressed: () { handleBilledType(type); },
      child: Container(
        width: wScale(160),
        height: hScale(35),
        alignment: Alignment.center,
        child: Text(
          cardName,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(14),
              color: const Color(0xff70828D)),
        ),
      ),
    );
  }

  Widget getTransactionArrWidgets(arr) {
    return Column(children: arr.map<Widget>((item) {
      return TransactionItem(date: item['date'], time: item['time'], transactionName: item['transactionName'], userName: item['userName'], cardNum: item['cardNum'], value:item['value'], status: item['status'],);
    }).toList());
  }

  Widget getBillingArrWidgets(arr) {
    return Column(children: arr.map<Widget>((item) {
      return BillingItem(statementDate: item['statementDate'], totalAmount: item['totalAmount'], dueDate: item['dueDate'], status: item['status']);
    }).toList());
  }

  Widget suspendedField() {
    return
      Container(
        // width: wScale(327),
        padding: EdgeInsets.all(hScale(12)),
        decoration: BoxDecoration(
          color: const Color(0xffF6C6C0),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(hScale(10)),
            topRight: Radius.circular(hScale(10)),
            bottomLeft: Radius.circular(hScale(10)),
            bottomRight: Radius.circular(hScale(10)),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0ff6c6c0).withOpacity(0.25),
              spreadRadius: 4,
              blurRadius: 20,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const CustomSpacer(size: 8),
                    Icon(Icons.error, color: const Color(0xffEB5757),size: wScale(20)),
                  ],
                ),
                SizedBox(width: wScale(11)),
                Text(
                    'Your account has been suspended until\nthe amount due is paid in full. Interest\ncharges will apply.',
                    style: TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w500, color: const Color(0xFF1A2831), height: 1.8))
              ],
            ),
            Container(
              width: wScale(20),
              height: wScale(20),
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: hScale(8)),
              child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                  ),
                  child: Icon(Icons.close_rounded, color: const Color(0xff81919B), size: wScale(20),),
                  onPressed: (){ }
              )
            )
          ]
        ),
      );
  }
}

import 'package:co/ui/main/home/deposit_funds.dart';
import 'package:co/ui/main/home/notification.dart';
import 'package:co/ui/main/home/request_card.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class HomeScreen extends StatefulWidget {
  // final CupertinoTabController controller;
  // final GlobalKey<NavigatorState> navigatorKey;
  // const Home({Key key, required this.controller, required this.navigatorKey}) : super(key: key);

  const HomeScreen({Key key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  double cardType = 1.0;
  var transactionArr = [
    {
      'date': '21 June 2021',
      'time': '03:45 AM',
      'transactionName': 'Mobile Phone Rechage1',
      'status': 'Cancelled',
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'value': '1,200.00'
    },
    {
      'date': '22 June 2021',
      'time': '03:45 AM',
      'transactionName': 'Mobile Phone Rechage2',
      'status': 'Cancelled',
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'value': '1,200.00'
    },
    {
      'date': '23 June 2021',
      'time': '03:45 AM',
      'transactionName': 'Mobile Phone Rechage3',
      'status': 'Cancelled',
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'value': '1,200.00'
    },
    {
      'date': '24 June 2021',
      'time': '03:45 AM',
      'transactionName': 'Mobile Phone Rechage4',
      'status': 'Cancelled',
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'value': '1,200.00'
    },
    {
      'date': '25 June 2021',
      'time': '03:45 AM',
      'transactionName': 'Mobile Phone Rechage5',
      'status': 'Cancelled',
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'value': '1,200.00'
    },
    {
      'date': '26 June 2021',
      'time': '03:45 AM',
      'transactionName': 'Mobile Phone Rechage6',
      'status': 'Cancelled',
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'value': '1,200.00'
    },
    {
      'date': '27 June 2021',
      'time': '03:45 AM',
      'transactionName': 'Mobile Phone Rechage7',
      'status': 'Cancelled',
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'value': '1,200.00'
    }
  ];

  handleCardType(type) {
    setState(() {
      cardType = type;
    });
  }

  handleViewAllTransaction() {}

  handleNotification() {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => const NotificationScreen()),
    );
  }

  handleDepositFunds() {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => const DepositFundsScreen()),
    );
  }

  handleQuickActions(index) {
    if (index == 0) {
    } else if (index == 1) {
    } else if (index == 2) {
      Navigator.of(context).push(
        CupertinoPageRoute(builder: (context) => const RequestCard()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Stack(children: [
      SingleChildScrollView(
          padding: EdgeInsets.only(left: wScale(24), right: wScale(24)),
          child: Align(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const CustomSpacer(size: 30),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      welcomeUser(),
                      IconButton(
                        icon: customImage('assets/notification.png', 16.00),
                        iconSize: hScale(10),
                        onPressed: () {
                          handleNotification();
                        },
                      )
                    ]),
                const CustomSpacer(size: 20),
                cardValanceField(),
                const CustomSpacer(size: 20),
                welcomeHandleField(
                    'assets/deposit_funds.png', 27.0, "Deposit Funds"),
                const CustomSpacer(size: 10),
                welcomeHandleField(
                    'assets/get_credit_line.png', 21.0, "Get Credit Line"),
                const CustomSpacer(size: 16),
                quickActionsField(),
                const CustomSpacer(size: 16),
                customText('Cards Overview'),
                const CustomSpacer(size: 16),
                cardOverviewField(),
                const CustomSpacer(size: 16),
                recentTransactionField(),
                const CustomSpacer(size: 16),
                getTransactionArrWidgets(transactionArr),
                const CustomSpacer(size: 88),
              ]))),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 0),
      )
    ])));
  }

  Widget welcomeUser() {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fSize(16),
          color: Colors.black,
        ),
        children: const [
          TextSpan(text: 'Welcome, '),
          TextSpan(
              text: 'Terry Herwit',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget customText(text) {
    return Text(text,
        style: TextStyle(
            fontSize: fSize(16),
            color: Colors.black,
            fontWeight: FontWeight.w500));
  }

  Widget customImage(url, width) {
    return Image.asset(url, fit: BoxFit.contain, width: wScale(width));
  }

  Widget cardValanceField() {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(hScale(24)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(hScale(10)),
          image: const DecorationImage(
            image: AssetImage("assets/dashboard_header.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(children: [
          moneyValue('Total Funds', '50,000.00', 20.0, FontWeight.bold,
              const Color(0xff30E7A9)),
          const CustomSpacer(
            size: 8,
          ),
          moneyValue('Credit Line', '40,000.00', 16.0, FontWeight.w600,
              const Color(0xffADD2C8)),
          const CustomSpacer(
            size: 8,
          ),
          moneyValue('Business Account', '10,000.00', 16.0, FontWeight.w600,
              const Color(0xffADD2C8)),
        ]));
  }

  Widget moneyValue(title, value, size, weight, color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(fontSize: fSize(12), color: Colors.white)),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("SGD  ",
              style: TextStyle(
                fontSize: fSize(12),
                fontWeight: weight,
                color: color,
                height: 1,
              )),
          Text(value,
              style: TextStyle(
                fontSize: fSize(size),
                fontWeight: weight,
                color: color,
                height: 1,
              )),
        ])
      ],
    );
  }

  Widget welcomeHandleField(imageURL, imageScale, title) {
    return SizedBox(
        height: hScale(63),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: const Color(0xffffffff),
              side: const BorderSide(width: 0, color: Color(0xffffffff)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              handleDepositFunds();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(children: [
                  SizedBox(
                    width: hScale(22),
                    child: customImage(imageURL, imageScale),
                  ),
                  SizedBox(width: wScale(18)),
                  Text(title,
                      style: TextStyle(
                          fontSize: fSize(12), color: const Color(0xff465158))),
                ]),
                const Icon(Icons.arrow_forward_rounded,
                    color: Color(0xff70828D), size: 24.0),
              ],
            )));
  }

  Widget quickActionsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        customText('Quick Actions'),
        const CustomSpacer(size: 7),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              actionButton('assets/invite_user.png', 'Invite\nUser', 0),
              actionButton(
                  'assets/issue_virtual_card.png', 'Issue\nVirtual Card', 1),
              actionButton('assets/green_card.png', 'Request\nPhysical Card', 2)
            ])
      ],
    );
  }

  Widget actionButton(imageUrl, text, index) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          primary: const Color(0xffffffff),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          handleQuickActions(index);
        },
        child: Container(
            width: wScale(99),
            padding: EdgeInsets.symmetric(vertical: hScale(16)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(imageUrl, fit: BoxFit.contain, height: hScale(24)),
                const CustomSpacer(size: 8),
                Text(
                  text,
                  style: TextStyle(
                      fontSize: fSize(12),
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ],
            )));
  }

  Widget cardOverviewField() {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.all(wScale(16)),
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
          cardGroupField(),
          const CustomSpacer(size: 16),
          cardTypeField()
        ],
      ),
    );
  }

  Widget cardGroupField() {
    return Container(
      width: wScale(295),
      height: hScale(34),
      padding: EdgeInsets.all(hScale(2)),
      decoration: BoxDecoration(
        color: const Color(0xfff5f5f6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(hScale(17)),
          topRight: Radius.circular(hScale(17)),
          bottomLeft: Radius.circular(hScale(17)),
          bottomRight: Radius.circular(hScale(17)),
        ),
      ),
      child: Row(children: [
        cardGroupButton('My Cards', 1.0),
        cardGroupButton('Company Cards', 2.0),
      ]),
    );
  }

  Widget cardGroupButton(cardName, type) {
    return type == cardType
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0),
              primary: const Color(0xff4B5A63),
              side: const BorderSide(width: 0, color: Color(0xff4B5A63)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              handleCardType(type);
            },
            child: Container(
              width: wScale(145),
              height: hScale(30),
              alignment: Alignment.center,
              child: Text(
                cardName,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ))
        : TextButton(
            style: TextButton.styleFrom(
              primary: const Color(0xff70828D),
              padding: const EdgeInsets.all(0),
              textStyle: TextStyle(
                  fontSize: fSize(14), color: const Color(0xff70828D)),
            ),
            onPressed: () {
              handleCardType(type);
            },
            child: Container(
              width: wScale(145),
              height: hScale(30),
              alignment: Alignment.center,
              child: Text(
                cardName,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff70828D)),
              ),
            ),
          );
  }

  Widget cardTypeField() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      cardTypeImage(
          'assets/physical_card.png', 'Physical Cards', 4, 'physical'),
      cardTypeImage('assets/virtual_card.png', 'Virtual Cards', 16, 'virtual'),
    ]);
  }

  Widget cardTypeImage(imageURL, cardName, value, type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
            child:
                Image.asset(imageURL, fit: BoxFit.contain, width: wScale(142)),
            onPressed: () async {
              // widget.navigatorKey.currentState!.pushNamed(type);
              // widget.controller.index = 1;
              // await Future.delayed(const Duration(seconds: 0), () {});
              // widget.navigatorKey.currentState!.pushNamed(type);
            }),
        const CustomSpacer(size: 8),
        Row(
          children: [
            Text(cardName,
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff465158))),
            Text('  ($value)  ',
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff30E7A9))),
            const Icon(Icons.arrow_forward_rounded,
                color: Color(0xff70828D), size: 12),
          ],
        ),
      ],
    );
  }

  Widget recentTransactionField() {
    return SizedBox(
      width: wScale(327),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              customText('Recent Transactions'),
              viewAllTransactionButton()
            ],
          )
        ],
      ),
    );
  }

  Widget viewAllTransactionButton() {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff30E7A9),
        textStyle: TextStyle(
            fontSize: fSize(12),
            color: const Color(0xff30E7A9),
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline),
      ),
      onPressed: () {
        handleViewAllTransaction();
      },
      child: const Text('View All'),
    );
  }

  Widget transactionField(
      date, time, transactionName, status, userName, cardNum, value) {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(
          left: wScale(16),
          right: wScale(16),
          top: hScale(16),
          bottom: hScale(16)),
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
          transactionTimeField(date, time),
          transactionStatus(transactionName, status),
          transactionUser(userName, cardNum),
          moneyValue('', value, 14.0, FontWeight.w700, const Color(0xffADD2C8)),
        ],
      ),
    );
  }

  Widget transactionTimeField(date, time) {
    return Text('$date  |  $time',
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
            text: ' ($status)',
            style: TextStyle(fontSize: fSize(12), fontStyle: FontStyle.italic),
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
            text: ' (**** **** **** $cardNum)',
            style: const TextStyle(color: Color(0xff70828D)),
          ),
        ],
      ),
    );
  }

  Widget getTransactionArrWidgets(arr) {
    return Column(
        children: arr.map<Widget>((item) {
      return transactionField(
          item['date'],
          item['time'],
          item['transactionName'],
          item['status'],
          item['userName'],
          item['cardNum'],
          item['value']);
    }).toList());
  }
}

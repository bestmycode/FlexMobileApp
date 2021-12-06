import 'package:co/ui/main/cards/view_limits.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class PhysicalPersonalCard extends StatefulWidget {
  const PhysicalPersonalCard({Key? key}) : super(key: key);

  @override
  PhysicalPersonalCardState createState() => PhysicalPersonalCardState();
}

class PhysicalPersonalCardState extends State<PhysicalPersonalCard> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  int cardType = 1;
  int transactionStatus = 1;
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
  bool showCardDetail = true;

  handleBack() {}

  handleCardType(type) {
    setState(() {
      cardType = type;
    });
  }

  handleTransactionStatus(status) {
    setState(() {
      transactionStatus = status;
    });
  }

  handleExport() {}

  handleAction(index) {
    if (index == 1) {
      Navigator.of(context).push(
        CupertinoPageRoute(builder: (context) => const ViewLimits()),
      );
    }
  }

  handleShowCardDetail() {
    setState(() {
      showCardDetail = !showCardDetail;
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
            body: Stack(children: [
      SingleChildScrollView(
          child: Column(children: [
        const CustomSpacer(size: 44),
        const CustomMainHeader(title: 'Angel Matthew’s Card'),
        const CustomSpacer(size: 31),
        cardDetailField(),
        const CustomSpacer(size: 10),
        spendLimitField(),
        const CustomSpacer(size: 20),
        actionButtonField(),
        const CustomSpacer(size: 20),
        allTransactionField(),
        const CustomSpacer(size: 15),
        getTransactionArrWidgets(transactionArr),
        const CustomSpacer(size: 88),
      ])),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 1),
      )
    ])));
  }

  Widget cardDetailField() {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(
          left: wScale(16),
          right: wScale(16),
          top: hScale(16),
          bottom: hScale(16)),
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
        children: [cardField(), const CustomSpacer(size: 14), cardValueField()],
      ),
    );
  }

  Widget cardField() {
    return Container(
        width: wScale(295),
        height: wScale(187),
        padding: EdgeInsets.all(hScale(16)),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/physical_card_detail.png"),
            fit: BoxFit.contain,
          ),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [const SizedBox(), eyeIconField()],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Angel Matthews',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: fSize(14))),
                  const CustomSpacer(size: 6),
                  Row(children: [
                    Text(
                        showCardDetail
                            ? '2145 4587 4875 1211'
                            : '* * * *  * * * *  * * * *  * * * *',
                        style: TextStyle(
                            color: Colors.white, fontSize: fSize(16))),
                    SizedBox(width: wScale(7)),
                    const Icon(Icons.content_copy,
                        color: Color(0xff30E7A9), size: 14.0)
                  ]),
                ],
              ),
              Row(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Valid Thru',
                        style: TextStyle(
                            color: Colors.white, fontSize: fSize(10))),
                    Text(showCardDetail ? '12/20' : 'MM / DD',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: fSize(11),
                            fontWeight: FontWeight.bold))
                  ],
                ),
                SizedBox(width: wScale(10)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CVV',
                        style: TextStyle(
                            color: Colors.white, fontSize: fSize(10))),
                    Text(showCardDetail ? '214' : '* * *',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: fSize(11),
                            fontWeight: FontWeight.bold))
                  ],
                ),
                SizedBox(width: wScale(6)),
                const Icon(Icons.content_copy,
                    color: Color(0xff30E7A9), size: 14.0)
              ])
            ]));
  }

  Widget cardValueField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Available Limit',
            style: TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w600)),
        Container(
            padding: EdgeInsets.only(
                left: wScale(16),
                right: wScale(16),
                top: hScale(5),
                bottom: hScale(5)),
            decoration: BoxDecoration(
              color: const Color(0xFFDEFEE9),
              borderRadius: BorderRadius.all(
                Radius.circular(hScale(16)),
              ),
            ),
            child: Text(r'S$3,000.00',
                style: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF30E7A9))))
      ],
    );
  }

  Widget eyeIconField() {
    return Container(
        height: hScale(34),
        width: hScale(34),
        // padding: EdgeInsets.all(hScale(17)),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(hScale(17)),
              topRight: Radius.circular(hScale(17)),
              bottomLeft: Radius.circular(hScale(17)),
              bottomRight: Radius.circular(hScale(17)),
            )),
        child: IconButton(
          padding: const EdgeInsets.all(0),
          // icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xff30E7A9),),
          icon: Image.asset(
              showCardDetail ? 'assets/hide_eye.png' : 'assets/show_eye.png',
              fit: BoxFit.contain,
              height: hScale(16)),
          iconSize: hScale(17),
          onPressed: () {
            handleShowCardDetail();
          },
        ));
  }

  Widget spendLimitField() {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(
          left: wScale(16),
          right: wScale(16),
          top: hScale(16),
          bottom: hScale(16)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly Spend Limit',
                  style: TextStyle(
                      fontSize: fSize(14),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A2831))),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r'S$5,000.00',
                        style: TextStyle(
                            fontSize: fSize(14),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A2831))),
                  ])
            ],
          ),
          const CustomSpacer(size: 12),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              value: 0.8,
              backgroundColor: const Color(0xFFF4F4F4),
              color: const Color(0xFF30E7A9),
              minHeight: hScale(10),
            ),
          ),
          const CustomSpacer(size: 12),
          Row(
            children: [
              Image.asset('assets/happy_emoji.png',
                  fit: BoxFit.contain, width: wScale(18)),
              SizedBox(width: wScale(10)),
              Text('Great job, you are within your allocated limit!',
                  style: TextStyle(
                      fontSize: fSize(12), color: const Color(0xFF70828D))),
            ],
          )
        ],
      ),
    );
  }

  Widget actionButton(imageUrl, text, index) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          primary: const Color(0xffffffff),
          side: const BorderSide(width: 0, color: Color(0xffffffff)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          handleAction(index);
        },
        child: SizedBox(
            width: wScale(102),
            height: hScale(82),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(imageUrl, fit: BoxFit.contain, height: wScale(24)),
                const CustomSpacer(
                  size: 10,
                ),
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

  Widget actionButtonField() {
    return SizedBox(
      width: wScale(327),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        actionButton('assets/free.png', 'Freeze Card', 0),
        actionButton('assets/limit.png', 'View Limit', 1),
        actionButton('assets/cancel.png', 'Cancel Card', 2),
      ]),
    );
  }

  Widget allTransactionField() {
    return SizedBox(
      width: wScale(327),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('All Transactions',
                  style: TextStyle(
                      fontSize: fSize(16), fontWeight: FontWeight.w500)),
              TextButton(
                style: TextButton.styleFrom(
                  primary: const Color(0xff30E7A9),
                  textStyle: TextStyle(
                      fontSize: fSize(14), color: const Color(0xff30E7A9)),
                ),
                onPressed: () {
                  handleExport();
                },
                child: const Text('Export',
                    style: TextStyle(decoration: TextDecoration.underline)),
              ),
            ],
          ),
          // const CustomSpacer(size: 10),
          transactionStatusField()
        ],
      ),
    );
  }

  Widget transactionStatusField() {
    return Container(
      width: wScale(327),
      height: hScale(34),
      padding: EdgeInsets.all(hScale(1)),
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
        transactionStatusButton('Completed', 1, const Color(0xFF70828D)),
        transactionStatusButton('Pending', 2, const Color(0xFF1A2831)),
        transactionStatusButton('Declined', 3, const Color(0xFFEB5757))
      ]),
    );
  }

  Widget transactionStatusButton(status, type, textColor) {
    return type == transactionStatus
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0),
              primary: const Color(0xffffffff),
              side: const BorderSide(width: 0, color: Color(0xffffffff)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              handleTransactionStatus(type);
            },
            child: Container(
              width: wScale(107),
              height: hScale(30),
              alignment: Alignment.center,
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: fSize(14), color: textColor),
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
              handleTransactionStatus(type);
            },
            child: Container(
              width: wScale(107),
              height: hScale(30),
              alignment: Alignment.center,
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: fSize(14), color: textColor),
              ),
            ),
          );
  }

  Widget transactionField(date, transactionName, value) {
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
          transactionTimeField(date),
          transactionNameField(transactionName),
          moneyValue('', value, 14.0, FontWeight.w700, const Color(0xffADD2C8)),
        ],
      ),
    );
  }

  Widget transactionTimeField(date) {
    return Text('$date',
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xff70828D)));
  }

  Widget transactionNameField(name) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fSize(16),
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        children: [
          TextSpan(text: name),
        ],
      ),
    );
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
                  height: 1)),
          Text(value,
              style: TextStyle(
                  fontSize: fSize(size),
                  fontWeight: weight,
                  color: color,
                  height: 1)),
        ])
      ],
    );
  }

  Widget getTransactionArrWidgets(arr) {
    return Column(
        children: arr.map<Widget>((item) {
      return transactionField(
          item['date'], item['transactionName'], item['value']);
    }).toList());
  }
}

import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/transaction_item.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

class CreditTransactionTypeSectionItem extends StatefulWidget {
  final unbilledTrans;
  final billedTrans;
  const CreditTransactionTypeSectionItem(
      {Key? key, this.billedTrans, this.unbilledTrans})
      : super(key: key);

  @override
  CreditTransactionTypeSectionItemState createState() =>
      CreditTransactionTypeSectionItemState();
}

class CreditTransactionTypeSectionItemState
    extends State<CreditTransactionTypeSectionItem> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  int billedType = 1;

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
    return DefaultTabController(
      length: 2,
      child: Container(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
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
                child: TabBar(
                  unselectedLabelColor: const Color(0xff70828D),
                  labelPadding: const EdgeInsets.all(1),
                  labelStyle: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  labelColor: Color(0xff1A2831),
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(260),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF040415).withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset:
                            const Offset(0, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  indicatorPadding: const EdgeInsets.all(1),
                  indicatorWeight: 1,
                  tabs: [
                    Tab(
                      text: 'Unbilled',
                    ),
                    Tab(
                      text: 'Billed',
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: hScale(584),
              width: double.maxFinite,
              child: TabBarView(
                children: [
                  Container(
                      height: hScale(570),
                      child: SingleChildScrollView(
                          child: Column(children: [
                        CustomSpacer(size: 15),
                        getTransactionArrWidgets(
                            widget.unbilledTrans['financeAccountTransactions'])
                      ]))),
                  Container(
                      height: hScale(570),
                      child: SingleChildScrollView(
                          child: Column(children: [
                        CustomSpacer(size: 15),
                        getTransactionArrWidgets(
                            widget.billedTrans['financeAccountTransactions'])
                      ])))
                ],
              ),
            ),
          ],
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
      child: Row(children: [
        cardGroupButton('Unbilled', 1),
        cardGroupButton('Billed', 2),
      ]),
    );
  }

  Widget cardGroupButton(cardName, type) {
    return type == billedType
        ? Container(
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
                  blurRadius: 10,
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
                      fontSize: fSize(14), color: const Color(0xff1A2831)),
                ),
                onPressed: () {
                  handleBilledType(type);
                }),
          )
        : TextButton(
            style: TextButton.styleFrom(
              primary: const Color(0xff70828D),
              padding: const EdgeInsets.all(0),
              textStyle: TextStyle(
                  fontSize: fSize(14), color: const Color(0xff70828D)),
            ),
            onPressed: () {
              handleBilledType(type);
            },
            child: Container(
              width: wScale(160),
              height: hScale(35),
              alignment: Alignment.center,
              child: Text(
                cardName,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: fSize(14), color: const Color(0xff70828D)),
              ),
            ),
          );
  }

  Widget getTransactionArrWidgets(arr) {
    return arr.length == 0
        ? Image.asset('assets/empty_transaction.png',
            fit: BoxFit.contain, width: wScale(327))
        : Column(
            children: arr.map<Widget>((item) {
            return TransactionItem(
                whichTab: billedType == 1 ? "UNBILLED" : "BILLED",
                accountId: item['txnFinanceAccId'],
                transactionId: item['sourceTransactionId'],
                date: item['transactionDate'],
                transactionName: item['description'],
                status: item['status'],
                transactionType: item['transactionType'],
                userName: item['merchantName'],
                cardNum: item['pan'],
                billCurrency: item['billCurrency'],
                fxrBillAmount: item['fxrBillAmount'],
                transactionCurrency: item['transactionCurrency'],
                transactionAmount: item['transactionAmount'],
                qualifiers:
                    item['qualifiers'] == null ? "" : item['qualifiers'],
                receiptStatus: item['fxrBillAmount'] >= 0
                    ? 0
                    : item['receiptStatus'] == "PAID"
                        ? 2
                        : 1);
          }).toList());
  }
}

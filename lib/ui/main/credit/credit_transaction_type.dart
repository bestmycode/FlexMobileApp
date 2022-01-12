import 'package:co/ui/main/credit/credit_bill_type_item.dart';
import 'package:co/ui/main/transactions/all_transaction_header.dart';
import 'package:co/ui/widgets/billing_item.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/transaction_item.dart';
import 'package:co/ui/widgets/virtual_my_transaction_search_filed%20copy.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:indexed/indexed.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

import 'credit_transaction_type_item.dart';

class CreditTransactionTypeSection extends StatefulWidget {
  const CreditTransactionTypeSection({
    Key? key,
  }) : super(key: key);

  @override
  CreditTransactionTypeSectionState createState() =>
      CreditTransactionTypeSectionState();
}

class CreditTransactionTypeSectionState
    extends State<CreditTransactionTypeSection> {
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
  int billedType = 1;
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String readBusinessAccountSummary = Queries.QUERY_BUSINESS_ACCOUNT_SUMMARY;
  String billedUnbilledTransactions = Queries.QUERY_BILLED_UNBILLED_TRANSACTIONS;
  String billingStatementsTable = Queries.QUERY_BILLING_STATEMENTTABLE;

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
    return Column(
      children: [
        transactionTypeField(),
        transactionType == 1 ? const CustomSpacer(size: 15) : const SizedBox(),
        transactionType == 1 ? billedTypeField() : const SizedBox(),
        const CustomSpacer(size: 15),
        transactionType == 1
            ? CreditTransactionTypeSectionItem()
            : CreditBillTypeSectionItem(),
      ],
    );
  }

  Widget transactionTypeField() {
    return Container(
      alignment: Alignment.topCenter,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        activeButton('Transactions', 1),
        activeButton('Billing Statements', 2),
      ]),
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

  Widget getTransactionArrWidgets(arr) {
    return arr.length == 0
        ? Image.asset('assets/empty_transaction.png',
            fit: BoxFit.contain, width: wScale(327))
        : Column(
            children: arr.map<Widget>((item) {
            return TransactionItem(
              date: item['date'],
              transactionName: item['transactionName'],
              userName: item['userName'],
              cardNum: item['cardNum'],
              value: item['value'],
              status: 'COMPLETE',
            );
          }).toList());
  }

  Widget getBillingArrWidgets(arr) {
    return arr.length == 0
        ? Image.asset('assets/empty_transaction.png',
            fit: BoxFit.contain, width: wScale(327))
        : Column(
            children: arr.map<Widget>((item) {
            return BillingItem(
                statementDate: DateFormat('dd-MM-yyyy | hh:mm a').format(
                    DateTime.fromMillisecondsSinceEpoch(item['statementDate'])),
                totalAmount: item['totalAmountDue'].toString(),
                dueDate: item['dueDate'] == null
                    ? "-"
                    : DateFormat('dd-MM-yyyy | hh:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            item['statementDate'])),
                status: item['status'],
                documentLink: item['documentLink']);
          }).toList());
  }

  Widget activeButton(title, type) {
    return Container(
      width: wScale(163),
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
          textStyle:
              TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
        ),
        onPressed: () {
          handleTransactionType(type);
        },
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(14),
              color: type == transactionType
                  ? const Color(0xff1A2831)
                  : const Color(0xFF70828D)),
        ),
      ),
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
}

import 'package:co/ui/main/credit/credit_bill_type_item.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/queries.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:localstorage/localstorage.dart';

import 'credit_transaction_type_item.dart';

class CreditTransactionTypeSection extends StatefulWidget {
  final billedTrans;
  final unbilledTrans;
  final listBills;
  const CreditTransactionTypeSection({
    this.billedTrans,
    this.unbilledTrans,
    this.listBills,
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
  String billedUnbilledTransactions =
      Queries.QUERY_BILLED_UNBILLED_TRANSACTIONS;
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
        const CustomSpacer(size: 15),
        transactionType == 1
            ? CreditTransactionTypeSectionItem(
                unbilledTrans: widget.unbilledTrans,
                billedTrans: widget.billedTrans)
            : CreditBillTypeSectionItem(listBills: widget.listBills),
      ],
    );
  }

  Widget transactionTypeField() {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.symmetric(horizontal: wScale(24)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        activeButton('Transactions', 1),
        activeButton('Billing Statements', 2),
      ]),
    );
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
}

import 'package:co/ui/widgets/billing_item.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:intl/intl.dart';

class CreditBillTypeSectionItem extends StatefulWidget {
  final listBills;
  const CreditBillTypeSectionItem({Key? key, this.listBills}) : super(key: key);

  @override
  CreditBillTypeSectionItemState createState() =>
      CreditBillTypeSectionItemState();
}

class CreditBillTypeSectionItemState extends State<CreditBillTypeSectionItem> {
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
    return Container(
        height: hScale(625),
        child: SingleChildScrollView(
            child: getBillingArrWidgets(widget.listBills['listOfBills'])));
  }

  Widget getBillingArrWidgets(arr) {
    return arr.length == 0
        ? Image.asset('assets/empty_transaction.png',
            fit: BoxFit.contain, width: wScale(327))
        : Column(
            children: arr.map<Widget>((item) {
            return BillingItem(
                index: arr.indexOf(item),
                statementDate:
                    '${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(item['statementDate']))}',
                totalAmount: item['totalAmountDue'].toString(),
                dueDate: item['dueDate'] == null
                    ? "N/A"
                    : '${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(item['dueDate']))}',
                status: item['status'],
                download: item['documentLink']);
          }).toList());
  }
}

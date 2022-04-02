import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/transaction_item.dart';
import 'package:co/ui/widgets/virtual_my_transaction_search_filed.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:indexed/indexed.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:timezone/standalone.dart' as tz;

class VirtualMyTransactionsMain extends StatefulWidget {
  final transactions;
  final activeType;
  final dateType;
  final showDateRange;
  final handleCardType;
  final startDateCtl;
  final endDateCtl;
  final setDateType;
  const VirtualMyTransactionsMain({
    Key? key,
    this.transactions,
    this.activeType,
    this.dateType,
    this.showDateRange,
    this.handleCardType,
    this.startDateCtl,
    this.endDateCtl,
    this.setDateType,
  }) : super(key: key);

  @override
  VirtualMyTransactionsMainState createState() =>
      VirtualMyTransactionsMainState();
}

class VirtualMyTransactionsMainState extends State<VirtualMyTransactionsMain> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  String searchText = "";
  final searchCtl = TextEditingController();
  var selectedArr = [];

  handleSearch(text) {
    setState(() {
      searchText = text;
    });
  }

  final LocalStorage userStorage = LocalStorage('user_info');

  convertLocalToDetroit(time) {
    final detroit = tz.getLocation(userStorage.getItem("org_timezone"));
    return tz.TZDateTime.from(
            DateTime.fromMillisecondsSinceEpoch(time), detroit)
        .millisecondsSinceEpoch;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Indexer(children: [
      widget.transactions.length > 0
          ? Indexed(
              index: 100,
              child: VirtualMyTransactionSearchField(
                  transactions: widget.transactions,
                  searchCtl: searchCtl,
                  handleSearch: handleSearch,
                  dateType: widget.dateType,
                  setDateType: widget.setDateType,
                  isShowCalendar: false))
          : SizedBox(),
      Indexed(
          index: 50,
          child: Column(
            children: [
              SizedBox(height: hScale(50)),
              const CustomSpacer(size: 5),
              widget.showDateRange ? dateRangeField() : const SizedBox(),
              Container(
                  height: hScale(475),
                  width: wScale(375),
                  child: SingleChildScrollView(
                      child: getTransactionArrWidgets(widget.transactions)))
            ],
          ))
    ]);
  }

  Widget searchCountField(searchCount) {
    return Container(
        width: wScale(327),
        margin: EdgeInsets.only(bottom: hScale(6)),
        child: Text('Showing ${searchCount} results',
            style: TextStyle(fontSize: fSize(12), color: Color(0xFF606060))));
  }

  Widget getTransactionArrWidgets(arr) {
    var tempArr = [];
    if (widget.dateType == 0) {
      tempArr = arr;
    } else if (widget.dateType == 1) {
      arr.forEach((item) {
        if (item['transactionDate'] + 7 * 24 * 3600 * 1000 >=
            DateTime.now().millisecondsSinceEpoch) tempArr.add(item);
      });
    } else if (widget.dateType == 2) {
      arr.forEach((item) {
        if (item['transactionDate'] + 30 * 24 * 3600 * 1000 >=
            DateTime.now().millisecondsSinceEpoch) tempArr.add(item);
      });
    } else if (widget.dateType == 3) {
      arr.forEach((item) {
        if (item['transactionDate'] + 90 * 24 * 3600 * 1000 >=
            DateTime.now().millisecondsSinceEpoch) tempArr.add(item);
      });
    } else {
      var start = 0;
      var end = 0;
      start = widget.startDateCtl.text == ""
          ? 0
          : DateTime(
                  int.parse(widget.startDateCtl.text.split("/")[2]),
                  int.parse(widget.startDateCtl.text.split("/")[1]),
                  int.parse(widget.startDateCtl.text.split("/")[0]))
              .millisecondsSinceEpoch;
      end = widget.endDateCtl.text == ""
          ? DateTime.now().millisecondsSinceEpoch
          : DateTime(
                      int.parse(widget.endDateCtl.text.split("/")[2]),
                      int.parse(widget.endDateCtl.text.split("/")[1]),
                      int.parse(widget.endDateCtl.text.split("/")[0]))
                  .millisecondsSinceEpoch +
              24 * 3600 * 1000 -
              1;
      arr.forEach((item) {
        if (item['transactionDate'] >= convertLocalToDetroit(start) &&
            item['transactionDate'] <= convertLocalToDetroit(end))
          tempArr.add(item);
      });
    }
    var resultArr = [];
    tempArr.forEach((item) {
      if (item['description']
              .toString()
              .toLowerCase()
              .contains(searchText.toString().toLowerCase()) ||
          item['merchantName']
              .toString()
              .toLowerCase()
              .contains(searchText.toString().toLowerCase()) ||
          item['fxrBillAmount']
              .toString()
              .toLowerCase()
              .contains(searchText.toString().toLowerCase()))
        resultArr.add(item);
    });
    Future.delayed(Duration.zero, () {
      selectedArr = resultArr;
    });

    return resultArr.length == 0
        ? Column(children: [
            searchText.length != 0
                ? searchCountField(resultArr.length)
                : SizedBox(),
            Image.asset('assets/empty_transaction.png',
                fit: BoxFit.contain, width: wScale(327))
          ])
        : Column(children: [
            searchText.length != 0
                ? searchCountField(resultArr.length)
                : SizedBox(),
            Opacity(
                opacity: widget.activeType == 3 ? 0.5 : 1,
                child: Column(
                    children: resultArr.map<Widget>((item) {
                  return TransactionItem(
                      whichTab: widget.activeType == 1
                          ? "COMPLETED"
                          : widget.activeType == 2
                              ? "PENDING"
                              : "DECLINED",
                      accountId: item['txnFinanceAccId'],
                      transactionId: item['sourceTransactionId'],
                      date: item['transactionDate'],
                      transactionName: item['merchantName'],
                      userName: item['cardName'],
                      cardNum: item['pan'],
                      billCurrency: item['billCurrency'],
                      fxrBillAmount: item['fxrBillAmount'],
                      transactionCurrency: item['transactionCurrency'],
                      transactionAmount: item['transactionAmount'],
                      qualifiers:
                          item['qualifiers'] == null ? "" : item['qualifiers'],
                      status: item['status'],
                      transactionType: item['transactionType'],
                      receiptStatus: item['fxrBillAmount'] >= 0
                          ? 0
                          : item['receiptStatus'] == "PAID"
                              ? 2
                              : 1);
                }).toList()))
          ]);
  }

  Widget dateRangeField() {
    return Container(
        width: wScale(327),
        padding:
            EdgeInsets.symmetric(vertical: hScale(16), horizontal: wScale(16)),
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
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomSpacer(size: 11),
              dateField(1),
              const CustomSpacer(size: 23),
              dateField(2),
              const CustomSpacer(size: 5),
            ]));
  }

  Widget dateField(type) {
    return Stack(
      children: [
        Container(
          width: wScale(295),
          height: hScale(56),
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: hScale(8)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border:
                  Border.all(color: const Color(0xFF040415).withOpacity(0.1))),
          child: TextButton(
              style: TextButton.styleFrom(
                // primary: const Color(0xffF5F5F5).withOpacity(0.4),
                padding: const EdgeInsets.all(0),
              ),
              onPressed: () {
                _openDatePicker(type);
              },
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    style: TextStyle(
                        fontSize: fSize(16),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF040415)),
                    controller:
                        type == 1 ? widget.startDateCtl : widget.endDateCtl,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 1.0)),
                      hintText: 'DD/MM/YYYY',
                      hintStyle: TextStyle(
                          color: const Color(0xffBFBFBF), fontSize: fSize(14)),
                      focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 1.0)),
                    ),
                    readOnly: true,
                    onTap: () {
                      _openDatePicker(type);
                    },
                  )),
                  Container(
                      margin: EdgeInsets.only(right: wScale(20)),
                      child: Image.asset('assets/calendar.png',
                          fit: BoxFit.contain, width: wScale(18)))
                ],
              )),
        ),
        Positioned(
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text(type == 1 ? 'Start Date' : 'End Date',
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFBFBFBF))),
          ),
        )
      ],
    );
  }

  void _openDatePicker(type) async {
    var initialDate = DateTime.now();
    var firstDate = DateTime(1900);
    var lastDate = DateTime(2101);
    if (type == 1 && widget.endDateCtl.text != "") {
      lastDate = DateTime.parse(
          "${widget.endDateCtl.text.split('/')[2]}-${widget.endDateCtl.text.split('/')[1]}-${widget.endDateCtl.text.split('/')[0]}");
    } else if (type == 2 && widget.startDateCtl.text != "") {
      initialDate = DateTime.parse(
          "${widget.startDateCtl.text.split('/')[2]}-${widget.startDateCtl.text.split('/')[1]}-${widget.startDateCtl.text.split('/')[0]}");
      firstDate = DateTime.parse(
          "${widget.startDateCtl.text.split('/')[2]}-${widget.startDateCtl.text.split('/')[1]}-${widget.startDateCtl.text.split('/')[0]}");
    }
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate);

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      setState(() {
        if (type == 1) {
          widget.startDateCtl.text = formattedDate;
        } else {
          widget.endDateCtl.text = formattedDate;
        }
      });
    } else {
      print("Date is not selected");
    }
  }

  Widget searchButton() {
    return SizedBox(
        width: wScale(295),
        height: hScale(56),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            // handleSearch();
          },
          child: Text("Search",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }
}

import 'dart:io';
import 'dart:convert' show utf8;

import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/transaction_item.dart';
import 'package:co/ui/widgets/virtual_my_transaction_search_filed.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:indexed/indexed.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timezone/standalone.dart' as tz;

class GetTransactionField extends StatefulWidget {
  final height;
  final transactions;
  final sortType;
  final dateType;
  final startDateCtl;
  final endDateCtl;
  final transactionStatus;
  final orgName;
  final handleSearch;
  final setDateType;
  final showDateRange;
  final handleShowExport;
  final showExportDateRange;
  const GetTransactionField(
      {Key? key,
      this.height = 280.0,
      this.transactions,
      this.sortType,
      this.dateType = 0,
      this.startDateCtl,
      this.endDateCtl,
      this.transactionStatus,
      this.orgName,
      this.handleSearch,
      this.setDateType,
      this.showDateRange,
      this.handleShowExport,
      this.showExportDateRange})
      : super(key: key);

  @override
  GetTransactionFieldState createState() => GetTransactionFieldState();
}

class GetTransactionFieldState extends State<GetTransactionField> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  int dateType = 0;
  bool showCalendarModal = false;
  bool showDateRange = false;
  bool showExportDateRange = false;
  var selectedArr = [];

  Future<void> setSelectedArr(arr) async {}

  handleShowExport() {
    setState(() {
      showExportDateRange = !showExportDateRange;
      showDateRange = false;
      showCalendarModal = false;
      dateType = 4;
    });
  }

  handleCalendar() {
    setState(() {
      showCalendarModal = !showCalendarModal;
    });
  }

  final LocalStorage userStorage = LocalStorage('user_info');

  convertLocalToDetroit(time) {
    final detroit = tz.getLocation(userStorage.getItem("org_timezone"));
    final localizedDt =
        tz.TZDateTime.from(DateTime.fromMillisecondsSinceEpoch(time), detroit);
    var date = DateFormat.yMMMd().format(localizedDt).split(' ')[1].substring(
        0, DateFormat.yMMMd().format(localizedDt).split(' ')[1].length - 1);
    var month = DateFormat.M().format(localizedDt);
    var year = DateFormat.yMMMd().format(localizedDt).split(' ')[2];
    return DateTime(int.parse(year), int.parse(month), int.parse(date))
        .millisecondsSinceEpoch;
  }

  setDateType(type) {
    if (type == 4) {
      setState(() {
        showExportDateRange = false;
        showCalendarModal = false;
        showDateRange = !showDateRange;
        dateType = type;
      });
    } else {
      setState(() {
        showDateRange = false;
        showCalendarModal = false;
        showExportDateRange = false;
        dateType = type;
      });
    }
  }

  var searchText = '';
  handleSearch(text) {
    setState(() {
      searchText = text;
    });
  }

  handleExport() async {
    List<List> rows = [];
    var headerRow = [];
    headerRow.add("User");
    headerRow.add("Details");
    headerRow.add("Payment Method");
    headerRow.add("Account Number");
    headerRow.add("Transaction Date/Time");
    headerRow.add("Transaction Status");
    headerRow.add("Transaction Amount");
    headerRow.add("Transaction Currency");
    headerRow.add("Bill Amount");
    headerRow.add("Bill Currency");
    headerRow.add("FCA Amount");
    headerRow.add("FPL Amount");
    rows.add(headerRow);
    for (int i = 0; i < selectedArr.length; i++) {
      var row = [];
      var cardNum = selectedArr[i]['pan'];
      var cardNumber = cardNum.substring(cardNum.length - 4, cardNum.length);
      row.add(selectedArr[i]['owner']);
      row.add(selectedArr[i]['description']);
      row.add(selectedArr[i]['paymentMethod']);
      row.add("**** **** **** ${cardNumber}");
      row.add(
          "${DateFormat('MM/dd/yyyy kk:mm a').format(DateTime.fromMillisecondsSinceEpoch(selectedArr[i]['transactionDate']))}");
      row.add(selectedArr[i]['status']);
      row.add(selectedArr[i]['transactionAmount']);
      row.add(selectedArr[i]['transactionCurrency']);
      row.add(selectedArr[i]['billAmount']);
      row.add(selectedArr[i]['billCurrency']);
      row.add(selectedArr[i]['fxrBillAmount']);
      row.add(selectedArr[i]['odAmount']);

      rows.add(row);
    }
    try {
      final Directory? download = await getApplicationDocumentsDirectory();
      final String downloadPath = download!.path;
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd-MM-yyyy').format(now);
      String path = "${downloadPath}/${widget.orgName}_${formattedDate}.csv";
      File file = File(path);
      String csv = const ListToCsvConverter().convert(rows);
      await file.writeAsString(csv);
      await Share.shareFiles([path]);
    } catch (error) {
      print("===== Error : Share CSV File =====");
      print(error);
      await Sentry.captureException(error);
      return null;
    }
  }

  String getNewString(String str) {
    String retVal = '';
    for (var i = 0; i < str.length; i++) {
      var char = (utf8.encode(str[i]));
      if (char.length == 3 && (char[2] == 152 || char[2] == 153))
        retVal += "'";
      else
        retVal += utf8.decode(char);
    }
    return retVal;
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
                  dateType: dateType,
                  handleSearch: handleSearch,
                  setDateType: setDateType,
                  handleExport: handleExport,
                  showCalendarModal: showCalendarModal,
                  handleCalendar: handleCalendar,
                  transactionStatus: widget.transactionStatus))
          : SizedBox(),
      Indexed(
          index: 50,
          child: Column(
            children: [
              const CustomSpacer(size: 50),
              showDateRange ? dateRangeField(0) : const SizedBox(),
              // showExportDateRange ? dateRangeField(1) : const SizedBox(),
              // const CustomSpacer(size: 10),
              Container(
                height: hScale(widget.height),
                width: wScale(375),
                child: SingleChildScrollView(
                  child: getTransactionArrWidgets(),
                ),
              )
              // const CustomSpacer(size: 88),
            ],
          )),
    ]);
  }

  Widget searchCountField(searchCount) {
    return Container(
        width: wScale(327),
        margin: EdgeInsets.only(bottom: hScale(6)),
        child: Text('Showing ${searchCount} results',
            style: TextStyle(fontSize: fSize(12), color: Color(0xFF606060))));
  }

  Widget getTransactionArrWidgets() {
    if (widget.sortType == 0) {
      widget.transactions.sort((a, b) => b['transactionDate']
          .toString()
          .compareTo(a['transactionDate'].toString()));
    } else if (widget.sortType == 1) {
      widget.transactions.sort((a, b) => a['transactionDate']
          .toString()
          .compareTo(b['transactionDate'].toString()));
    } else if (widget.sortType == 2) {
      widget.transactions.sort((a, b) => a['pan']
          .substring(a['pan'].length - 4, a['pan'].length)
          .toString()
          .compareTo(b['pan']
              .substring(b['pan'].length - 4, b['pan'].length)
              .toString()));
    } else if (widget.sortType == 3) {
      widget.transactions.sort((a, b) => b['pan']
          .substring(b['pan'].length - 4, b['pan'].length)
          .toString()
          .compareTo(a['pan']
              .substring(a['pan'].length - 4, a['pan'].length)
              .toString()));
    } else {
      widget.transactions.sort(
          (a, b) => b['status'].toString().compareTo(a['status'].toString()));
    }

    var tempArr = [];
    if (widget.dateType == 0) {
      tempArr = widget.transactions;
    } else if (widget.dateType == 1) {
      widget.transactions.forEach((item) {
        if (item['transactionDate'] + 7 * 24 * 3600 * 1000 >=
            DateTime.now().millisecondsSinceEpoch) tempArr.add(item);
      });
    } else if (widget.dateType == 2) {
      widget.transactions.forEach((item) {
        if (item['transactionDate'] + 30 * 24 * 3600 * 1000 >=
            DateTime.now().millisecondsSinceEpoch) tempArr.add(item);
      });
    } else if (widget.dateType == 3) {
      widget.transactions.forEach((item) {
        if (item['transactionDate'] + 90 * 24 * 3600 * 1000 >=
            DateTime.now().millisecondsSinceEpoch) tempArr.add(item);
      });
    } else if (widget.dateType == 4) {
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
      widget.transactions.forEach((item) {
        if (convertLocalToDetroit(item['transactionDate']) >= start &&
            convertLocalToDetroit(item['transactionDate']) <= end)
          tempArr.add(item);
      });
    }

    var resultArr = [];
    var search = searchText.toString().toLowerCase();
    search = getNewString(search);

    tempArr.forEach((item) {
      var description = item['description'].toString().toLowerCase();

      var merchantName = item['merchantName'].toString().toLowerCase();

      var fxrBillAmount = item['fxrBillAmount'].toString().toLowerCase();

      if (description.contains(search) ||
          merchantName.contains(search) ||
          fxrBillAmount.contains(search)) resultArr.add(item);
    });
    Future.delayed(Duration.zero, () {
      selectedArr = resultArr;
    });
    return transactionList(resultArr);
  }

  Widget transactionList(resultArr) {
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
                opacity: widget.transactionStatus == 3 ? 0.65 : 1,
                child: Column(
                    children: resultArr.map<Widget>((item) {
                  return TransactionItem(
                      whichTab: widget.transactionStatus == 1
                          ? "COMPLETED"
                          : widget.transactionStatus == 2
                              ? "PENDING"
                              : "DECLINED",
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
                }).toList()))
          ]);
  }

  Widget dateRangeField(index) {
    return Container(
        width: wScale(327),
        padding:
            EdgeInsets.symmetric(vertical: hScale(16), horizontal: wScale(16)),
        // margin: EdgeInsets.only(bottom: hScale(16)),
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
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          const CustomSpacer(size: 11),
          dateField(1),
          const CustomSpacer(size: 23),
          dateField(2),
          const CustomSpacer(size: 23),
          index == 1 ? buttonField() : SizedBox(),
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
                      hintText:
                          type == 1 ? 'Select Start Date' : 'Select End Date',
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
            child: Text(
                type == 1 ? 'Start Date (DD/MM/YY)' : 'End Date (DD/MM/YY)',
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
    if (widget.endDateCtl.text != "") {
      lastDate = DateTime.parse(
          "${widget.endDateCtl.text.split('/')[2]}-${widget.endDateCtl.text.split('/')[1]}-${widget.endDateCtl.text.split('/')[0]}");
    }
    if (type == 1 && widget.startDateCtl.text != "") {
      initialDate = DateTime.parse(
          "${widget.startDateCtl.text.split('/')[2]}-${widget.startDateCtl.text.split('/')[1]}-${widget.startDateCtl.text.split('/')[0]}");
    }
    if (type == 2) {
      firstDate = DateTime.parse(
          "${widget.startDateCtl.text.split('/')[2]}-${widget.startDateCtl.text.split('/')[1]}-${widget.startDateCtl.text.split('/')[0]}");
    }
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: new DateTime.now());
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

  Widget buttonField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
            width: wScale(130),
            height: hScale(56),
            margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                primary: const Color(0xff1A2831),
                side: const BorderSide(width: 0, color: Color(0xff1A2831)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                handleExport();
              },
              child: Text('Export',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fSize(16),
                      fontWeight: FontWeight.w700)),
            )),
        Container(
            width: wScale(130),
            height: hScale(56),
            margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: const Color(0xFFFFFFFF),
                side: BorderSide(width: 1, color: Color(0xff1A2831)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                setState(() {
                  widget.startDateCtl.text = '';
                  widget.endDateCtl.text = '';
                });
              },
              child: Text('Clear',
                  style: TextStyle(
                      color: Color(0xFF1A2831),
                      fontSize: fSize(16),
                      fontWeight: FontWeight.w700)),
            ))
      ],
    );
  }
}

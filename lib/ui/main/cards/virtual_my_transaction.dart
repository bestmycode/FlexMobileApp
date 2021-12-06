import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/transaction_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:indexed/indexed.dart';
import 'package:intl/intl.dart';

class VirtualMyTransactions extends StatefulWidget {
  const VirtualMyTransactions({Key? key}) : super(key: key);

  @override
  VirtualMyTransactionsState createState() => VirtualMyTransactionsState();
}

class VirtualMyTransactionsState extends State<VirtualMyTransactions> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  var transactionArr = [
    {
      'date': '21 June 2021',
      'time': '03:45 AM',
      'transactionName': 'Mobile Phone Rechage1',
      'status': 4,
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'value': '1,200.00'
    },
    {
      'date': '22 June 2021',
      'time': '03:45 AM',
      'transactionName': 'Mobile Phone Rechage2',
      'status': 4,
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'value': '1,200.00'
    },
    {
      'date': '23 June 2021',
      'time': '03:45 AM',
      'transactionName': 'Mobile Phone Rechage3',
      'status': 4,
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'value': '1,200.00'
    },
    {
      'date': '24 June 2021',
      'time': '03:45 AM',
      'transactionName': 'Mobile Phone Rechage4',
      'status': 4,
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'value': '1,200.00'
    },
    {
      'date': '25 June 2021',
      'time': '03:45 AM',
      'transactionName': 'Mobile Phone Rechage5',
      'status': 4,
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'value': '1,200.00'
    },
    {
      'date': '26 June 2021',
      'time': '03:45 AM',
      'transactionName': 'Mobile Phone Rechage6',
      'status': 4,
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'value': '1,200.00'
    },
    {
      'date': '27 June 2021',
      'time': '03:45 AM',
      'transactionName': 'Mobile Phone Rechage7',
      'status': 4,
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'value': '1,200.00'
    }
  ];

  int activeType = 1;
  int dateType = 1;
  bool showDateRange = false;
  bool showCalendarModal = false;
  final searchCtl = TextEditingController();
  final startDateCtl = TextEditingController();
  final endDateCtl = TextEditingController();

  handleCardType(type) {
    setState(() {
      activeType = type;
    });
  }

  setDateType(type) {
    if (type == 4) {
      setState(() {
        showDateRange = !showDateRange;
        showCalendarModal = false;
        dateType = type;
      });
    } else {
      setState(() {
        showCalendarModal = false;
        showDateRange = false;
        dateType = type;
      });
    }
  }

  handleExport() {}

  handleSearch() {}

  handleCalendar() {
    setState(() {
      showCalendarModal = !showCalendarModal;
    });
  }

  handleStartDateCalendar() {}

  handleEndDateCalendar() {}

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      headerStatusField(),
      // const CustomSpacer(size: 17),
      // searchRow(),
      Indexer(children: [
        Indexed(index: 100, child: searchRowField()),
        Indexed(
            index: 50,
            child: Column(
              children: [
                const CustomSpacer(size: 36),
                showDateRange ? const CustomSpacer(size: 15) : const SizedBox(),
                showDateRange ? dateRangeField() : const SizedBox(),
                showDateRange ? const SizedBox() : const CustomSpacer(size: 15),
                getTransactionArrWidgets(transactionArr),
              ],
            )),
      ]),
    ]);
  }

  Widget headerStatusField() {
    return Container(
      width: wScale(327),
      alignment: Alignment.topCenter,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          statusButton('Completed', 1),
          statusButton('Pending', 2),
          statusButton('Declined', 3),
        ]),
      ]),
    );
  }

  Widget statusButton(title, type) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff70828D),
        padding: const EdgeInsets.all(0),
        textStyle:
            TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
      ),
      onPressed: () {
        handleCardType(type);
      },
      child: Container(
        width: wScale(109),
        height: hScale(35),
        padding: EdgeInsets.only(left: wScale(6), right: wScale(6)),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: type == 3 && activeType == 3
                        ? const Color(0xFFEB5757)
                        : type == activeType
                            ? const Color(0xFF29C490)
                            : const Color(0xFFEEEEEE),
                    width: type == activeType ? hScale(2) : hScale(1)))),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(14),
              color: type == 3
                  ? const Color(0xFFEB5757)
                  : type == activeType
                      ? Colors.black
                      : const Color(0xff70828D)),
        ),
      ),
    );
  }

  Widget searchField() {
    return Container(
        width: wScale(212),
        height: hScale(36),
        padding: EdgeInsets.only(left: wScale(15), right: wScale(15)),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border.all(
              color: const Color(0xff040415).withOpacity(0.1),
              width: hScale(1)),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: wScale(150),
                height: hScale(36),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: searchCtl,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)),
                    hintText: 'Type your search here',
                    hintStyle: TextStyle(
                        color: const Color(0xff040415).withOpacity(0.5),
                        fontSize: fSize(12),
                        fontWeight: FontWeight.w500),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)),
                  ),
                  style: TextStyle(
                      fontSize: fSize(12), fontWeight: FontWeight.w500),
                )),
            SizedBox(
              width: wScale(20),
              child: TextButton(
                  style: TextButton.styleFrom(
                    primary: const Color(0xff70828D),
                    padding: const EdgeInsets.all(0),
                    textStyle: TextStyle(
                        fontSize: fSize(14), color: const Color(0xff70828D)),
                  ),
                  onPressed: () {
                    handleSearch();
                  },
                  // child: const Icon( Icons.search_rounded, color: Color(0xFFBFBFBF), size: 20 ),
                  child: Image.asset(
                    'assets/search_icon.png',
                    fit: BoxFit.contain,
                    width: wScale(13),
                  )),
            ),
          ],
        ));
  }

  Widget searchRowField() {
    return Stack(overflow: Overflow.visible, children: [
      searchRow(),
      showCalendarModal
          ? Positioned(top: hScale(50), right: 0, child: calendarModalField())
          : const SizedBox()
    ]);
  }

  Widget searchRow() {
    return Container(
        width: wScale(327),
        height: hScale(500),
        alignment: Alignment.topCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            searchField(),
            Container(
              width: wScale(43),
              height: wScale(36),
              decoration: BoxDecoration(
                color: const Color(0xFFA3A3A3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: wScale(12))),
                child: Image.asset('assets/calendar.png',
                    fit: BoxFit.contain, width: wScale(24)),
                onPressed: () {
                  handleCalendar();
                },
              ),
            ),
            SizedBox(
              width: wScale(40),
              height: hScale(36),
              child: TextButton(
                style: TextButton.styleFrom(
                  primary: const Color(0xff29C490),
                  padding: const EdgeInsets.all(0),
                  textStyle: TextStyle(
                      fontSize: fSize(12),
                      color: const Color(0xff29C490),
                      decoration: TextDecoration.underline),
                ),
                onPressed: () {
                  handleExport();
                },
                child: const Text('Export'),
              ),
            )
          ],
        ));
  }

  Widget getTransactionArrWidgets(arr) {
    return Column(
        children: arr.map<Widget>((item) {
      return TransactionItem(
        date: item['date'],
        time: item['time'],
        transactionName: item['transactionName'],
        userName: item['userName'],
        cardNum: item['cardNum'],
        value: item['value'],
        status: item['status'],
      );
    }).toList());
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
              const CustomSpacer(size: 11),
              dateField(1),
              const CustomSpacer(size: 23),
              dateField(2),
              const CustomSpacer(size: 17),
              searchButton(),
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
                    controller: type == 1 ? startDateCtl : endDateCtl,
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
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(
            2000), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2101));

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      setState(() {
        if (type == 1) {
          startDateCtl.text = formattedDate;
        } else {
          endDateCtl.text = formattedDate;
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
            handleSearch();
          },
          child: Text("Search",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget calendarModalField() {
    return Container(
      width: wScale(177),
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
          modalButton('Last 7 Days', 1),
          modalButton('Last 30 Days', 2),
          modalButton('Last 90 Days', 3),
          modalButton('Date Range', 4),
        ],
      ),
    );
  }

  Widget modalButton(title, type) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: dateType == type ? const Color(0xFF29C490) : Colors.black,
        // padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
        textStyle: TextStyle(fontSize: fSize(14), color: Colors.black),
      ),
      onPressed: () {
        setDateType(type);
      },
      child: Container(
        width: wScale(177),
        // padding: EdgeInsets.only(top:hScale(6), bottom: hScale(6)),
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: fSize(12)),
        ),
      ),
    );
  }
}

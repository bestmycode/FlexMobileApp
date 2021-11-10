import 'package:flexflutter/ui/main/cards/physical_my_card.dart';
import 'package:flexflutter/ui/main/cards/physical_team_card.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flexflutter/ui/widgets/custom_textfield.dart';
import 'package:flexflutter/ui/widgets/transaction_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

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
    {'date':'21 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage1', 'status':'Cancelled', 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'22 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage2', 'status':'Cancelled', 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'23 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage3', 'status':'Cancelled', 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'24 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage4', 'status':'Cancelled', 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'25 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage5', 'status':'Cancelled', 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'26 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage6', 'status':'Cancelled', 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'27 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage7', 'status':'Cancelled', 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'}

  ];

  int activeType = 1;
  bool showDateRange = false;
  final searchCtl = TextEditingController();
  final startDateCtl = TextEditingController();
  final endDateCtl = TextEditingController();

  handleCardType(type) {
    setState(() {
      activeType = type;
    });
  }

  handleSearch() {

  }

  handleCalendar() {
    setState(() {
      showDateRange = !showDateRange;
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
        headerStatusField(),
        const CustomSpacer(size: 17),
        searchRow(),
        showDateRange ? dateRangeField() : const SizedBox(),
        const CustomSpacer(size: 15),
        getTransactionArrWidgets(transactionArr),
      ]
    );
  }

  Widget headerStatusField() {
    return Container(
      width: wScale(327),
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              statusButton('Completed', 1),
              statusButton('Pending', 2),
              statusButton('Declined', 3),
            ]
          ),
        ]
      ),
    );
  }

  Widget statusButton(title, type) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff70828D),
        padding: const EdgeInsets.all(0),
        textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
      ),
      onPressed: () { handleCardType(type); },
      child: Container(
        width: wScale(109),
        height: hScale(35),
        padding: EdgeInsets.only(left: wScale(6),right: wScale(6)),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(
                color: type == 3 && activeType == 3 ? const Color(0xFFEB5757) : type == activeType ? const Color(0xFF29C490): const Color(0xFFEEEEEE),
                width: type == activeType ? hScale(2): hScale(1)))
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(14),
              color: type == 3 ? Color(0xFFEB5757) : type == activeType ? Colors.black : const Color(0xff70828D)),
        ),
      ),
    );
  }

  Widget searchField() {
    return Container(
        width: wScale(273),
        height: hScale(36),
        padding: EdgeInsets.only(left: wScale(15), right: wScale(15)),
        decoration: BoxDecoration(
          color: const Color(0xffffffff),
          border: Border.all(color: Color(0xff040415), width: hScale(1)),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(hScale(10)),
            topRight: Radius.circular(hScale(10)),
            bottomLeft: Radius.circular(hScale(10)),
            bottomRight: Radius.circular(hScale(10)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: wScale(210),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: searchCtl,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0),
                    enabledBorder: const OutlineInputBorder( borderSide: BorderSide(color: Colors.transparent) ),
                    hintText: 'Card Holders , Cards…',
                    hintStyle: TextStyle(
                        color: const Color(0xff040415).withOpacity(0.5),
                        fontSize: fSize(12),
                        fontWeight: FontWeight.w500),
                    focusedBorder: const OutlineInputBorder( borderSide: BorderSide(color: Colors.transparent) ),
                  ),
                  style: TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w500),
                )
            ),
            SizedBox(
              width: wScale(20),
              child: TextButton(
                style: TextButton.styleFrom(
                  primary: const Color(0xff70828D),
                  padding: const EdgeInsets.all(0),
                  textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
                ),
                onPressed: () { handleSearch(); },
                child: const Icon( Icons.search_rounded, color: Colors.black, size: 20 ),
              ),
            ),
          ],
        )
    );
  }

  Widget searchRow() {
    return SizedBox(
      width: wScale(327),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          searchField(),
          IconButton(
            icon: Image.asset('assets/calendar.png', fit: BoxFit.contain, width: wScale(24)),
            highlightColor: Colors.transparent,
            iconSize: hScale(10),
            onPressed: () { handleCalendar();},
          )
        ],
      )
    );
  }

  Widget getTransactionArrWidgets(arr) {
    return Column(children: arr.map<Widget>((item) {
      return TransactionItem(date: item['date'], time: item['time'], transactionName: item['transactionName'], userName: item['userName'], cardNum: item['cardNum'], value:item['value'], status: item['status'],);
    }).toList());
  }

  Widget dateRangeField() {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(left: wScale(16), right: wScale(16), top: hScale(16), bottom: hScale(16)),
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
            Text('Date Range', style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w500)),
            const CustomSpacer(size: 23),
            CustomTextField(ctl: startDateCtl, hint: 'DD/MM/YYYY', label: 'Start Date'),
            const CustomSpacer(size: 23),
            CustomTextField(ctl: endDateCtl, hint: 'DD/MM/YYYY', label: 'End Date'),
            const CustomSpacer(size: 17),
            searchButton()
          ]
      )
    );
  }

  Widget searchButton() {
    return SizedBox(
        width: wScale(295),
        height: hScale(56),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
            ),
          ),
          onPressed: () { handleSearch(); },
          child: Text(
              "Search",
              style: TextStyle(color: Colors.white, fontSize: fSize(16), fontWeight: FontWeight.w700 )),
        )
    );
  }


}
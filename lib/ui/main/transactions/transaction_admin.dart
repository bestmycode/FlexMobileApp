import 'package:flexflutter/ui/widgets/custom_bottom_bar.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flexflutter/ui/widgets/transaction_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';
import 'package:flexflutter/ui/widgets/custom_textfield.dart';
import 'package:indexed/indexed.dart';

class TransactionAdmin extends StatefulWidget {
  // final CupertinoTabController controller;
  // final GlobalKey<NavigatorState> navigatorKey;
  // const TransactionAdmin({Key? key, required this.controller, required this.navigatorKey}) : super(key: key);
  const TransactionAdmin({Key? key}) : super(key: key);
  @override
  TransactionAdminState createState() => TransactionAdminState();
}

class TransactionAdminState extends State<TransactionAdmin> {

  hScale(double scale) {
    return Scale().hScale(context, scale);
  }
  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  int transactionStatus = 1;
  int dateType = 1;
  bool showDateRange = false;
  bool showModal = false;
  final searchCtl = TextEditingController();
  final startDateCtl = TextEditingController();
  final endDateCtl = TextEditingController();
  var transactionArr = [
    // status => 0: Accept, 1: Check, 2:Deposit, 3: Refund, 4: Cancelled
    {'date':'21 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage1', 'status':2, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'22 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage2', 'status':3, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'23 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage3', 'status':4, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'24 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage4', 'status':1, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'25 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage5', 'status':0, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'26 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage6', 'status':3, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'27 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage7', 'status':4, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'}

  ];
  handleDepositFunds() {

  }

  handleTransactionStatus(type) {
    setState(() {
      transactionStatus = type;
    });
  }

  handleCalendar() {
    setState(() {
      showModal = !showModal;
    });
  }

  handleSearch() {

  }

  handleSort() {

  }

  handleExport() {

  }

  setDateType(type) {
    if(type == 4) {
      setState(() {
        showDateRange = !showDateRange;
        showModal = false;
        dateType = type;
      });
    } else {
      setState(() {
        showModal = false;
        showDateRange = false;
        dateType = type;
      });
    }
  }

  handleStartDateCalendar() {

  }

  handleEndDateCalendar() {

  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
      Material(
        child: Scaffold(
            body: Stack(
                children:[
                  SingleChildScrollView(
                      padding: EdgeInsets.only(left: wScale(24), right: wScale(24)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CustomSpacer(size: 57),
                            cardValanceField(),
                            const CustomSpacer(size: 20),
                            welcomeHandleField('assets/deposit_funds.png', 27.0, "Deposit Funds"),
                            const CustomSpacer(size: 10),
                            welcomeHandleField('assets/get_credit_line.png', 27.0, "Increase Credit Line"),
                            const CustomSpacer(size: 20),
                            allTransactionField(),
                            // const CustomSpacer(size: 15),
                            Indexer(
                                children: [
                                  Indexed(index: 100, child: searchRowField()),
                                  Indexed(index: 50, child: Column(
                                    children: [
                                      const CustomSpacer(size: 35),
                                      showDateRange ? const CustomSpacer(size: 30): const SizedBox(),
                                      showDateRange ? dateRangeField() : const SizedBox(),
                                      const CustomSpacer(size: 20),
                                      getTransactionArrWidgets(transactionArr),
                                      const CustomSpacer(size: 88),
                                    ],
                                  )),
                                ]
                            ),
                          ]
                      )
                  ),
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    child: CustomBottomBar(active: 2),
                  )
                ]
            )
    )
    );
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
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF106549).withOpacity(0.1),
              spreadRadius: 6,
              blurRadius: 18,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Column(
            children: [
              moneyValue('Total Balance', '0.00', 20.0, FontWeight.bold, const Color(0xff30E7A9)),
              const CustomSpacer(size: 10),
              moneyValue('Ledger Balance', '0.00', 18.0, FontWeight.w600, const Color(0xffADD2C8)),
            ]
        )
    );
  }

  Widget moneyValue(title, value, size, weight, color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
            title,
            style: TextStyle(fontSize: fSize(14), color: Colors.white, fontWeight: FontWeight.w500)),
        Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Text("SGD ",
                  style: TextStyle(fontSize: fSize(12), fontWeight: weight, color: color, height: 1.4)),
              Text(value,
                  style: TextStyle(fontSize: fSize(size), fontWeight: weight, color: color)),
            ]
        )
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
                  borderRadius: BorderRadius.circular(10)
              ),
            ),
            onPressed: () { handleDepositFunds(); },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                    children:[
                      SizedBox(
                        height: hScale(22),
                        child: Image.asset(imageURL, fit: BoxFit.contain, width: wScale(imageScale)),
                      ),
                      SizedBox(width: wScale(18)),
                      Text(title, style: TextStyle(fontSize: fSize(12), color: const Color(0xff465158))),
                    ]
                ),
                const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xff70828D),
                    size: 24.0
                ),
              ],
            )
        )
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
              Text('All Transactions', style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w500)),
              TextButton(
                  style: TextButton.styleFrom(
                    primary: const Color(0xff70828D),
                    padding: const EdgeInsets.all(0),
                    textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
                  ),
                  onPressed: () { handleSort(); },
                  child:Row(
                    children: [
                      Icon(Icons.swap_vert_rounded, color: const Color(0xff29C490),size: hScale(18)),
                      Text('Sort by', style: TextStyle(fontSize: fSize(12)))
                    ],
                  )
              ),
            ],
          ),
          const CustomSpacer(size: 10),
          transactionStatusField()
        ],
      ),
    );
  }

  Widget transactionStatusField() {
    return Container(
      width: wScale(327),
      height: hScale(34),
      padding: EdgeInsets.all(hScale(2)),
      decoration: BoxDecoration(
        color: const Color(0xff040415).withOpacity(0.04),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(hScale(17)),
          topRight: Radius.circular(hScale(17)),
          bottomLeft: Radius.circular(hScale(17)),
          bottomRight: Radius.circular(hScale(17)),
        ),
      ),
      child: Row(
          children: [
            transactionStatusButton('Completed', 1),
            transactionStatusButton('Pending', 2),
            transactionStatusButton('Declined', 3)
          ]
      ),
    );
  }

  Widget transactionStatusButton(status, type) {
    return type == transactionStatus ?
    Container(
      width: wScale(107),
      height: hScale(35),
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(260),
        boxShadow: [
          BoxShadow(
            color: const Color(0XFF040415).withOpacity(0.1),
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
            status,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: fSize(14), fontWeight: FontWeight.w600,
                color: type != 3 ? const Color(0xFF70828D): const Color(0xFFEB5757)),
          ),
          onPressed: () { handleTransactionStatus(type); }),
    ) : TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff70828D),
        padding: const EdgeInsets.all(0),
        textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
      ),
      onPressed: () { handleTransactionStatus(type); },
      child: Container(
        width: wScale(107),
        height: hScale(30),
        alignment: Alignment.center,
        child: Text(
          status,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(14),
              color: type != 3 ? const Color(0xFF1A2831): const Color(0xFFEB5757)),
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
          color: const Color(0xffffffff),
          border: Border.all(color: Color(0xff040415).withOpacity(0.1), width: hScale(1)),
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
                width: wScale(150),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: searchCtl,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0),
                    enabledBorder: const OutlineInputBorder( borderSide: BorderSide(color: Colors.transparent) ),
                    hintText: 'Type your search here',
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
                // child: const Icon( Icons.search_rounded, color: Colors.black, size: 20 ),
                child: Image.asset('assets/search_icon.png', fit:BoxFit.contain, width: wScale(13),)
              ),
            ),
          ],
        )
    );
  }

  Widget searchRowField() {
    return Stack(
        overflow: Overflow.visible,
        children: [
          searchRow(),
          showModal ? Positioned(
              top: hScale(50),
              right:0,
              child: modalField()
          ): const SizedBox()
        ]
    );
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
                    padding: EdgeInsets.symmetric(horizontal: wScale(12))
                ),
                child: Image.asset('assets/calendar.png', fit: BoxFit.contain, width: wScale(24)),
                onPressed: () { handleCalendar();},
              ),
            ),
            SizedBox(
              width: wScale(40),
              child: TextButton(
                style: TextButton.styleFrom(
                  primary: const Color(0xff29C490),
                  padding: const EdgeInsets.all(0),
                  textStyle: TextStyle(fontSize: fSize(12), color: const Color(0xff29C490),decoration: TextDecoration.underline),
                ),
                onPressed: () { handleExport(); },
                child: const Text('Export'),
              ),
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
    return  Container(
        width: wScale(327),
        padding: EdgeInsets.only(left: wScale(16), right: wScale(16), top: hScale(16), bottom: hScale(16)),
        // margin: EdgeInsets.only(bottom: hScale(16)),
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
              const CustomSpacer(size: 11),
              Stack(
                alignment: Alignment.center,
                children: [
                  CustomTextField(ctl: startDateCtl, hint: 'DD/MM/YYYY', label: 'Start Date'),
                  Positioned(
                    // bottom: 0,
                      right: 0,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                        ),
                        child: Image.asset('assets/calendar.png', fit: BoxFit.contain, width: wScale(24)),
                        onPressed: () { handleStartDateCalendar();},
                      )
                  ),
                ],
              ),
              const CustomSpacer(size: 23),
              Stack(
                alignment: Alignment.center,
                children: [
                  CustomTextField(ctl: endDateCtl, hint: 'DD/MM/YYYY', label: 'End Date'),
                  Positioned(
                    // bottom: 0,
                      right: 0,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                        ),
                        child: Image.asset('assets/calendar.png', fit: BoxFit.contain, width: wScale(24)),
                        onPressed: () { handleEndDateCalendar();},
                      )
                  ),
                ],
              ),
              const CustomSpacer(size: 17),
              searchButton(),
              const CustomSpacer(size: 5),
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

  Widget exportButton() {
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
          onPressed: () {  },
          child: Text(
              "Export",
              style: TextStyle(color: Colors.white, fontSize: fSize(16), fontWeight: FontWeight.w700 )),
        )
    );
  }

  Widget modalField() {
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
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
        textStyle: TextStyle(fontSize: fSize(14), color: Colors.black),
      ),
      onPressed: () { setDateType(type); },
      child: Container(
        width: wScale(177),
        padding: EdgeInsets.only(top:hScale(6), bottom: hScale(6)),
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
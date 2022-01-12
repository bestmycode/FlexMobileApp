import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/transaction_item.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:indexed/indexed.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

class AllTransaction extends StatefulWidget {
  final cardID;
  const AllTransaction({Key? key, this.cardID}) : super(key: key);

  @override
  AllTransactionState createState() => AllTransactionState();
}

class AllTransactionState extends State<AllTransaction> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');

  String queryAllTransactions = Queries.QUERY_ALL_TRANSACTIONS;

  int transactionStatus = 1;
  int dateType = 1;

  bool showDateRange = false;
  bool showCalendarModal = false;
  final searchCtl = TextEditingController();
  final startDateCtl = TextEditingController();
  final endDateCtl = TextEditingController();

  handleTransactionStatus(status) {
    setState(() {
      transactionStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: wScale(327),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('All Transactions',
                    style: TextStyle(
                        fontSize: fSize(16), fontWeight: FontWeight.w500)),
              ],
            ),
            const CustomSpacer(size: 10),
            transactionStatusField()
          ],
        ),
      ),
      Indexer(children: [
        Indexed(index: 100, child: searchRowField()),
        Indexed(
            index: 50,
            child: Column(
              children: [
                const CustomSpacer(size: 45),
                showDateRange ? const CustomSpacer(size: 15) : const SizedBox(),
                showDateRange ? dateRangeField() : const SizedBox(),
                const CustomSpacer(size: 15),
                queryTransactionField(widget.cardID)
              ],
            )),
      ])
    ]);
  }

  Widget queryTransactionField(cardId) {
    var orgId = userStorage.getItem('orgId');
    return Query(
        options: QueryOptions(
          document: gql(queryAllTransactions),
          variables: {
            "flaId": cardId,
            "limit": 10,
            "offset": 0,
            "orgId": orgId,
            "status": transactionStatus == 1
                ? "COMPLETED"
                : transactionStatus == 2
                    ? "APPROVED"
                    : "DECLINED"
          },
          // pollInterval: const Duration(seconds: 10),
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF60C094))));
          }
          var transactionArr =
              result.data!['listTransactions']['financeAccountTransactions'];
          return transactionArr.length == 0
              ? Image.asset('assets/empty_transaction.png',
                  fit: BoxFit.contain, width: wScale(327))
              : getTransactionArrWidgets(transactionArr);
        });
  }

  Widget getTransactionArrWidgets(arr) {
    return Column(
        children: arr.map<Widget>((item) {
      return TransactionItem(
          accountId: item['txnFinanceAccId'],
          transactionId: item['sourceTransactionId'],
          date: '${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(item['transactionDate']))}  |  ${DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(item['transactionDate']))}',
          transactionName: item['description'],
          status: item['status'],
          userName: item['merchantName'],
          cardNum: item['pan'],
          value: item['billAmount'].toString(),
          receiptStatus: item['fxrBillAmount'] >= 0 ? 0: item['receiptStatus'] == "PAID" ? 2 : 1);
    }).toList());
  }

  Widget transactionStatusField() {
    return Container(
      width: wScale(327),
      height: hScale(34),
      padding: EdgeInsets.all(hScale(2)),
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
        transactionStatusButton('Completed', 1),
        transactionStatusButton('Pending', 2),
        transactionStatusButton('Declined', 3)
      ]),
    );
  }

  Widget transactionStatusButton(status, type) {
    return type == transactionStatus
        ? Container(
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
                      fontSize: fSize(14),
                      fontWeight: FontWeight.w600,
                      color: type != 3
                          ? const Color(0xFF70828D)
                          : const Color(0xFFEB5757)),
                ),
                onPressed: () {
                  handleTransactionStatus(type);
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
              handleTransactionStatus(type);
            },
            child: Container(
              width: wScale(107),
              height: hScale(30),
              alignment: Alignment.center,
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: fSize(14),
                    color: type != 3
                        ? const Color(0xFF1A2831)
                        : const Color(0xFFEB5757)),
              ),
            ),
          );
  }

  Widget searchRowField() {
    return Stack(overflow: Overflow.visible, children: [
      searchRow(),
      showCalendarModal
          ? Positioned(top: hScale(50), right: 0, child: calendarModalField())
          : const SizedBox()
    ]);
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

  Widget searchRow() {
    return Container(
        width: wScale(327),
        height: hScale(300),
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
                  setState(() {
                    showCalendarModal = !showCalendarModal;
                  });
                },
              ),
            ),
            SizedBox(
              width: wScale(40),
              child: TextButton(
                style: TextButton.styleFrom(
                  primary: const Color(0xff29C490),
                  padding: const EdgeInsets.all(0),
                  textStyle: TextStyle(
                      fontSize: fSize(12),
                      color: const Color(0xff29C490),
                      decoration: TextDecoration.underline),
                ),
                onPressed: () {},
                child: const Text('Export'),
              ),
            )
          ],
        ));
  }

  Widget searchField() {
    return Container(
        width: wScale(212),
        height: hScale(36),
        padding: EdgeInsets.only(left: wScale(15), right: wScale(15)),
        decoration: BoxDecoration(
          color: const Color(0xffffffff),
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
                  onPressed: () {},
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

  Widget dateRangeField() {
    return Container(
        width: wScale(327),
        padding:
            EdgeInsets.symmetric(vertical: hScale(16), horizontal: wScale(16)),
        margin: EdgeInsets.only(bottom: hScale(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(const Radius.circular(10)),
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
          onPressed: () {},
          child: Text("Search",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }
}

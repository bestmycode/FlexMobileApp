import 'dart:io';

import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/get_transaction_field.dart';
import 'package:co/utils/queries.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:share_plus/share_plus.dart';

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

  bool isLoading = false;
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');

  String queryAllTransactions = Queries.QUERY_ALL_TRANSACTIONS;
  String searchText = "";
  int transactionStatus = 1;
  int dateType = 0;
  int sortType = 0;

  bool showDateRange = false;
  bool showCalendarModal = false;
  bool showFilter = false;
  bool showDateFilter = false;
  bool isEmptyStartDate = false;
  final searchCtl = TextEditingController();
  final startDateCtl = TextEditingController();
  final endDateCtl = TextEditingController();
  final _startDateCtl = TextEditingController();
  final _endDateCtl = TextEditingController();
  var transComplete = [];
  var transApprove = [];
  var transDecline = [];
  var selectedArr = [];

  String selectedStartDate = '';
  String selectedEndDate = '';

  handleTransactionStatus(status) {
    setState(() {
      transactionStatus = status;
    });
  }

  setSortType(type) {
    setState(() {
      sortType = type;
    });
  }

  setDateType(type) {
    setState(() {
      dateType = type;
    });
    if (type == 4) {
      Navigator.of(context).pop();
      _showDateModal(context);
    }
  }

  setDateRange(start, end) {
    setState(() {
      startDateCtl.text = start;
      endDateCtl.text = end;
    });
  }

  _setDateRange(start, end) {
    setState(() {
      _startDateCtl.text = start;
      _endDateCtl.text = end;
    });
  }

  setDefaultFilter() {
    setSortType(0);
    setDateType(0);
    setDateRange('', '');
    _setDateRange('', '');
    setState(() {
      showDateFilter = false;
    });
  }

  convertLocalToDetroit(_date) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    var date = _date.split('/')[0];
    var month = months[int.parse(_date.split('/')[1]) - 1];
    var year = _date.split('/')[2];
    return '${date.length == 1 ? "0$date" : date} $month $year';
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
      String path =
          "${downloadPath}/MyPhysicalCardTransaction_${formattedDate}.csv";
      File file = File(path);
      String csv = const ListToCsvConverter().convert(rows);
      await file.writeAsString(csv);
      await Share.shareFiles([path], text: 'Transaction CSV File');
    } catch (error) {
      print("===== Error : Share CSV File =====");
      print(error);
      await Sentry.captureException(error);
      return null;
    }
  }

  Future<void> _fetchData() async {
    isLoading = true;
    var accessToken = storage.getItem("jwt_token");
    final HttpLink httpLink =
        HttpLink("https://gql.staging.fxr.one/v1/graphql");

    final AuthLink authLink = AuthLink(getToken: () async => "$accessToken");
    final Link link = authLink.concat(httpLink);
    final client = GraphQLClient(cache: GraphQLCache(), link: link);
    final orgId = userStorage.getItem('orgId');

    final transCompleteVars = {
      "flaId": widget.cardID,
      "offset": 0,
      "orgId": orgId,
      "status": "COMPLETED"
    };
    final transApproveVars = {
      "flaId": widget.cardID,
      "offset": 0,
      "orgId": orgId,
      "status": "APPROVED"
    };
    final transDeclineVars = {
      "flaId": widget.cardID,
      "offset": 0,
      "orgId": orgId,
      "status": "DECLINED"
    };
    try {
      final transCompleteOption = QueryOptions(
          document: gql(queryAllTransactions), variables: transCompleteVars);
      final transCompleteResult = await client.query(transCompleteOption);
      final transApproveOption = QueryOptions(
          document: gql(queryAllTransactions), variables: transApproveVars);
      final transApproveResult = await client.query(transApproveOption);
      final transDeclineOption = QueryOptions(
          document: gql(queryAllTransactions), variables: transDeclineVars);
      final transDeclineResult = await client.query(transDeclineOption);

      setState(() {
        transComplete = transCompleteResult.data?['listTransactions']
                ['financeAccountTransactions'] ??
            [];
        transApprove = transApproveResult.data?['listTransactions']
                ['financeAccountTransactions'] ??
            [];
        transDecline = transDeclineResult.data?['listTransactions']
                ['financeAccountTransactions'] ??
            [];
        isLoading = false;
      });
    } catch (error) {
      print("===== Error : Get All Transactions =====");
      print("===== Query : allTransactionsQuery =====");
      print(error);
      await Sentry.captureException(error);
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: wScale(327),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            height: hScale(18),
                            child: Text('All Transactions',
                                style: TextStyle(
                                    fontSize: fSize(16),
                                    fontWeight: FontWeight.w500))),
                        Container(
                          height: hScale(18),
                          alignment: Alignment.center,
                          child: TextButton(
                              onPressed: () {
                                _openFilterDialog();
                              },
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  primary: Colors.white,
                                  alignment: Alignment.center),
                              child: Row(
                                children: [
                                  Image.asset('assets/filter.png',
                                      fit: BoxFit.contain, height: hScale(12)),
                                  SizedBox(width: wScale(6)),
                                  Text('Filter',
                                      style: TextStyle(
                                          fontSize: fSize(12),
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF70828D)))
                                ],
                              )),
                        )
                      ],
                    ),
                    const CustomSpacer(size: 10),
                    transactionStatusField()
                  ],
                ),
              ),
              isLoading
                  ? Container(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF60C094))))
                  : Container(
                      // height: hScale(510),
                      child: GetTransactionField(
                          height: showDateRange ? 292.0 : 450.0,
                          transactions: transactionStatus == 1
                              ? transComplete
                              : transactionStatus == 2
                                  ? transApprove
                                  : transDecline,
                          orgName: 'MyPhysicalCardTransaction',
                          sortType: sortType,
                          dateType: dateType,
                          startDateCtl: startDateCtl,
                          endDateCtl: endDateCtl,
                          transactionStatus: transactionStatus,
                          setDateType: setDateType,
                          showDateRange: showDateRange))
            ]));
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
            transactionStatus == 1
                ? SizedBox(
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
                      onPressed: () {
                        handleExport();
                      },
                      child: const Text('Export'),
                    ),
                  )
                : SizedBox(
                    height: wScale(43),
                  )
          ],
        ));
  }

  Widget searchField() {
    return Container(
        width: wScale(transactionStatus == 1 ? 230 : 270),
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
                  onPressed: () {
                    setState(() {
                      searchText = searchCtl.text;
                    });
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
              // dateField(1),
              const CustomSpacer(size: 23),
              // dateField(2),
              const CustomSpacer(size: 17),
              searchButton(),
              const CustomSpacer(size: 5),
            ]));
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

  void _openFilterDialog() => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(hScale(24)),
          topRight: Radius.circular(hScale(24)),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
              color: Colors.white,
              child: SingleChildScrollView(
                  child: Container(
                      child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  filterOnModal(),
                  modalDevider(),
                  filterItem('Last 7 days', 1, setState),
                  filterItem('Last 30 days', 2, setState),
                  filterItem('Last 90 days', 3, setState),
                  filterItem('Date Range', 4, setState),
                  modalButtonField(setState)
                ],
              ))));
        });
      });

  Widget modalDevider() {
    return Container(
      height: hScale(1),
      color: Color(0xFF828282),
    );
  }

  Widget filterOnModal() {
    return Container(
      height: hScale(72),
      padding: EdgeInsets.symmetric(horizontal: wScale(24)),
      alignment: Alignment.center,
      child: Row(children: [
        Text('Filter',
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: fSize(16),
                fontWeight: FontWeight.w600,
                color: Color(0xFF828282)))
      ]),
    );
  }

  Widget modalButtonField(setState) {
    return Container(
      height: hScale(120),
      padding: EdgeInsets.symmetric(horizontal: wScale(24)),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              width: wScale(156),
              height: hScale(56),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFFE8E9EA),
                  side: const BorderSide(width: 0, color: Color(0xFFE8E9EA)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  setState(() {
                    sortType = 0;
                    dateType = 0;
                    showDateFilter = false;
                  });
                  setDefaultFilter();
                },
                child: Text('Clear All',
                    style: TextStyle(
                        color: Color(0xff1A2831),
                        fontSize: fSize(16),
                        fontWeight: FontWeight.w700)),
              )),
          Container(
              width: wScale(156),
              height: hScale(56),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  primary: const Color(0xff1A2831),
                  side: const BorderSide(width: 0, color: Color(0xff1A2831)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  setState(() {});
                  Navigator.of(context).pop();
                },
                child: Text('Apply',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: fSize(16),
                        fontWeight: FontWeight.w700)),
              ))
        ],
      ),
    );
  }

  Widget filterItem(title, index, setState) {
    return Container(
      height: hScale(72),
      color: dateType == index ? Color(0xFFF5FEFB) : Color(0xFFFFFFFF),
      child: TextButton(
          onPressed: () {
            setState(() {
              dateType = index;
            });
            setDateType(index);
          },
          style: TextButton.styleFrom(
            primary: const Color(0xFFF5FEFB),
            padding: EdgeInsets.symmetric(horizontal: wScale(24)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: fSize(16),
                      fontWeight: FontWeight.w600,
                      color: dateType == index
                          ? Color(0xFF0F7855)
                          : Color(0xFF606060))),
              index == 4 && endDateCtl.text != ''
                  ? Text(
                      '${convertLocalToDetroit(startDateCtl.text)} - ${convertLocalToDetroit(endDateCtl.text)}',
                      style: TextStyle(
                          fontSize: fSize(16),
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F7855)))
                  : Image.asset(
                      dateType == index
                          ? 'assets/selected_radio.png'
                          : 'assets/unselected_radio.png',
                      fit: BoxFit.contain,
                      width: wScale(24)),
            ],
          )),
    );
  }

  _showDateModal(context) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                child: showDateModalField(setState));
          });
        });
  }

  Widget showDateModalField(setState) {
    return Container(
        width: wScale(327),
        padding:
            EdgeInsets.symmetric(vertical: hScale(24), horizontal: wScale(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 4,
              blurRadius: 10,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Stack(alignment: Alignment.center, children: [
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Select Date Range',
                style: TextStyle(
                    fontSize: fSize(20),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A2831))),
            CustomSpacer(size: 40),
            dateField(1, setState),
            isEmptyStartDate
                ? Container(
                    height: hScale(24),
                    alignment: Alignment.centerLeft,
                    child: Text('Please indicate start date first.',
                        style: TextStyle(
                            fontSize: fSize(12), color: Color(0xFFEB5757))))
                : CustomSpacer(size: 24),
            dateField(2, setState),
            CustomSpacer(size: 32),
            Opacity(
                opacity:
                    startDateCtl.text == '' || endDateCtl.text == '' ? 0.5 : 1,
                child: Container(
                    width: wScale(295),
                    height: hScale(56),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        primary: const Color(0xff1A2831),
                        side: const BorderSide(
                            width: 0, color: Color(0xff1A2831)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        if (startDateCtl.text != '' && endDateCtl.text != '') {
                          setState(() {
                            _startDateCtl.text = startDateCtl.text;
                            _endDateCtl.text = endDateCtl.text;
                          });
                          _setDateRange(startDateCtl.text, endDateCtl.text);
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text('Confirm',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: fSize(16),
                              fontWeight: FontWeight.w700)),
                    )))
          ]),
          Positioned(
              top: 0,
              right: 0,
              child: SizedBox(
                  width: wScale(20),
                  height: wScale(20),
                  child: TextButton(
                      style: TextButton.styleFrom(
                        primary: const Color(0xff000000),
                        padding: const EdgeInsets.all(0),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFFC8C4D9),
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })))
        ]));
  }

  Widget dateField(type, setState) {
    return Stack(
      children: [
        Container(
          width: wScale(295),
          height: hScale(56),
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: hScale(8)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: type == 1 && isEmptyStartDate
                      ? Color(0xFFEB5757)
                      : Color(0xFF828282))),
          child: TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                padding: const EdgeInsets.all(0),
              ),
              onPressed: () {
                _openDatePicker(type, setState);
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
                          color: type == 1 && isEmptyStartDate
                              ? Color(0xFFEB5757)
                              : Color(0xFF828282),
                          fontSize: fSize(14)),
                      focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 1.0)),
                    ),
                    readOnly: true,
                    onTap: () {
                      _openDatePicker(type, setState);
                    },
                  )),
                  Container(
                      margin: EdgeInsets.only(right: wScale(20)),
                      child: Image.asset(
                          type == 1 && isEmptyStartDate
                              ? 'assets/red_calendar.png'
                              : 'assets/calendar.png',
                          fit: BoxFit.contain,
                          width: wScale(18)))
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
                    color: type == 1 && isEmptyStartDate
                        ? Color(0xFFEB5757)
                        : Color(0xFF828282))),
          ),
        )
      ],
    );
  }

  void _openDatePicker(type, setState) async {
    var initialDate = DateTime.now();
    var firstDate = DateTime(1900);
    var lastDate = DateTime.now();
    if (type == 1 && endDateCtl.text != "") {
      initialDate = DateTime.parse(
          "${startDateCtl.text.split('/')[2]}-${startDateCtl.text.split('/')[1]}-${startDateCtl.text.split('/')[0]}");
      lastDate = DateTime.parse(
          "${endDateCtl.text.split('/')[2]}-${endDateCtl.text.split('/')[1]}-${endDateCtl.text.split('/')[0]}");
    }
    if (type == 2) {
      if (startDateCtl.text == '') {
        setState(() {
          isEmptyStartDate = true;
        });
      } else {
        firstDate = DateTime.parse(
            "${startDateCtl.text.split('/')[2]}-${startDateCtl.text.split('/')[1]}-${startDateCtl.text.split('/')[0]}");
      }
    }
    String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    setState(() {
      selectedStartDate = formattedDate;
      selectedEndDate = formattedDate;
    });
    type == 2 && startDateCtl.text == ""
        ? null
        : _showiOSCalendarDialog(
            CupertinoDatePicker(
              initialDateTime: initialDate,
              minimumDate: firstDate,
              maximumDate: lastDate,
              mode: CupertinoDatePickerMode.date,
              use24hFormat: true,
              onDateTimeChanged: (DateTime newDate) {
                formattedDate = DateFormat('dd/MM/yyyy').format(newDate);
                setState(() {
                  if (type == 1) {
                    isEmptyStartDate = false;
                    startDateCtl.text = formattedDate;
                    selectedStartDate = formattedDate;
                  } else {
                    endDateCtl.text = formattedDate;
                    selectedEndDate = formattedDate;
                  }
                });
              },
            ),
            type,
            setState);
  }

  void _showiOSCalendarDialog(child, type, setState) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
            height: hScale(812),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: wScale(327),
                  height: hScale(74),
                  padding: EdgeInsets.symmetric(horizontal: wScale(16)),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(hScale(10)),
                      topRight: Radius.circular(hScale(10)),
                    ),
                  ),
                  child:
                      Stack(alignment: AlignmentDirectional.center, children: [
                    Material(
                        child: Text(type == 1 ? 'Start Date' : 'End Date',
                            style: TextStyle(
                                fontSize: fSize(22),
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF251F39)))),
                    Positioned(
                        top: hScale(20),
                        right: 0,
                        child: SizedBox(
                            width: wScale(20),
                            height: wScale(20),
                            child: TextButton(
                                style: TextButton.styleFrom(
                                  primary: const Color(0xff000000),
                                  padding: const EdgeInsets.all(0),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFFC8C4D9),
                                  size: 24,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                })))
                  ]),
                ),
                Container(
                    width: wScale(327),
                    height: hScale(180),
                    color: Colors.white,
                    child: SafeArea(
                      top: false,
                      child: child,
                    )),
                Container(
                  width: wScale(327),
                  padding: EdgeInsets.only(
                      top: hScale(30),
                      left: wScale(16),
                      right: wScale(16),
                      bottom: hScale(20)),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(hScale(10)),
                      bottomRight: Radius.circular(hScale(10)),
                    ),
                  ),
                  child: Container(
                      width: wScale(295),
                      height: hScale(56),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          primary: const Color(0xff1A2831),
                          side: const BorderSide(
                              width: 0, color: Color(0xff1A2831)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          if (type == 1) {
                            setState(() {
                              startDateCtl.text = selectedStartDate;
                            });
                            setDateRange(selectedStartDate, endDateCtl.text);
                          } else {
                            setState(() {
                              endDateCtl.text = selectedEndDate;
                            });
                            setDateRange(startDateCtl.text, selectedEndDate);
                          }

                          Navigator.of(context).pop();
                        },
                        child: Text('Next',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: fSize(16),
                                fontWeight: FontWeight.w700)),
                      )),
                ),
              ],
            )));
  }
}

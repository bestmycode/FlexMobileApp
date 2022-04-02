import 'dart:io';

import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/get_transaction_field.dart';
import 'package:co/ui/widgets/transaction_item.dart';
import 'package:co/utils/queries.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:indexed/indexed.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:share_plus/share_plus.dart';

class TransactionUser extends StatefulWidget {
  const TransactionUser({Key? key}) : super(key: key);

  @override
  TransactionUserState createState() => TransactionUserState();
}

class TransactionUserState extends State<TransactionUser>
    with SingleTickerProviderStateMixin {
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
  int dateType = 0;
  var selectedTransactions;
  bool showDateRange = false;
  bool showModal = false;
  bool showExportDateRange = false;
  bool showCalendarModal = false;
  final searchCtl = TextEditingController();
  final startDateCtl = TextEditingController();
  final endDateCtl = TextEditingController();
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String getUserAccountSummary = Queries.QUERY_USER_ACCOUNT_SUMMARY;
  String getRecentTransactions =
      Queries.QUERY_ALL_TRANSACTIONS_TAB_PANE_CONTENTS;

  bool isLoading = false;
  var accountData = null;
  var transComplete = [];
  var transPending = [];
  var transDecline = [];
  late TabController tabController;

  bool showDateFilter = false;
  bool isEmptyStartDate = false;
  int sortType = 0;
  final _startDateCtl = TextEditingController();
  final _endDateCtl = TextEditingController();

  String selectedStartDate = '';
  String selectedEndDate = '';

  handleDepositFunds() {}

  handleTransactionStatus(type) {
    setState(() {
      transactionStatus = type;
    });
  }

  handleSort() {
    setState(() {
      showModal = !showModal;
    });
  }

  handleSearch() {}

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
    for (int i = 0; i < selectedTransactions.length; i++) {
      var row = [];
      var cardNum = selectedTransactions[i]['pan'];
      var cardNumber = cardNum.substring(cardNum.length - 4, cardNum.length);
      row.add(selectedTransactions[i]['owner']);
      row.add(selectedTransactions[i]['description']);
      row.add(selectedTransactions[i]['paymentMethod']);
      row.add("**** **** **** ${cardNumber}");
      row.add(
          "${DateFormat('MM/dd/yyyy kk:mm a').format(DateTime.fromMillisecondsSinceEpoch(selectedTransactions[i]['transactionDate']))}");
      row.add(selectedTransactions[i]['status']);
      row.add(selectedTransactions[i]['transactionAmount']);
      row.add(selectedTransactions[i]['transactionCurrency']);
      row.add(selectedTransactions[i]['billAmount']);
      row.add(selectedTransactions[i]['billCurrency']);
      row.add(selectedTransactions[i]['fxrBillAmount']);
      row.add(selectedTransactions[i]['odAmount']);

      rows.add(row);
    }
    try {
      final Directory? download = await getApplicationDocumentsDirectory();
      final String downloadPath = download!.path;
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd-MM-yyyy').format(now);
      String path = "${downloadPath}/MyTransaction_${formattedDate}.csv";
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

  setDateType(type) {
    setState(() {
      dateType = type;
    });
    if (type == 4) {
      Navigator.of(context).pop();
      _showDateModal(context);
    }
  }

  setSortType(type) {
    setState(() {
      sortType = type;
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

  Future<void> setTransaction(listTransactions) async {
    setState(() {
      selectedTransactions = listTransactions;
    });
  }

  _handleTabChange() {
    // setState(() {
    //   tabIndex = tabController.index;
    // });
    // setDefaultFilter();
  }

  Future<void> _fetchData() async {
    isLoading = true;
    var accessToken = storage.getItem("jwt_token");
    final HttpLink httpLink =
        HttpLink("https://gql.staging.fxr.one/v1/graphql");

    final AuthLink authLink = AuthLink(getToken: () async => "$accessToken");
    final Link link = authLink.concat(httpLink);
    final client = GraphQLClient(cache: GraphQLCache(), link: link);

    final accountVars = {
      'orgId': userStorage.getItem("orgId"),
      'isAdmin': false
    };

    final transVars1 = {
      'orgId': userStorage.getItem('orgId'),
      'userId': userStorage.getItem('userId'),
      'filterArgs': 'payment_method=',
      'offset': 0,
      'limit': 100,
      'status': "COMPLETED"
    };
    final transVars2 = {
      'orgId': userStorage.getItem('orgId'),
      'userId': userStorage.getItem('userId'),
      'filterArgs': 'payment_method=',
      'offset': 0,
      'limit': 100,
      'status': "APPROVED"
    };
    final transVars3 = {
      'orgId': userStorage.getItem('orgId'),
      'userId': userStorage.getItem('userId'),
      'filterArgs': 'payment_method=',
      'offset': 0,
      'limit': 100,
      'status': "DECLINED"
    };
    try {
      final accountSummaryOption = QueryOptions(
          document: gql(getUserAccountSummary), variables: accountVars);
      final accountSummaryResult = await client.query(accountSummaryOption);

      final queryOptions1 = QueryOptions(
          document: gql(getRecentTransactions), variables: transVars1);
      final transactionCompleteResult = await client.query(queryOptions1);
      final queryOption2 = QueryOptions(
          document: gql(getRecentTransactions), variables: transVars2);
      final transactionApproveResult = await client.query(queryOption2);
      final queryOptions3 = QueryOptions(
          document: gql(getRecentTransactions), variables: transVars3);
      final transactionDeclineResult = await client.query(queryOptions3);

      setState(() {
        accountData =
            accountSummaryResult.data?['readUserFinanceAccountSummary'] ?? {};
        transComplete = transactionCompleteResult.data?['listTransactions']
                ['financeAccountTransactions'] ??
            [];
        transPending = transactionApproveResult.data?['listTransactions']
                ['financeAccountTransactions'] ??
            [];
        transDecline = transactionDeclineResult.data?['listTransactions']
                ['financeAccountTransactions'] ??
            [];
        isLoading = false;
      });
    } catch (error) {
      print("===== Error : Get User Transactions =====");
      print("===== Query : allTransactionsTabPaneContents =====");
      print(error);
      await Sentry.captureException(error);
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    tabController = TabController(length: 3, initialIndex: 0, vsync: this);
    tabController.addListener(_handleTabChange);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CustomLoading()
        : Material(
            child: Scaffold(
                body: Stack(children: [
            Container(
                height: hScale(812),
                child: SingleChildScrollView(
                    child: Align(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                      const CustomSpacer(size: 57),
                      cardValanceField(),
                      const CustomSpacer(size: 20),
                      transactionField()
                    ])))),
            const Positioned(
              bottom: 0,
              left: 0,
              child: CustomBottomBar(active: 2),
            )
          ])));
  }

  Widget transactionField() {
    return Column(
      children: [
        Container(
            width: wScale(327),
            height: hScale(30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('All Transactions',
                    style: TextStyle(
                        fontSize: fSize(16), fontWeight: FontWeight.w500)),
                TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color(0xFF70828D),
                      padding: const EdgeInsets.all(0),
                      textStyle: TextStyle(
                          fontSize: fSize(14), color: const Color(0xFF70828D)),
                    ),
                    onPressed: () {
                      // handleSort();
                      _openSortByDialog();
                    },
                    child: Row(
                      children: [
                        Icon(Icons.swap_vert_rounded,
                            color: const Color(0xFF29C490), size: hScale(18)),
                        Text('Sort by', style: TextStyle(fontSize: fSize(12)))
                      ],
                    )),
              ],
            )),
        tab_Controller()
      ],
    );
  }

  Widget cardValanceField() {
    return Container(
        width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
            .size
            .width,
        margin: EdgeInsets.only(left: wScale(24), right: wScale(24)),
        padding: EdgeInsets.all(hScale(24)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(hScale(10)),
          image: const DecorationImage(
            image: AssetImage("assets/dashboard_header.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(children: [
          moneyValue(
              'Month to Date Spend',
              accountData == null
                  ? '-'
                  : accountData['data']['totalSpend'].toStringAsFixed(2),
              20.0,
              FontWeight.bold,
              const Color(0xff30E7A9)),
          // const CustomSpacer(
          //   size: 8,
          // ),
          // moneyValue('Ledger Balance', '0.00', 16.0, FontWeight.w600,
          //     const Color(0xffADD2C8)),
        ]));
  }

  Widget moneyValue(title, value, size, weight, color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(fontSize: fSize(12), color: Colors.white)),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("SGD  ",
              style: TextStyle(
                fontSize: fSize(12),
                fontWeight: weight,
                color: color,
                height: 1,
              )),
          Text(value,
              style: TextStyle(
                fontSize: fSize(size),
                fontWeight: weight,
                color: color,
                height: 1,
              )),
        ])
      ],
    );
  }

  Widget tab_Controller() {
    return DefaultTabController(
      length: 3,
      child: Container(
        padding: EdgeInsets.all(wScale(1)),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: wScale(327),
                height: hScale(34),
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Color(0xFF040415).withOpacity(0.04),
                ),
                child: TabBar(
                  controller: tabController,
                  unselectedLabelColor: Color(0xFF70828D),
                  labelPadding: const EdgeInsets.all(1),
                  labelStyle: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF70828D),
                  ),
                  labelColor: Color(0xFF040415),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xFFFFFFFF),
                  ),
                  tabs: [
                    Tab(
                      child: transactionStatusButton('Completed', 1),
                    ),
                    Tab(
                      child: transactionStatusButton('Pending', 2),
                    ),
                    Tab(
                      child: transactionStatusButton('Declined', 3),
                    ),
                  ],
                ),
              ),
            ),
            Container(
                height: hScale(550),
                child: TabBarView(
                  children: [
                    transactionBody(1),
                    transactionBody(2),
                    transactionBody(3)
                  ],
                  controller: tabController,
                )),
          ],
        ),
      ),
    );
  }

  Widget transactionStatusButton(status, type) {
    return Container(
      width: wScale(107),
      height: hScale(32),
      alignment: Alignment.center,
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: fSize(14),
            color:
                type != 3 ? const Color(0xFF1A2831) : const Color(0xFFEB5757)),
      ),
    );
  }

  Widget transactionBody(transactionStatus) {
    return GetTransactionField(
        height: 462.0,
        transactions: transactionStatus == 1
            ? transComplete
            : transactionStatus == 2
                ? transPending
                : transDecline,
        sortType: sortType,
        dateType: dateType,
        startDateCtl: _startDateCtl,
        endDateCtl: _endDateCtl,
        orgName: 'MyTransaction',
        transactionStatus: transactionStatus,
        handleSearch: handleSearch,
        handleShowExport: handleShowExport,
        showExportDateRange: showExportDateRange,
        showDateRange: showDateRange);
  }

  void _openSortByDialog() => showModalBottomSheet<void>(
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
                  sortbyOnModal(),
                  modalDevider(),
                  sortItem('Date Charged', 'New to Old', 0, setState),
                  sortItem('Date Charged', 'Old to New', 1, setState),
                  sortItem('Card No.', 'Ascending Order', 2, setState),
                  sortItem('Card No.', 'Descending Order', 3, setState),
                  modalDevider(),
                  filterOnModal(setState),
                  modalDevider(),
                  showDateFilter
                      ? Column(children: [
                          filterItem('Last 7 days', 1, setState),
                          filterItem('Last 30 days', 2, setState),
                          filterItem('Last 90 days', 3, setState),
                          filterItem('Date Range', 4, setState),
                        ])
                      : SizedBox(),
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

  Widget sortbyOnModal() {
    return Container(
      height: hScale(72),
      padding: EdgeInsets.symmetric(horizontal: wScale(24)),
      alignment: Alignment.center,
      child: Row(children: [
        Text('Sort By',
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: fSize(16),
                fontWeight: FontWeight.w600,
                color: Color(0xFF828282)))
      ]),
    );
  }

  Widget filterOnModal(setState) {
    return Container(
      height: hScale(72),
      alignment: Alignment.center,
      child: TextButton(
          onPressed: () {
            setState(() {
              showDateFilter = !showDateFilter;
            });
          },
          style: TextButton.styleFrom(
            primary: const Color(0xFFFFFFFF),
            padding: EdgeInsets.symmetric(horizontal: wScale(24)),
          ),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Filter',
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF828282))),
            Container(
                width: wScale(24),
                child: Image.asset(
                    showDateFilter ? 'assets/minus.png' : 'assets/plus.png',
                    fit: BoxFit.contain,
                    width: wScale(24)))
          ])),
    );
  }

  Widget sortItem(title, value, index, setState) {
    return Container(
      height: hScale(72),
      color: sortType == index ? Color(0xFFF5FEFB) : Color(0xFFFFFFFF),
      child: TextButton(
          onPressed: () {
            setState(() {
              sortType = index;
            });
            setSortType(index);
          },
          style: TextButton.styleFrom(
            primary: const Color(0xFFF5FEFB),
            padding: EdgeInsets.symmetric(horizontal: wScale(24)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text("${title}: ",
                      style: TextStyle(
                          fontSize: fSize(16),
                          fontWeight: FontWeight.w600,
                          color: sortType == index
                              ? Color(0xFF0F7855)
                              : Color(0xFF606060))),
                  Text(value,
                      style: TextStyle(
                          fontSize: fSize(16),
                          fontWeight: FontWeight.w400,
                          color: sortType == index
                              ? Color(0xFF0F7855)
                              : Color(0xFF606060)))
                ],
              ),
              sortType == index
                  ? Icon(Icons.check, color: Color(0xFF0F7855), size: 30.0)
                  : SizedBox()
            ],
          )),
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
                  : Container(
                      width: wScale(24),
                      child: Icon(
                          dateType == index
                              ? Icons.check_circle_outlined
                              : Icons.circle_outlined,
                          color: dateType == index
                              ? Color(0xFF0F7855)
                              : Color(0xFF606060),
                          size: 24.0),
                    )
            ],
          )),
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

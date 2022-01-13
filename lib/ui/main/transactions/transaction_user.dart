import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/transaction_item.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:indexed/indexed.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

class TransactionUser extends StatefulWidget {
  // final CupertinoTabController controller;
  // final GlobalKey<NavigatorState> navigatorKey;
  // const TransactionUser({Key? key, required this.controller, required this.navigatorKey}) : super(key: key);
  const TransactionUser({Key? key}) : super(key: key);

  @override
  TransactionUserState createState() => TransactionUserState();
}

class TransactionUserState extends State<TransactionUser> {
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
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String getUserAccountSummary = Queries.QUERY_USER_ACCOUNT_SUMMARY;
  String getRecentTransactions = Queries.QUERY_RECENT_TRANSACTIONS;

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

  handleExport() {
    setState(() {
      showDateRange = !showDateRange;
    });
  }

  setDateType(type) {
    setState(() {
      showModal = false;
      dateType = type;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    return Material(
        child: Scaffold(
            body: Query(
                options: QueryOptions(
                    document: gql(getUserAccountSummary),
                    variables: {
                      'orgId': userStorage.getItem('orgId'),
                      'isAdmin': false
                    }
                    // pollInterval: const Duration(seconds: 10),
                    ),
                builder: (QueryResult accountSummary,
                    {VoidCallback? refetch, FetchMore? fetchMore}) {
                  if (accountSummary.hasException) {
                    return Text(accountSummary.exception.toString());
                  }

                  if (accountSummary.isLoading) {
                    return CustomLoading();
                  }
                  var businessAccountSummary =
                      accountSummary.data!['readUserFinanceAccountSummary'];
                  return Query(
                      options: QueryOptions(
                        document: gql(getRecentTransactions),
                        variables: {
                          'orgId': userStorage.getItem('orgId'),
                          'offset': 0,
                          'status': "PENDING_OR_COMPLETED"
                        },
                      ),
                      builder: (QueryResult recentTransactionResult,
                          {VoidCallback? refetch, FetchMore? fetchMore}) {
                        if (recentTransactionResult.hasException) {
                          return Text(
                              recentTransactionResult.exception.toString());
                        }

                        if (recentTransactionResult.isLoading) {
                          return CustomLoading();
                        }
                        var listTransactions =
                            recentTransactionResult.data!['listTransactions']
                                ['financeAccountTransactions'];
                        return mainHome(
                            businessAccountSummary, listTransactions);
                      });
                })));
  }

  Widget mainHome(businessAccountSummary, listTransactions) {
    return Stack(children: [
      SingleChildScrollView(
          padding: EdgeInsets.only(left: wScale(24), right: wScale(24)),
          child: Container(
              height: hScale(812),
              child: Align(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const CustomSpacer(size: 57),
                    cardValanceField(businessAccountSummary),
                    const CustomSpacer(size: 20),
                    // welcomeHandleField(
                    //     'assets/deposit_funds.png', 27.0, "Deposit Funds"),
                    // const CustomSpacer(size: 10),
                    // welcomeHandleField(
                    //     'assets/get_credit_line.png', 21.0, "Increase Credit Line"),
                    // const CustomSpacer(size: 20),
                    Indexer(children: [
                      Indexed(index: 100, child: searchRowField()),
                      Indexed(
                          index: 50,
                          child: Column(
                            children: [
                              const CustomSpacer(size: 50),
                              transactionStatusField(),
                              showDateRange
                                  ? const CustomSpacer(size: 15)
                                  : const SizedBox(),
                              showDateRange
                                  ? dateRangeField()
                                  : const SizedBox(),
                              const CustomSpacer(size: 15),
                              getTransactionArrWidgets(listTransactions),
                              const CustomSpacer(size: 88),
                            ],
                          )),
                    ])
                  ])))),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 2),
      )
    ]);
  }

  Widget cardValanceField(businessAccountSummary) {
    return Container(
        width: MediaQuery.of(context).size.width,
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
              businessAccountSummary == null
                  ? '-'
                  : businessAccountSummary['data']['totalSpend']
                      .toStringAsFixed(2),
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

  Widget welcomeHandleField(imageURL, imageScale, title) {
    return SizedBox(
        height: hScale(63),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: const Color(0xffffffff),
              side: const BorderSide(width: 0, color: Color(0xffffffff)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              handleDepositFunds();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(children: [
                  SizedBox(
                    width: hScale(22),
                    child: Image.asset(imageURL,
                        fit: BoxFit.contain, width: wScale(imageScale)),
                  ),
                  SizedBox(width: wScale(18)),
                  Text(title,
                      style: TextStyle(
                          fontSize: fSize(14), color: const Color(0xff465158))),
                ]),
                const Icon(Icons.arrow_forward_rounded,
                    color: Color(0xff70828D), size: 24.0),
              ],
            )));
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
        transactionStatusButton('Completed', 1, const Color(0xFF70828D)),
        transactionStatusButton('Pending', 2, const Color(0xFF1A2831)),
        transactionStatusButton('Declined', 3, const Color(0xFFEB5757))
      ]),
    );
  }

  Widget transactionStatusButton(status, type, textColor) {
    return type == transactionStatus
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0),
              primary: const Color(0xffffffff),
              side: const BorderSide(width: 0, color: Color(0xffffffff)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
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
                style: TextStyle(fontSize: fSize(14), color: textColor),
              ),
            ))
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
                style: TextStyle(fontSize: fSize(14), color: textColor),
              ),
            ),
          );
  }

  Widget searchRowField() {
    return Stack(overflow: Overflow.visible, children: [
      searchRow(),
      showModal
          ? Positioned(top: hScale(50), right: 0, child: modalField())
          : const SizedBox()
    ]);
  }

  Widget searchRow() {
    return Container(
        width: wScale(327),
        height: hScale(200),
        alignment: Alignment.topCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('All Transactions',
                style: TextStyle(
                    fontSize: fSize(16), fontWeight: FontWeight.w500)),
            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    primary: const Color(0xff30E7A9),
                    textStyle: TextStyle(
                        fontSize: fSize(12),
                        color: const Color(0xff30E7A9),
                        decoration: TextDecoration.underline),
                  ),
                  onPressed: () {
                    handleExport();
                  },
                  child: const Text('Export'),
                ),
                TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color(0xff70828D),
                      padding: const EdgeInsets.all(0),
                      textStyle: TextStyle(
                          fontSize: fSize(14), color: const Color(0xff70828D)),
                    ),
                    onPressed: () {
                      handleSort();
                    },
                    child: Row(
                      children: [
                        Icon(Icons.swap_vert_rounded,
                            color: const Color(0xff29C490), size: hScale(18)),
                        Text('Sort by', style: TextStyle(fontSize: fSize(12)))
                      ],
                    )),
              ],
            )
          ],
        ));
  }

  Widget getTransactionArrWidgets(arr) {
    return arr.length == 0
        ? Image.asset('assets/empty_transaction.png',
            fit: BoxFit.contain, width: wScale(327))
        : Column(
            children: arr.map<Widget>((item) {
            return TransactionItem(
                accountId: item['txnFinanceAccId'],
                transactionId: item['sourceTransactionId'],
                date:
                    '${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(item['transactionDate']))}  |  ${DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(item['transactionDate']))}',
                transactionName: item['description'],
                status: item['status'],
                userName: item['merchantName'],
                cardNum: item['pan'],
                value: item['fxrBillAmount'].toStringAsFixed(2),
                receiptStatus: item['fxrBillAmount'] >= 0
                    ? 0
                    : item['receiptStatus'] == "PAID"
                        ? 2
                        : 1);
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
          borderRadius: BorderRadius.all(Radius.circular(10)),
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
              CustomTextField(
                  ctl: startDateCtl, hint: 'DD/MM/YYYY', label: 'Start Date'),
              const CustomSpacer(size: 23),
              CustomTextField(
                  ctl: endDateCtl, hint: 'DD/MM/YYYY', label: 'End Date'),
              const CustomSpacer(size: 17),
              exportButton()
            ]));
  }

  Widget exportButton() {
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
          child: Text("Export",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
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
          modalButton('Sort by newest on top', 1),
          modalButton('Sort by oldest on top', 2),
          modalButton('Sort by card type', 3),
        ],
      ),
    );
  }

  Widget modalButton(title, type) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: dateType == type ? const Color(0xFF29C490) : Colors.black,
        padding: EdgeInsets.only(
            top: hScale(10),
            bottom: hScale(10),
            left: wScale(16),
            right: wScale(16)),
        textStyle: TextStyle(fontSize: fSize(14), color: Colors.black),
      ),
      onPressed: () {
        setDateType(type);
      },
      child: Container(
        width: wScale(177),
        padding: EdgeInsets.only(top: hScale(6), bottom: hScale(6)),
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

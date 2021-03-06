import 'package:co/constants/constants.dart';
import 'package:co/ui/main/credit/credit.dart';
import 'package:co/ui/main/credit/credit_transaction_type.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/ui/widgets/custom_no_internet.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'credit_payment.dart';

class CreditMainScreen extends StatefulWidget {
  final flaId;
  final listUserFinanceAccounts;
  const CreditMainScreen({Key? key, this.flaId, this.listUserFinanceAccounts})
      : super(key: key);

  @override
  CreditMainScreenState createState() => CreditMainScreenState();
}

class CreditMainScreenState extends State<CreditMainScreen> {
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
  bool isSuspended = false;

  int FPL_enhancement = 1; // 1: active, 2: suspended, 3: closed
  int transactionType = 1;
  int billedType = 1;

  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');

  String readBusinessAccountSummary = Queries.QUERY_BUSINESS_ACCOUNT_SUMMARY;
  String billedUnbilledTransactions =
      Queries.QUERY_BILLED_UNBILLED_TRANSACTIONS;
  String billingStatementsTable = Queries.QUERY_BILLING_STATEMENTTABLE;

  var billedTrans = {};
  var unbilledTrans = {};
  var listBills = {};

  handleDepositFunds(data, flag) {
    if (flag == 'payment') {
      Navigator.of(context).push(
        CupertinoPageRoute(
            builder: (context) => CreditPaymentScreen(data: data)),
      );
    } else if (flag == 'deposit') {}
  }

  handleCreditline(title) {
    // Intercom.displayMessenger();
    debugPrint(title);

    String msg = "";

    if (title == "Increase Credit Line") {
      msg = '''Hello Flex,

I would like to apply for increase in Flex Plus Credit line [SGD 10,000 or 30,000 or 100,000]. 

Please reach out to me to process the application further.

Thanks.''';
    } else {
      msg = '''Hello Flex,

I would like to apply for Flex plus credit line [SGD 3000 or 10,000 or 30,000 or 100,000] 

Please reach out to me to process the application further.

Thanks.''';
    }

    Intercom.displayMessageComposer(msg);
  }

  _onBackPressed(context) {
    Navigator.of(context).pushReplacementNamed(HOME_SCREEN);
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

    final billedVars = {
      "orgId": orgId,
      "status": "BILLED",
      "flaId": widget.flaId
    };
    final unbilledVars = {
      "orgId": orgId,
      "status": "PENDING_OR_UNBILLED",
      "flaId": widget.flaId
    };
    final statementVars = {"fplId": widget.flaId};
    try {
      final transActiveOption = QueryOptions(
          document: gql(billedUnbilledTransactions), variables: billedVars);
      final billedResult = await client.query(transActiveOption);
      final transInactiveOption = QueryOptions(
          document: gql(billedUnbilledTransactions), variables: unbilledVars);
      final unbilledResult = await client.query(transInactiveOption);
      final statementOption = QueryOptions(
          document: gql(billingStatementsTable), variables: statementVars);
      final statementResult = await client.query(statementOption);
      setState(() {
        billedTrans = billedResult.data?['listTransactions'] ?? {};
        unbilledTrans = unbilledResult.data?['listTransactions'] ?? {};
        listBills = statementResult.data?['listBills'] ?? {};
        isLoading = false;
      });
    } catch (error) {
      print("===== Error : Credit Transactions Data =====");
      print(
          "===== Query : billedUnbilledTransactions, billingStatementsTable =====");
      print(error);
      await Sentry.captureException(error);
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    setState(() {
      isSuspended = FPL_enhancement == 2 ||
              widget.listUserFinanceAccounts['data']['creditLine']['status'] !=
                  'ACTIVE'
          ? true
          : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CustomLoading()
        : mainHome(widget.listUserFinanceAccounts);
  }

  Widget mainHome(listUserFinanceAccounts) {
    return WillPopScope(
        onWillPop: () => _onBackPressed(context),
        child: Scaffold(
            body: Stack(children: [
          SingleChildScrollView(
              child: Column(children: [
            const CustomSpacer(size: 44),
            Row(children: [
              SizedBox(width: wScale(20)),
              backButton(),
              SizedBox(width: wScale(20)),
              Text('Flex PLUS Credit',
                  style: TextStyle(
                      fontSize: fSize(20), fontWeight: FontWeight.w600))
            ]),
            Container(
                padding: EdgeInsets.symmetric(horizontal: wScale(24)),
                child: Column(
                  children: [
                    const CustomSpacer(size: 20),
                    titleField(
                        listUserFinanceAccounts['data']['creditLine']['name']),
                    FPL_enhancement == 2 ||
                            listUserFinanceAccounts['data']['creditLine']
                                    ['status'] !=
                                'ACTIVE'
                        ? const CustomSpacer(size: 15)
                        : const SizedBox(),
                    isSuspended ? suspendedField() : const SizedBox(),
                    const CustomSpacer(size: 16),
                    cardAvailableValanceField(
                        listUserFinanceAccounts['data']['creditLine']),
                    const CustomSpacer(size: 10),
                    cardTotalValanceField(
                        listUserFinanceAccounts['data']['creditLine']),
                    FPL_enhancement == 1
                        ? const CustomSpacer(size: 30)
                        : const SizedBox(),
                    FPL_enhancement == 1
                        ? isSuspended
                            ? SizedBox()
                            : welcomeHandleField(
                                listUserFinanceAccounts['data'],
                                'assets/deposit_funds.png',
                                27.0,
                                FPL_enhancement == 3
                                    ? "Get Credit Line"
                                    : "Increase Credit Line",
                                'deposit')
                        : const SizedBox(),
                    isSuspended ? SizedBox() : CustomSpacer(size: 10),
                    welcomeHandleField(listUserFinanceAccounts['data'],
                        'assets/green_card.png', 21.0, "Payment", 'payment'),
                    const CustomSpacer(size: 26),
                  ],
                )),
            CreditTransactionTypeSection(
                billedTrans: billedTrans,
                unbilledTrans: unbilledTrans,
                listBills: listBills),
            const CustomSpacer(size: 88),
          ])),
          const Positioned(
            bottom: 0,
            left: 0,
            child: CustomBottomBar(active: 3),
          )
        ])));
  }

  Widget backButton() {
    return Container(
      width: hScale(40),
      height: hScale(40),
      padding: EdgeInsets.zero,
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
      child: TextButton(
          style: TextButton.styleFrom(
            primary: const Color(0xff70828D),
            padding: const EdgeInsets.all(0),
          ),
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
            size: 12,
          ),
          onPressed: () async {
            Navigator.of(context).pushReplacementNamed(HOME_SCREEN);
          }),
    );
  }

  Widget titleField(accountNum) {
    return Container(
      width: wScale(327),
      alignment: Alignment.centerLeft,
      child: Text('Flex PLUS Account ${accountNum}',
          style: TextStyle(
              fontSize: fSize(16),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2831))),
    );
  }

  Widget cardAvailableValanceField(creditLine) {
    return Stack(
      children: [
        Container(
            width: wScale(327),
            height: hScale(150),
            padding: EdgeInsets.all(hScale(24)),
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(hScale(10)),
                image: const DecorationImage(
                  image: AssetImage("assets/dashboard_header.png"),
                  fit: BoxFit.cover,
                )),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  moneyValue(
                      'Available Credit',
                      creditLine['currencyCode'],
                      creditLine['availableLimit'].toStringAsFixed(2),
                      20.0,
                      FontWeight.bold,
                      const Color(0xff30E7A9)),
                  moneyValue(
                      'Total Credit Line',
                      creditLine['currencyCode'],
                      creditLine['totalCreditLimit'].toStringAsFixed(2),
                      16.0,
                      FontWeight.w600,
                      const Color(0xffADD2C8)),
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: LinearProgressIndicator(
                      value: creditLine['totalCreditLimit'] /
                          creditLine['availableLimit'],
                      backgroundColor: const Color(0xFFF4F4F4),
                      color: const Color(0xFF30E7A9),
                      minHeight: hScale(10),
                    ),
                  ),
                ])),
        Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: wScale(327),
              height: hScale(150),
              decoration: BoxDecoration(
                color: FPL_enhancement == 2
                    ? Colors.black.withOpacity(0.5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(hScale(10)),
              ),
            ))
      ],
    );
  }

  Widget cardTotalValanceField(creditLine) {
    return Container(
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
              'Total Amount Due',
              creditLine['currencyCode'],
              (creditLine['creditUsage'] - creditLine['totalUnbilledAmount'])
                  .toStringAsFixed(2),
              20.0,
              FontWeight.bold,
              isSuspended ? Color(0xFFEB5757) : Color(0xff30E7A9)),
          const CustomSpacer(size: 8),
          moneyValue(
              'Due Date',
              '',
              creditLine['dueDate'] == null
                  ? '-'
                  : DateFormat.yMMMd().format(new DateTime(
                      int.parse(creditLine['dueDate'].split("-")[0]),
                      int.parse(creditLine['dueDate'].split("-")[1]),
                      int.parse(creditLine['dueDate'].split("-")[2]))),
              16.0,
              FontWeight.w600,
              isSuspended ? Color(0xFFEB5757) : const Color(0xffADD2C8)),
          const CustomSpacer(size: 14),
          moneyValue(
              'Unbilled Amount',
              creditLine['currencyCode'],
              creditLine['totalUnbilledAmount'].toStringAsFixed(2),
              16.0,
              FontWeight.w600,
              const Color(0xffADD2C8)),
        ]));
  }

  Widget moneyValue(title, unit, value, size, weight, color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(fontSize: fSize(12), color: Colors.white)),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$unit  ',
              style: TextStyle(
                  fontSize: fSize(12),
                  fontWeight: weight,
                  color: color,
                  height: 1)),
          Text(value,
              style: TextStyle(
                  fontSize: fSize(size),
                  fontWeight: weight,
                  color: color,
                  height: 1)),
        ])
      ],
    );
  }

  Widget welcomeHandleField(data, imageURL, imageScale, title, funcFlag) {
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
              title == "Payment"
                  ? handleDepositFunds(data, funcFlag)
                  : handleCreditline(title);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(children: [
                  SizedBox(
                      width: hScale(22),
                      child: Image.asset(imageURL,
                          fit: BoxFit.contain, width: wScale(imageScale))),
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

  Widget suspendedField() {
    return Container(
      // width: wScale(327),
      padding: EdgeInsets.all(hScale(12)),
      decoration: BoxDecoration(
        color: const Color(0xffF6C6C0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(hScale(10)),
          topRight: Radius.circular(hScale(10)),
          bottomLeft: Radius.circular(hScale(10)),
          bottomRight: Radius.circular(hScale(10)),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0ff6c6c0).withOpacity(0.25),
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const CustomSpacer(size: 8),
                    Icon(Icons.error,
                        color: const Color(0xffEB5757), size: wScale(20)),
                  ],
                ),
                SizedBox(width: wScale(11)),
                Container(
                    width: wScale(240),
                    child: Text(
                        'Your account has been suspended until the amount due is paid in full. Interest charges will apply.',
                        style: TextStyle(
                            fontSize: fSize(12),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1A2831),
                            height: 1.8)))
              ],
            ),
            Container(
                width: wScale(20),
                height: wScale(20),
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: hScale(8)),
                child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: const Color(0xff81919B),
                      size: wScale(20),
                    ),
                    onPressed: () {
                      setState(() {
                        isSuspended = false;
                      });
                    }))
          ]),
    );
  }
}

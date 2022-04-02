import 'package:co/ui/main/home/deposit_funds.dart';
import 'package:co/ui/main/transactions/transaction_type.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/queries.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class TransactionAdmin extends StatefulWidget {
  const TransactionAdmin({Key? key}) : super(key: key);
  @override
  TransactionAdminState createState() => TransactionAdminState();
}

GlobalKey<TransactionAdminState> globalKey = GlobalKey();

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
  int sortType = 0;
  bool showDateRange = false;
  bool showModal = false;
  final searchCtl = TextEditingController();
  final startDateCtl = TextEditingController();
  final endDateCtl = TextEditingController();
  String searchText = "";
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String totalCompanyBalanceQuery = Queries.QUERY_TOTAL_COMPANY_BALANCE;
  String getBusinessAccountSummary = Queries.QUERY_BUSINESS_ACCOUNT_SUMMARY;
  String allTransationsQuery = Queries.QUERY_ALL_TRANSACTIONS_TAB_PANE_CONTENTS;
  String getUserInfoQuery = Queries.QUERY_DASHBOARD_LAYOUT;

  bool isLoading = false;
  var businessData = {};
  String availableBalance = '0.00';
  String balance = '0.00';
  var transComplete = [];
  var transPending = [];
  var transDecline = [];
  var userOrg = {};

  handleDepositFunds(businessAccountSummary) {
    Navigator.of(context).push(
      CupertinoPageRoute(
          builder: (context) =>
              DepositFundsScreen(data: businessAccountSummary['data'])),
    );
  }

  handleCreditline(title) async {
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

  handleTouchPan() {
    return true;
  }

  Future<void> _fetchData() async {
    isLoading = true;
    var accessToken = storage.getItem("jwt_token");
    final HttpLink httpLink =
        HttpLink("https://gql.staging.fxr.one/v1/graphql");

    final AuthLink authLink = AuthLink(getToken: () async => "$accessToken");
    final Link link = authLink.concat(httpLink);
    final client = GraphQLClient(cache: GraphQLCache(), link: link);

    final businessVars = {
      'orgId': userStorage.getItem("orgId"),
      'isAdmin': true
    };
    final cardValanceVars = {'orgId': userStorage.getItem("orgId")};
    final transVars1 = {
      'orgId': userStorage.getItem("orgId"),
      'status': "COMPLETED",
      'limit': 100
    };
    final transVars2 = {
      'orgId': userStorage.getItem("orgId"),
      'status': "APPROVED",
      'limit': 100
    };
    final transVars3 = {
      'orgId': userStorage.getItem("orgId"),
      'status': "DECLINED",
      'limit': 100
    };
    try {
      final businessSummaryOption = QueryOptions(
          document: gql(getBusinessAccountSummary), variables: businessVars);
      final businessSummaryResult = await client.query(businessSummaryOption);
      final cardValanceOption = QueryOptions(
          document: gql(totalCompanyBalanceQuery), variables: cardValanceVars);
      final cardValanceResult = await client.query(cardValanceOption);

      final queryOptions1 = QueryOptions(
          document: gql(allTransationsQuery), variables: transVars1);
      final transactionCompleteResult = await client.query(queryOptions1);
      final queryOption2 = QueryOptions(
          document: gql(allTransationsQuery), variables: transVars2);
      final transactionApproveResult = await client.query(queryOption2);
      final queryOptions3 = QueryOptions(
          document: gql(allTransationsQuery), variables: transVars3);
      final transactionDeclineResult = await client.query(queryOptions3);
      final queryOptions4 =
          QueryOptions(document: gql(getUserInfoQuery), variables: {});
      final userInfoResult = await client.query(queryOptions4);
      final userInfo = userInfoResult.data!['user'];
      setState(() {
        businessData =
            businessSummaryResult.data?['readBusinessAcccountSummary'] ?? {};
        availableBalance = cardValanceResult
                .data?['readBusinessAcccountSummary']['data']['businessAccount']
                    ['availableBalance']
                .toStringAsFixed(2) ??
            '0.00';
        balance = cardValanceResult.data?['readBusinessAcccountSummary']['data']
                    ['businessAccount']['balance']
                .toStringAsFixed(2) ??
            '0.00';
        transComplete = transactionCompleteResult.data?['listTransactions']
                ['financeAccountTransactions'] ??
            [];
        transPending = transactionApproveResult.data?['listTransactions']
                ['financeAccountTransactions'] ??
            [];
        transDecline = transactionDeclineResult.data?['listTransactions']
                ['financeAccountTransactions'] ??
            [];
        userOrg = userInfo['roles']
            .firstWhere((item) => item['orgId'] == userInfo['currentOrgId']);
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
    // _pageController = PageController(initialPage: transactionStatus);
    _fetchData();
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
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Container(
                        padding: EdgeInsets.only(
                            left: wScale(24), right: wScale(24)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CustomSpacer(size: 57),
                              cardValanceField(),
                              const CustomSpacer(size: 20),
                              welcomeHandleField(
                                  businessData,
                                  'assets/deposit_funds.png',
                                  27.0,
                                  "Deposit Funds"),
                              const CustomSpacer(size: 10),
                              welcomeHandleField(
                                  businessData,
                                  'assets/get_credit_line.png',
                                  27.0,
                                  "Increase Credit Line"),
                              const CustomSpacer(size: 20),
                            ])),
                    TransactionTypeSection(
                      transComplete: transComplete,
                      transPending: transPending,
                      transDecline: transDecline,
                      userOrg: userOrg,
                    )
                  ])),
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              child: CustomBottomBar(active: 2),
            )
          ])));
  }

  Widget cardValanceField() {
    return Container(
        width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
            .size
            .width,
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
        child: Column(children: [
          moneyValue('Total Balance', availableBalance, 20.0, FontWeight.w700,
              const Color(0xff30E7A9)),
          const CustomSpacer(size: 10),
          moneyValue('Ledger Balance', balance, 18.0, FontWeight.w600,
              const Color(0xffADD2C8)),
        ]));
  }

  Widget moneyValue(title, value, size, weight, color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: fSize(14),
                color: Colors.white,
                fontWeight: FontWeight.w500)),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("SGD ",
              style: TextStyle(
                  fontSize: fSize(12),
                  fontWeight: weight,
                  color: color,
                  height: 1)),
          Text(value,
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: fSize(size),
                  fontWeight: weight,
                  color: color,
                  height: 1)),
        ])
      ],
    );
  }

  Widget welcomeHandleField(
      businessAccountSummary, imageURL, imageScale, title) {
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
              title == "Deposit Funds"
                  ? handleDepositFunds(businessAccountSummary)
                  : handleCreditline(title);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(children: [
                  SizedBox(
                    height: hScale(22),
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
}

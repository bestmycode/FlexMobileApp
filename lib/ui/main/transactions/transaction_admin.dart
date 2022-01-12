import 'package:co/ui/main/home/deposit_funds.dart';
import 'package:co/ui/main/transactions/all_transaction_header.dart';
import 'package:co/ui/main/transactions/transaction_type.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/transaction_item.dart';
import 'package:co/ui/widgets/virtual_my_transaction_search_filed%20copy.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:indexed/indexed.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:intercom_flutter/intercom_flutter.dart';

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
  String getUserAccountSummary = Queries.QUERY_USER_ACCOUNT_SUMMARY;
  String allTransationsQuery = Queries.QUERY_ALL_TRANSACTIONS_TAB_PANE_CONTENTS;

  handleDepositFunds(businessAccountSummary) {
    Navigator.of(context).push(
      CupertinoPageRoute(
          builder: (context) =>
              DepositFundsScreen(data: businessAccountSummary['data'])),
    );
  }

  handleCreditline(title) async {
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

  handleTransactionStatus(type) {
    setState(() {
      transactionStatus = type;
    });
  }

  handleSearch() {
    setState(() {
      searchText = searchCtl.text;
    });
  }

  handleExport() {}

  setSortType(type) {
    setState(() {
      sortType = type;
    });
  }

  setDateType(type) {
    if (type == 4) {
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

  handleStartDateCalendar() {}

  handleEndDateCalendar() {}

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
    var isAdmin = userStorage.getItem("isAdmin");
    var orgId = userStorage.getItem("orgId");
    return Query(
        options: QueryOptions(
          document:
              gql(isAdmin ? getBusinessAccountSummary : getUserAccountSummary),
          variables: {'orgId': orgId, 'isAdmin': isAdmin ? true : false},
        ),
        builder: (QueryResult accountSummary,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (accountSummary.hasException) {
            return Text(accountSummary.exception.toString());
          }

          if (accountSummary.isLoading) {
            return CustomLoading();
          }

          var businessAccountSummary = isAdmin
              ? accountSummary.data!['readBusinessAcccountSummary']
              : accountSummary.data!['readUserFinanceAccountSummary'];
          return mainHome(businessAccountSummary);
        });
  }

  Widget mainHome(businessAccountSummary) {
    return Material(
        child: Scaffold(
            body: Stack(children: [
      Container(
        height: hScale(812),
        child: SingleChildScrollView(
            padding: EdgeInsets.only(left: wScale(24), right: wScale(24)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const CustomSpacer(size: 57),
              cardValance(),
              const CustomSpacer(size: 20),
              welcomeHandleField(businessAccountSummary,
                  'assets/deposit_funds.png', 27.0, "Deposit Funds"),
              const CustomSpacer(size: 10),
              welcomeHandleField(businessAccountSummary,
                  'assets/get_credit_line.png', 27.0, "Increase Credit Line"),
              const CustomSpacer(size: 20),
              TransactionTypeSection()
            ])),
      ),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 2),
      )
    ])));
  }

  Widget cardValance() {
    var orgId = userStorage.getItem('orgId');
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Query(
            options: QueryOptions(
              document: gql(totalCompanyBalanceQuery),
              variables: {
                'orgId': orgId,
              },
              // pollInterval: const Duration(seconds: 10),
            ),
            builder: (QueryResult result,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.hasException) {
                return Text(result.exception.toString());
              }

              if (result.isLoading) {
                return cardValanceField(0, 0);
              }
              var businessAcccountSummary =
                  result.data!['readBusinessAcccountSummary'];
              return cardValanceField(
                  businessAcccountSummary['data']['businessAccount']
                      ['availableBalance'],
                  businessAcccountSummary['data']['businessAccount']
                      ['balance']);
            }));
  }

  Widget cardValanceField(availableBalance, balance) {
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
        child: Column(children: [
          moneyValue('Total Balance', availableBalance.toStringAsFixed(2), 20.0,
              FontWeight.w700, const Color(0xff30E7A9)),
          const CustomSpacer(size: 10),
          moneyValue('Ledger Balance', balance.toStringAsFixed(2), 18.0,
              FontWeight.w600, const Color(0xffADD2C8)),
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

import 'package:co/ui/main/transactions/all_transaction_header.dart';
import 'package:co/ui/widgets/billing_item.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/transaction_item.dart';
import 'package:co/ui/widgets/virtual_my_transaction_search_filed%20copy.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:indexed/indexed.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

class CreditTransactionTypeSectionItem extends StatefulWidget {
  const CreditTransactionTypeSectionItem({
    Key? key,
  }) : super(key: key);

  @override
  CreditTransactionTypeSectionItemState createState() =>
      CreditTransactionTypeSectionItemState();
}

class CreditTransactionTypeSectionItemState
    extends State<CreditTransactionTypeSectionItem> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  int transactionType = 1;
  int billedType = 1;
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String readBusinessAccountSummary = Queries.QUERY_BUSINESS_ACCOUNT_SUMMARY;
  String billedUnbilledTransactions = Queries.QUERY_BILLED_UNBILLED_TRANSACTIONS;
  String billingStatementsTable = Queries.QUERY_BILLING_STATEMENTTABLE;

  handleTransactionType(type) {
    setState(() {
      transactionType = type;
    });
  }

  handleBilledType(type) {
    setState(() {
      billedType = type;
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
    var orgId = userStorage.getItem('orgId');
    var isAdmin = userStorage.getItem('isAdmin');
    return Query(
        options: QueryOptions(
          document: gql(readBusinessAccountSummary),
          variables: {
            "orgId": orgId,
            "isAdmin": isAdmin,
          },
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
          var listUserFinanceAccounts = result.data!['readBusinessAcccountSummary'];
          var flaId = listUserFinanceAccounts['data']['creditLine']['id'];
      return Query(
        options: QueryOptions(
          document: gql(billedUnbilledTransactions),
          variables: {
            "orgId": orgId, 
            "status": billedType == 1 ? "BILLED" : "UNBILLED",
            "flaId": flaId
          },
          // pollInterval: const Duration(seconds: 10),
        ),
        builder: (QueryResult billedResult,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (billedResult.hasException) {
            return Text(billedResult.exception.toString());
          }

          if (billedResult.isLoading) {
            return Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF60C094))));
          }
          var listTransactions = billedResult.data!['listTransactions'];
          return mainHome(listTransactions);
        });
      });
  }

  Widget mainHome(listTransactions) {
    return getTransactionArrWidgets(listTransactions['financeAccountTransactions']);
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
              date: '${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(item['transactionDate']))}  |  ${DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(item['transactionDate']))}',
              transactionName: item['description'],
              status: item['status'],
              userName: item['merchantName'],
              cardNum: item['pan'],
              value: item['fxrBillAmount'].toString());
          }).toList());
  }
}

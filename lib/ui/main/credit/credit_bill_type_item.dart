import 'package:co/ui/widgets/billing_item.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

class CreditBillTypeSectionItem extends StatefulWidget {
  const CreditBillTypeSectionItem({
    Key? key,
  }) : super(key: key);

  @override
  CreditBillTypeSectionItemState createState() =>
      CreditBillTypeSectionItemState();
}

class CreditBillTypeSectionItemState extends State<CreditBillTypeSectionItem> {
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
  String billedUnbilledTransactions =
      Queries.QUERY_BILLED_UNBILLED_TRANSACTIONS;
  String billingStatementsTable = Queries.QUERY_BILLING_STATEMENTTABLE;
  String billDownloadQuery = Queries.QUERY_BILL_DOWNLOAD;

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
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF60C094))));
          }
          var listUserFinanceAccounts =
              result.data!['readBusinessAcccountSummary'];
          var flaId = listUserFinanceAccounts['data']['creditLine']['id'];
          return Query(
              options: QueryOptions(
                document: gql(billingStatementsTable),
                variables: {"fplId": flaId},
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
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF60C094))));
                }
                var listBills = billedResult.data!['listBills'];
                return mainHome(listBills);
              });
        });
  }

  Widget mainHome(listBills) {
    return getBillingArrWidgets(listBills['listOfBills']);
  }

 Widget getBillingArrWidgets(arr) {
    return arr.length == 0
        ? Image.asset('assets/empty_transaction.png',
            fit: BoxFit.contain, width: wScale(327))
        : Column(
            children: arr.map<Widget>((item) {
            return Query(
                options: QueryOptions(
                  document: gql(billDownloadQuery),
                  variables: {"fileId": item['documentLink']},
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
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF60C094))));
                  }

                  print(result.data!['downloadBillStatement']);

                  return BillingItem(
                      index: arr.indexOf(item),
                      statementDate:
                          '${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(item['statementDate']))}',
                      totalAmount: item['totalAmountDue'].toString(),
                      dueDate: item['dueDate'] == null
                          ? "N/A"
                          : '${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(item['dueDate']))}',
                      status: item['status'],
                      documentLink: result.data!['downloadBillStatement']);
                });
          }).toList());
  }
}

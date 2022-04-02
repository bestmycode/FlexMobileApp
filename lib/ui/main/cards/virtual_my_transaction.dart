import 'package:co/ui/main/cards/virtual_my_transaction_main.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/transaction_item.dart';
import 'package:co/ui/widgets/virtual_my_transaction_search_filed.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:indexed/indexed.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class VirtualMyTransactions extends StatefulWidget {
  const VirtualMyTransactions({Key? key}) : super(key: key);

  @override
  VirtualMyTransactionsState createState() => VirtualMyTransactionsState();
}

class VirtualMyTransactionsState extends State<VirtualMyTransactions> {
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
  int activeType = 1;
  int dateType = 0;
  bool showDateRange = false;
  String searchText = "";
  final searchCtl = TextEditingController();
  final startDateCtl = TextEditingController();
  final endDateCtl = TextEditingController();
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String myVirtualCardTransactionsQuery =
      Queries.QUERY_MY_VIRTUAL_CARD_TRANSACTION;
  var completeTrans = [];
  var approveTrans = [];
  var declineTrans = [];

  handleCardType(type) {
    setState(() {
      activeType = type;
    });
  }

  setDateType(type) {
    if (type == 4) {
      setState(() {
        showDateRange = !showDateRange;
        dateType = type;
      });
    } else {
      setState(() {
        showDateRange = false;
        dateType = type;
      });
    }
  }

  handleExport() {}

  handleSearch() {
    setState(() {
      searchText = searchCtl.text;
    });
  }

  handleStartDateCalendar() {}

  handleEndDateCalendar() {}

  Future<void> _fetchData() async {
    isLoading = true;
    var accessToken = storage.getItem("jwt_token");
    final HttpLink httpLink =
        HttpLink("https://gql.staging.fxr.one/v1/graphql");

    final AuthLink authLink = AuthLink(getToken: () async => "$accessToken");
    final Link link = authLink.concat(httpLink);
    final client = GraphQLClient(cache: GraphQLCache(), link: link);
    final orgId = userStorage.getItem('orgId');
    final userId = userStorage.getItem('userId');

    final completeVars = {
      'filterArgs': "payment_method=VIRTUAL",
      'limit': 100,
      'offset': 0,
      'orgId': orgId,
      'userId': userId,
      'status': "COMPLETED"
    };
    final approveVars = {
      'filterArgs': "payment_method=VIRTUAL",
      'limit': 100,
      'offset': 0,
      'orgId': orgId,
      'userId': userId,
      'status': "APPROVED"
    };
    final declineVars = {
      'filterArgs': "payment_method=VIRTUAL",
      'limit': 100,
      'offset': 0,
      'orgId': orgId,
      'userId': userId,
      'status': "DECLINED",
    };
    try {
      final completeOption = QueryOptions(
          document: gql(myVirtualCardTransactionsQuery),
          variables: completeVars);
      final completeResult = await client.query(completeOption);
      final approveOption = QueryOptions(
          document: gql(myVirtualCardTransactionsQuery),
          variables: approveVars);
      final approveResult = await client.query(approveOption);
      final declineOption = QueryOptions(
          document: gql(myVirtualCardTransactionsQuery),
          variables: declineVars);
      final declineResult = await client.query(declineOption);

      setState(() {
        completeTrans = completeResult.data?['listTransactions']
                ['financeAccountTransactions'] ??
            [];
        approveTrans = approveResult.data?['listTransactions']
                ['financeAccountTransactions'] ??
            [];
        declineTrans = declineResult.data?['listTransactions']
                ['financeAccountTransactions'] ??
            [];
        isLoading = false;
      });
    } catch (error) {
      print("===== Error : Virtual My Card Transactions =====");
      print("===== Query : myVirtualCardsListQuery =====");
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
      child: Column(children: [
        headerStatusField(),
        isLoading
            ? Container(
                margin: EdgeInsets.only(top: hScale(50)),
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF60C094))))
            : VirtualMyTransactionsMain(
                transactions: activeType == 1
                    ? completeTrans
                    : activeType == 2
                        ? approveTrans
                        : declineTrans,
                activeType: activeType,
                dateType: dateType,
                showDateRange: showDateRange,
                handleCardType: handleCardType,
                startDateCtl: startDateCtl,
                endDateCtl: endDateCtl,
                setDateType: setDateType)
      ]),
    );
  }

  Widget headerStatusField() {
    return Container(
      width: wScale(327),
      height: hScale(40),
      alignment: Alignment.bottomCenter,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          statusButton('Completed', 1),
          statusButton('Pending', 2),
          statusButton('Declined', 3),
        ]),
      ]),
    );
  }

  Widget statusButton(title, type) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff70828D),
        padding: EdgeInsets.symmetric(vertical: 0),
        textStyle:
            TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
      ),
      onPressed: () {
        handleCardType(type);
      },
      child: Container(
        width: wScale(109),
        height: hScale(40),
        padding: EdgeInsets.only(left: wScale(6), right: wScale(6)),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: type == 3 && activeType == 3
                        ? const Color(0xFFEB5757)
                        : type == activeType
                            ? const Color(0xFF29C490)
                            : const Color(0xFFEEEEEE),
                    width: type == activeType ? hScale(2) : hScale(1)))),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(14),
              color: type == 3
                  ? const Color(0xFFEB5757)
                  : type == activeType
                      ? Colors.black
                      : const Color(0xff70828D)),
        ),
      ),
    );
  }
}

import 'package:co/ui/main/transactions/all_transaction_header.dart';
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

class TransactionTypeSection extends StatefulWidget {
  const TransactionTypeSection({
    Key? key,
  }) : super(key: key);

  @override
  TransactionTypeSectionState createState() => TransactionTypeSectionState();
}

class TransactionTypeSectionState extends State<TransactionTypeSection> {
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
  int sortType = 0;
  bool showDateRange = false;
  bool showModal = false;
  final searchCtl = TextEditingController();
  final startDateCtl = TextEditingController();
  final endDateCtl = TextEditingController();
  String searchText = "";
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String allTransationsQuery = Queries.QUERY_ALL_TRANSACTIONS_TAB_PANE_CONTENTS;

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
        dateType = type;
      });
    } else {
      setState(() {
        showDateRange = false;
        dateType = type;
      });
    }
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
    return Indexer(
      children: [
        Indexed(
            index: 100,
            child: AllTransactionHeader(
              dateType: dateType,
              sortType: sortType,
              transactionStatus: transactionStatus,
              handleTransactionStatus: handleTransactionStatus,
              setDateType: setDateType,
              setSortType: setSortType,
            )),
        Indexed(
            index: 50,
            child: Column(children: [
              const CustomSpacer(size: 105),
              Indexer(children: [
                Indexed(
                    index: 100,
                    child: VirtualMyTransactionSearchField(
                      searchCtl: searchCtl,
                      dateType: dateType,
                      handleExport: handleExport,
                      handleSearch: handleSearch,
                      setDateType: setDateType,
                    )),
                Indexed(
                    index: 50,
                    child: Column(
                      children: [
                        const CustomSpacer(size: 40),
                        showDateRange
                            ? const CustomSpacer(size: 30)
                            : const SizedBox(),
                        showDateRange ? dateRangeField() : const SizedBox(),
                        const CustomSpacer(size: 20),
                        transactions(),
                        const CustomSpacer(size: 88),
                      ],
                    )),
              ]),
            ]))
      ],
    );
  }

  Widget dateRangeField() {
    return Container(
        width: wScale(327),
        padding:
            EdgeInsets.symmetric(vertical: hScale(16), horizontal: wScale(16)),
        // margin: EdgeInsets.only(bottom: hScale(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                      hintText: 'Select Date of Birth',
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
            child: Text('Date of Birth (DD/MM/YY)',
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
          onPressed: () {
            handleSearch();
          },
          child: Text("Search",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget transactions() {
    var orgId = userStorage.getItem('orgId');
    return Query(
        options: QueryOptions(
          document: gql(allTransationsQuery),
          variables: {
            'orgId': orgId,
            'status': transactionStatus == 1
                ? "COMPLETED"
                : transactionStatus == 2
                    ? "APPROVED"
                    : "DECLINED",
            'limit': 100
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
          var listTransactions = result.data!['listTransactions'];
          return getTransactionArrWidgets(
              listTransactions['financeAccountTransactions']);
        });
  }

  Widget getTransactionArrWidgets(arr) {
    if (sortType == 0) {
      arr.sort((a, b) => b['transactionDate']
          .toString()
          .compareTo(a['transactionDate'].toString()));
    } else if (sortType == 1) {
      arr.sort((a, b) => a['transactionDate']
          .toString()
          .compareTo(b['transactionDate'].toString()));
    } else {
      arr.sort((a, b) => b['transactionType']
          .toString()
          .compareTo(a['transactionType'].toString()));
    }

    var tempArr = [];
    if (dateType == 0) {
      tempArr = arr;
    } else if (dateType == 1) {
      arr.forEach((item) {
        if (item['transactionDate'] + 7 * 24 * 3600 * 1000 >=
            DateTime.now().millisecondsSinceEpoch) tempArr.add(item);
      });
    } else if (dateType == 2) {
      arr.forEach((item) {
        if (item['transactionDate'] + 30 * 24 * 3600 * 1000 >=
            DateTime.now().millisecondsSinceEpoch) tempArr.add(item);
      });
    } else if (dateType == 3) {
      arr.forEach((item) {
        if (item['transactionDate'] + 90 * 24 * 3600 * 1000 >=
            DateTime.now().millisecondsSinceEpoch) tempArr.add(item);
      });
    } else {
      var start = 0;
      var end = 0;
      start = startDateCtl.text == ""
          ? 0
          : DateTime(
                  int.parse(startDateCtl.text.split("/")[2]),
                  int.parse(startDateCtl.text.split("/")[1]),
                  int.parse(startDateCtl.text.split("/")[0]))
              .millisecondsSinceEpoch;
      end = endDateCtl.text == ""
          ? DateTime.now().millisecondsSinceEpoch
          : DateTime(
                  int.parse(endDateCtl.text.split("/")[2]),
                  int.parse(endDateCtl.text.split("/")[1]),
                  int.parse(endDateCtl.text.split("/")[0]))
              .millisecondsSinceEpoch;
      arr.forEach((item) {
        if (item['transactionDate'] >= start && item['transactionDate'] <= end)
          tempArr.add(item);
      });
    }

    var resultArr = [];
    tempArr.forEach((item) {
      if (item['merchantName']
                  .toLowerCase()
                  .indexOf(searchText.toLowerCase()) >=
              0 ||
          item['cardName'].toLowerCase().indexOf(searchText.toLowerCase()) >= 0)
        resultArr.add(item);
    });

    return resultArr.length == 0
        ? Image.asset('assets/empty_transaction.png',
            fit: BoxFit.contain, width: wScale(327))
        : Column(
            children: resultArr.map<Widget>((item) {
            return TransactionItem(
                accountId: item['txnFinanceAccId'],
                transactionId: item['sourceTransactionId'],
                date: '${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(item['transactionDate']))}  |  ${DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(item['transactionDate']))}',
                transactionName: item['merchantName'],
                userName: item['cardName'],
                cardNum: item['pan'],
                value: item['fxrBillAmount'].toStringAsFixed(2),
                status: item['status'],
                receiptStatus: item['fxrBillAmount'] >= 0 ? 0: item['receiptStatus'] == "PAID" ? 2 : 1);
          }).toList());
  }
}

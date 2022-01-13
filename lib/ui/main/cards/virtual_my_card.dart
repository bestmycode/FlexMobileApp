import 'package:co/ui/main/cards/virtual_personal_card.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/virtual_my_cards_search_filed.dart';
import 'package:co/ui/widgets/virtual_my_cards_sub_search_filed.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:expandable/expandable.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:indexed/indexed.dart';
import 'package:localstorage/localstorage.dart';

class VirtualMyCards extends StatefulWidget {
  const VirtualMyCards({Key? key}) : super(key: key);

  @override
  VirtualMyCardsState createState() => VirtualMyCardsState();
}

class VirtualMyCardsState extends State<VirtualMyCards> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  int activeType = 1;
  int sortType = -1;
  int subSortType = 0;
  final searchCtl = TextEditingController();
  bool showSubSortModal = false;
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String listCardNamesQuery = Queries.QUERY_LIST_CARDNAME;
  String myVirtualCardsListQuery = Queries.QUERY_MY_VIRTUAL_CARD_LIST;
  String searchText = "";
  var sortArr = [
    {'sortType': 'card holder', 'subType1': 'Fixed', 'subType2': 'Recurring'},
    {
      'sortType': 'available limit',
      'subType1': 'Highest to lowest',
      'subType2': 'Lowest to highest'
    },
    {
      'sortType': 'date issued',
      'subType1': 'Newest to oldest',
      'subType2': 'Oldest to newest'
    },
  ];

  handleCardType(type) {
    setState(() {
      activeType = type;
    });
  }

  handleSearch() {
    setState(() {
      searchText = searchCtl.text;
    });
  }

  handleCardDetail(data) {
    Navigator.of(context)
        .push(
          CupertinoPageRoute(
              builder: (context) => VirtualPersonalCard(
                    cardData: data,
                  )),
        )
        .then((_) => setState(() {}));
  }

  handleSortType(type) {
    setState(() {
      sortType = type;
    });
  }

  handleSubSortType(type) {
    setState(() {
      subSortType = type;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    var orgId = userStorage.getItem('orgId');
    return GraphQLProvider(
        client: Token().getLink(accessToken), child: mainHome(orgId));
  }

  Widget mainHome(orgId) {
    return Container(
      padding: EdgeInsets.only(left: wScale(24), right: wScale(24)),
      child: Indexer(children: [
        Indexed(
            index: 100,
            child: VirtualMyCardsSearchField(
              activeType: activeType,
              sortArr: sortArr,
              sortType: sortType,
              handleCardType: handleCardType,
              handleSortType: handleSortType,
            )),
        Indexed(
            index: 50,
            child: Column(
              children: [
                const CustomSpacer(size: 60),
                searchField(),
                Indexer(children: [
                  Indexed(
                      index: 200,
                      child: sortType >= 0
                          ? VirtualMyCardsSubSearchField(
                              sortArr: sortArr,
                              sortType: sortType,
                              subSortType: subSortType,
                              handleSubSortType: handleSubSortType,
                            )
                          : const SizedBox()),
                  Indexed(
                      index: 40,
                      child: Column(
                        children: [
                          sortType >= 0
                              ? const CustomSpacer(size: 60)
                              : const SizedBox(),
                          sortType < 0
                              ? const CustomSpacer(size: 10)
                              : const SizedBox(),
                          transaction(orgId)
                        ],
                      ))
                ])
              ],
            )),
      ]),
    );
  }

  Widget transaction(orgId) {
    return Query(
        options: QueryOptions(
          document: gql(myVirtualCardsListQuery),
          variables: {
            'accountSubtype': "VIRTUAL",
            'limit': 10,
            'offset': 0,
            'orgId': orgId,
            'status': activeType == 1 ? "ACTIVE" : "INACTIVE",
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
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF60C094))));
          }
          var listUserFinanceAccounts = result.data!['listUserFinanceAccounts'];
          return getTransactionArrWidgets(
              listUserFinanceAccounts['financeAccounts']);
        });
  }

  Widget searchField() {
    return Container(
        height: hScale(36),
        padding: EdgeInsets.only(left: wScale(15), right: wScale(15)),
        decoration: BoxDecoration(
          color: const Color(0xffffffff),
          border: Border.all(
              color: const Color(0xff040415).withOpacity(0.1),
              width: hScale(1)),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: wScale(260),
                // height: hScale(24),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: searchCtl,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)),
                    hintText: 'Card Holders , Cards…',
                    hintStyle: TextStyle(
                        color: const Color(0xff040415).withOpacity(0.5),
                        fontSize: fSize(12),
                        fontWeight: FontWeight.w500),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)),
                  ),
                  style: TextStyle(
                      fontSize: fSize(14), fontWeight: FontWeight.w500),
                  scrollPadding: EdgeInsets.zero,
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
                    handleSearch();
                  },
                  // child: const Icon( Icons.search_rounded, color: Colors.black, size: 20 ),
                  child: Image.asset(
                    'assets/search_icon.png',
                    fit: BoxFit.contain,
                    width: wScale(13),
                  )),
            ),
          ],
        ));
  }

  Widget collapseField(index, data) {
    return ExpandableNotifier(
      initialExpanded: index == 0 ? true : false,
      child: Container(
        margin: EdgeInsets.only(bottom: hScale(10)),
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
          children: [
            ScrollOnExpand(
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                    tapBodyToCollapse: true, tapBodyToExpand: true),
                expanded: Column(
                  children: [cardHeader(data), cardBody(data)],
                ),
                collapsed: cardHeader(data),
                builder: (_, collapsed, expanded) {
                  return SizedBox(
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getTransactionArrWidgets(arr) {
    if (sortType == 0) {
      List tempArr = [];
      arr.forEach((item) {
        if (subSortType == 0) {
          if (item['cardType'] == "ONE-TIME") tempArr.add(item);
        } else {
          if (item['cardType'] == "RECURRING") tempArr.add(item);
        }
      });
      arr = tempArr;
    } else if (sortType == 1) {
      subSortType == 0
          ? arr.sort((a, b) => a['financeAccountLimits'][0]['availableLimit'] <
                  b['financeAccountLimits'][0]['availableLimit']
              ? 1
              : -1)
          : arr.sort((a, b) => a['financeAccountLimits'][0]['availableLimit'] >
                  b['financeAccountLimits'][0]['availableLimit']
              ? 1
              : -1);
    } else {
      subSortType == 0
          ? arr.sort((a, b) =>
              a['startDate'].toString().compareTo(b['startDate'].toString()))
          : arr.sort((a, b) =>
              b['startDate'].toString().compareTo(a['startDate'].toString()));
    }
    List tempArr = [];
    arr.forEach((item) {
      var cardName =
          item['cardName'] != null ? item['cardName'].toLowerCase() : '';
      var searchTxt = searchText != '' ? searchText.toLowerCase() : '';
      if (cardName.indexOf(searchTxt) >= 0) tempArr.add(item);
    });

    return arr.length == 0
        ? Image.asset('assets/empty_transaction.png',
            fit: BoxFit.contain, width: wScale(327))
        : Column(
            children: tempArr.map<Widget>((item) {
            return collapseField(tempArr.indexOf(item), item);
          }).toList());
  }

  Widget cardHeader(data) {
    return Container(
        width: wScale(327),
        // height: hScale(50),
        padding: EdgeInsets.only(
            left: wScale(16),
            right: wScale(16),
            top: hScale(8),
            bottom: hScale(8)),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2931),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(hScale(10)),
            topRight: Radius.circular(hScale(10)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${data['cardName']}',
                style: TextStyle(fontSize: fSize(12), color: Colors.white)),
            Text('${data["permanentAccountNumber"]} | ${data['accountType']}',
                style: TextStyle(fontSize: fSize(12), color: Colors.white)),
          ],
        ));
  }

  Widget cardBody(data) {
    return Container(
        width: wScale(327),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(hScale(10)),
            topRight: Radius.circular(hScale(10)),
          ),
        ),
        child: Column(
          children: [
            cardBodyDetail(
                'Available Limit',
                data['currencyCode'],
                data['financeAccountLimits'][0]['availableLimit']
                    .toStringAsFixed(2),
                1),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            cardBodyDetail(
                'Monthly Spend Limit',
                data['currencyCode'],
                data['financeAccountLimits'][0]['limitValue']
                    .toStringAsFixed(2),
                2),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            cardBodyDetail('Status', '', data['status'], 3),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            TextButton(
              style: TextButton.styleFrom(
                primary: const Color(0xff1da7ff),
                textStyle: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff1da7ff)),
              ),
              onPressed: () {
                handleCardDetail(data);
              },
              child: const Text('View Card Details'),
            ),
          ],
        ));
  }

  Widget cardBodyDetail(title, symbol, value, type) {
    return Container(
        padding: EdgeInsets.only(
            top: hScale(10),
            bottom: hScale(10),
            left: wScale(16),
            right: wScale(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: fSize(12), color: const Color(0xFF70828D))),
            Container(
                padding: EdgeInsets.only(
                    left: wScale(16),
                    right: wScale(16),
                    top: hScale(5),
                    bottom: hScale(5)),
                decoration: BoxDecoration(
                  color: type == 3
                      ? value == "ACTIVE"
                          ? Color(0xFFDEFEE9)
                          : value == "SUSPENDED"
                              ? Color(0xFFc9e8fb)
                              : Color(0xFFffdfd5)
                      : type != 2
                          ? const Color(0xFFDEFEE9)
                          : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(hScale(16)),
                    topRight: Radius.circular(hScale(16)),
                    bottomLeft: Radius.circular(hScale(16)),
                    bottomRight: Radius.circular(hScale(16)),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    type != 3
                        ? Text('$symbol ',
                            style: TextStyle(
                                fontSize: fSize(8),
                                fontWeight: FontWeight.w500,
                                height: 1,
                                color: type == 1
                                    ? const Color(0xFF30E7A9)
                                    : const Color(0xFF1A2831)))
                        : const SizedBox(),
                    Text(
                        type == 3
                            ? value == "ACTIVE"
                                ? "Active"
                                : value == "SUSPENDED"
                                    ? "Frozen"
                                    : "Cancelled"
                            : value,
                        style: TextStyle(
                            fontSize: fSize(14),
                            fontWeight: FontWeight.w500,
                            height: 1,
                            color: type == 3
                                ? value == "ACTIVE"
                                    ? Color(0xFF30E7A9)
                                    : value == "SUSPENDED"
                                        ? Color(0xFF2f7bfa)
                                        : Color(0xFFeb5757)
                                : type == 2
                                    ? const Color(0xFF1A2831)
                                    : const Color(0xFF30E7A9)))
                  ],
                ))
          ],
        ));
  }
}

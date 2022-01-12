import 'package:co/ui/main/cards/physical_personal_card.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/physical_team_header.dart';
import 'package:co/ui/widgets/physical_team_subsort.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:expandable/expandable.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:indexed/indexed.dart';
import 'package:localstorage/localstorage.dart';

class PhysicalTeamCards extends StatefulWidget {
  const PhysicalTeamCards({Key? key}) : super(key: key);

  @override
  PhysicalTeamCardsState createState() => PhysicalTeamCardsState();
}

class PhysicalTeamCardsState extends State<PhysicalTeamCards> {
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
  String teamCardsList = Queries.QUERY_PHYSICAL_TEAMCARD_LIST;
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String queryAllTransactions = Queries.QUERY_PHYSICAL_TEAMCARD_LIST;

  var sortArr = [
    {'sortType': 'card holder', 'subType1': 'A - Z', 'subType2': 'Z - A'},
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
  String searchText = "";

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
    Navigator.of(context).push(
      CupertinoPageRoute(
          builder: (context) => PhysicalPersonalCard(cardData: data)),
    );
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
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    return Container(
      padding: EdgeInsets.only(left: wScale(24), right: wScale(24)),
      margin: EdgeInsets.only(top: hScale(14)),
      child: Indexer(children: [
        Indexed(
            index: 100,
            child: PhysicalTeamHeader(
              activeType: activeType,
              sortType: sortType,
              subSortType: subSortType,
              sortArr: sortArr,
              handleCardType: handleCardType,
              handleSortType: handleSortType,
              handleSubSortType: handleSubSortType,
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
                          ? PhysicalTeamSubSort(
                              sortType: sortType,
                              subSortType: subSortType,
                              sortArr: sortArr,
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
                          // widget.data['data']['totalPhysicalCards'] ==  0 ? emptyTransactionWidget() : getTransactionArrWidgets(transactionArr)
                          queryTransactionField()
                        ],
                      ))
                ])
                // const CustomSpacer(size: 15),
                // getTransactionArrWidgets(transactionArr),
              ],
            )),
      ]),
    );
  }

  Widget queryTransactionField() {
    var orgId = userStorage.getItem('orgId');
    return Query(
        options: QueryOptions(
          document: gql(queryAllTransactions),
          variables: {
            "accountSubtype": "PHYSICAL",
            "limit": 10,
            "offset": 0,
            "orgId": orgId,
            "status": activeType == 1 ? "ACTIVE" : "INACTIVE"
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
          var transactionArr =
              result.data!['listTeamFinanceAccounts']['financeAccounts'];
          return getTransactionArrWidgets(transactionArr);
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
                  // child: _rounded, color: Color(0xFF7B7E80), size: 20 ),
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
        margin: EdgeInsets.only(bottom: hScale(5)),
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
      subSortType == 0
          ? arr.sort((a, b) => a['accountName']
              .toString()
              .toLowerCase()
              .compareTo(b['accountName'].toString().toLowerCase()))
          : arr.sort((a, b) => b['accountName']
              .toString()
              .toLowerCase()
              .compareTo(a['accountName'].toString().toLowerCase()));
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
      if (item['accountName'].toLowerCase().indexOf(searchText.toLowerCase()) >= 0)
        tempArr.add(item);
    });

    return tempArr.length == 0
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
            Text(data['accountName'],
                style: TextStyle(fontSize: fSize(12), color: Colors.white)),
            Text(data['permanentAccountNumber'],
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
                data['financeAccountLimits'][0]['availableLimit'].toString(),
                0),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            cardBodyDetail('Monthly Spend Limit',
                data['financeAccountLimits'][0]['limitValue'].toString(), 1),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            cardBodyDetail(
                'Status',
                data['status'] == "ACTIVATE"
                    ? 'Activated'
                    : data['status'] == "INACTIVE"
                        ? 'Unactivated'
                        : 'Cancelled',
                2),
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

  Widget cardBodyDetail(title, value, type) {
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
                  color: type == 1
                      ? Colors.transparent
                      : type == 2 && value == "Unactivated"
                          ? Color(0xFF1A2831)
                          : type == 2 && value == "Activated"
                              ? Color(0xFFDEFEE9)
                              : type == 2
                                  ? Color(0xFFffdfd5)
                                  : Color(0xFFDEFEE9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(hScale(16)),
                    topRight: Radius.circular(hScale(16)),
                    bottomLeft: Radius.circular(hScale(16)),
                    bottomRight: Radius.circular(hScale(16)),
                  ),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      type != 2
                          ? Text('SGD ',
                              style: TextStyle(
                                  fontSize: fSize(8),
                                  height: 1,
                                  color: type != 1
                                      ? const Color(0xFF30E7A9)
                                      : const Color(0xFF1A2831)))
                          : SizedBox(),
                      Text(value,
                          style: TextStyle(
                              fontSize: fSize(14),
                              fontWeight: FontWeight.w600,
                              height: 1,
                              color: type == 1
                                  ? const Color(0xFF1A2831)
                                  : type == 2 && value == "Unactivated"
                                      ? const Color(0xFFFFFFFF)
                                      : type == 2 && value == "Activated"
                                          ? const Color(0xFF30E7A9)
                                          : type == 2
                                              ? const Color(0xFFeb5757)
                                              : const Color(0xFF30E7A9)))
                    ]))
          ],
        ));
  }
}

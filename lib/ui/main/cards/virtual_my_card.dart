import 'package:co/ui/main/cards/virtual_my_card_main.dart';
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
import 'package:sentry_flutter/sentry_flutter.dart';

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
    {'sortType': 'Card Type', 'subType1': 'Fixed', 'subType2': 'Recurring'},
    {
      'sortType': 'Available Limit',
      'subType1': 'Highest to lowest',
      'subType2': 'Lowest to highest'
    },
    {
      'sortType': 'Date Issued',
      'subType1': 'Newest to oldest',
      'subType2': 'Oldest to newest'
    },
  ];

  bool isLoading = false;
  var transActive = [];
  var transInactive = [];

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

  Future<void> _fetchData() async {
    isLoading = true;
    var accessToken = storage.getItem("jwt_token");
    final HttpLink httpLink =
        HttpLink("https://gql.staging.fxr.one/v1/graphql");

    final AuthLink authLink = AuthLink(getToken: () async => "$accessToken");
    final Link link = authLink.concat(httpLink);
    final client = GraphQLClient(cache: GraphQLCache(), link: link);
    final orgId = userStorage.getItem('orgId');

    final activeVars = {
      "accountSubtype": "VIRTUAL",
      "limit": 100,
      "offset": 0,
      "orgId": orgId,
      "status": "ACTIVE"
    };
    final inactiveVars = {
      "accountSubtype": "VIRTUAL",
      "limit": 100,
      "offset": 0,
      "orgId": orgId,
      "status": "INACTIVE"
    };
    try {
      final transActiveOption = QueryOptions(
          document: gql(myVirtualCardsListQuery), variables: activeVars);
      final transActiveResult = await client.query(transActiveOption);
      final transInactiveOption = QueryOptions(
          document: gql(myVirtualCardsListQuery), variables: inactiveVars);
      final transInactiveResult = await client.query(transInactiveOption);

      setState(() {
        transActive = transActiveResult.data?['listUserFinanceAccounts']
                ['financeAccounts'] ??
            [];
        transInactive = transInactiveResult.data?['listUserFinanceAccounts']
                ['financeAccounts'] ??
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
        isLoading
            ? Container(
                margin: EdgeInsets.only(top: hScale(50)),
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF60C094))))
            : VirtualMyCardsMain(
                transactions: activeType == 1 ? transActive : transInactive,
                sortArr: sortArr,
                sortType: sortType,
                subSortType: subSortType,
                handleSubSortType: handleSubSortType,
                handleCardDetail: handleCardDetail,
              )
      ]),
    );
  }
}

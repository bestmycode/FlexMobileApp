import 'package:co/ui/main/cards/physical_personal_card.dart';
import 'package:co/ui/main/cards/physical_team_card_main.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/team_header.dart';
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
import 'package:sentry_flutter/sentry_flutter.dart';

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
  bool isLoading = false;
  var transActive = [];
  var transInactive = [];
  var sortArr = [
    {'sortType': 'Card Holder', 'subType1': 'A - Z', 'subType2': 'Z - A'},
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
    Navigator.of(context)
        .push(
          CupertinoPageRoute(
              builder: (context) =>
                  PhysicalPersonalCard(cardData: data, isTeam: true)),
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
      "accountSubtype": "PHYSICAL",
      "limit": 100,
      "offset": 0,
      "orgId": orgId,
      "status": "ACTIVE"
    };
    final inactiveVars = {
      "accountSubtype": "PHYSICAL",
      "limit": 100,
      "offset": 0,
      "orgId": orgId,
      "status": "INACTIVE"
    };
    try {
      final transActiveOption = QueryOptions(
          document: gql(queryAllTransactions), variables: activeVars);
      final transActiveResult = await client.query(transActiveOption);
      final transInactiveOption = QueryOptions(
          document: gql(queryAllTransactions), variables: inactiveVars);
      final transInactiveResult = await client.query(transInactiveOption);

      setState(() {
        transActive = transActiveResult.data?['listTeamFinanceAccounts']
                ['financeAccounts'] ??
            [];
        transInactive = transInactiveResult.data?['listTeamFinanceAccounts']
                ['financeAccounts'] ??
            [];
        isLoading = false;
      });
    } catch (error) {
      print("===== Error : Physical Team Card Transactions =====");
      print("===== Query : teamCardsList =====");
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
      margin: EdgeInsets.only(top: hScale(14)),
      child: Indexer(children: [
        Indexed(
            index: 100,
            child: TeamHeader(
              type: 'physical',
              activeType: activeType,
              sortType: sortType,
              sortArr: sortArr,
              handleCardType: handleCardType,
              handleSortType: handleSortType,
              activeCounts: transActive.length,
              inActiveCounts: transInactive.length
            )),
        isLoading
            ? Container(
                margin: EdgeInsets.only(top: hScale(50)),
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF60C094))))
            : PhysicalTeamCardsMain(
                transactionArr: activeType == 1 ? transActive : transInactive,
                sortType: sortType,
                searchText: searchText,
                handleCardDetail: handleCardDetail,
                sortArr: sortArr)
      ]),
    );
  }
}

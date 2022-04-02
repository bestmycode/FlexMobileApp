import 'package:co/ui/main/cards/physical_card.dart';
import 'package:co/ui/main/cards/physical_user_card.dart';
import 'package:co/ui/main/cards/virtual_card.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/queries.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class HomeCardType extends StatefulWidget {
  final bool mobileVerified;
  const HomeCardType({Key? key, this.mobileVerified = true}) : super(key: key);

  @override
  HomeCardTypeState createState() => HomeCardTypeState();
}

class HomeCardTypeState extends State<HomeCardType> {
  late final PageController _pageController;
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');

  ///
  int totalPhysicalCompanyCards = 0;
  int totalVirtualCompanyCards = 0;

  ///
  int totalPhysicalCards = 0;
  int totalVirtualCards = 0;

  String getBusinessAccountSummary = Queries.QUERY_BUSINESS_ACCOUNT_SUMMARY;
  String getUserAccountSummary = Queries.QUERY_USER_ACCOUNT_SUMMARY;

  Future<void> _fetchCards() async {
    var accessToken = storage.getItem("jwt_token");
    final HttpLink httpLink =
        HttpLink("https://gql.staging.fxr.one/v1/graphql");

    final AuthLink authLink = AuthLink(getToken: () async => "$accessToken");
    final Link link = authLink.concat(httpLink);
    final client = GraphQLClient(cache: GraphQLCache(), link: link);
    final vars = {
      'orgId': userStorage.getItem("orgId"),
      'isAdmin': userStorage.getItem("isAdmin")
    };
    try {
      final queryOptions1 =
          QueryOptions(document: gql(getUserAccountSummary), variables: vars);
      final useAccountsResult = await client.query(queryOptions1);
      final queryOptions2 = QueryOptions(
          document: gql(getBusinessAccountSummary), variables: vars);
      final businessAccountsResult = await client.query(queryOptions2);
      setState(() {
        totalVirtualCompanyCards =
            businessAccountsResult.data?['readBusinessAcccountSummary']['data']
                    ['totalVirtualCards'] ??
                0;
        totalPhysicalCompanyCards =
            businessAccountsResult.data?['readBusinessAcccountSummary']['data']
                    ['totalPhysicalCards'] ??
                0;

        totalPhysicalCards =
            useAccountsResult.data?['readUserFinanceAccountSummary']['data']
                    ['totalPhysicalCards'] ??
                0;
        totalVirtualCards =
            useAccountsResult.data?['readUserFinanceAccountSummary']['data']
                    ['totalVirtualCards'] ??
                0;
      });
    } catch (error) {
      print("===== Error : Get Account Summary =====");
      print("===== Query : getBusinessAccountSummary =====");
      print(error);
      await Sentry.captureException(error);
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: cardType);
    _fetchCards();
  }

  int cardType = 0;

  handleCard(type) {
    if (!widget.mobileVerified) {
      return;
    }
    var isAdmin = userStorage.getItem('isAdmin');

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => type == "physical"
            ? isAdmin
                ? PhysicalCards(defaultType: cardType)
                : const PhysicalUserCard()
            : VirtualCards(defaultType: cardType + 1),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        width: wScale(327),
        padding: EdgeInsets.all(wScale(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(hScale(10)),
            topRight: Radius.circular(hScale(10)),
            bottomLeft: Radius.circular(hScale(10)),
            bottomRight: Radius.circular(hScale(10)),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF106549).withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 10,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            const Divider(color: Colors.transparent, height: 5),
            userStorage.getItem('isAdmin')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: hScale(34),
                      decoration: const BoxDecoration(
                        color: Color(0xfff5f5f6),
                      ),
                      child: TabBar(
                        unselectedLabelColor: const Color(0xff70828D),
                        labelPadding: const EdgeInsets.all(1),
                        labelStyle: TextStyle(
                          fontSize: fSize(14),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        labelColor: Colors.white,
                        indicator: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          color: Color(0xff4B5A63),
                        ),
                        indicatorPadding: const EdgeInsets.all(1),
                        indicatorWeight: 1,
                        tabs: [
                          Tab(
                            text: AppLocalizations.of(context)!.mycards,
                          ),
                          Tab(
                            text: AppLocalizations.of(context)!.comapnycards,
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(),
            CustomSpacer(size: userStorage.getItem('isAdmin') ? 16 : 0),
            SizedBox(
              height: 119,
              width: double.maxFinite,
              child: TabBarView(
                children: [
                  cardTypeField(totalPhysicalCards, totalVirtualCards),
                  cardTypeField(
                    totalPhysicalCompanyCards,
                    totalVirtualCompanyCards,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cardTypeField(physicalCards, virtualCards) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: cardTypeImage(
            'assets/physical_card.png',
            AppLocalizations.of(context)!.physicalcards,
            physicalCards,
            'physical',
          ),
        ),
        Expanded(
          child: cardTypeImage(
            'assets/virtual_card.png',
            AppLocalizations.of(context)!.virtualcards,
            virtualCards,
            'virtual',
          ),
        ),
      ],
    );
  }

  Widget cardTypeImage(imageURL, cardName, value, type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              primary: Colors.white,
            ),
            child: Image.asset(imageURL,
                color: value == 0
                    ? Colors.white.withOpacity(0.5)
                    : Colors.white.withOpacity(1),
                colorBlendMode: BlendMode.modulate,
                fit: BoxFit.contain,
                width: wScale(142)),
            onPressed: () {
              value == 0 ? null : handleCard(type);
            },
          ),
        ),
        const CustomSpacer(size: 8),
        Row(
          children: [
            Text(cardName,
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff465158))),
            SizedBox(
              width: wScale(26),
              height: hScale(16),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                ),
                child: Text('($value)',
                    style: TextStyle(
                        fontSize: fSize(12),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff30E7A9))),
                onPressed: () {
                  value == 0 ? null : handleCard(type);
                },
              ),
            ),
            value == 0
                ? const SizedBox()
                : Container(
                    width: wScale(12),
                    height: hScale(12),
                    alignment: Alignment.center,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        primary: Colors.white,
                      ),
                      child: Icon(Icons.arrow_forward_rounded,
                          color: const Color(0xff70828D), size: wScale(12)),
                      onPressed: () {
                        handleCard(type);
                      },
                    ),
                  ),
          ],
        ),
      ],
    );
  }
}

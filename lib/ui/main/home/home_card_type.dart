import 'package:co/ui/main/cards/physical_card.dart';
import 'package:co/ui/main/cards/virtual_card.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeCardType extends StatefulWidget {
  final bool mobileVerified;
  const HomeCardType({Key? key, this.mobileVerified = true}) : super(key: key);

  @override
  HomeCardTypeState createState() => HomeCardTypeState();
}

class HomeCardTypeState extends State<HomeCardType> {
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

  String getBusinessAccountSummary = Queries.QUERY_BUSINESS_ACCOUNT_SUMMARY;
  String getUserAccountSummary = Queries.QUERY_USER_ACCOUNT_SUMMARY;

  int cardType = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            color: Colors.grey.withOpacity(0.25),
            spreadRadius: 4,
            blurRadius: 20,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          userStorage.getItem('isAdmin') ? cardGroupField() : SizedBox(),
          CustomSpacer(size: userStorage.getItem('isAdmin') ? 16 : 0),
          cardTypeQueryField()
        ],
      ),
    );
  }

  Widget cardGroupField() {
    return Container(
      width: wScale(295),
      height: hScale(34),
      padding: EdgeInsets.all(hScale(2)),
      decoration: BoxDecoration(
        color: const Color(0xfff5f5f6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(hScale(17)),
          topRight: Radius.circular(hScale(17)),
          bottomLeft: Radius.circular(hScale(17)),
          bottomRight: Radius.circular(hScale(17)),
        ),
      ),
      child: Row(children: [
        cardGroupButton(AppLocalizations.of(context)!.mycards, 0),
        cardGroupButton(AppLocalizations.of(context)!.comapnycards, 1),
      ]),
    );
  }

  Widget cardGroupButton(cardName, type) {
    return type == cardType
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0),
              primary: const Color(0xff4B5A63),
              side: const BorderSide(width: 0, color: Color(0xff4B5A63)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () {
              setState(() {
                cardType = type;
              });
            },
            child: Container(
              width: wScale(145),
              height: hScale(30),
              alignment: Alignment.center,
              child: Text(
                cardName,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ))
        : TextButton(
            style: TextButton.styleFrom(
              primary: const Color(0xff70828D),
              padding: const EdgeInsets.all(0),
              textStyle: TextStyle(
                  fontSize: fSize(14), color: const Color(0xff70828D)),
            ),
            onPressed: () {
              setState(() {
                cardType = type;
              });
            },
            child: Container(
              width: wScale(145),
              height: hScale(30),
              alignment: Alignment.center,
              child: Text(
                cardName,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff70828D)),
              ),
            ),
          );
  }

  Widget cardTypeQueryField() {
    var accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Query(
            options: QueryOptions(
              document: gql(cardType == 0
                  ? getUserAccountSummary
                  : getBusinessAccountSummary),
              variables: {
                'orgId': userStorage.getItem("orgId"),
                'isAdmin': userStorage.getItem("isAdmin")
              },
            ),
            builder: (QueryResult result,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.hasException) {
                return Text(result.exception.toString());
              }

              if (result.isLoading) {
                return cardTypeField(0, 0);
              }
              var totalPhysicalCards = cardType == 0
                  ? result.data!['readUserFinanceAccountSummary'] == null
                      ? 0
                      : result.data!['readUserFinanceAccountSummary']['data']
                          ['totalPhysicalCards']
                  : result.data!['readBusinessAcccountSummary'] == null
                      ? 0
                      : result.data!['readBusinessAcccountSummary']['data']
                          ['totalPhysicalCards'];
              var totalVirtaulCards = result.data == null
                  ? 0
                  : cardType == 0
                      ? result.data!['readUserFinanceAccountSummary'] == null
                          ? 0
                          : result.data!['readUserFinanceAccountSummary']
                              ['data']['totalVirtualCards']
                      : result.data!['readBusinessAcccountSummary'] == null
                          ? 0
                          : result.data!['readBusinessAcccountSummary']['data']
                              ['totalVirtualCards'];
              return cardTypeField(totalPhysicalCards, totalVirtaulCards);
            }));
  }

  Widget cardTypeField(physicalCards, virtualCards) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      cardTypeImage(
          'assets/physical_card.png',
          AppLocalizations.of(context)!.physicalcards,
          physicalCards,
          'physical'),
      cardTypeImage('assets/virtual_card.png',
          AppLocalizations.of(context)!.virtualcards, virtualCards, 'virtual'),
    ]);
  }

  Widget cardTypeImage(imageURL, cardName, value, type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: Image.asset(imageURL,
              color: value == 0
                  ? Colors.white.withOpacity(0.5)
                  : Colors.white.withOpacity(1),
              colorBlendMode: BlendMode.modulate,
              fit: BoxFit.contain,
              width: wScale(142)),
        ),
        const CustomSpacer(size: 8),
        Row(
          children: [
            Text(cardName,
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff465158))),
            Text('  ($value)  ',
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff30E7A9))),
            value == 0
                ? SizedBox()
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
                            color: Color(0xff70828D), size: wScale(12)),
                        onPressed: () {
                          widget.mobileVerified
                              ? Navigator.of(context).push(
                                  CupertinoPageRoute(
                                      builder: (context) => type == "physical"
                                          ? PhysicalCards(defaultType: cardType)
                                          : VirtualCards(
                                              defaultType: cardType + 1)),
                                )
                              : null;
                        })),
          ],
        ),
      ],
    );
  }
}

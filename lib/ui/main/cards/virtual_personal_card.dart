import 'dart:convert';

import 'package:co/ui/main/cards/virtual_personal_card_main.dart';
import 'package:co/ui/main/home/home.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/ui/widgets/custom_no_internet.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class VirtualPersonalCard extends StatefulWidget {
  final cardData;
  final isTeam;
  const VirtualPersonalCard({Key? key, this.cardData, this.isTeam = false})
      : super(key: key);

  @override
  VirtualPersonalCardState createState() => VirtualPersonalCardState();
}

class VirtualPersonalCardState extends State<VirtualPersonalCard> {
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
  String queryVirtualCardPage = Queries.QUERY_VIRTUAL_CARD_PAGE;

  @override
  void initState() {
    super.initState();
  }

  updateState() {
    setState(() {});
  }

@override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    return Query(
        options: QueryOptions(
          document: gql(queryVirtualCardPage),
          variables: {
            "financeAccountId": widget.cardData['id'],
            "orgId": widget.cardData['orgId'],
          },
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return CustomNoInternet(handleTryAgain: () {
              Navigator.of(context)
                  .push(new MaterialPageRoute(
                      builder: (context) => VirtualPersonalCard()))
                  .then((value) => setState(() => {}));
            });
          }

          if (result.isLoading) {
            return CustomLoading();
          }
          var readFinanceAccount = result.data!['readFinanceAccount'];
          return VirtualPersonalCardMain(
              cardData: readFinanceAccount, isTeam: widget.isTeam, updateState: updateState);
        });
  }
}

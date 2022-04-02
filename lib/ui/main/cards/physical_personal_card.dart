import 'package:co/ui/main/cards/physical_personal_card_main.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/ui/widgets/custom_no_internet.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';

class PhysicalPersonalCard extends StatefulWidget {
  final cardData;
  final isTeam;
  const PhysicalPersonalCard({Key? key, this.cardData, this.isTeam})
      : super(key: key);

  @override
  PhysicalPersonalCardState createState() => PhysicalPersonalCardState();
}

class PhysicalPersonalCardState extends State<PhysicalPersonalCard> {
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
  String queryReadFinanceAccount = Queries.QUERY_READ_FINANCE_ACCOUNT;


  handleReload() {
    setState(() {});
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
    return Query(
        options: QueryOptions(
          document: gql(queryReadFinanceAccount),
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
                      builder: (context) => PhysicalPersonalCard()))
                  .then((value) => setState(() => {}));
            });
          }

          if (result.isLoading) {
            return CustomLoading();
          }
          var readFinanceAccount = result.data!['readFinanceAccount'];
          return PhysicalPersonalCardMain(
              cardData: readFinanceAccount, isTeam: widget.isTeam, handleReload: handleReload);
        });
  }
}

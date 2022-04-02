import 'package:co/ui/main/cards/manage_limits_main.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';

class ManageLimits extends StatefulWidget {
  final data;
  const ManageLimits({Key? key, this.data}) : super(key: key);
  @override
  ManageLimitsState createState() => ManageLimitsState();
}

class ManageLimitsState extends State<ManageLimits> {
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
  String readFinanceAccountQuery = Queries.QUERY_READ_FINANCE_ACCOUNT;

  handlePopNavigator() {
    Navigator.pop(context, true);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Query(
            options: QueryOptions(
              document: gql(readFinanceAccountQuery),
              variables: {
                'orgId': widget.data['orgId'],
                "financeAccountId": widget.data['id']
              },
              
            ),
            builder: (QueryResult result,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.hasException) {
                return Text(result.exception.toString());
              }

              if (result.isLoading) {
                return CustomLoading();
              }

              var financeAccount = result.data!['readFinanceAccount'];

              return ManageLimitsMain(
                  financeAccount: financeAccount,
                  data: widget.data,
                  handlePopNavigator: handlePopNavigator);
            }));
  }
}

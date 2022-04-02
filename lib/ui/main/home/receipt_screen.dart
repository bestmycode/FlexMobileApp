import 'package:camera/camera.dart';
import 'package:co/ui/main/home/receipt_transaction_type.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/scale.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';

class ReceiptScreen extends StatefulWidget {
  final XFile? uploadFile;
  final String? accountID;
  final String? transactionID;
  final initTransactionType;
  const ReceiptScreen(
      {Key? key, this.uploadFile, this.accountID, this.transactionID, this.initTransactionType = 1})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ReceiptScreen();
  }
}

class _ReceiptScreen extends State<ReceiptScreen> {
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
  String getTransactionDetail = Queries.QUERY_GET_TRANSACTION_DETAIL;

  int transactionType = 1;
  handleTransactionType(type) {
    setState(() {
      transactionType = type;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      transactionType = widget.initTransactionType;
    });
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    return Material(
        child: Scaffold(
            body: Query(
                options: QueryOptions(
                  document: gql(getTransactionDetail),
                  variables: {
                    "financeAccountId": widget.accountID,
                    "sourceTransactionId": widget.transactionID
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

                  return mainHome(result.data!['getTransactionDetails']
                      ['getTransactionData']);
                })));
  }

  Widget mainHome(data) {
    return Material(
        child: Scaffold(
            body: Container(
                height: hScale(812),
                child: Stack(children: [
                  SingleChildScrollView(
                      child: Align(
                          child: Column(
                    children: [
                      const CustomSpacer(size: 50),
                      CustomMainHeader(
                          title: "Transaction ${data['sourceTransactionId']}"),
                      const CustomSpacer(size: 39),
                      ReceiptTransactionType(data: data, accountID: widget.accountID, transactionID: widget.transactionID, initTransactionType: widget.initTransactionType)
                    ],
                  ))),
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    child: CustomBottomBar(active: 0),
                  )
                ]))));
  }
}

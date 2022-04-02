import 'package:co/models/mcd_card_data.model.dart';
import 'package:co/services/mcd.dart';

import 'package:co/ui/main/cards/manage_limits.dart';
import 'package:co/ui/main/cards/manage_user_limits.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_result_modal.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/transaction_item.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class VirtualPersonalCardMain extends StatefulWidget {
  final cardData;
  final isTeam;
  final cardDetail;
  final updateState;
  const VirtualPersonalCardMain(
      {Key? key,
      this.cardData,
      this.isTeam = false,
      this.cardDetail,
      this.updateState})
      : super(key: key);

  @override
  VirtualPersonalCardMainState createState() => VirtualPersonalCardMainState();
}

class VirtualPersonalCardMainState extends State<VirtualPersonalCardMain> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  bool isLoading = false;
  int cardType = 1;
  int transactionStatus = 1;
  bool showCardDetail = false;
  bool freezeMode = false;
  bool flagCopiedCVV = false;
  bool flagCopiedAccount = false;
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String queryAllTransactions = Queries.QUERY_ALL_TRANSACTIONS;
  String freezeMutation = FXRMutations.MUTATION_FREEZE_FINANCE_ACCOUNT;
  String unFreezeMutation = FXRMutations.MUTATION_UNFREEZE_FINANCE_ACCOUNT;
  String removeMutation = FXRMutations.MUTATION_BLOCK_FINANCE_ACCOUNT;
  var transComplete = [];
  var transPending = [];
  var transDecline = [];

  handleCardType(type) {
    setState(() {
      cardType = type;
    });
  }

  handleTransactionStatus(status) {
    setState(() {
      transactionStatus = status;
    });
  }

  handleShowCardDetail() {
    setState(() {
      showCardDetail = !showCardDetail;
    });
  }

  handleCopied(index, num) {
    Clipboard.setData(ClipboardData(text: num));
    setState(() {
      index == 0 ? flagCopiedAccount = true : flagCopiedCVV = true;
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

    final transVars1 = {
      "flaId": widget.cardData['id'],
      "limit": 100,
      "offset": 0,
      "orgId": widget.cardData['orgId'],
      "status": "COMPLETED"
    };
    final transVars2 = {
      "flaId": widget.cardData['id'],
      "limit": 100,
      "offset": 0,
      "orgId": widget.cardData['orgId'],
      "status": "APPROVED"
    };
    final transVars3 = {
      "flaId": widget.cardData['id'],
      "limit": 100,
      "offset": 0,
      "orgId": widget.cardData['orgId'],
      "status": "DECLINED"
    };
    try {
      final queryOptions1 = QueryOptions(
          document: gql(queryAllTransactions), variables: transVars1);
      final transactionCompleteResult = await client.query(queryOptions1);
      final queryOption2 = QueryOptions(
          document: gql(queryAllTransactions), variables: transVars2);
      final transactionApproveResult = await client.query(queryOption2);
      final queryOptions3 = QueryOptions(
          document: gql(queryAllTransactions), variables: transVars3);
      final transactionDeclineResult = await client.query(queryOptions3);

      setState(() {
        transComplete = transactionCompleteResult.data?['listTransactions']
                ['financeAccountTransactions'] ??
            [];
        transPending = transactionApproveResult.data?['listTransactions']
                ['financeAccountTransactions'] ??
            [];
        transDecline = transactionDeclineResult.data?['listTransactions']
                ['financeAccountTransactions'] ??
            [];
        isLoading = false;
      });
    } catch (error) {
      print("===== Error : Virtual Personal Card Transactions =====");
      print("===== Query : allTransactionsQuery =====");
      print(error);
      await Sentry.captureException(error);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    return Material(
        child: Scaffold(
            body: Stack(children: [
      SingleChildScrollView(
          child: Column(children: [
        const CustomSpacer(size: 44),
        CustomMainHeader(
            title: widget.cardData["accountName"] == null
                ? ""
                : widget.isTeam
                    ? '${widget.cardData["accountName"]}’s ${widget.cardData["cardName"]} Card'
                    : '${widget.cardData["cardName"]} Card'),
        const CustomSpacer(size: 31),
        cardDetailField(),
        const CustomSpacer(size: 10),
        spendLimitField(),
        const CustomSpacer(size: 20),
        actionButtonField(),
        const CustomSpacer(size: 20),
        Container(
            height: hScale(500),
            child: SingleChildScrollView(
                child: Column(
              children: [
                allTransactionField(),
                const CustomSpacer(size: 10),
                tab_Controller()
              ],
            ))),
        const CustomSpacer(size: 88),
      ])),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 11),
      )
    ])));
  }

  Widget cardDetailField() {
    return Opacity(
        opacity: widget.cardData['status'] == 'ACTIVE' ? 1 : 0.5,
        child: Container(
          width: wScale(327),
          padding: EdgeInsets.only(
              left: wScale(16),
              right: wScale(16),
              top: hScale(16),
              bottom: hScale(16)),
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
                color: Color(0xFF106549).withOpacity(0.1),
                spreadRadius: 4,
                blurRadius: 10,
                offset: const Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // cardField(),
              showCardDetail
                  ? FutureBuilder<McdCardData?>(
                      future: const McdCardService().getCardData(
                          cardId: widget.cardData['id'],
                          publicToken: widget.cardData['publicToken']),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return cardField(
                            cvv: snapshot.data!.cvv,
                            pan: snapshot.data!.pan,
                          );
                        }
                        return cardField(isLoading: true);
                      },
                    )
                  : cardField(),
              const CustomSpacer(size: 14),
              widget.cardData['status'] == "ACTIVE"
                  ? cardValueField()
                  : cardNoActiveValueField(widget.cardData['status'])
            ],
          ),
        ));
  }

  Widget cardField({bool isLoading = false, String cvv = '', String pan = ''}) {
    return Stack(children: [
      Container(
          width: wScale(295),
          height: wScale(187),
          padding: EdgeInsets.all(hScale(16)),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/virtual_card_detail.png"),
              fit: BoxFit.contain,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    cardTypeField(),
                    SizedBox(width: wScale(10)),
                    widget.isTeam ? SizedBox() : eyeIconField()
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        widget.cardData['cardName'] == null
                            ? ""
                            : widget.cardData['cardName']
                                .toString()
                                .toUpperCase(),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            fontSize: fSize(14))),
                    const CustomSpacer(size: 6),
                    Row(children: [
                      Text(
                          showCardDetail && pan.isNotEmpty
                              ? "${pan.substring(0, 4)} ${pan.substring(4, 8)} ${pan.substring(8, 12)} ${pan.substring(12, 16)}"
                              : '* * * *  * * * *  * * * *  ${widget.cardData['permanentAccountNumber'].split('******')[1]}',
                          style: TextStyle(
                              color: Colors.white, fontSize: fSize(16))),
                      SizedBox(width: wScale(7)),
                      showCardDetail
                          ? Container(
                              width: wScale(14),
                              height: hScale(14),
                              alignment: Alignment.center,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  primary: const Color(0xff515151),
                                  padding: EdgeInsets.all(0),
                                  textStyle: TextStyle(
                                      fontSize: fSize(14),
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xff040415)),
                                ),
                                onPressed: () {
                                  handleCopied(0, pan);
                                },
                                child: const Icon(Icons.content_copy,
                                    color: Color(0xff30E7A9), size: 14.0),
                              ))
                          : SizedBox(),
                      SizedBox(width: wScale(4)),
                      flagCopiedAccount
                          ? TextButton(
                              style: TextButton.styleFrom(
                                primary: const Color(0xff515151),
                                padding: EdgeInsets.all(0),
                              ),
                              onPressed: () {
                                handleCopied(0, pan);
                              },
                              child: Text('Copied',
                                  style: TextStyle(
                                      fontSize: fSize(14),
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xff30E7A9))))
                          : const SizedBox(),
                    ]),
                  ],
                ),
                Row(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Valid Thru',
                          style: TextStyle(
                              color: Colors.white, fontSize: fSize(10))),
                      Text(
                          showCardDetail
                              ? "${widget.cardData['expiryDate'].substring(0, 2)}/${widget.cardData['expiryDate'].substring(2, 4)}"
                              : 'MM / DD',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: fSize(11),
                              fontWeight: FontWeight.bold))
                    ],
                  ),
                  SizedBox(width: wScale(10)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CVV',
                          style: TextStyle(
                              color: Colors.white, fontSize: fSize(10))),
                      Text(showCardDetail && cvv.isNotEmpty ? cvv : '* * *',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: fSize(11),
                              fontWeight: FontWeight.bold))
                    ],
                  ),
                  SizedBox(width: wScale(6)),
                  showCardDetail
                      ? Container(
                          width: wScale(14),
                          height: hScale(14),
                          alignment: Alignment.center,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              primary: const Color(0xff515151),
                              padding: EdgeInsets.all(0),
                              textStyle: TextStyle(
                                  fontSize: fSize(14),
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff040415)),
                            ),
                            onPressed: () {
                              handleCopied(1, widget.cardData['cvv']);
                            },
                            child: const Icon(Icons.content_copy,
                                color: Color(0xff30E7A9), size: 14.0),
                          ))
                      : SizedBox(),
                  SizedBox(width: wScale(4)),
                  flagCopiedCVV
                      ? TextButton(
                          style: TextButton.styleFrom(
                            primary: const Color(0xff515151),
                            padding: EdgeInsets.all(0),
                          ),
                          onPressed: () {
                            handleCopied(1, widget.cardData['cvv']);
                          },
                          child: Text('Copied',
                              style: TextStyle(
                                  fontSize: fSize(14),
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff30E7A9))))
                      : const SizedBox(),
                ]),
                Text(
                    widget.cardData['accountName'] == null
                        ? ""
                        : widget.cardData['accountName'].toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: fSize(14))),
              ])),
      if (isLoading)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            color: Colors.white.withOpacity(0.7),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
    ]);
  }

  Widget cardValueField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Available Limit',
            style: TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w600)),
        Container(
            padding: EdgeInsets.only(
                left: wScale(16),
                right: wScale(16),
                top: hScale(5),
                bottom: hScale(5)),
            decoration: BoxDecoration(
              color: const Color(0xFFDEFEE9),
              borderRadius: BorderRadius.all(
                Radius.circular(hScale(16)),
              ),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${widget.cardData['currencyCode']} ',
                      style: TextStyle(
                          fontSize: fSize(12),
                          fontWeight: FontWeight.w500,
                          height: 1,
                          color: Color(0xFF30E7A9))),
                  Text(
                      widget.cardData['financeAccountLimits'][0]
                              ['availableLimit']
                          .toStringAsFixed(2),
                      style: TextStyle(
                          fontSize: fSize(12),
                          fontWeight: FontWeight.w500,
                          height: 1,
                          color: Color(0xFF30E7A9))),
                ]))
      ],
    );
  }

  Widget cardNoActiveValueField(status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Card Status',
            style: TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w600)),
        Container(
            padding: EdgeInsets.only(
                left: wScale(16),
                right: wScale(16),
                top: hScale(5),
                bottom: hScale(5)),
            decoration: BoxDecoration(
              color: widget.cardData['status'] == "SUSPENDED"
                  ? Color(0xFFC9E8FB)
                  : widget.cardData['status'] == "EXPIRED"
                      ? Color(0xFFC1CACF)
                      : Color(0xFFFFC3BD),
              borderRadius: BorderRadius.all(
                Radius.circular(hScale(16)),
              ),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      widget.cardData['status'] == "SUSPENDED"
                          ? "Frozen"
                          : widget.cardData['status'] == "EXPIRED"
                              ? "Expired"
                              : "Cancelled",
                      style: TextStyle(
                          fontSize: fSize(12),
                          fontWeight: FontWeight.w500,
                          height: 1,
                          color: widget.cardData['status'] == "SUSPENDED"
                              ? Color(0xFF0C649A)
                              : widget.cardData['status'] == "EXPIRED"
                                  ? Color(0xFF606060)
                                  : Color(0xFFEB5757))),
                ]))
      ],
    );
  }

  Widget cardTypeField() {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: wScale(10), vertical: hScale(3)),
      decoration: BoxDecoration(
          color: Color(0xFF21C990),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(hScale(17)),
            topRight: Radius.circular(hScale(17)),
            bottomLeft: Radius.circular(hScale(17)),
            bottomRight: Radius.circular(hScale(17)),
          )),
      child: Text(
          widget.cardData['cardType'] == "RECURRING" ? "Recurring" : "Fixed",
          style: TextStyle(fontSize: fSize(12), color: Colors.white)),
    );
  }

  Widget eyeIconField() {
    return widget.cardData['status'] == "CLOSED"
        ? SizedBox()
        : Container(
            height: hScale(34),
            width: hScale(34),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(hScale(17)),
                  topRight: Radius.circular(hScale(17)),
                  bottomLeft: Radius.circular(hScale(17)),
                  bottomRight: Radius.circular(hScale(17)),
                )),
            child: IconButton(
              padding: const EdgeInsets.all(0),
              icon: Image.asset(
                  showCardDetail
                      ? 'assets/hide_eye.png'
                      : 'assets/show_eye.png',
                  fit: BoxFit.contain,
                  height: hScale(16)),
              iconSize: hScale(17),
              onPressed: () {
                handleShowCardDetail();
              },
            ));
  }

  Widget spendLimitField() {
    var limitData = widget.cardData['financeAccountLimits'][0];
    double percentage =
        (1 - limitData['availableLimit'] / limitData['limitValue']) as double;
    return Opacity(
        opacity: widget.cardData['status'] == 'ACTIVE' ? 1 : 0.5,
        child: Container(
          width: wScale(327),
          padding: EdgeInsets.only(
              left: wScale(16),
              right: wScale(16),
              top: hScale(16),
              bottom: hScale(16)),
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
                color: Color(0xFF106549).withOpacity(0.1),
                spreadRadius: 4,
                blurRadius: 10,
                offset: const Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Monthly Spend Limit',
                      style: TextStyle(
                          fontSize: fSize(14),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A2831))),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${widget.cardData['currencyCode']} ',
                            style: TextStyle(
                                fontSize: fSize(10),
                                fontWeight: FontWeight.w600,
                                height: 1,
                                color: const Color(0xFF1A2831))),
                        Text(
                            widget.cardData['financeAccountLimits'][0]
                                    ['limitValue']
                                .toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: fSize(14),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A2831))),
                      ])
                ],
              ),
              const CustomSpacer(size: 12),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: const Color(0xFFF4F4F4),
                  color: percentage < 0.7
                      ? const Color(0xFF30E7A9)
                      : percentage < 1
                          ? const Color(0xFFFEB533)
                          : const Color(0xFFEB5757),
                  minHeight: hScale(10),
                ),
              ),
              const CustomSpacer(size: 12),
              Row(
                children: [
                  Image.asset(
                      percentage < 0.7
                          ? 'assets/emoji1.png'
                          : percentage < 1
                              ? 'assets/emoji2.png'
                              : 'assets/emoji3.png',
                      fit: BoxFit.contain,
                      width: wScale(18)),
                  SizedBox(width: wScale(10)),
                  Container(
                      width: wScale(260),
                      child: Text(
                          percentage < 0.7
                              ? widget.isTeam
                                  ? 'Great job, ${widget.cardData["accountName"]} is within the allocated limit!'
                                  : 'Great job, you are within your allocated limit!'
                              : percentage < 1
                                  ? widget.isTeam
                                      ? 'Careful! ${widget.cardData["accountName"]} is almost at limit. Consider adding more?'
                                      : 'Careful! you are almost at limit. Consider adding more?'
                                  : widget.isTeam
                                      ? '${widget.cardData["accountName"]} has reached the limit! Add more?'
                                      : 'You have reached your limit! Add more?',
                          style: TextStyle(
                              fontSize: fSize(12),
                              color: const Color(0xFF70828D)))),
                ],
              )
            ],
          ),
        ));
  }

  Widget actionButton(imageUrl, text, type) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          primary: const Color(0xffffffff),
          side: const BorderSide(width: 0, color: Color(0xffffffff)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () async {
          if (type == 0) {
            widget.cardData['status'] == "ACTIVE" ||
                    widget.cardData['status'] == "SUSPENDED"
                ? _showFreezeModalDialog()
                : null;
          } else if (type == 1) {
            if (widget.cardData['status'] == "ACTIVE") {
              var result = await Navigator.of(context).push(
                CupertinoPageRoute(
                    builder: (context) => userStorage.getItem("isAdmin")
                        ? ManageLimits(data: widget.cardData)
                        : ManageUserLimits(data: widget.cardData)),
              );
              if (result) {
                widget.updateState();
              }
            }
          } else {
            widget.cardData['status'] == "ACTIVE" ||
                    widget.cardData['status'] == "SUSPENDED"
                ? _showRemoveModalDialog()
                : null;
          }
        },
        child: SizedBox(
            width: wScale(102),
            height: hScale(82),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(imageUrl, fit: BoxFit.contain, height: wScale(24)),
                const CustomSpacer(
                  size: 10,
                ),
                Text(
                  text,
                  style: TextStyle(
                      fontSize: fSize(12),
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ],
            )));
  }

  Widget actionButtonField() {
    return SizedBox(
      width: wScale(327),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Opacity(
            opacity: widget.cardData['status'] == 'ACTIVE' ||
                    widget.cardData['status'] == 'SUSPENDED'
                ? 1
                : 0.5,
            child: actionButton(
                'assets/free.png',
                widget.cardData['status'] != 'SUSPENDED'
                    ? 'Freeze Card'
                    : 'Unfreeze Card',
                0)),
        Opacity(
            opacity: widget.cardData['status'] == 'ACTIVE' ? 1 : 0.5,
            child: actionButton(
                'assets/limit.png',
                userStorage.getItem("isAdmin") ? 'Edit Limit' : 'View Limit',
                1)),
        Opacity(
            opacity: widget.cardData['status'] == 'ACTIVE' ||
                    widget.cardData['status'] == 'SUSPENDED'
                ? 1
                : 0.5,
            child: actionButton('assets/cancel.png', 'Cancel Card', 2)),
      ]),
    );
  }

  Widget allTransactionField() {
    return SizedBox(
      width: wScale(327),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
                '${widget.cardData["accountName"] == null ? "" : widget.cardData["accountName"]}’s Transactions',
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w500,
                    height: 1.8)),
          ]),
        ],
      ),
    );
  }

  Widget transactionStatusButton(status, type) {
    return Container(
      width: wScale(107),
      height: hScale(32),
      alignment: Alignment.center,
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: fSize(14),
            color:
                type != 3 ? const Color(0xFF1A2831) : const Color(0xFFEB5757)),
      ),
    );
  }

  Widget transactionField(date, transactionName, value, status) {
    return Container(
        width: wScale(327),
        padding:
            EdgeInsets.symmetric(vertical: hScale(16), horizontal: wScale(16)),
        margin: EdgeInsets.only(bottom: hScale(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF106549).withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 10,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                transactionTimeField(date),
                const CustomSpacer(size: 6),
                transactionNameField(transactionName),
                const CustomSpacer(size: 6),
                moneyValue(
                    '',
                    value,
                    14.0,
                    FontWeight.w700,
                    status == 0
                        ? const Color(0xFF1A2831)
                        : const Color(0xff60C094)),
              ],
            ),
            SizedBox(
                width: wScale(16),
                height: hScale(18),
                child: status == 0
                    ? Image.asset('assets/add_transaction.png',
                        fit: BoxFit.contain, width: wScale(16))
                    : Image.asset('assets/check_transaction.png',
                        fit: BoxFit.contain, width: wScale(16)))
          ],
        ));
  }

  Widget transactionTimeField(date) {
    return Text('$date',
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xff70828D)));
  }

  Widget transactionNameField(name) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fSize(16),
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        children: [
          TextSpan(text: name),
        ],
      ),
    );
  }

  Widget moneyValue(title, value, size, weight, color) {
    return SizedBox(
      width: wScale(263),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title,
              style: TextStyle(fontSize: fSize(12), color: Colors.white)),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("SGD  ",
                style: TextStyle(
                  fontSize: fSize(12),
                  fontWeight: weight,
                  color: color,
                  height: 1,
                )),
            Text(value,
                style: TextStyle(
                  fontSize: fSize(size),
                  fontWeight: weight,
                  color: color,
                  height: 1,
                )),
          ])
        ],
      ),
    );
  }

  Widget getTransactionArrWidgets(arr) {
    return arr.length == 0
        ? Image.asset('assets/empty_transaction.png',
            fit: BoxFit.contain, width: wScale(327))
        : Opacity(
            opacity: transactionStatus == 3 ? 0.5 : 1,
            child: Column(
                children: arr.map<Widget>((item) {
              return TransactionItem(
                  whichTab: transactionStatus == 1
                      ? "COMPLETED"
                      : transactionStatus == 2
                          ? "PENDING"
                          : "DECLINED",
                  accountId: item['txnFinanceAccId'],
                  transactionId: item['sourceTransactionId'],
                  date: item['transactionDate'],
                  transactionName: item['description'],
                  status: item['status'],
                  transactionType: item['transactionType'],
                  userName: item['merchantName'],
                  cardNum: item['pan'],
                  billCurrency: item['billCurrency'],
                  fxrBillAmount: item['fxrBillAmount'],
                  transactionCurrency: item['transactionCurrency'],
                  transactionAmount: item['transactionAmount'],
                  qualifiers:
                      item['qualifiers'] == null ? "" : item['qualifiers'],
                  receiptStatus: item['fxrBillAmount'] >= 0
                      ? 0
                      : item['receiptStatus'] == "PAID"
                          ? 2
                          : 1);
            }).toList()));
  }

  _showFreezeModalDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: wScale(40)),
              child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: freezeMutationField()));
        });
  }

  _showRemoveModalDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: wScale(40)),
              child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: removeMutationField()));
        });
  }

  Widget freezeMutationField() {
    String accessToken = storage.getItem("jwt_token");
    String cardStatus = widget.cardData['status'];
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Mutation(
            options: MutationOptions(
              document: gql(cardStatus == 'ACTIVE'
                  ? freezeMutation
                  : cardStatus == 'SUSPENDED'
                      ? unFreezeMutation
                      : ''),
              update: (GraphQLDataProxy cache, QueryResult? result) {
                return cache;
              },
              onCompleted: (resultData) {
                var success = cardStatus == 'ACTIVE'
                    ? resultData['freezeFinanceAccount']['success']
                    : resultData['unfreezeFinanceAccount']['success'];
                var message = cardStatus == 'ACTIVE'
                    ? resultData['freezeFinanceAccount']['message']
                    : resultData['unfreezeFinanceAccount']['message'];
                if (success)
                  setState(() {
                    freezeMode = true;
                  });
                _showResultModalDialog(context, success, message, 0);
              },
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              return freezeModalField(runMutation);
            }));
  }

  Widget removeMutationField() {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Mutation(
            options: MutationOptions(
              document: gql(removeMutation),
              update: (GraphQLDataProxy cache, QueryResult? result) {
                return cache;
              },
              onCompleted: (resultData) {
                var success = resultData['blockFinanceAccount']['success'];
                var message = resultData['blockFinanceAccount']['message'];
                if (success)
                  setState(() {
                    freezeMode = true;
                  });
                _showResultModalDialog(context, success, message, 2);
              },
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              return removeModalField(runMutation);
            }));
  }

  _showResultModalDialog(context, success, message, type) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: wScale(40)),
              child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: CustomResultModal(
                      status: success,
                      title: type == 0
                          ? widget.cardData['status'] == "ACTIVE"
                              ? success
                                  ? "Card frozen successfully"
                                  : "Card frozen failed"
                              : success
                                  ? "Card reactivated successfully"
                                  : "Card reactive failed"
                          : success
                              ? "Card cancelled successfully"
                              : "Something went wrong",
                      message: type == 0
                          ? widget.cardData['status'] == "ACTIVE"
                              ? success
                                  ? "The card has been frozen and is temporarily deactivated. To resume usage, please unfreeze it."
                                  : message
                              : success
                                  ? "Your card is active. You can now proceed to make payments."
                                  : message
                          : success
                              ? "The card has been cancelled, you won't be able to reactivate it again."
                              : "Please try again later",
                      handleOKClick: () {
                        Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
                        widget.updateState();
                      })));
        });
  }

  Widget freezeModalField(runMutation) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
          padding: EdgeInsets.symmetric(
              vertical: hScale(25), horizontal: wScale(16)),
          child: Column(children: [
            Image.asset('assets/snow_icon.png',
                fit: BoxFit.contain, height: wScale(30)),
            const CustomSpacer(size: 15),
            Text(
                widget.cardData['status'] == "ACTIVE"
                    ? 'Freezing this card?'
                    : "Unfreezing this card?",
                style: TextStyle(
                    fontSize: fSize(14), fontWeight: FontWeight.w700)),
            const CustomSpacer(size: 10),
            Text(
              widget.cardData['status'] == "ACTIVE"
                  ? "Once the card is frozen, the user won't be able to use the card until you reactivate it."
                  : "You will be able to use the card when you unfreeze it.",
              style:
                  TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ])),
      Container(height: 1, color: const Color(0xFFD5DBDE)),
      Container(
          height: hScale(50),
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color(0xff30E7A9),
                      textStyle: TextStyle(
                          fontSize: fSize(16), color: const Color(0xff30E7A9)),
                    ),
                    onPressed: () => Navigator.of(context, rootNavigator: true)
                        .pop('dialog'),
                    child: const Text('Cancel'),
                  )),
              Container(width: 1, color: const Color(0xFFD5DBDE)),
              Expanded(
                  flex: 1,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color(0xff30E7A9),
                      textStyle: TextStyle(
                          fontSize: fSize(16), color: const Color(0xff30E7A9)),
                    ),
                    onPressed: () {
                      var orgId = userStorage.getItem('orgId');
                      var accountId = widget.cardData['id'];
                      runMutation(
                          {'financeAccountId': accountId, "orgId": orgId});
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                    child: const Text('Ok'),
                  ))
            ],
          ))
    ]);
  }

  Widget removeModalField(runMutation) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
          padding: EdgeInsets.symmetric(vertical: hScale(25)),
          child: Column(children: [
            Image.asset('assets/warning_icon.png',
                fit: BoxFit.contain, height: wScale(30)),
            const CustomSpacer(size: 15),
            Text('This action cannot be reversed?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: fSize(14), fontWeight: FontWeight.w700)),
            const CustomSpacer(size: 10),
            Text(
              'Once the card is cancelled, you won’t be able to reactivate it again.',
              style:
                  TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ])),
      Container(height: 1, color: const Color(0xFFD5DBDE)),
      Container(
          height: hScale(50),
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color(0xff30E7A9),
                      textStyle: TextStyle(
                          fontSize: fSize(16), color: const Color(0xff30E7A9)),
                    ),
                    onPressed: () => Navigator.of(context, rootNavigator: true)
                        .pop('dialog'),
                    child: const Text('Cancel'),
                  )),
              Container(width: 1, color: const Color(0xFFD5DBDE)),
              Expanded(
                  flex: 1,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color(0xff30E7A9),
                      textStyle: TextStyle(
                          fontSize: fSize(16), color: const Color(0xff30E7A9)),
                    ),
                    onPressed: () {
                      var orgId = userStorage.getItem('orgId');
                      var accountId = widget.cardData['id'];
                      runMutation({
                        'financeAccountId': accountId,
                        "orgId": orgId,
                        "reason": "DESTROYED"
                      });
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                    child: const Text('Confirm'),
                  ))
            ],
          ))
    ]);
  }

  Widget tab_Controller() {
    return DefaultTabController(
      length: 3,
      child: Container(
        padding: EdgeInsets.all(wScale(1)),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: wScale(327),
                height: hScale(34),
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Color(0xFF040415).withOpacity(0.04),
                ),
                child: TabBar(
                  unselectedLabelColor: Color(0xFF70828D),
                  labelPadding: const EdgeInsets.all(1),
                  labelStyle: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF70828D),
                  ),
                  labelColor: Color(0xFF040415),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xFFFFFFFF),
                  ),
                  tabs: [
                    Tab(
                      child: transactionStatusButton('Completed', 1),
                    ),
                    Tab(
                      child: transactionStatusButton('Pending', 2),
                    ),
                    Tab(
                      child: transactionStatusButton('Declined', 3),
                    ),
                  ],
                ),
              ),
            ),
            isLoading
                ? Container(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF60C094))))
                : Container(
                    height: hScale(330),
                    padding: EdgeInsets.only(top: hScale(10)),
                    child: TabBarView(
                      children: [
                        getTransactionArrWidgets(transComplete),
                        getTransactionArrWidgets(transPending),
                        getTransactionArrWidgets(transDecline),
                      ],
                    )),
          ],
        ),
      ),
    );
  }
}

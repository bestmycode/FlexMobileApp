import 'package:co/ui/main/cards/manage_limits.dart';
import 'package:co/ui/main/cards/manage_user_limits.dart';
import 'package:co/ui/main/cards/physical_card_detail.dart';
import 'package:co/ui/main/cards/physical_my_card.dart';
import 'package:co/ui/main/cards/view_limits.dart';
import 'package:co/ui/widgets/all_transaction_field.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_loading.dart';
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

class PhysicalUserCard extends StatefulWidget {
  const PhysicalUserCard({Key? key}) : super(key: key);

  @override
  PhysicalUserCardState createState() => PhysicalUserCardState();
}

class PhysicalUserCardState extends State<PhysicalUserCard> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  bool freezeMode = false;
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String getUserAccountSummary = Queries.QUERY_USER_ACCOUNT_SUMMARY;
  String freezeMutation = FXRMutations.MUTATION_FREEZE_FINANCE_ACCOUNT;
  String unFreezeMutation = FXRMutations.MUTATION_UNFREEZE_FINANCE_ACCOUNT;
  String removeMutation = FXRMutations.MUTATION_BLOCK_FINANCE_ACCOUNT;

  handleMonthlySpendLimit() {}

  handleAction(index, userAccountSummary) {
    if (index == 0) {
      _showFreezeModalDialog(context, userAccountSummary);
    } else if (index == 1) {
      Navigator.of(context).push(
        CupertinoPageRoute(
            builder: (context) => userStorage.getItem('isAdmin')
                ? ManageLimits(data: userAccountSummary['data']['physicalCard'])
                : ManageUserLimits(
                    data: userAccountSummary['data']['physicalCard'])),
      );
    } else {
      _showRemoveModalDialog(context, userAccountSummary);
    }
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
    var orgId = userStorage.getItem('orgId');
    return Material(
        child: Scaffold(
            body: Query(
                options: QueryOptions(
                  document: gql(getUserAccountSummary),
                  variables: {'orgId': orgId},
                ),
                builder: (QueryResult result,
                    {VoidCallback? refetch, FetchMore? fetchMore}) {
                  if (result.hasException) {
                    return Text(result.exception.toString());
                  }

                  if (result.isLoading) {
                    return CustomLoading();
                  }
                  var userAccountSummary =
                      result.data!['readUserFinanceAccountSummary'];
                  return mainHome(userAccountSummary);
                })));
  }

  Widget mainHome(userAccountSummary) {
    return Stack(children: [
      SingleChildScrollView(
          child: Column(children: [
        const CustomSpacer(size: 44),
        CustomMainHeader(title: 'Physical Card'),
        const CustomSpacer(size: 31),
        PhysicalCardDetail(data: userAccountSummary),
        const CustomSpacer(size: 10),
        spendLimitField(userAccountSummary),
        const CustomSpacer(size: 20),
        actionButtonField(userAccountSummary),
        const CustomSpacer(size: 20),
        userAccountSummary['data']['physicalCard'] == null
            ? SizedBox()
            : AllTransaction(
                cardID: userAccountSummary['data']['physicalCard']['id']),
        const CustomSpacer(size: 88),
      ])),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 1),
      )
    ]);
  }

  Widget spendLimitField(userAccountSummary) {
    var limitData = userAccountSummary['data']['physicalCard'] == null
        ? {"limitValue": 0}
        : userAccountSummary['data']['physicalCard']['financeAccountLimits'][0];
    double percentage = userAccountSummary['data']['physicalCard'] == null
        ? 0
        : (1 - limitData['availableLimit'] / limitData['limitValue']) as double;
    return Opacity(
        opacity: userAccountSummary['data']['physicalCard'] != null &&
                userAccountSummary['data']['physicalCard']['status'] == 'ACTIVE'
            ? 1
            : 0.5,
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
                color: const Color(0xFF106549).withOpacity(0.1),
                spreadRadius: 4,
                blurRadius: 10,
                offset: const Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          child: TextButton(
              style: TextButton.styleFrom(
                primary: const Color(0xFFFFFFFF),
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                handleMonthlySpendLimit();
              },
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
                            Text(
                                userAccountSummary['data']['physicalCard'] ==
                                        null
                                    ? ""
                                    : "${userAccountSummary['data']['physicalCard']['currencyCode']} ",
                                style: TextStyle(
                                    fontSize: fSize(10),
                                    fontWeight: FontWeight.w600,
                                    height: 1,
                                    color: const Color(0xFF1A2831))),
                            Text(limitData['limitValue'].toString(),
                                style: TextStyle(
                                    fontSize: fSize(16),
                                    fontWeight: FontWeight.w600,
                                    height: 1,
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
                                  ? 'Great job, you are within your allocated limit!'
                                  : percentage < 1
                                      ? 'Careful! you almost at limit. Consider adding more?'
                                      : 'You have reached your limit! Add more?',
                              style: TextStyle(
                                  fontSize: fSize(12),
                                  color: const Color(0xFF70828D)))),
                      percentage >= 0.8
                          ? Container(
                              height: hScale(12),
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.all(0)),
                                  onPressed: () {},
                                  child: Text('Add more!',
                                      style: TextStyle(
                                          fontSize: fSize(12),
                                          color: const Color(0xFF30E7A9)))))
                          : SizedBox()
                    ],
                  )
                ],
              )),
        ));
  }

  Widget actionButton(imageUrl, text, index, userAccountSummary) {
    return Container(
        width: wScale(102),
        // height: hScale(82),
        padding:
            EdgeInsets.symmetric(vertical: hScale(16), horizontal: wScale(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF106549).withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 40,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: TextButton(
            style: TextButton.styleFrom(
                primary: const Color(0xFFFFFFFF), padding: EdgeInsets.zero),
            onPressed: () {
              if (userAccountSummary['data']['physicalCard'] != null) {
                if (index == 1) {
                  userAccountSummary['data']['physicalCard']['status'] ==
                          "ACTIVE"
                      ? handleAction(index, userAccountSummary)
                      : null;
                } else {
                  userAccountSummary['data']['physicalCard']['status'] ==
                              "ACTIVE" ||
                          userAccountSummary['data']['physicalCard']
                                  ['status'] ==
                              "SUSPENDED"
                      ? handleAction(index, userAccountSummary)
                      : null;
                }
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  imageUrl,
                  fit: BoxFit.contain,
                  height: hScale(28),
                  width: wScale(28),
                ),
                const CustomSpacer(
                  size: 10,
                ),
                Text(
                  text,
                  style: TextStyle(
                      fontSize: fSize(12),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF70828D)),
                  textAlign: TextAlign.center,
                ),
              ],
            )));
  }

  Widget actionButtonField(userAccountSummary) {
    String freezeText = userAccountSummary['data']['physicalCard'] != null &&
            userAccountSummary['data']['physicalCard']['status'] == 'SUSPENDED'
        ? 'Unfreeze Card'
        : 'Freeze Card';
    return Opacity(
        opacity: userAccountSummary['data']['physicalCard'] == null ? 0.5 : 1,
        child: SizedBox(
          width: wScale(327),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Opacity(
                opacity: userAccountSummary['data']['physicalCard'] != null &&
                        (userAccountSummary['data']['physicalCard']['status'] ==
                                'ACTIVE' ||
                            userAccountSummary['data']['physicalCard']
                                    ['status'] ==
                                'SUSPENDED')
                    ? 1
                    : 0.5,
                child: actionButton(
                    'assets/free.png', freezeText, 0, userAccountSummary)),
            Opacity(
                opacity: userAccountSummary['data']['physicalCard'] != null &&
                        userAccountSummary['data']['physicalCard']['status'] ==
                            'ACTIVE'
                    ? 1
                    : 0.5,
                child: actionButton(
                    'assets/limit.png',
                    userStorage.getItem("isAdmin")
                        ? 'Edit Limit'
                        : 'View Limit',
                    1,
                    userAccountSummary)),
            Opacity(
                opacity: userAccountSummary['data']['physicalCard'] != null &&
                        (userAccountSummary['data']['physicalCard']['status'] ==
                                'ACTIVE' ||
                            userAccountSummary['data']['physicalCard']
                                    ['status'] ==
                                'SUSPENDED')
                    ? 1
                    : 0.5,
                child: actionButton(
                    'assets/cancel.png', 'Cancel Card', 2, userAccountSummary)),
          ]),
        ));
  }

  _showFreezeModalDialog(context, userAccountSummary) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: wScale(40)),
              child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: freezeMutationField(userAccountSummary)));
        });
  }

  _showRemoveModalDialog(context, userAccountSummary) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: wScale(40)),
              child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: removeMutationField(userAccountSummary)));
        });
  }

  _showResultModalDialog(context, success, message) {
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
                      title: freezeMode
                          ? success
                              ? "Card frozen successfully"
                              : "Card frozen failed"
                          : success
                              ? "Card reactivated successfully"
                              : "Card reactive failed",
                      message: freezeMode
                          ? success
                              ? "The card has been frozen and is temporarily deactivated. To resume usage, please unfreeze it."
                              : message
                          : success
                              ? "Your card is active. You can now proceed to make payments."
                              : message)));
        });
  }

  Widget freezeModalField(runMutation, userAccountSummary) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
          padding: EdgeInsets.symmetric(vertical: hScale(25)),
          child: Column(children: [
            Image.asset('assets/snow_icon.png',
                fit: BoxFit.contain, height: wScale(30)),
            const CustomSpacer(size: 15),
            Text('Freezing this card?',
                style: TextStyle(
                    fontSize: fSize(14), fontWeight: FontWeight.w700)),
            const CustomSpacer(size: 10),
            Text(
              "Once the card is frozen, the user won't be able to use the card until you reactivate it.",
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
                      var accountId =
                          userAccountSummary['data']['physicalCard']['id'];
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

  Widget freezeMutationField(userAccountSummary) {
    String accessToken = storage.getItem("jwt_token");
    String cardStatus = userAccountSummary['data']['physicalCard']['status'];
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
                _showResultModalDialog(context, success, message);
              },
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              return freezeModalField(runMutation, userAccountSummary);
            }));
  }

  Widget removeMutationField(userAccountSummary) {
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
                _showResultModalDialog(context, success, message);
              },
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              return removeModalField(runMutation, userAccountSummary);
            }));
  }

  Widget removeModalField(runMutation, userAccountSummary) {
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
                      var accountId =
                          userAccountSummary['data']['physicalCard']['id'];
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
}

import 'dart:convert';

import 'package:co/ui/main/home/deposit_funds.dart';
import 'package:co/ui/main/home/home_card_type.dart';
import 'package:co/ui/main/home/issue_virtual_card.dart';
import 'package:co/ui/main/home/notification.dart';
import 'package:co/ui/main/home/request_card.dart';
import 'package:co/ui/main/more/account_setting.dart';
import 'package:co/ui/main/more/company_setting.dart';
import 'package:co/ui/main/transactions/transaction_admin.dart';
import 'package:co/ui/main/transactions/transaction_user.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_fca_user_alert.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/transaction_item.dart';
import 'package:co/utils/basedata.dart';
import 'package:co/utils/defaultLayoutQuery.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  // final CupertinoTabController controller;
  // final GlobalKey<NavigatorState> navigatorKey;
  // const Home({Key? key, required this.controller, required this.navigatorKey}) : super(key: key);

  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
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
  double cardType = 1.0;
  String getUserInfoQuery = Queries.QUERY_DASHBOARD_LAYOUT;
  String getOrgIntegration = Queries.QUERY_ORGINTEGRATIONS;
  String getBusinessAccountSummary = Queries.QUERY_BUSINESS_ACCOUNT_SUMMARY;
  String getUserAccountSummary = Queries.QUERY_USER_ACCOUNT_SUMMARY;
  String getRecentTransactions = Queries.QUERY_RECENT_TRANSACTIONS;

  int userType = 0; // 0 => "normal user", 1 => "FCA user", 2 => "NON FCA user"

  String token = '';

  handleCardType(type) {
    setState(() {
      cardType = type;
    });
  }

  handleViewAllTransaction(isMobileVerified) {
    var isAdmin = userStorage.getItem("isAdmin");
    isMobileVerified ? Navigator.of(context).push(
      CupertinoPageRoute(
          builder: (context) =>
              isAdmin ? const TransactionAdmin() : const TransactionUser()),
    ): null;
  }

  handleNotification() {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => const NotificationScreen()),
    );
  }

  handleDepositFunds(businessAccountSummary) {
    Navigator.of(context).push(
      CupertinoPageRoute(
          builder: (context) =>
              DepositFundsScreen(data: businessAccountSummary)),
    );
  }

  handleCreditline(title) async {
    // Intercom.displayMessenger();
    debugPrint(title);

    String msg = "";

    if (title == "Increase Credit Line") {
      msg = '''Hello Flex,

I would like to apply for increase in Flex Plus Credit line [SGD 10,000 or 30,000 or 100,000]. 

Please reach out to me to process the application further.

Thanks.''';
    } else {
      msg = '''Hello Flex,

I would like to apply for Flex plus credit line [SGD 3000 or 10,000 or 30,000 or 100,000] 

Please reach out to me to process the application further.

Thanks.''';
    }

    Intercom.displayMessageComposer(msg);
  }

  handleQuickActions(index, isMobileVerified) {
    if (index == 0) {
      Navigator.pop(context);
      Navigator.of(context).push(
        CupertinoPageRoute(builder: (context) => CompanySetting(tabIndex: 1)),
      );
    } else if (index == 1) {
      isMobileVerified ? Navigator.of(context).push(
        CupertinoPageRoute(builder: (context) => const IssueVirtaulCard()),
      ) : null;
    } else if (index == 2) {
      isMobileVerified ? Navigator.of(context).push(
        CupertinoPageRoute(builder: (context) => const RequestCard()),
      ) : null;
    }
  }

  _onBackPressed(context) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Text("NO"),
          ),
          SizedBox(height: 16),
          new GestureDetector(
            onTap: () => SystemNavigator.pop(),
            child: Text("YES"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken), child: home(context));
  }

  Widget home(context) {
    return WillPopScope(
        onWillPop: () => _onBackPressed(context),
        child: Scaffold(
            body: Query(
                options: QueryOptions(
                  document: gql(getUserInfoQuery),
                  variables: {},
                  // pollInterval: const Duration(seconds: 10),
                ),
                builder: (QueryResult userInfoResult,
                    {VoidCallback? refetch, FetchMore? fetchMore}) {
                  if (userInfoResult.hasException) {
                    return Text(userInfoResult.exception.toString());
                  }

                  if (userInfoResult.isLoading) {
                    return CustomLoading();
                  }

                  var userInfo = userInfoResult.data!['user'];
                  var userRole = userInfo['roles'].firstWhere(
                      (item) => item['orgId'] == userInfo['currentOrgId']);
                  var isAdmin = userRole['roleName'] == 'admin' ? true : false;

                  userStorage.setItem("isAdmin", isAdmin);
                  userStorage.setItem("userId", userInfo['id']);
                  userStorage.setItem("orgId", userInfo['currentOrgId']);

                  return Query(
                      options: QueryOptions(
                        document: gql(isAdmin
                            ? getBusinessAccountSummary
                            : getUserAccountSummary),
                        variables: {
                          'orgId': userInfo['currentOrgId'],
                          'isAdmin': isAdmin ? true : false
                        },
                      ),
                      builder: (QueryResult accountSummary,
                          {VoidCallback? refetch, FetchMore? fetchMore}) {
                        if (accountSummary.hasException) {
                          return Text(accountSummary.exception.toString());
                        }

                        if (accountSummary.isLoading) {
                          return CustomLoading();
                        }

                        var businessAccountSummary = isAdmin
                            ? accountSummary
                                .data!['readBusinessAcccountSummary']
                            : accountSummary
                                .data!['readUserFinanceAccountSummary'];
                        // var userAccountSummary = accountSummary.data!['readUserFinanceAccountSummary'];
                        return Query(
                            options: QueryOptions(
                              document: gql(getRecentTransactions),
                              variables: {
                                'orgId': userInfo['currentOrgId'],
                                'limit': 10,
                                'offset': 0,
                                'status': "PENDING_OR_COMPLETED"
                              },
                            ),
                            builder: (QueryResult recentTransactionResult,
                                {VoidCallback? refetch, FetchMore? fetchMore}) {
                              if (recentTransactionResult.hasException) {
                                return Text(recentTransactionResult.exception
                                    .toString());
                              }

                              if (recentTransactionResult.isLoading) {
                                return CustomLoading();
                              }
                              var listTransactions = recentTransactionResult
                                  .data!['listTransactions'];
                              return Query(
                                  options: QueryOptions(
                                    document: gql(getOrgIntegration),
                                    variables: {
                                      "orgId": userInfo['currentOrgId']
                                    },
                                  ),
                                  builder: (QueryResult result,
                                      {VoidCallback? refetch,
                                      FetchMore? fetchMore}) {
                                    if (result.hasException) {
                                      return Text(result.exception.toString());
                                    }

                                    if (result.isLoading) {
                                      return CustomLoading();
                                    }
                                    var orgIntegrations =
                                        result.data!['orgIntegrations'];
                                    var temp_index = orgIntegrations.indexWhere(
                                        (item) =>
                                            item['integrationType'] ==
                                            "FINANCE");

                                    if (isAdmin) {
                                      if (temp_index >= 0) {
                                        if (businessAccountSummary['data'] ==
                                            null) {
                                          // Non FCA user
                                          return noFCAuser(userInfo);
                                        } else {
                                          // FCA user
                                          return mainField(
                                              userInfo,
                                              businessAccountSummary['data'],
                                              listTransactions[
                                                  'financeAccountTransactions'],
                                              isAdmin);
                                        }
                                      }
                                      return mainField(
                                          userInfo,
                                          businessAccountSummary['data'],
                                          listTransactions[
                                              'financeAccountTransactions'],
                                          isAdmin);
                                    }
                                    // Normal User
                                    return mainField(
                                        userInfo,
                                        businessAccountSummary['data'],
                                        listTransactions[
                                            'financeAccountTransactions'],
                                        isAdmin);
                                  });
                            });
                      });
                })));
  }

  Widget mainField(
      userInfo, businessAccountSummary, listTransactions, isAdmin) {
    bool isMobileVerified = userInfo['mobileVerified'];
    return Stack(children: [
      Container(
        height: hScale(812),
        child: SingleChildScrollView(
            padding: EdgeInsets.only(left: wScale(24), right: wScale(24)),
            child: Align(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  CustomSpacer(size: userInfo['mobileVerified'] ? 30 : 50),
                  userInfo['mobileVerified'] ? SizedBox() : mobileVerified(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        welcomeUser(
                            '${userInfo["firstName"]} ${userInfo["lastName"]}'),
                        IconButton(
                          icon: customImage('assets/notification.png', 16.00),
                          iconSize: hScale(10),
                          onPressed: () {
                            handleNotification();
                          },
                        )
                      ]),
                  // const CustomSpacer(size: 20),
                  CustomFCAUser(),
                  const CustomSpacer(size: 10),
                  cardValanceField(businessAccountSummary, isAdmin),
                  const CustomSpacer(size: 20),
                  isAdmin
                      ? welcomeHandleField(
                          businessAccountSummary,
                          'assets/deposit_funds.png',
                          27.0,
                          AppLocalizations.of(context)!.depositfunds)
                      : SizedBox(),
                  isAdmin ? const CustomSpacer(size: 10) : SizedBox(),
                  isAdmin
                      ? welcomeHandleField(
                          businessAccountSummary,
                          'assets/get_credit_line.png',
                          21.0,
                          businessAccountSummary == null
                              ? AppLocalizations.of(context)!.getcreditline
                              : businessAccountSummary["totalFplBalance"] == 0
                                  ? AppLocalizations.of(context)!.getcreditline
                                  : AppLocalizations.of(context)!
                                      .increasecreditline)
                      : SizedBox(),
                  isAdmin ? const CustomSpacer(size: 16) : SizedBox(),
                  isAdmin ? quickActionsField(isMobileVerified) : SizedBox(),
                  isAdmin ? const CustomSpacer(size: 16) : SizedBox(),
                  customText(isAdmin
                      ? AppLocalizations.of(context)!.cardsoverview
                      : AppLocalizations.of(context)!.mycardsoverview),
                  const CustomSpacer(size: 16),
                  HomeCardType(mobileVerified: isMobileVerified),
                  const CustomSpacer(size: 16),
                  recentTransactionField(isMobileVerified),
                  const CustomSpacer(size: 16),
                  listTransactions.length == 0
                      ? Image.asset('assets/empty_transaction.png',
                          fit: BoxFit.contain, width: wScale(327))
                      : getTransactionArrWidgets(listTransactions, isMobileVerified),
                  const CustomSpacer(size: 88),
                ]))),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 0, mobileVerified: isMobileVerified),
      )
    ]);
  }

  Widget welcomeUser(fullName) {
    return Row(
      children: [
        Text(AppLocalizations.of(context)!.welcome,
            style: TextStyle(fontSize: fSize(16), color: Colors.black)),
        Text(fullName,
            style: TextStyle(
                fontSize: fSize(16),
                color: Colors.black,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget mobileVerified() {
    return Container(
      width: wScale(327),
      padding:
          EdgeInsets.symmetric(horizontal: wScale(16), vertical: hScale(16)),
      margin: EdgeInsets.only(bottom: hScale(16)),
      decoration: BoxDecoration(
        color: Color(0xFF30e7a9),
        borderRadius: BorderRadius.all(Radius.circular(hScale(10))),
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
          Row(
            children: [
              Image.asset('assets/mobile.png',
                  fit: BoxFit.contain, width: hScale(30)),
              SizedBox(width: wScale(16)),
              Container(
                width: wScale(248),
                child: Column(children: [
                  Text('Verify your mobile number to access your account.',
                      style: TextStyle(
                          fontSize: fSize(22), fontWeight: FontWeight.w600)),
                  Text(
                      "Click on 'Send SMS Link' and verify mobile number. A SMS notification will be sent to you shortly.")
                ]),
              ),
            ],
          ),
          CustomSpacer(size: 20),
          gotoMySettingButton()
        ],
      ),
    );
  }

  Widget gotoMySettingButton() {
    return SizedBox(
        width: wScale(295),
        height: hScale(56),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(builder: (context) => const AccountSetting()),
            );
          },
          child: Text("Go to My Setting",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget customText(text) {
    return Text(text,
        style: TextStyle(
            fontSize: fSize(16),
            color: Colors.black,
            fontWeight: FontWeight.w500));
  }

  Widget customImage(url, width) {
    return Image.asset(url, fit: BoxFit.contain, width: wScale(width));
  }

  Widget cardValanceField(businessAccountSummary, isAdmin) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(hScale(24)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(hScale(10)),
        image: const DecorationImage(
          image: AssetImage("assets/dashboard_header.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: isAdmin
          ? Column(children: [
              moneyValue(
                  AppLocalizations.of(context)!.totalfunds,
                  businessAccountSummary == null
                      ? '-'
                      : businessAccountSummary['totalBalance']
                          .toStringAsFixed(2),
                  20.0,
                  FontWeight.w600,
                  const Color(0xff30E7A9),
                  businessAccountSummary == null
                      ? ''
                      : businessAccountSummary['currencyCode']),
              const CustomSpacer(
                size: 8,
              ),
              moneyValue(
                  AppLocalizations.of(context)!.creditline,
                  businessAccountSummary == null
                      ? '-'
                      : businessAccountSummary['totalFplBalance']
                          .toStringAsFixed(2),
                  20.0,
                  FontWeight.w600,
                  const Color(0xffADD2C8),
                  businessAccountSummary == null
                      ? ''
                      : businessAccountSummary['currencyCode']),
              const CustomSpacer(
                size: 8,
              ),
              moneyValue(
                  AppLocalizations.of(context)!.businessaccount,
                  businessAccountSummary == null
                      ? '-'
                      : businessAccountSummary['totalFcaBalance']
                          .toStringAsFixed(2),
                  20.0,
                  FontWeight.w600,
                  const Color(0xffADD2C8),
                  businessAccountSummary == null
                      ? ''
                      : businessAccountSummary['currencyCode']),
            ])
          : moneyValue(
              AppLocalizations.of(context)!.monthtodatespend,
              businessAccountSummary == null
                  ? '-'
                  : businessAccountSummary['totalSpend'].toStringAsFixed(2),
              20.0,
              FontWeight.w600,
              const Color(0xffADD2C8),
              businessAccountSummary == null
                  ? ''
                  : businessAccountSummary['currencyCode']),
    );
  }

  Widget moneyValue(title, value, size, weight, color, currencyCode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(fontSize: fSize(12), color: Colors.white)),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("$currencyCode  ",
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
    );
  }

  Widget welcomeHandleField(
      businessAccountSummary, imageURL, imageScale, title) {
    return SizedBox(
        height: hScale(63),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: const Color(0xffffffff),
              side: const BorderSide(width: 0, color: Color(0xffffffff)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              // handleDepositFunds(businessAccountSummary);
              title == AppLocalizations.of(context)!.depositfunds
                  ? handleDepositFunds(businessAccountSummary)
                  : handleCreditline(title);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(children: [
                  SizedBox(
                    width: hScale(22),
                    child: customImage(imageURL, imageScale),
                  ),
                  SizedBox(width: wScale(18)),
                  Text(title,
                      style: TextStyle(
                          fontSize: fSize(14), color: const Color(0xff465158))),
                ]),
                const Icon(Icons.arrow_forward_rounded,
                    color: Color(0xff70828D), size: 24.0),
              ],
            )));
  }

  Widget quickActionsField(isMobileVerified) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        customText(AppLocalizations.of(context)!.quickactions),
        const CustomSpacer(size: 7),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              actionButton('assets/invite_user.png',
                  AppLocalizations.of(context)!.inviteuser, 0, isMobileVerified),
              actionButton('assets/issue_virtual_card.png',
                  AppLocalizations.of(context)!.issuevirtualcard, 1, isMobileVerified),
              actionButton('assets/green_card.png',
                  AppLocalizations.of(context)!.requestphysicalcard, 2, isMobileVerified)
            ])
      ],
    );
  }

  Widget actionButton(imageUrl, text, index, isMobileVerified) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          primary: const Color(0xffffffff),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          handleQuickActions(index, isMobileVerified);
        },
        child: Container(
            width: wScale(99),
            padding: EdgeInsets.symmetric(vertical: hScale(16)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(imageUrl, fit: BoxFit.contain, height: hScale(24)),
                const CustomSpacer(size: 8),
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

  Widget recentTransactionField(isMobileVerified) {
    return SizedBox(
      width: wScale(327),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              customText(AppLocalizations.of(context)!.recenttransactions),
              viewAllTransactionButton(isMobileVerified)
            ],
          )
        ],
      ),
    );
  }

  Widget viewAllTransactionButton(isMobileVerified) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff30E7A9),
        textStyle: TextStyle(
            fontSize: fSize(12),
            color: const Color(0xff30E7A9),
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline),
      ),
      onPressed: () {
        handleViewAllTransaction(isMobileVerified);
      },
      child: Text(AppLocalizations.of(context)!.viewall),
    );
  }

  Widget transactionField(
      date, transactionName, status, userName, cardNum, value, currencyCode) {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(
          left: wScale(16),
          right: wScale(16),
          top: hScale(16),
          bottom: hScale(16)),
      margin: EdgeInsets.only(bottom: hScale(16)),
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          transactionTimeField(date),
          transactionStatus(transactionName, status),
          transactionUser(userName, cardNum),
          moneyValue('', value, 14.0, FontWeight.w700, const Color(0xffADD2C8),
              currencyCode),
        ],
      ),
    );
  }

  Widget transactionTimeField(date) {
    return Text(date,
        style: TextStyle(
            fontSize: fSize(10),
            fontWeight: FontWeight.w500,
            color: const Color(0xff70828D)));
  }

  Widget transactionStatus(name, status) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fSize(16),
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        children: [
          TextSpan(text: name),
          TextSpan(
            text: ' ($status)',
            style: TextStyle(fontSize: fSize(12), fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget transactionUser(name, cardNum) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fSize(12),
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        children: [
          TextSpan(text: name),
          TextSpan(
            text: ' ($cardNum)',
            style: const TextStyle(color: Color(0xff70828D)),
          ),
        ],
      ),
    );
  }

  Widget getTransactionArrWidgets(arr, isMobileVerified) {
    if (arr == [])
      return Container(child: Image.asset('assets/empty_transaction'));
    return Column(
        children: arr.map<Widget>((item) {
      return TransactionItem(
          accountId: item['txnFinanceAccId'],
          transactionId: item['sourceTransactionId'],
          date:
              '${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(item['transactionDate']))}  |  ${DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(item['transactionDate']))}',
          transactionName: item['description'],
          status: item['status'],
          userName: item['merchantName'],
          cardNum: item['pan'],
          value: item['fxrBillAmount'].toStringAsFixed(2),
          receiptStatus: item['fxrBillAmount'] >= 0
              ? 0
              : item['receiptStatus'] == "PAID"
                  ? 2
                  : 1,
          mobileVerified: isMobileVerified);
    }).toList());
  }

  Widget noFCAuser(userInfo) {
    return Stack(children: [
      Container(
          height: hScale(812),
          child: Column(
            children: [
              const CustomSpacer(size: 30),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: wScale(24)),
                  child: welcomeUser(
                      '${userInfo["firstName"]} ${userInfo["lastName"]}')),
              const CustomSpacer(size: 30),
              Container(
                  width: wScale(327),
                  // height: hScale(320),
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(hScale(24)),
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
                        offset:
                            const Offset(0, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            AppLocalizations.of(context)!
                                .noflexbussinessaccount,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: fSize(12),
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF70828D))),
                        CustomSpacer(size: 18),
                        Image.asset('assets/empty_transaction.png',
                            fit: BoxFit.contain, width: wScale(159)),
                        CustomSpacer(size: 36),
                        Text(
                            AppLocalizations.of(context)!.flexmobilesupportflex,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: fSize(12),
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF70828D))),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                  AppLocalizations.of(context)!.clickhere,
                                  style: TextStyle(
                                      fontSize: fSize(12),
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF29C490))),
                            ),
                            Text(AppLocalizations.of(context)!.torequestfor,
                                style: TextStyle(
                                    fontSize: fSize(12),
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF70828D))),
                          ],
                        )
                      ]))
            ],
          )),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 0),
      )
    ]);
  }
}

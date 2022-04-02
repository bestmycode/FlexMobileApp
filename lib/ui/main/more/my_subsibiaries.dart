import 'dart:ui';
import 'package:co/constants/constants.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:expandable/expandable.dart';
import 'package:co/ui/main/more/new_subsidiary.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MySubsibiaries extends StatefulWidget {
  const MySubsibiaries({Key? key}) : super(key: key);
  @override
  MySubsibiariesState createState() => MySubsibiariesState();
}

class MySubsibiariesState extends State<MySubsibiaries> {
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
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String getUserInfoSettingQuery = Queries.QUERY_GET_USER_SETTING;
  String updateMutation = FXRMutations.MUTATION_UPDATE_LAST_ORG_SESSION;
  String acceptInvitationMutation = FXRMutations.MUTATION_ACCEPT_INVITATION;
  String getBusinessAccountSummary = Queries.QUERY_BUSINESS_ACCOUNT_SUMMARY;
  String getUserAccountSummary = Queries.QUERY_USER_ACCOUNT_SUMMARY;

  var userSettingInfo = {};
  var userInvitations = [];
  var isFCAUserForRole = [];
  handleNewSubsidiay() async {
    var result = await Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => NewSubsidiary()),
    );
    if (result) {
      setState(() {});
    }
  }

  handleSwitchSubsidiary(data, runMutation) {
    runMutation({'orgId': data['orgId']});
  }

  handleAccept(data, runMutation) {
    runMutation({'id': data['id']});
  }

  handleRegister() async {
    var signupUrl = 'https://app.staging.fxr.one/signup';
    if (await canLaunch(signupUrl)) {
      await launch(signupUrl);
    } else {
      throw 'Could not launch $signupUrl';
    }
  }

  Future<void> _fetchData() async {
    isLoading = true;
    var accessToken = storage.getItem("jwt_token");
    final HttpLink httpLink =
        HttpLink("https://gql.staging.fxr.one/v1/graphql");

    final AuthLink authLink = AuthLink(getToken: () async => "$accessToken");
    final Link link = authLink.concat(httpLink);
    final client = GraphQLClient(cache: GraphQLCache(), link: link);

    final userSettingOption =
        QueryOptions(document: gql(getUserInfoSettingQuery), variables: {});
    final userSettingResult = await client.query(userSettingOption);
    final userInvitationOption =
        QueryOptions(document: gql(getUserInfoSettingQuery), variables: {});
    final userInvitationResult = await client.query(userInvitationOption);

    final userRoles = userSettingResult.data!['user']['roles'];
    try {
      await userRoles.forEach((item) async {
        final userRoleVars = {
          'orgId': item['orgId'],
          'isAdmin': item['roleName'] == 'admin'
        };
        final userRoleOption = QueryOptions(
            document: gql(item['roleName'] == 'admin'
                ? getBusinessAccountSummary
                : getUserAccountSummary),
            variables: userRoleVars);
        final userRoleResult = await client.query(userRoleOption);
        final userAccount = item['roleName'] == 'admin'
            ? userRoleResult.data!['readBusinessAcccountSummary']
            : userRoleResult.data!['readUserFinanceAccountSummary'];
        bool noFCAUser = userAccount['data'] == null &&
            userAccount['response']['success'] == false;
        isFCAUserForRole.add({'orgId': item['orgId'], 'status': noFCAUser});
        setState(() {});
      });

      setState(() {
        userSettingInfo = userSettingResult.data?['user'] ?? {};
        userInvitations =
            userInvitationResult.data?['currentUserInvitations'] ?? [];
        isLoading = false;
      });
    } catch (error) {
      print("===== Error : Get User Roles =====");
      print("===== Query : getBusinessAccountSummary,  =====");
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
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    return isLoading
        ? Container(
            margin: EdgeInsets.only(top: hScale(50)),
            alignment: Alignment.center,
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF60C094))))
        : SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: wScale(24)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomSpacer(size: 15),
                      companyNameField(userSettingInfo['roles']),
                      const CustomSpacer(size: 20),
                      informationField(),
                      const CustomSpacer(size: 33),
                      titleSubsidiariesField(),
                      getSubsidiariesArrWidgets(userSettingInfo['roles']),
                      const CustomSpacer(size: 24),
                      titleInvitationField(),
                      const CustomSpacer(size: 18),
                      getInvitationArrWidgets(userInvitations),
                    ])));
  }

  Widget companyNameField(roles) {
    var currentCompany = roles
        .firstWhere((role) => role['orgId'] == userStorage.getItem("orgId"));
    return Container(
        width: wScale(327),
        height: hScale(73),
        padding: EdgeInsets.symmetric(horizontal: wScale(24)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(hScale(10)),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF106549).withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 10,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
          image: const DecorationImage(
            image: AssetImage("assets/dashboard_header.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(currentCompany['orgName'],
                  style: TextStyle(
                      fontSize: fSize(22),
                      fontWeight: FontWeight.w700,
                      color: Colors.white))
            ]));
  }

  Widget informationField() {
    return Container(
        width: wScale(327),
        height: hScale(173),
        padding:
            EdgeInsets.symmetric(vertical: hScale(13), horizontal: wScale(20)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Information",
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A2831))),
            const CustomSpacer(size: 13),
            RichText(
              text: TextSpan(
                style: TextStyle(
                    fontSize: fSize(14),
                    color: const Color(0xFF70828D),
                    height: 1.25),
                children: [
                  TextSpan(
                      text:
                          'This page allows you to create separate \nsubsidiares to be managed under the same \ne-mail address. If you are looking to create \na separate Flex Business Account under a \nseparate e-mail address,  '),
                  TextSpan(
                      text: 'click here',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: Color(0xFF0450e0)),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          handleRegister();
                        }),
                ],
              ),
            )
          ],
        ));
  }

  Widget titleSubsidiariesField() {
    var isAdmin = userStorage.getItem("isAdmin");
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('List of Subsidiaries',
            style: TextStyle(
                fontSize: fSize(16),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2831))),
        isAdmin
            ? TextButton(
                style: TextButton.styleFrom(
                    primary: const Color(0xff29C490),
                    padding: const EdgeInsets.all(0),
                    textStyle: TextStyle(
                        fontSize: fSize(14),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF29C490),
                        decoration: TextDecoration.underline)),
                child: const Text('Create New Subsidiary'),
                onPressed: () {
                  handleNewSubsidiay();
                })
            : SizedBox(height: hScale(40)),
      ],
    );
  }

  Widget getSubsidiariesArrWidgets(arr) {
    return arr.length == 0
        ? Image.asset('assets/empty_transaction.png',
            fit: BoxFit.contain, width: wScale(327))
        : Column(
            children: arr.reversed.map<Widget>((item) {
            return collapseField(arr.indexOf(item), item);
          }).toList());
  }

  Widget collapseField(index, data) {
    return ExpandableNotifier(
      initialExpanded:
          index == userSettingInfo['roles'].length - 1 ? true : false,
      child: Container(
        margin: EdgeInsets.only(bottom: hScale(5)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
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
          children: [
            ScrollOnExpand(
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                    tapBodyToCollapse: true, tapBodyToExpand: true),
                expanded: Column(
                  children: [
                    cardHeader(data),
                    isFCAUserForRole.length == userSettingInfo['roles'].length
                        ? cardBody(data)
                        : SizedBox()
                  ],
                ),
                collapsed: cardHeader(data),
                builder: (_, collapsed, expanded) {
                  return SizedBox(
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cardHeader(data) {
    return Container(
        width: wScale(327),
        height: hScale(35),
        padding: EdgeInsets.only(
            left: wScale(16),
            right: wScale(16),
            top: hScale(8),
            bottom: hScale(8)),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2931),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(hScale(10)),
            topRight: Radius.circular(hScale(10)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(data['orgName'],
                style: TextStyle(fontSize: fSize(12), color: Colors.white)),
            Text(data['roleName'],
                style: TextStyle(fontSize: fSize(12), color: Colors.white)),
          ],
        ));
  }

  Widget cardBody(data) {
    var statusItem = isFCAUserForRole
        .firstWhere((element) => element['orgId'] == data['orgId']);
    return Mutation(
        options: MutationOptions(
          document: gql(updateMutation),
          update: (GraphQLDataProxy cache, QueryResult? result) {
            return cache;
          },
          onCompleted: (resultData) {
            Navigator.of(context).pushReplacementNamed(HOME_SCREEN);
          },
        ),
        builder: (RunMutation runMutation, QueryResult? result) {
          return Container(
              width: wScale(327),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(hScale(10)),
                  topRight: Radius.circular(hScale(10)),
                ),
              ),
              child: Column(
                children: [
                  statusItem['status']
                      ? Column(children: [
                          roleStatus(),
                          Container(height: 1, color: const Color(0xFFF1F1F1)),
                        ])
                      : SizedBox(),
                  TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color(0xff1da7ff),
                      textStyle: TextStyle(
                          fontSize: fSize(12),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff1da7ff)),
                    ),
                    onPressed: () {
                      handleSwitchSubsidiary(data, runMutation);
                    },
                    child: const Text('Switch to this Subsidiary'),
                  ),
                ],
              ));
        });
  }

  Widget titleInvitationField() {
    return Text('Invitation sent to you',
        style: TextStyle(
            fontSize: fSize(16),
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A2831)));
  }

  Widget getInvitationArrWidgets(arr) {
    return arr.length == 0
        ? SizedBox()
        : Column(
            children: arr.map<Widget>((item) {
            return Column(
              children: [
                invitationField(item),
                const CustomSpacer(size: 10),
              ],
            );
          }).toList());
  }

  Widget invitationField(data) {
    return Container(
        width: wScale(327),
        height: hScale(157),
        padding:
            EdgeInsets.symmetric(vertical: hScale(13), horizontal: wScale(20)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 4,
              blurRadius: 10,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                    fontSize: fSize(14),
                    color: const Color(0xFF465158),
                    fontWeight: FontWeight.w600,
                    height: 1.25),
                children: [
                  TextSpan(text: "${data['senderName']} "),
                  TextSpan(
                      text: 'has invited you to ',
                      style: TextStyle(fontWeight: FontWeight.w400)),
                  TextSpan(text: "${data['orgName']} "),
                  TextSpan(
                      text: 'as ',
                      style: TextStyle(fontWeight: FontWeight.w400)),
                  TextSpan(text: data['role'] == 'admin' ? 'Admin.' : 'User.'),
                ],
              ),
            ),
            const CustomSpacer(size: 30),
            Mutation(
                options: MutationOptions(
                  document: gql(acceptInvitationMutation),
                  update: (GraphQLDataProxy cache, QueryResult? result) {
                    return cache;
                  },
                  onCompleted: (resultData) {
                    Navigator.of(context).pushReplacementNamed(HOME_SCREEN);
                  },
                ),
                builder: (RunMutation runMutation, QueryResult? result) {
                  return SizedBox(
                      width: wScale(135),
                      height: hScale(60),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: const Color(0xff1A2831),
                          side: const BorderSide(
                              width: 0, color: Color(0xff1A2831)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          handleAccept(data, runMutation);
                        },
                        child: Text("Accept",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: fSize(16),
                                fontWeight: FontWeight.bold)),
                      ));
                })
          ],
        ));
  }

  Widget roleStatus() {
    return Container(
        padding: EdgeInsets.only(
            top: hScale(10),
            bottom: hScale(10),
            left: wScale(16),
            right: wScale(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Status',
                style: TextStyle(
                    fontSize: fSize(14),
                    color: const Color(0xFF70828D),
                    fontWeight: FontWeight.w500)),
            Container(
                padding: EdgeInsets.symmetric(
                    horizontal: wScale(8), vertical: hScale(8)),
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(hScale(16)),
                    topRight: Radius.circular(hScale(16)),
                    bottomLeft: Radius.circular(hScale(16)),
                    bottomRight: Radius.circular(hScale(16)),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pending Verification',
                        style: TextStyle(
                            fontSize: fSize(14),
                            fontWeight: FontWeight.w600,
                            height: 1,
                            color: Color(0xFF1A2831)))
                  ],
                ))
          ],
        ));
  }
}

import 'dart:ui';
import 'package:co/constants/constants.dart';
import 'package:co/utils/mutations.dart';
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
import 'package:url_launcher/url_launcher.dart';

class MySubsibiaries extends StatefulWidget {
  final roles;
  final userInvitations;
  const MySubsibiaries({Key? key, this.roles, this.userInvitations})
      : super(key: key);
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

  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String updateMutation = FXRMutations.MUTATION_UPDATE_LAST_ORG_SESSION;

  handleNewSubsidiay() {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => const NewSubsidiary()),
    );
  }

  handleSwitchSubsidiary(data, runMutation) {
    runMutation({'orgId': data['orgId']});
  }

  handleAccept() {}

  handleRegister() async {
    var signupUrl = 'https://app.staging.fxr.one/signup';
    if (await canLaunch(signupUrl)) {
      await launch(signupUrl);
    } else {
      throw 'Could not launch $signupUrl';
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
          return mainHome(runMutation);
        });
  }

  Widget mainHome(runMutation) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: wScale(24)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomSpacer(size: 15),
              companyNameField(),
              const CustomSpacer(size: 20),
              informationField(),
              const CustomSpacer(size: 33),
              titleSubsidiariesField(),
              getSubsidiariesArrWidgets(widget.roles, runMutation),
              const CustomSpacer(size: 24),
              titleInvitationField(),
              const CustomSpacer(size: 18),
              getInvitationArrWidgets(widget.userInvitations),
            ]));
  }

  Widget companyNameField() {
    var currentCompany = widget.roles
        .firstWhere((role) => role['orgId'] == userStorage.getItem("orgId"));
    return Container(
        width: wScale(327),
        height: hScale(73),
        padding: EdgeInsets.symmetric(horizontal: wScale(24)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(hScale(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              spreadRadius: 4,
              blurRadius: 20,
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
              color: Colors.grey.withOpacity(0.25),
              spreadRadius: 4,
              blurRadius: 20,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('List of Subsidiaries',
            style: TextStyle(
                fontSize: fSize(16),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2831))),
        TextButton(
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
            }),
      ],
    );
  }

  Widget getSubsidiariesArrWidgets(arr, runMutation) {
    return Column(
        children: arr.map<Widget>((item) {
      return collapseField(arr.indexOf(item), item, runMutation);
    }).toList());
  }

  Widget collapseField(index, data, runMutation) {
    return ExpandableNotifier(
      initialExpanded: index == 0 ? true : false,
      child: Container(
        margin: EdgeInsets.only(bottom: hScale(5)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
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
            ScrollOnExpand(
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                    tapBodyToCollapse: true, tapBodyToExpand: true),
                expanded: Column(
                  children: [cardHeader(data), cardBody(data, runMutation)],
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

  Widget cardBody(data, runMutation) {
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
              blurRadius: 20,
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
                children: const [
                  TextSpan(text: 'Arthur Simon '),
                  TextSpan(
                      text: 'has invited you to ',
                      style: TextStyle(fontWeight: FontWeight.w400)),
                  TextSpan(text: 'join Red Batton pte ltd '),
                  TextSpan(
                      text: 'as ',
                      style: TextStyle(fontWeight: FontWeight.w400)),
                  TextSpan(text: 'User.'),
                ],
              ),
            ),
            const CustomSpacer(size: 30),
            SizedBox(
                width: wScale(135),
                height: hScale(60),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xff1A2831),
                    side: const BorderSide(width: 0, color: Color(0xff1A2831)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    handleAccept();
                  },
                  child: Text("Accept",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: fSize(16),
                          fontWeight: FontWeight.bold)),
                ))
          ],
        ));
  }
}

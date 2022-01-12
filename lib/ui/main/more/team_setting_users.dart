import 'package:co/ui/main/cards/physical_card.dart';
import 'package:co/ui/main/cards/virtual_card.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TeamSettingUsers extends StatefulWidget {
  final bool mobileVerified;
  const TeamSettingUsers({Key? key, this.mobileVerified = true})
      : super(key: key);

  @override
  TeamSettingUsersState createState() => TeamSettingUsersState();
}

class TeamSettingUsersState extends State<TeamSettingUsers> {
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
  String getTeamInvitations = Queries.QUERY_TEAMMEMBER_INVITATIONS;

  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    return Query(
        options: QueryOptions(
          document: gql(getTeamInvitations),
          variables: {"orgId": userStorage.getItem('orgId')},
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF60C094))));
          }
          return getUsersArrWidget(
              result.data!['invitations']['userInvitationList']);
        });
  }

  Widget getUsersArrWidget(arr) {
    return Column(
        children: arr.map<Widget>((item) {
      return collapseField(arr.indexOf(item), item);
    }).toList());
  }

  Widget collapseField(index, data) {
    return ExpandableNotifier(
      initialExpanded: index == 0 ? true : false,
      child: Container(
        margin: EdgeInsets.only(bottom: hScale(5)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                  children: [cardHeader(data), cardBody(data)],
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
          children: [
            Text(data['senderName'],
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
            Text(data['role'],
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
          ],
        ));
  }

  Widget cardBody(data) {
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
            cardBodyDetail(
                'Invitation Sent On',
                DateFormat('dd-MM-yyyy | hh:mm a').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        data['invitationSentAt']))),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            cardBodyDetail(
                'Invitation Accepted On',
                data['invitationAcceptedAt'] == null
                    ? ""
                    : DateFormat('dd-MM-yyyy | hh:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            data['invitationAcceptedAt']))),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            cardBodyDetail('Email', data['email']),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            cardBodyDetailStatus('Status', data['status']),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            Row(
              children: [
                cardBodyButton(1),
                Container(
                    width: 1,
                    height: hScale(33),
                    color: const Color(0xFFF1F1F1)),
                cardBodyButton(2),
              ],
            )
          ],
        ));
  }

  Widget cardBodyDetail(title, value) {
    return Container(
        height: hScale(35),
        padding: EdgeInsets.only(
            top: hScale(10),
            bottom: hScale(10),
            left: wScale(16),
            right: wScale(16)),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: fSize(12),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF70828D))),
              Text(value,
                  style: TextStyle(
                      fontSize: fSize(12),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A2831))),
            ]));
  }

  Widget cardBodyButton(type) {
    return SizedBox(
        width: wScale(162),
        height: hScale(35),
        child: TextButton(
          style: TextButton.styleFrom(
            primary:
                type == 1 ? const Color(0xff1da7ff) : const Color(0xFFEB5757),
            textStyle: TextStyle(
                fontSize: fSize(12),
                fontWeight: FontWeight.w500,
                color: type == 1
                    ? const Color(0xff1da7ff)
                    : const Color(0xFFEB5757)),
          ),
          onPressed: () {},
          child: Text(type == 1 ? 'Change Roles' : 'Deactivate User'),
        ));
  }

  Widget cardBodyDetailStatus(title, value) {
    return Container(
        height: hScale(35),
        padding: EdgeInsets.only(left: wScale(16), right: wScale(16)),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: fSize(12),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF70828D))),
              Container(
                  padding: EdgeInsets.symmetric(
                      vertical: hScale(4), horizontal: wScale(16)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1FFEF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(hScale(16)),
                      topRight: Radius.circular(hScale(16)),
                      bottomLeft: Radius.circular(hScale(16)),
                      bottomRight: Radius.circular(hScale(16)),
                    ),
                  ),
                  child: Text(value,
                      style: TextStyle(
                          fontSize: fSize(12),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff2ED47A))))
            ]));
  }
}

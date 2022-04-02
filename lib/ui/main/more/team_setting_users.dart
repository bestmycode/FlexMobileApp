import 'package:co/ui/widgets/custom_result_modal.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:indexed/indexed.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
  String revokeInviteMutation = FXRMutations.MUTATION_REVOKE_INVITE;
  String changeRoleMutation = FXRMutations.MUTATION_CHANGE_ROLE;
  String deactiveUserMutation = FXRMutations.MUTATION_DEACTIVE_USER;
  bool mutationResult = false;
  int userRole = -1;
  bool showUserRoles = false;

  handleRevoke(runMutation, data) {
    _showRevokeModalDialog(runMutation, data);
  }

  handleChangeRole(runMutation, data) async {
    try {
      await runMutation({
        "orgId": data['orgId'],
        "role": userRole == 0 ? "admin" : "user",
        "userId": data['userId'],
      });
      Navigator.of(context).pop();
    } catch (error) {
      print("===== Error : revoke, change role, deactivate User Result =====");
      print("===== Mutation : revokeInviteMutation, changeRole, deactivateUser =====");
      print(error);
      await Sentry.captureException(error);
      return null;
    }
  }

  handleDeactive(runMutation, data) {
    _showFreezeModalDialog(runMutation, data);
  }

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
    return arr.length == 0
        ? Image.asset('assets/empty_transaction.png',
            fit: BoxFit.contain, width: wScale(327))
        : Column(
            children: arr.map<Widget>((item) {
            return collapseField(arr.indexOf(item), item);
          }).toList());
  }

  Widget collapseField(index, data) {
    return ExpandableNotifier(
      initialExpanded: index == 0 ? true : false,
      child: Container(
        margin:
            EdgeInsets.symmetric(horizontal: wScale(24), vertical: hScale(4)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
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
            Text(data['email'],
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
            data['status'] == "SENT"
                ? mutationButton(0, data)
                : data['status'] == "ACCEPTED"
                    ? Row(
                        children: [
                          mutationButton(1, data),
                          Container(
                              width: 1,
                              height: hScale(33),
                              color: const Color(0xFFF1F1F1)),
                          mutationButton(2, data),
                        ],
                      )
                    : SizedBox()
          ],
        ));
  }

  _showUserRoleModal(context, runMutation, data) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                child: userRoleModalField(setState, runMutation, data));
          });
        });
  }

  Widget userRoleModalField(setState, runMutation, data) {
    return Container(
      width: wScale(295),
      padding:
          EdgeInsets.symmetric(vertical: hScale(16), horizontal: wScale(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Change Role',
                style: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A2831))),
            SizedBox(
                width: wScale(20),
                height: wScale(20),
                child: TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color(0xff000000),
                      padding: const EdgeInsets.all(0),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFFC8C4D9),
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }))
          ],
        ),
        const CustomSpacer(size: 23),
        Indexer(children: [
          Indexed(index: 100, child: selectUserRoleField(setState)),
          Indexed(
              index: 50,
              child: Column(
                children: [
                  const CustomSpacer(size: 85),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      modalBackButton('Back'),
                      modalSaveButton('Confirm', runMutation, data)
                    ],
                  )
                ],
              )),
        ]),
      ]),
    );
  }

  Widget selectUserRoleField(setState) {
    return Container(
        height: hScale(150),
        child: Stack(overflow: Overflow.visible, children: [
          userRoleField(setState),
          showUserRoles == true
              ? Positioned(
                  top: hScale(65), right: 0, child: userRoles(setState))
              : const SizedBox()
        ]));
  }

  Widget userRoleField(setState) {
    return Stack(
      children: [
        Container(
            width: wScale(295),
            height: hScale(56),
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: hScale(8)),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: const Color(0xFF040415).withOpacity(0.1))),
            child: TextButton(
                style: TextButton.styleFrom(primary: Colors.white),
                onPressed: () {
                  setState(() {
                    showUserRoles = true;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                        userRole == -1
                            ? 'Select User Role'
                            : userRole == 0
                                ? 'Admin'
                                : 'User',
                        style: TextStyle(
                            fontSize: fSize(14),
                            fontWeight: FontWeight.w400,
                            color: userRole == -1
                                ? const Color(0xFFBFBFBF)
                                : const Color(0xFF040415))),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFFBFBFBF), size: wScale(15)),
                  ],
                ))),
        Positioned(
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text('Role',
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFBFBFBF))),
          ),
        )
      ],
    );
  }

  Widget userRoles(setState) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 4,
              blurRadius: 10,
              offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
          children: [userRoleButton(0, setState), userRoleButton(1, setState)]),
    );
  }

  Widget userRoleButton(index, setState) {
    return SizedBox(
        width: wScale(265),
        height: hScale(36),
        child: TextButton(
            style: TextButton.styleFrom(
                primary: userRole == -1
                    ? const Color(0xFF1A2831)
                    : index == userRole
                        ? const Color(0xFF29C490)
                        : const Color(0xFF1A2831),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: wScale(18)),
                textStyle: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: userRole == -1
                        ? const Color(0xFFBFBFBF)
                        : index == userRole
                            ? const Color(0xFF29C490)
                            : const Color(0xFF1A2831))),
            child: Text(
                index == -1
                    ? 'Select Role'
                    : index == 0
                        ? 'Admin'
                        : 'User',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: fSize(14),
                  fontWeight: FontWeight.w400,
                )),
            onPressed: () {
              setState(() {
                userRole = index;
                showUserRoles = false;
              });
            }));
  }

  Widget modalBackButton(title) {
    return SizedBox(
        width: wScale(120),
        height: hScale(56),
        // margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            primary: const Color(0xFFe8e9ea),
            side: BorderSide(width: 0, color: const Color(0xFFe8e9ea)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(title,
              style: TextStyle(
                  color: Color(0xFF1A2831),
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget modalSaveButton(title, runMutation, data) {
    return SizedBox(
        width: wScale(120),
        height: hScale(56),
        // margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () async {
            await handleChangeRole(runMutation, data);
          },
          child: Text(title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
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

  Widget mutationButton(type, data) {
    return Mutation(
        options: MutationOptions(
          document: gql(type == 0
              ? revokeInviteMutation
              : type == 1
                  ? changeRoleMutation
                  : deactiveUserMutation),
          update: (GraphQLDataProxy cache, QueryResult? result) {
            return cache;
          },
          onCompleted: (resultData) {
            if (type == 0) {
              resultData['revokeInvitation: '] != null
                  ? setState(() {
                      mutationResult = true;
                    })
                  : null;
            } else if (type == 1) {
              resultData['changeRoleInOrganization'] == true
                  ? setState(() {
                      mutationResult = true;
                    })
                  : null;
            } else {
              resultData != null &&
                      resultData['removeUserFromOrganization'] != null
                  ? showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: wScale(40)),
                            child: Dialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                                child: CustomResultModal(
                                    status: true,
                                    title: "Deactivated",
                                    titleColor: Color(0xFF0F7855),
                                    message:
                                        'You’ve successfully deactivated \n“${data['email']}”',
                                    handleOKClick: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop('dialog');
                                      setState(() {
                                        mutationResult = true;
                                      });
                                    })));
                      })
                  : showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: wScale(40)),
                            child: Dialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                                child: CustomResultModal(
                                    status: true,
                                    title: "Unable to deactive user",
                                    titleColor: Color(0xFFEB5757),
                                    message:
                                        "This user is currently having active card(s) running.\nPlease cancel the card(s) before deactivating this user.")));
                      });
            }
          },
        ),
        builder: (RunMutation runMutation, QueryResult? result) {
          return cardBodyButton(type, runMutation, data);
        });
  }

  Widget cardBodyButton(type, runMutation, data) {
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
          onPressed: () {
            if (type == 0) {
              handleRevoke(runMutation, data);
            } else if (type == 1) {
              _showUserRoleModal(context, runMutation, data);
            } else {
              handleDeactive(runMutation, data);
            }
          },
          child: Text(type == 0
              ? 'Revoke Invite'
              : type == 1
                  ? 'Change Roles'
                  : 'Deactivate User'),
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
                    color: value == "SENT"
                        ? Color(0xFFfff2da)
                        : value == "ACCEPTED"
                            ? Color(0xFFE1FFEF)
                            : Color(0xffc1cacf),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(hScale(16)),
                      topRight: Radius.circular(hScale(16)),
                      bottomLeft: Radius.circular(hScale(16)),
                      bottomRight: Radius.circular(hScale(16)),
                    ),
                  ),
                  child: Text(
                      value == "SENT"
                          ? "Pending"
                          : value == "EXPIRED"
                              ? "Expired"
                              : value == "ACCEPTED"
                                  ? "Active"
                                  : "Revoked",
                      style: TextStyle(
                          fontSize: fSize(12),
                          fontWeight: FontWeight.w500,
                          color: value == "SENT"
                              ? Color(0xFFffbb36)
                              : value == "ACCEPTED"
                                  ? Color(0xff2ED47A)
                                  : Color(0xff3f505a))))
            ]));
  }

  _showFreezeModalDialog(runMutation, data) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: wScale(40)),
              child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: deactiveModalField(runMutation, data)));
        });
  }

  _showRevokeModalDialog(runMutation, data) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: wScale(40)),
              child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: revokeModalField(runMutation, data)));
        });
  }

  Widget deactiveModalField(runMutation, data) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
          padding: EdgeInsets.symmetric(
              vertical: hScale(25), horizontal: wScale(16)),
          child: Column(children: [
            Image.asset('assets/warning_icon.png',
                fit: BoxFit.contain, height: wScale(30)),
            const CustomSpacer(size: 15),
            Text("This action cannot be reversed",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: fSize(14), fontWeight: FontWeight.w700)),
            const CustomSpacer(size: 10),
            Text(
              "By taking this action, user's access and permission will be permanently remove from this company",
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
                      runMutation({
                        "orgId": data['orgId'],
                        "userId": data['userId'],
                      });
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                    child: const Text('Ok'),
                  ))
            ],
          ))
    ]);
  }

  Widget revokeModalField(runMutation, data) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
          padding: EdgeInsets.symmetric(
              vertical: hScale(25), horizontal: wScale(16)),
          child: Column(children: [
            Image.asset('assets/warning_icon.png',
                fit: BoxFit.contain, height: wScale(30)),
            const CustomSpacer(size: 15),
            Text("Revoke Invitation",
                style: TextStyle(
                    fontSize: fSize(14), fontWeight: FontWeight.w700)),
            const CustomSpacer(size: 10),
            Text(
              "Are you sure you want to revoke this invitation to ${data['email']} ?",
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
                    child: const Text('Back'),
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
                      runMutation({"id": data['id']});
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                    child: const Text('Confirm'),
                  ))
            ],
          ))
    ]);
  }
}

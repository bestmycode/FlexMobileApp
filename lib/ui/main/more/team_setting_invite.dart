import 'package:co/ui/widgets/custom_result_modal.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/token.dart';
import 'package:co/utils/validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:indexed/indexed.dart';
import 'package:localstorage/localstorage.dart';

class TeamSettingInvite extends StatefulWidget {
  final bool mobileVerified;
  final handleUpdate;
  const TeamSettingInvite(
      {Key? key, this.mobileVerified = true, this.handleUpdate})
      : super(key: key);

  @override
  TeamSettingInviteState createState() => TeamSettingInviteState();
}

class TeamSettingInviteState extends State<TeamSettingInvite> {
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
  String mutationUserInvitation = FXRMutations.MUTATION_USER_INVITE;

  bool isButtonDisabled = true;
  final selectRoleCtl = TextEditingController();
  final userEmailCtl = TextEditingController();
  int userRole = -1;
  bool showUserRoles = false;
  String inviteErrMsg = "";
  bool isLoading = false;
  bool isInvalidEmail = false;
  bool errorUserRole = false;

  handleEditProfile(runMutation) {
    checkValidation();
    if (!isInvalidEmail && !errorUserRole) {
      setState(() {
        isLoading = true;
      });

      runMutation({
        "email": userEmailCtl.text,
        "orgId": userStorage.getItem('orgId'),
        "role": userRole == 0 ? "admin" : "user",
        "senderId": userStorage.getItem('userId'),
      });
    }
  }

  checkValidation() {
    setState(() {
      errorUserRole = userRole == -1 ? true : false;
      isInvalidEmail =
          Validator().validateEmail(userEmailCtl.text).toString() != ''
              ? true
              : false;
    });
  }

  showUserRolesField(setState) {
    setState(() {
      showUserRoles = true;
    });
  }

  handleConfirm() {
    setState(() {});
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    return Container(
        width: wScale(327),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: wScale(16)),
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
                opacity: isLoading ? 0.5 : 1,
                child: Column(
                  children: [
                    const CustomSpacer(size: 28),
                    userRoleField(0, setState),
                    Container(
                        width: wScale(295),
                        height: hScale(32),
                        child: Text(
                            errorUserRole ? "This field is required." : '',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: fSize(12),
                                color: Color(0xFFEB5757),
                                fontWeight: FontWeight.w400))),
                    customTextField(userEmailCtl, 'Enter User Email Here',
                        'New Member Email'),
                    Container(
                        width: wScale(295),
                        height: hScale(32),
                        child: Text(
                            isInvalidEmail
                                ? Validator()
                                    .validateEmail(userEmailCtl.text)
                                    .toString()
                                : '',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: fSize(12),
                                color: Color(0xFFEB5757),
                                fontWeight: FontWeight.w400))),
                    mutationButton(),
                    const CustomSpacer(size: 20),
                  ],
                )),
            isLoading
                ? Positioned(
                    top: 110,
                    child: Container(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF60C094)))),
                  )
                : SizedBox()
          ],
        ));
  }

  Widget inviteButton(runMutation) {
    return SizedBox(
        width: wScale(295),
        height: hScale(56),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831),
            onPrimary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            handleEditProfile(runMutation);
          },
          child: Text("Invite",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.bold)),
        ));
  }

  Widget mutationButton() {
    return Mutation(
        options: MutationOptions(
          document: gql(mutationUserInvitation),
          update: (GraphQLDataProxy cache, QueryResult? result) {
            return cache;
          },
          onCompleted: (resultData) {
            if (resultData == null || resultData['inviteUser'] == null) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Padding(
                        padding: EdgeInsets.symmetric(horizontal: wScale(40)),
                        child: Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            child: CustomResultModal(
                              status: false,
                              title: "Active User",
                              titleColor: Color(0xFFEB5757),
                              message:
                                  "${userEmailCtl.text} is already a team member.",
                              handleOKClick: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop('dialog');
                                setState(() {
                                  isLoading = false;
                                  isButtonDisabled = true;
                                });
                                widget.handleUpdate();
                              },
                            )));
                  });
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Padding(
                        padding: EdgeInsets.symmetric(horizontal: wScale(40)),
                        child: Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            child: CustomResultModal(
                              status: true,
                              title: "Invitation Sent",
                              message:
                                  "Your invitation has been sent successfully to ${userEmailCtl.text}.",
                              handleOKClick: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop('dialog');
                                setState(() {
                                  isLoading = false;
                                  selectRoleCtl.text = "";
                                  userEmailCtl.text = "";
                                  userRole = -1;
                                  isButtonDisabled = true;
                                });
                                widget.handleUpdate();
                              },
                            )));
                  });
            }
          },
        ),
        builder: (RunMutation runMutation, QueryResult? result) {
          return inviteButton(runMutation);
        });
  }

  Widget userRoleField(type, setState) {
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
                  type == 0
                      ? _showUserRoleModal(context)
                      : showUserRolesField(setState);
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

  _showUserRoleModal(context) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                child: userRoleModalField(setState));
          });
        });
  }

  Widget userRoleModalField(setState) {
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
                      modalSaveButton('Confirm')
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
          userRoleField(1, setState),
          showUserRoles == true
              ? Positioned(
                  top: hScale(65), right: 0, child: userRoles(setState))
              : const SizedBox()
        ]));
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
            offset: const Offset(0, 1), // changes position of shadow
          ),
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
                // padding: const EdgeInsets.all(0),
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

  Widget modalSaveButton(title) {
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
          onPressed: () {
            handleConfirm();
          },
          child: Text(title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget customTextField(ctl, hint, label) {
    return Stack(
      children: [
        Container(
            width: wScale(295),
            height: hScale(64),
            padding: EdgeInsets.only(top: hScale(8)),
            alignment: Alignment.center,
            child: TextField(
              style: TextStyle(
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF040415)),
              controller: ctl,
              onChanged: (text) {
                setState(() {
                  if (text != '' && userRole != -1) {
                    isButtonDisabled = false;
                  } else {
                    isButtonDisabled = true;
                  }
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFFFFFFF),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: const Color(0xff040415).withOpacity(0.1),
                        width: 1.0)),
                hintText: hint,
                hintStyle: TextStyle(
                    color: const Color(0xffBFBFBF), fontSize: fSize(14)),
                focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xff040415), width: 1.0)),
              ),
            )),
        Positioned(
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text(label,
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFBFBFBF))),
          ),
        )
      ],
    );
  }
}

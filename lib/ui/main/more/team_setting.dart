import 'package:expandable/expandable.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flexflutter/ui/widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

class TeamSetting extends StatefulWidget {
  const TeamSetting({Key? key}) : super(key: key);
  @override
  TeamSettingState createState() => TeamSettingState();
}

class TeamSettingState extends State<TeamSetting> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  bool isButtonDisabled = true;
  final selectRoleCtl = TextEditingController();
  final userEmailCtl = TextEditingController();
  var userArr = [
    // role => 0: Admin, 1: user
    {
      'id': 0,
      'userName': 'James Rosser',
      'role': 0,
      'sentDate': '30 Jan 2021',
      'acceptDate': '30 Jan 2021',
      'email': 'jamesrosser@gmail.com ',
      'status': 'Active'
    },
    {
      'id': 1,
      'userName': 'Jocelyn Herwitz',
      'role': 1,
      'sentDate': '30 Jan 2021',
      'acceptDate': '30 Jan 2021',
      'email': 'jamesrosser@gmail.com ',
      'status': 'Active'
    },
    {
      'id': 2,
      'userName': 'Aspen Franci',
      'role': 1,
      'sentDate': '30 Jan 2021',
      'acceptDate': '30 Jan 2021',
      'email': 'jamesrosser@gmail.com ',
      'status': 'Active'
    },
    {
      'id': 3,
      'userName': 'James Rosser',
      'role': 0,
      'sentDate': '30 Jan 2021',
      'acceptDate': '30 Jan 2021',
      'email': 'jamesrosser@gmail.com ',
      'status': 'Active'
    },
    {
      'id': 4,
      'userName': 'Rayna Westervelt',
      'role': 1,
      'sentDate': '30 Jan 2021',
      'acceptDate': '30 Jan 2021',
      'email': 'jamesrosser@gmail.com ',
      'status': 'Active'
    },
    {
      'id': 5,
      'userName': 'James Rosser',
      'role': 0,
      'sentDate': '30 Jan 2021',
      'acceptDate': '30 Jan 2021',
      'email': 'jamesrosser@gmail.com ',
      'status': 'Active'
    },
  ];
  // var userRoles = ['User', 'Admin'];
  int userRole = -1;
  bool showUserRoles = false;

  handleEditProfile() {}

  showUserRolesField() {
    setState(() {
      showUserRoles = true;
    });
  }

  handleConfirm() {}

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const CustomSpacer(size: 15),
      titleField('Invite New User'),
      const CustomSpacer(size: 4),
      titleDetailField(
          'We will send an invitation email that is valid for 7 days'),
      const CustomSpacer(size: 15),
      inviteField(),
      const CustomSpacer(size: 25),
      Text('Users',
          style: TextStyle(
              fontSize: fSize(14),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2831))),
      const CustomSpacer(size: 15),
      getUsersArrWidget(userArr),
      const CustomSpacer(size: 15),
    ]);
  }

  Widget titleField(title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: fSize(16),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2831))),
      ],
    );
  }

  Widget titleDetailField(detail) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(detail,
            style:
                TextStyle(fontSize: fSize(12), color: const Color(0xFF70828D))),
      ],
    );
  }

  Widget inviteField() {
    return Container(
        width: wScale(327),
        padding: EdgeInsets.symmetric(horizontal: wScale(16)),
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
          children: [
            const CustomSpacer(size: 28),
            // CustomTextField(
            //     ctl: selectRoleCtl, hint: 'Select Role', label: 'Role'),
            userRoleField(0),
            const CustomSpacer(size: 32),
            CustomTextField(
                ctl: userEmailCtl,
                hint: 'Enter User Email Here',
                label: 'New Member Email'),
            const CustomSpacer(size: 30),
            inviteButton(),
            const CustomSpacer(size: 20),
          ],
        ));
  }

  Widget inviteButton() {
    return SizedBox(
        width: wScale(295),
        height: hScale(56),
        child: Opacity(
            opacity: isButtonDisabled ? 0.4 : 1,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: const Color(0xff1A2831),
                onPrimary: const Color(0xff1A2831),
                side: const BorderSide(width: 0, color: Color(0xff1A2831)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                isButtonDisabled ? null : handleEditProfile();
              },
              child: Text("Invite",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fSize(16),
                      fontWeight: FontWeight.bold)),
            )));
  }

  Widget getUsersArrWidget(arr) {
    return Column(
        children: arr.map<Widget>((item) {
      return collapseField(item);
    }).toList());
  }

  Widget collapseField(data) {
    return ExpandableNotifier(
      initialExpanded: data['id'] == 0 ? true : false,
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
            Text(data['userName'],
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
            Text(data['role'] == 0 ? 'Admin' : 'User',
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
            cardBodyDetail('Invitation Sent On', data['sentDate']),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            cardBodyDetail('Invitation Accepted On', data['acceptDate']),
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

  Widget userRoleField(type) {
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
                      : showUserRolesField();
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
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: userRoleModalField());
        });
  }

  Widget userRoleModalField() {
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
            blurRadius: 20,
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
        selectUserRoleField(),
        const CustomSpacer(size: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [modalBackButton('Back'), modalSaveButton('Confirm')],
        )
      ]),
    );
  }

  Widget selectUserRoleField() {
    return Stack(
        // overflow: Overflow.visible,
        children: [
          userRoleField(1),
          showUserRoles == true
              ? Positioned(top: hScale(50), right: 0, child: userRoles())
              : const SizedBox()
        ]);
  }

  Widget userRoles() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(children: [userRoleButton(0), userRoleButton(1)]),
    );
  }

  Widget userRoleButton(index) {
    return SizedBox(
        width: wScale(295),
        height: hScale(36),
        child: TextButton(
            style: TextButton.styleFrom(
                primary: const Color(0xffF5F5F5).withOpacity(0.4),
                // padding: const EdgeInsets.all(0),
                textStyle: TextStyle(
                    fontSize: fSize(12), fontWeight: FontWeight.w400)),
            child: Text(index == 0 ? 'Admin' : 'User'),
            onPressed: () {
              setState(() {
                userRole = index;
              });
            }));
  }

  Widget modalBackButton(title) {
    return SizedBox(
        width: wScale(141),
        height: hScale(56),
        // margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            primary: const Color(0xffc9c9c9).withOpacity(0.1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(title,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget modalSaveButton(title) {
    return SizedBox(
        width: wScale(141),
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
}

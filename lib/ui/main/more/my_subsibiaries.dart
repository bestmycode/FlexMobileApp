import 'dart:ui';
import 'package:expandable/expandable.dart';
import 'package:flexflutter/ui/main/more/new_subsidiary.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

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

  var subsidiariesArr = [
    // type=> 0: Admin, 1: User
    {
      'id': 0,
      'userName': 'Sushi Tei Paragon',
      'type': 0,
    },
    {
      'id': 1,
      'userName': 'Green Grocer Pte Ltd',
      'type': 1,
    },
    {
      'id': 2,
      'userName': 'Sushi Tei Paragon',
      'type': 1,
    },
    {
      'id': 3,
      'userName': 'Green Grocer Pte Ltd',
      'type': 0,
    },
    {
      'id': 4,
      'userName': 'Natural Packaging Pte Ltd',
      'type': 0,
    },
    {
      'id': 5,
      'userName': 'Sushi Tei Toa Payoh',
      'type': 1,
    },
    {
      'id': 6,
      'userName': 'Green Grocer Pte Ltd',
      'type': 0,
    },
    {
      'id': 7,
      'userName': 'Natural Packaging Pte Ltd',
      'type': 0,
    },
    {
      'id': 8,
      'userName': 'Sushi Tei Toa Payoh',
      'type': 1,
    },
  ];
  var invitationArr = [
    // type=> 0: Admin, 1: User
    {'id': 0, 'name': 'Arthur Simon1'},
    {
      'id': 1,
      'name': 'Arthur Simon2',
    },
    {
      'id': 2,
      'name': 'Arthur Simon3',
    },
    {
      'id': 3,
      'name': 'Arthur Simon4',
    },
    {
      'id': 4,
      'name': 'Arthur Simon5',
    },
  ];

  handleNewSubsidiay() {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => const NewSubsidiary()),
    );
  }

  handleSwitchSubsidiary(data) {}

  handleAccept() {}

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              const CustomSpacer(size: 15),
              getSubsidiariesArrWidgets(subsidiariesArr),
              const CustomSpacer(size: 24),
              titleInvitationField(),
              const CustomSpacer(size: 18),
              getInvitationArrWidgets(invitationArr),
            ]));
  }

  Widget companyNameField() {
    return Container(
        width: wScale(327),
        padding: EdgeInsets.all(hScale(24)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(hScale(10)),
          image: const DecorationImage(
            image: AssetImage("assets/dashboard_header.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(children: [
          Text('Green Grocer Pte Ltd',
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
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(hScale(10)),
            topRight: Radius.circular(hScale(10)),
            bottomLeft: Radius.circular(hScale(10)),
            bottomRight: Radius.circular(hScale(10)),
          ),
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
                children: const [
                  TextSpan(
                      text:
                          'This page allows you to create separate \nsubsidiares to be managed under the same \ne-mail address. If you are looking to create \na separate Flex Business Account under a \nseparate e-mail address,'),
                  TextSpan(
                      text: 'click here',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: Color(0xFF0450e0))),
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
                primary: const Color(0xff29C490).withOpacity(0.4),
                padding: const EdgeInsets.all(0),
                textStyle: TextStyle(
                    fontSize: fSize(12),
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

  Widget getSubsidiariesArrWidgets(arr) {
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(data['userName'],
                style: TextStyle(fontSize: fSize(12), color: Colors.white)),
            Text(data["type"] == 0 ? 'Admin' : 'User',
                style: TextStyle(fontSize: fSize(12), color: Colors.white)),
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
            TextButton(
              style: TextButton.styleFrom(
                primary: const Color(0xff1da7ff),
                textStyle: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff1da7ff)),
              ),
              onPressed: () {
                handleSwitchSubsidiary(data);
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
    return Column(
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
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(hScale(10)),
            topRight: Radius.circular(hScale(10)),
            bottomLeft: Radius.circular(hScale(10)),
            bottomRight: Radius.circular(hScale(10)),
          ),
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
                width: wScale(141),
                height: hScale(56),
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

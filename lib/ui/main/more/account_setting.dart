import 'package:co/ui/main/more/my_subsibiaries.dart';
import 'package:co/ui/main/more/user_profile.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class AccountSetting extends StatefulWidget {
  const AccountSetting({Key? key}) : super(key: key);
  @override
  AccountSettingState createState() => AccountSettingState();
}

class AccountSettingState extends State<AccountSetting> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  int settingType = 1;

  handleSettingType(type) {
    setState(() {
      settingType = type;
    });
  }

  handleUpdate() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Stack(children: [
      Container(
        color: Colors.white,
        child: SizedBox(
            height: hScale(812),
            child: SingleChildScrollView(
                child: Column(children: [
              const CustomSpacer(size: 44),
              const CustomMainHeader(title: 'User Settings'),
              const CustomSpacer(size: 20),
              tabView(),
            ]))),
      ),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 14),
      )
    ])));
  }

  Widget tabView() {
    return DefaultTabController(
      length: 2,
      child: Container(
        child: Column(
          children: [
            Container(
              width: wScale(327),
              child: TabBar(
                unselectedLabelColor: const Color(0xFF70828D),
                labelPadding: const EdgeInsets.all(1),
                labelStyle: TextStyle(
                  fontSize: fSize(14),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                labelColor: Color(0xff1A2831),
                indicator: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Color(0xFF29C490), width: hScale(2)))),
                indicatorPadding: const EdgeInsets.all(1),
                indicatorWeight: 1,
                tabs: [
                  Tab(
                    text: 'User Profile',
                  ),
                  Tab(
                    text: 'My Subsidiaries',
                  ),
                ],
              ),
            ),
            Container(
              height: hScale(546),
              width: double.maxFinite,
              margin: EdgeInsets.only(top: hScale(15)),
              child: TabBarView(
                children: [UserProfile(), MySubsibiaries()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget userSettingTypeField() {
    return Container(
      width: wScale(327),
      alignment: Alignment.topCenter,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          statusButton('User Profile', 1),
          statusButton('My Subsidiaries', 2),
        ]),
      ]),
    );
  }

  Widget statusButton(title, type) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff70828D),
        padding: const EdgeInsets.all(0),
        textStyle:
            TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
      ),
      onPressed: () {
        handleSettingType(type);
      },
      child: Container(
        width: wScale(163),
        height: hScale(35),
        // padding: EdgeInsets.only(left: wScale(6),right: wScale(6)),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: type == 3 && settingType == 3
                        ? const Color(0xFFEB5757)
                        : type == settingType
                            ? const Color(0xFF29C490)
                            : const Color(0xFFEEEEEE),
                    width: type == settingType ? hScale(2) : hScale(1)))),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(14),
              color: type == 3
                  ? Color(0xFFEB5757)
                  : type == settingType
                      ? Colors.black
                      : const Color(0xff70828D)),
        ),
      ),
    );
  }
}

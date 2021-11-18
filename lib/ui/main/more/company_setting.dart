import 'package:flexflutter/ui/main/cards/physical_my_card.dart';
import 'package:flexflutter/ui/main/cards/physical_team_card.dart';
import 'package:flexflutter/ui/main/more/app_setting.dart';
import 'package:flexflutter/ui/main/more/company_profile.dart';
import 'package:flexflutter/ui/main/more/team_setting.dart';
import 'package:flexflutter/ui/main/more/user_profile.dart';
import 'package:flexflutter/ui/widgets/custom_bottom_bar.dart';
import 'package:flexflutter/ui/widgets/custom_header.dart';
import 'package:flexflutter/ui/widgets/custom_main_header.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

class CompanySetting extends StatefulWidget {

  const CompanySetting({Key? key}) : super(key: key);
  @override
  CompanySettingState createState() => CompanySettingState();
}

class CompanySettingState extends State<CompanySetting> {

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Stack(
                children:[
                  Container(
                    color: Colors.white,
                    child: Container(
                        height: hScale(812),
                        padding: EdgeInsets.symmetric(horizontal: wScale(24)),
                        child: SingleChildScrollView(
                            child: Column(
                                children: [
                                  const CustomSpacer(size: 57),
                                  companyTitle(),
                                  const CustomSpacer(size: 40),
                                  userSettingTypeField(),
                                  settingType == 1 ? const CompanyProfile() : settingType == 2 ? const TeamSetting() : const AppSetting(),
                                  const CustomSpacer(size: 88),
                                ]
                            )
                        )
                    ),
                  ),
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    child: CustomBottomBar(active: 4),
                  )
                ]
            )
        )
    );
  }

  Widget companyTitle() {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(hScale(24)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(hScale(10)),
          image: const DecorationImage(
            image: AssetImage("assets/dashboard_header.png"),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF106549).withOpacity(0.02),
              spreadRadius: 6,
              blurRadius: 18,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Text('Green Grocer Pte Ltd', style:TextStyle(fontSize: fSize(22), fontWeight: FontWeight.w700, color:Colors.white))
    );
  }

  Widget userSettingTypeField() {
    return Container(
      width: wScale(327),
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              statusButton('Company Profile', 1),
              statusButton('Team', 2),
              statusButton('App', 3),
            ]
        ),
      ),
    );
  }

  Widget statusButton(title, type) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff70828D),
        padding: const EdgeInsets.all(0),
        textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
      ),
      onPressed: () { handleSettingType(type); },
      child: Container(
        width: wScale(123),
        height: hScale(35),
        // padding: EdgeInsets.only(left: wScale(10),right: wScale(10)),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(
                color: type == settingType ? const Color(0xFF29C490): const Color(0xFFEEEEEE),
                width: type == settingType ? hScale(2): hScale(1)))
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(14),
              color: type == settingType ? Colors.black : const Color(0xff70828D)),
        ),
      ),
    );
  }

}
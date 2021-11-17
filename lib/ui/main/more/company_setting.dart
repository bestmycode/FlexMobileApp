import 'package:flexflutter/ui/main/cards/physical_my_card.dart';
import 'package:flexflutter/ui/main/cards/physical_team_card.dart';
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
                    child: SizedBox(
                        height: hScale(812),
                        child: SingleChildScrollView(
                            child: Column(
                                children: [
                                  const CustomSpacer(size: 44),
                                  const CustomMainHeader(title: 'Company Setting'),
                                  const CustomSpacer(size: 49),
                                  userSettingTypeField(),
                                  settingType == 1 ? const UserProfile() : const PhysicalTeamCards(),
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

  Widget userSettingTypeField() {
    return Container(
      width: wScale(327),
      alignment: Alignment.topCenter,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
                children: [
                  statusButton('User Profile', 1),
                  statusButton('My Subsibiaries', 2),
                ]
            ),
          ]
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
        width: wScale(163),
        height: hScale(35),
        // padding: EdgeInsets.only(left: wScale(6),right: wScale(6)),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(
                color: type == 3 && settingType == 3 ? const Color(0xFFEB5757) : type == settingType ? const Color(0xFF29C490): const Color(0xFFEEEEEE),
                width: type == settingType ? hScale(2): hScale(1)))
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(14),
              color: type == 3 ? Color(0xFFEB5757) : type == settingType ? Colors.black : const Color(0xff70828D)),
        ),
      ),
    );
  }

}
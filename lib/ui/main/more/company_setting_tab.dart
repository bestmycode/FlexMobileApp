import 'package:co/ui/main/more/app_setting.dart';
import 'package:co/ui/main/more/company_profile.dart';
import 'package:co/ui/main/more/team_setting.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/queries.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:localstorage/localstorage.dart';

class CompanySettingTab extends StatefulWidget {
  final tabIndex;
  const CompanySettingTab({Key? key, this.tabIndex}) : super(key: key);
  @override
  CompanySettingTabState createState() => CompanySettingTabState();
}

class CompanySettingTabState extends State<CompanySettingTab> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  late int settingType;
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String getCompanySettingQuery = Queries.QUERY_GET_COMPANY_SETTING;

  handleSettingType(type) {
    setState(() {
      settingType = type;
    });
  }

  @override
  void initState() {
    setState(() {
      settingType = widget.tabIndex;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      userSettingTypeField(),
      settingType == 0
          ? CompanyProfile()
          : settingType == 1
              ? TeamSetting()
              : AppSetting(),
      const CustomSpacer(size: 88),
    ]);
  }

  Widget userSettingTypeField() {
    return Container(
      width: wScale(327),
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(children: [
          statusButton('Company Profile', 0),
          statusButton('Team', 1),
          // statusButton('App', 2),
        ]),
      ),
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
        width: wScale(162),
        height: hScale(35),
        // padding: EdgeInsets.only(left: wScale(10),right: wScale(10)),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: type == settingType
                        ? const Color(0xFF29C490)
                        : const Color(0xFFEEEEEE),
                    width: type == settingType ? hScale(2) : hScale(1)))),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(14),
              fontWeight:
                  type == settingType ? FontWeight.w600 : FontWeight.w500,
              color:
                  type == settingType ? Colors.black : const Color(0xff70828D)),
        ),
      ),
    );
  }
}

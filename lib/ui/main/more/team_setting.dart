import 'package:co/ui/main/more/team_setting_invite.dart';
import 'package:co/ui/main/more/team_setting_users.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

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

  handleUpdate() {
    this.setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const CustomSpacer(size: 15),
      titleField('Invite New User'),
      const CustomSpacer(size: 4),
      titleDetailField(
          'We will send an invitation email that is valid for 7 days'),
      const CustomSpacer(size: 15),
      TeamSettingInvite(handleUpdate: handleUpdate),
      const CustomSpacer(size: 25),
      titleField('Users'),
      const CustomSpacer(size: 15),
      TeamSettingUsers(),
      const CustomSpacer(size: 15),
    ]));
  }

  Widget titleField(title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: wScale(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A2831))),
        ],
      ),
    );
  }

  Widget titleDetailField(detail) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: wScale(24)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(detail,
                style: TextStyle(
                    fontSize: fSize(12), color: const Color(0xFF70828D))),
          ],
        ));
  }
}

import 'package:flexflutter/ui/main/cards/physical_my_card.dart';
import 'package:flexflutter/ui/main/cards/physical_team_card.dart';
import 'package:flexflutter/ui/main/more/my_subsibiaries.dart';
import 'package:flexflutter/ui/main/more/user_profile.dart';
import 'package:flexflutter/ui/widgets/custom_bottom_bar.dart';
import 'package:flexflutter/ui/widgets/custom_header.dart';
import 'package:flexflutter/ui/widgets/custom_main_header.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flexflutter/ui/widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

class UserProfileEdit extends StatefulWidget {

  const UserProfileEdit({Key? key}) : super(key: key);
  @override
  UserProfileEditState createState() => UserProfileEditState();
}

class UserProfileEditState extends State<UserProfileEdit> {

  hScale(double scale) {
    return Scale().hScale(context, scale);
  }
  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final firstNameCtl = TextEditingController();
  final lastNameCtl = TextEditingController();
  final emailCtl = TextEditingController();
  final phoneNumberCtl = TextEditingController();
  final languageCtl = TextEditingController();

  handleConfirm() {

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
                                  const CustomMainHeader(title: 'User Profile'),
                                  const CustomSpacer(size: 39),
                                  userProfileEditField(),
                                  const CustomSpacer(size: 30),
                                  confirmButton(),
                                  const CustomSpacer(size: 88),
                                ]
                            )
                        )
                    ),
                  ),
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    child: CustomBottomBar(active: 14),
                  )
                ]
            )
        )
    );
  }

  Widget userProfileEditField() {
    return Container(
        width: wScale(327),
        // height: hScale(40),
        padding: EdgeInsets.symmetric(vertical: hScale(16), horizontal: wScale(16)),
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
          children: [
            Text("Edit Profile", style:TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w600, color: const Color(0xFF1A2831))),
            const CustomSpacer(size: 22),
            CustomTextField(ctl: firstNameCtl, hint: 'Enter First Name', label: 'First Name', fillColor: const Color(0xFFBDBDBD).withOpacity(0.1)),
            const CustomSpacer(size: 22),
            CustomTextField(ctl: lastNameCtl, hint: 'Enter Last Name', label: 'Last Name', fillColor: const Color(0xFFBDBDBD).withOpacity(0.1)),
            const CustomSpacer(size: 22),
            CustomTextField(ctl: emailCtl, hint: 'Enter Email', label: 'Email', fillColor: const Color(0xFFBDBDBD).withOpacity(0.1)),
            const CustomSpacer(size: 22),
            CustomTextField(ctl: phoneNumberCtl, hint: 'Enter Phone Number', label: 'Phone Number', fillColor: const Color(0xFFBDBDBD).withOpacity(0.1)),
            const CustomSpacer(size: 22),
            CustomTextField(ctl: languageCtl, hint: 'Enter Language', label: 'Language', fillColor: const Color(0xFFBDBDBD).withOpacity(0.1)),
          ],
        )
        
    );
  }

  Widget confirmButton() {
    return SizedBox(
        width: wScale(295),
        height: hScale(56),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
            ),
          ),
          onPressed: () { handleConfirm(); },
          child: Text(
              "Confirm Changes",
              style: TextStyle(color: Colors.white, fontSize: fSize(16), fontWeight: FontWeight.bold )),
        )
    );
  }
}
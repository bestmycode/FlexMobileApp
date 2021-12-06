import 'package:co/ui/main/more/user_profile_edit.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);
  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  handleEditProfile() {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => const UserProfileEdit()),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const CustomSpacer(size: 15),
      userProfileField(),
      const CustomSpacer(size: 30),
      editProfileButton(),
    ]);
  }

  Widget userProfileField() {
    return Container(
        width: wScale(327),
        // height: hScale(40),
        padding:
            EdgeInsets.symmetric(vertical: hScale(16), horizontal: wScale(16)),
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
        child: Row(
          children: [
            Container(
              width: wScale(60),
              height: wScale(60),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(wScale(30)),
                  topRight: Radius.circular(wScale(30)),
                  bottomLeft: Radius.circular(wScale(30)),
                  bottomRight: Radius.circular(wScale(30)),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.asset(
                'assets/user.png',
                fit: BoxFit.contain,
                width: wScale(60),
              ),
            ),
            SizedBox(width: wScale(20)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Terry Herwit',
                    style: TextStyle(
                        fontSize: fSize(16),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF040415))),
                const CustomSpacer(size: 9),
                Text('terryherwit@green.com',
                    style: TextStyle(
                        fontSize: fSize(14), color: const Color(0xFF70828D))),
                const CustomSpacer(size: 28),
                Row(
                  children: [
                    Text('+6513455666',
                        style: TextStyle(
                            fontSize: fSize(14),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF040415))),
                    SizedBox(width: wScale(10)),
                    Text('Verified',
                        style: TextStyle(
                            fontSize: fSize(14),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF30E7A9))),
                    SizedBox(width: wScale(5)),
                    Icon(Icons.check_circle,
                        color: const Color(0xff30E7A9), size: hScale(14)),
                  ],
                ),
                const CustomSpacer(size: 19),
                Row(
                  children: [
                    Text('Language: ',
                        style: TextStyle(
                            fontSize: fSize(14),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF70828D))),
                    Text('English (US)',
                        style: TextStyle(
                            fontSize: fSize(14),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF040415)))
                  ],
                )
              ],
            ),
          ],
        ));
  }

  Widget editProfileButton() {
    return SizedBox(
        width: wScale(295),
        height: hScale(56),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            handleEditProfile();
          },
          child: Text("Edit Profile",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.bold)),
        ));
  }
}

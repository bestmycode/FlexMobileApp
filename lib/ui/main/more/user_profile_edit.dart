import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_result_modal.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';

class UserProfileEdit extends StatefulWidget {
  final userData;
  const UserProfileEdit({Key? key, this.userData}) : super(key: key);
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

  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String updateUserProfileMutation = FXRMutations.MUTATION_UPDATE_USER_PROFILE;

  handleConfirm(runMutation) {
    runMutation({
      "firstName": widget.userData['firstName'],
      "language": languageCtl.text,
      "lastName": widget.userData['lastName'],
      "mobile": phoneNumberCtl.text,
      "userId": widget.userData['id'],
    });
  }

  @override
  void initState() {
    firstNameCtl.text = widget.userData['firstName'];
    lastNameCtl.text = widget.userData['lastName'];
    emailCtl.text = widget.userData['email'];
    phoneNumberCtl.text = widget.userData['mobile'];
    languageCtl.text = widget.userData['language'];
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
              const CustomMainHeader(title: 'User Profile'),
              const CustomSpacer(size: 39),
              userProfileEditField(),
              const CustomSpacer(size: 30),
              mutationButton(),
              const CustomSpacer(size: 88),
            ]))),
      ),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 14),
      )
    ])));
  }

  Widget userProfileEditField() {
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
        child: Column(
          children: [
            Text("Edit Profile",
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A2831))),
            const CustomSpacer(size: 22),
            CustomTextField(
                ctl: firstNameCtl,
                hint: 'Enter First Name',
                label: 'First Name',
                readOnly: true,
                fillColor: const Color(0xFFBDBDBD).withOpacity(0.1)),
            const CustomSpacer(size: 22),
            CustomTextField(
                ctl: lastNameCtl,
                hint: 'Enter Last Name',
                label: 'Last Name',
                readOnly: true,
                fillColor: const Color(0xFFBDBDBD).withOpacity(0.1)),
            const CustomSpacer(size: 22),
            CustomTextField(
                ctl: emailCtl,
                hint: 'Enter Email',
                label: 'Email',
                readOnly: true,
                fillColor: const Color(0xFFBDBDBD).withOpacity(0.1)),
            const CustomSpacer(size: 22),
            CustomTextField(
                ctl: phoneNumberCtl,
                hint: 'Enter Phone Number',
                label: 'Phone Number',
                fillColor: const Color(0xFFBDBDBD).withOpacity(0.1)),
            const CustomSpacer(size: 22),
            CustomTextField(
                ctl: languageCtl,
                hint: 'Enter Language',
                label: 'Language',
                fillColor: const Color(0xFFBDBDBD).withOpacity(0.1)),
          ],
        ));
  }

  Widget mutationButton() {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Mutation(
            options: MutationOptions(
              document: gql(updateUserProfileMutation),
              update: (GraphQLDataProxy cache, QueryResult? result) {
                return cache;
              },
              onCompleted: (resultData) {
                if (resultData['user'] != null) {
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
                                  title: "Update Successful",
                                  message:
                                      "User Profile has been successfully updated")));
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
                                  title: "Failed",
                                  message:
                                      "User Profile Don't Updated!!!")));
                    });
                }
              },
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              return confirmButton(runMutation);
            }));
  }

  Widget confirmButton(runMutation) {
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
            handleConfirm(runMutation);
          },
          child: Text("Confirm Changes",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.bold)),
        ));
  }
}

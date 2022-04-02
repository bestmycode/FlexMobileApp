import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_cardtype_popup_list.dart';
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
  var langTypeArr = ["English(US)", "Vietnamese"];

  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String updateUserProfileMutation = FXRMutations.MUTATION_UPDATE_USER_PROFILE;
  bool isLoading = false;

  handleConfirm(runMutation) {
    setState(() {
      isLoading = true;
    });
    runMutation({
      "firstName": widget.userData['firstName'],
      "language": languageCtl.text == "English(US)" ? "en" : "vi",
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
    languageCtl.text =
        widget.userData['language'] == "en" ? "English(US)" : "Vietnamese";
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
              blurRadius: 10,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
                opacity: isLoading ? 0.5 : 1,
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
                        fillColor: const Color(0xFFFFFFFF)),
                    const CustomSpacer(size: 22),
                    widget.userData['language'] == "en" ? Stack(children: [
                      CustomTextField(
                          ctl: languageCtl,
                          hint: 'Enter Language',
                          label: 'Language',
                          readOnly: true,
                          fillColor: const Color(0xFFFFFFFF)),
                      // Positioned(
                      //     right: 0,
                      //     child: Container(
                      //         width: wScale(40),
                      //         height: hScale(64),
                      //         child: TextButton(
                      //             onPressed: () {
                      //               _showCardTypeModalDialog(
                      //                   context, langTypeArr);
                      //             },
                      //             child: Icon(Icons.keyboard_arrow_down_rounded,
                      //                 color: const Color(0xFFBFBFBF)))))
                    ]): SizedBox()
                  ],
                )),
            isLoading
                ? Positioned(
                    top: 150,
                    child: Container(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF60C094)))),
                  )
                : SizedBox()
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
              onError: (error) {
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
                                  title: "Something went wrong",
                                  titleColor: Color(0xFFEB5757),
                                  message: error!.graphqlErrors.length != 0
                                      ? "This mobile number has been registered to an existing account.\nPlease enter a different mobile number."
                                      : "We are unable to update the user profile.\nPlease try again later")));
                    });
              },
              onCompleted: (resultData) {
                setState(() {
                  isLoading = false;
                });
                if (resultData != null && resultData['user'] != null) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: wScale(40)),
                            child: Dialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                                child: CustomResultModal(
                                    status: true,
                                    title: "Update Successful",
                                    message:
                                        "User Profile has been successfully updated",
                                    handleOKClick: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop('dialog');
                                      Navigator.pop(context, true);
                                    })));
                      });
                }
              },
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              return confirmButton(runMutation);
            }));
  }

  Widget confirmButton(runMutation) {
    return Opacity(
        opacity: isLoading ? 0.5 : 1,
        child: SizedBox(
            width: wScale(295),
            height: hScale(56),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: const Color(0xff1A2831),
                side: const BorderSide(width: 0, color: Color(0xff1A2831)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                isLoading ? null : handleConfirm(runMutation);
              },
              child: Text("Confirm Changes",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fSize(16),
                      fontWeight: FontWeight.bold)),
            )));
  }

  _showCardTypeModalDialog(context, arrData) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: wScale(40)),
              child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: CustomCardTypePopUpList(
                    arrData: arrData,
                    onPress: (index) {
                      languageCtl.text =
                          index == 0 ? "English(US)" : "Vietnamese";
                    },
                  )));
        });
  }
}

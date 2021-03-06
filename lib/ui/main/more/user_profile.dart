import 'package:co/ui/main/more/account_setting.dart';
import 'package:co/ui/main/more/user_profile_edit.dart';
import 'package:co/ui/widgets/custom_no_internet.dart';
import 'package:co/ui/widgets/custom_result_modal.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';

class UserProfile extends StatefulWidget {
  // final userData;
  // final handleUpdate;
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

  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String getUserInfoSettingQuery = Queries.QUERY_GET_USER_SETTING;
  String phoneVerificationMutation = FXRMutations.MUTATION_PHONE_VERIFICATION;

  handleEditProfile(userData) async {
    var result = await Navigator.of(context).push(
      CupertinoPageRoute(
          builder: (context) => UserProfileEdit(userData: userData)),
    );
    if (result) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    return Query(
        options: QueryOptions(
          document: gql(getUserInfoSettingQuery),
          variables: {},
          
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return CustomNoInternet(handleTryAgain: () {
              Navigator.of(context)
                  .push(new MaterialPageRoute(
                      builder: (context) => AccountSetting()))
                  .then((value) => setState(() => {}));
            });
          }

          if (result.isLoading) {
            return Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF60C094))));
          }
          var userSettingInfo = result.data!['user'];
          return mainHome(userSettingInfo);
        });
  }

  Widget mainHome(userSettingInfo) {
    return Column(children: [
      const CustomSpacer(size: 15),
      userProfileField(userSettingInfo),
      const CustomSpacer(size: 30),
      editProfileButton(userSettingInfo),
    ]);
  }

  Widget userProfileField(userData) {
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container(
            //   width: wScale(60),
            //   height: wScale(60),
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.only(
            //       topLeft: Radius.circular(wScale(30)),
            //       topRight: Radius.circular(wScale(30)),
            //       bottomLeft: Radius.circular(wScale(30)),
            //       bottomRight: Radius.circular(wScale(30)),
            //     ),
            //   ),
            //   clipBehavior: Clip.hardEdge,
            //   child: Image.asset(
            //     'assets/user.png',
            //     fit: BoxFit.contain,
            //     width: wScale(60),
            //   ),
            // ),
            SizedBox(width: wScale(20)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${userData['firstName']} ${userData['lastName']}",
                    style: TextStyle(
                        fontSize: fSize(16),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF040415))),
                const CustomSpacer(size: 9),
                Text(userData['email'],
                    style: TextStyle(
                        fontSize: fSize(14), color: const Color(0xFF70828D))),
                const CustomSpacer(size: 10),
                Row(
                  children: [
                    Text(userData['mobile'],
                        style: TextStyle(
                            fontSize: fSize(14),
                            fontWeight: FontWeight.w500,
                            color: userData['mobileVerified'] == true
                                ? const Color(0xFF040415)
                                : const Color(0xFFEB5757))),
                    SizedBox(width: wScale(10)),
                    Text(userData['mobileVerified'] == true ? 'Verified' : '',
                        style: TextStyle(
                            fontSize: fSize(14),
                            fontWeight: FontWeight.w500,
                            color: userData['mobileVerified'] == true
                                ? const Color(0xFF30E7A9)
                                : const Color(0xFFEB5757))),
                    SizedBox(width: wScale(5)),
                    Icon(
                        userData['mobileVerified'] == true
                            ? Icons.check_circle
                            : Icons.info,
                        color: userData['mobileVerified'] == true
                            ? const Color(0xff30E7A9)
                            : const Color(0xFFEB5757),
                        size: hScale(14)),
                    SizedBox(width: wScale(10)),
                    userData['mobileVerified'] != true
                        ? mutationButton(userData)
                        : SizedBox()
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
                    Text(
                        userData['language'] == 'en'
                            ? 'English(US)'
                            : 'Vietnamese',
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

  Widget editProfileButton(userData) {
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
            handleEditProfile(userData);
          },
          child: Text("Edit Profile",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.bold)),
        ));
  }

  Widget mutationButton(userData) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Mutation(
            options: MutationOptions(
              document: gql(phoneVerificationMutation),
              update: (GraphQLDataProxy cache, QueryResult? result) {
                return cache;
              },
              onCompleted: (resultData) {
                if (resultData['sendVerificationMessage'] != null) {
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
                                    title: "SMS verification link sent",
                                    message:
                                        "An SMS verification link has been sent to your mobile number.")));
                      });
                } else {
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
                                    title: "SMS verification Failed",
                                    message:
                                        "An SMS verification link can't send to your mobile number.")));
                      });
                }
              },
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              return TextButton(
                  style: TextButton.styleFrom(
                    primary: const Color(0xffF5F5F5).withOpacity(0.4),
                    padding: const EdgeInsets.all(0),
                  ),
                  child: Text('Send SMS Link',
                      style: TextStyle(
                          fontSize: fSize(12),
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF29C490),
                          decoration: TextDecoration.underline)),
                  onPressed: () {
                    runMutation({
                      "country": "SG",
                      "language": userData['language'],
                      "mobile": userData['mobile'],
                      "verificationType": "SMS",
                    });
                  });
            }));
  }
}

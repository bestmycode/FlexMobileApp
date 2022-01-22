import 'package:co/ui/main/more/my_subsibiaries.dart';
import 'package:co/ui/main/more/user_profile.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';

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
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String getUserInfoSettingQuery = Queries.QUERY_GET_USER_SETTING;

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
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    var orgId = userStorage.getItem('orgId');
    return Material(
        child: Scaffold(
            body: Query(
            options: QueryOptions(
              document: gql(getUserInfoSettingQuery),
              variables: {},
              // pollInterval: const Duration(seconds: 10),
            ),
            builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.hasException) {
                return Text(result.exception.toString());
              }

              if (result.isLoading) {
                return CustomLoading();
              }
              var userSettingInfo = result.data!['user'];
              var userInvitations = result.data!['currentUserInvitations'];
              return mainHome(userSettingInfo, userInvitations);
            })));
  }

  Widget mainHome(userSettingInfo, userInvitations) {
    return Stack(children: [
      Container(
        color: Colors.white,
        child: SizedBox(
            height: hScale(812),
            child: SingleChildScrollView(
                child: Column(children: [
              const CustomSpacer(size: 44),
              const CustomMainHeader(title: 'User Settings'),
              const CustomSpacer(size: 49),
              userSettingTypeField(),
              settingType == 1 ? UserProfile(userData: userSettingInfo) : MySubsibiaries(roles: userSettingInfo['roles'], userInvitations: userInvitations),
              const CustomSpacer(size: 88),
            ]))),
      ),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 14),
      )
    ]);
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

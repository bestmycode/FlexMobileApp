import 'package:co/ui/main/more/company_setting_tab.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';

class CompanySetting extends StatefulWidget {
  final tabIndex;
  const CompanySetting({Key? key, this.tabIndex}) : super(key: key);
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

  late int settingType;
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String getCompanySettingQuery = Queries.QUERY_GET_COMPANY_SETTING;

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
            resizeToAvoidBottomInset: false,
            body: Query(
                options: QueryOptions(
                  document: gql(getCompanySettingQuery),
                  variables: {'orgId': orgId},
                  // pollInterval: const Duration(seconds: 10),
                ),
                builder: (QueryResult result,
                    {VoidCallback? refetch, FetchMore? fetchMore}) {
                  if (result.hasException) {
                    return Text(result.exception.toString());
                  }

                  if (result.isLoading) {
                    return CustomLoading();
                  }
                  var companyProfile = result.data!['organization'];
                  return mainHome(companyProfile);
                })));
  }

  Widget mainHome(companyProfile) {
    return Stack(children: [
      Container(
        color: Colors.white,
        child: Container(
            height: hScale(812),
            padding: EdgeInsets.symmetric(horizontal: wScale(24)),
            child: SingleChildScrollView(
                child: Column(children: [
              const CustomSpacer(size: 57),
              companyTitle(companyProfile!['name']),
              const CustomSpacer(size: 40),
              CompanySettingTab(tabIndex: widget.tabIndex),
              // const CustomSpacer(size: 88),
            ]))),
      ),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 4),
      )
    ]);
  }

  Widget companyTitle(title) {
    return Container(
        width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
        height: hScale(96),
        padding: EdgeInsets.symmetric(horizontal: wScale(24)),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: fSize(22),
                    fontWeight: FontWeight.w700,
                    color: Colors.white))
          ],
        ));
  }
}

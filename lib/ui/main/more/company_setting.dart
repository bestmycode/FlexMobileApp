import 'package:co/ui/main/more/company_profile.dart';
import 'package:co/ui/main/more/team_setting.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/ui/widgets/custom_no_internet.dart';
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
  const CompanySetting({Key? key, this.tabIndex = 0}) : super(key: key);
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
                ),
                builder: (QueryResult result,
                    {VoidCallback? refetch, FetchMore? fetchMore}) {
                  if (result.hasException) {
                    return Scaffold(body: CustomNoInternet(handleTryAgain: () {
                      Navigator.of(context)
                          .push(new MaterialPageRoute(
                              builder: (context) => CompanySetting()))
                          .then((value) => setState(() => {}));
                    }));
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
            child: SingleChildScrollView(
                child: Column(children: [
              Container(
                  padding: EdgeInsets.symmetric(horizontal: wScale(24)),
                  child: Column(children: [
                    const CustomSpacer(size: 57),
                    companyTitle(companyProfile!['name']),
                    const CustomSpacer(size: 20)
                  ])),
              tabView(),
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
        width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
            .size
            .width,
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

  Widget tabView() {
    return DefaultTabController(
      length: 2,
      child: Container(
        child: Column(
          children: [
            Container(
              width: wScale(327),
              child: TabBar(
                unselectedLabelColor: const Color(0xFF70828D),
                labelPadding: const EdgeInsets.all(1),
                labelStyle: TextStyle(
                  fontSize: fSize(14),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                labelColor: Color(0xff1A2831),
                indicator: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Color(0xFF29C490), width: hScale(2)))),
                indicatorPadding: const EdgeInsets.all(1),
                indicatorWeight: 1,
                tabs: [
                  Tab(
                    text: 'Company Profile',
                  ),
                  Tab(
                    text: 'Team',
                  ),
                ],
              ),
            ),
            Container(
              height: hScale(480),
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: hScale(15)),
              child: TabBarView(
                children: [
                  CompanyProfile(),
                  TeamSetting(),
                  // AppSetting()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

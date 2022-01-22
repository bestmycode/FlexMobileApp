import 'dart:async';

import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';

class AppSetting extends StatefulWidget {
  const AppSetting({Key? key}) : super(key: key);
  @override
  AppSettingState createState() => AppSettingState();
}

class AppSettingState extends State<AppSetting> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  int appType = 0;
  bool syncing = false;
  bool synced = false;
  final LocalStorage tokenStorage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String getCompanySettingQuery = Queries.QUERY_GET_COMPANY_SETTING;
  String partnerConnectionMutation = FXRMutations.MUTATION_PARTNER_CONNECT;
  String partnerBAnkPushMutation = FXRMutations.MUTATION_PARTNER_BANK_PUSH;

  startTime() async {
    var _duration = const Duration(seconds: 3);
    return Timer(_duration, handleSynced);
  }

  void handleSynced() {
    setState(() {
      synced = true;
      syncing = false;
    });
  }

  handleAppType(type) {
    setState(() {
      appType = type;
    });
  }

  handleSync(runMutation, id) {
    if (!synced) {
      runMutation(
          {"orgId": userStorage.getItem('orgId'), "partner": "xero_bank_feed"});
      setState(() {
        syncing = true;
      });
      startTime();
    }
  }

  handleRemovePartnerBank(runMutation) {
    runMutation({'orgId': userStorage.getItem('orgId')});
  }

  handleConnectNewApp(runMutation, id) {
    runMutation({
      "callback":
          "https://app.staging.fxr.one/flex/organization/apps/integration",
      "orgId": userStorage.getItem('orgId'),
      "partner": id,
      "startDate": new DateTime.now()
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = tokenStorage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    var orgId = userStorage.getItem('orgId');
    return Query(
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
            return Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF60C094))));
          }
          var organizationApps = result.data!['organizationApps'];
          return mainHome(organizationApps);
        });
  }

  Widget mainHome(organizationApps) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const CustomSpacer(size: 15),
      Text('Connected Apps',
          style: TextStyle(
              fontSize: fSize(16),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2831))),
      const CustomSpacer(size: 15),
      connectedApp(organizationApps),
      const CustomSpacer(size: 30),
      Text('Connect a New App',
          style: TextStyle(
              fontSize: fSize(16),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2831))),
      appTypeField(),
      appsDetailField(organizationApps),
      const CustomSpacer(size: 30),
    ]);
  }

  Widget connectedApp(organizationApps) {
    var appsList = organizationApps['installedApps'];
    return organizationApps['installedApps'].length == 0
        ? Container(
            alignment: Alignment.center,
            child: Image.asset('assets/empty_transaction.png',
                fit: BoxFit.contain, width: wScale(159)))
        : Column(
            children: appsList.map<Widget>((item) {
            return connectedAppField(item);
          }).toList());
  }

  Widget connectedAppField(item) {
    return Container(
        width: wScale(327),
        padding:
            EdgeInsets.symmetric(vertical: hScale(20), horizontal: wScale(20)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 4,
              blurRadius: 20,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            connectedAppIcon(item['integrationId'], item['status']),
            const CustomSpacer(size: 6),
            Text(item['integrationId'],
                style: TextStyle(
                    fontSize: fSize(18),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A2831))),
            const CustomSpacer(size: 6),
            Text("Last Sync : ${item['lastUpdateAttempt']}",
                style: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF70828D))),
            const CustomSpacer(size: 26),
            buttonField(item['integrationId'], item['status'])
          ],
        ));
  }

  Widget connectedAppIcon(id, status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
            id == 'xero'
                ? 'assets/xero.png'
                : id == "lazada"
                    ? 'assets/lazada.png'
                    : 'assets/xero.png',
            fit: BoxFit.contain,
            height: hScale(59)),
        Container(
          margin: EdgeInsets.only(top: hScale(10)),
          padding:
              EdgeInsets.symmetric(vertical: hScale(4), horizontal: wScale(8)),
          decoration: BoxDecoration(
            color: status == "CONNECTED"
                ? Color(0xFFE1FFEF)
                : Color(0xFFFF0000).withOpacity(0.1),
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
          child: Text(
              status == "CONNECTED"
                  ? 'Connected'
                  : status == "UPDATE_FAILED"
                      ? "Update Failed"
                      : '',
              style: TextStyle(
                  fontSize: fSize(12),
                  fontWeight: FontWeight.w500,
                  color: status == "CONNECTED"
                      ? const Color(0xFF2ED47A)
                      : const Color(0xFFFF0000))),
        )
      ],
    );
  }

  Widget buttonField(id, status) {
    return status == "CONNECTED"
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [mutationSyncButton(id), mutationRemoveButton()],
          )
        : SizedBox();
  }

  Widget mutationSyncButton(id) {
    String accessToken = tokenStorage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Mutation(
            options: MutationOptions(
              document: gql(partnerBAnkPushMutation),
              update: (GraphQLDataProxy cache, QueryResult? result) {
                return cache;
              },
              onCompleted: (resultData) {
                if (resultData['partnerSync']['status'] == "success") {
                } else {}
              },
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              return syncActionButton(runMutation, id);
            }));
  }

  Widget syncActionButton(runMutation, id) {
    return TextButton(
      style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
      child: Container(
          width: wScale(132),
          height: hScale(56),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: !syncing ? const Color(0xFF1A2831) : const Color(0xFF81919B),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(synced ? 'Connected' : 'Sync Now',
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            syncing ? SizedBox(width: wScale(8)) : const SizedBox(),
            syncing
                ? SizedBox(
                    child: CircularProgressIndicator(
                      color: const Color(0xFFFFFFFF),
                      backgroundColor: const Color(0xFFFFFFFF).withOpacity(0.5),
                      strokeWidth: 1,
                    ),
                    width: hScale(13),
                    height: hScale(13))
                : const SizedBox()
          ])),
      onPressed: () {
        handleSync(runMutation, id);
      },
    );
  }

  Widget mutationRemoveButton() {
    String accessToken = tokenStorage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Mutation(
            options: MutationOptions(
              document: gql(partnerBAnkPushMutation),
              update: (GraphQLDataProxy cache, QueryResult? result) {
                return cache;
              },
              onCompleted: (resultData) {},
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              return removeActionButton(runMutation);
            }));
  }

  Widget removeActionButton(runMutation) {
    return TextButton(
      style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
      child: Container(
          width: wScale(132),
          height: hScale(56),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFEB5757).withOpacity(0.1),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset('assets/red_delete.png',
                fit: BoxFit.contain, height: hScale(17)),
            SizedBox(width: wScale(8)),
            Text('Delete',
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEB5757))),
          ])),
      onPressed: () {
        handleRemovePartnerBank(runMutation);
      },
    );
  }

  Widget appTypeField() {
    return Container(
      width: wScale(327),
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(children: [
          statusButton('All Apps', 0),
          statusButton('Accounting', 1),
          statusButton('Trade', 2),
          statusButton('Payment', 3),
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
        handleAppType(type);
      },
      child: Container(
        width: wScale(81),
        height: hScale(30),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: type == appType
                        ? const Color(0xFF29C490)
                        : const Color(0xFFEEEEEE),
                    width: type == appType ? hScale(2) : hScale(1)))),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(12),
              fontWeight: type == appType ? FontWeight.w600 : FontWeight.w500,
              color: type == appType
                  ? const Color(0xFF1A2831)
                  : const Color(0xff70828D)),
        ),
      ),
    );
  }

  Widget appsDetailField(organizationApps) {
    var appsList = appType == 0
        ? organizationApps['connectToApps']
        : appType == 1
            ? organizationApps['connectToApps']
                .where((item) => item['integrationType'] == "ACCOUNTING")
                .toList()
            : appType == 2
                ? organizationApps['connectToApps']
                    .where((item) => item['integrationType'] == "BANK")
                    .toList()
                : organizationApps['connectToApps']
                    .where((item) => item['integrationType'] == "PAYMENT")
                    .toList();
    return Wrap(
        children: appsList.map<Widget>((item) {
      return appField(
          item['id'] == 'qb' ? 'assets/quickbooks.png' : 'assets/xero.png',
          item['name'],
          item['integrationId']);
    }).toList());
  }

  Widget appField(icon, name, id) {
    return Container(
      width: wScale(155),
      height: hScale(197),
      padding: EdgeInsets.symmetric(horizontal: wScale(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 4,
            blurRadius: 20,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
              height: hScale(59),
              margin: EdgeInsets.only(top: hScale(16)),
              child: Image.asset(
                icon,
                fit: BoxFit.contain,
                width: wScale(124),
                height: hScale(59),
              )),
          const CustomSpacer(size: 6),
          Text(name,
              style: TextStyle(
                  fontSize: fSize(18),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF70828D))),
          const CustomSpacer(size: 14),
          mutationConnectButton(id)
        ],
      ),
    );
  }

  Widget mutationConnectButton(id) {
    String accessToken = tokenStorage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Mutation(
            options: MutationOptions(
              document: gql(partnerConnectionMutation),
              update: (GraphQLDataProxy cache, QueryResult? result) {
                return cache;
              },
              onCompleted: (resultData) {
                print(resultData);
              },
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              return connectActionButton(runMutation, id);
            }));
  }

  Widget connectActionButton(runMutation, id) {
    return TextButton(
      style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
      child: Container(
        width: wScale(123),
        height: hScale(56),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFF1A2831),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Text('Connect',
            style: TextStyle(
                fontSize: fSize(16),
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
      onPressed: () {
        handleConnectNewApp(runMutation, id);
      },
    );
  }
}

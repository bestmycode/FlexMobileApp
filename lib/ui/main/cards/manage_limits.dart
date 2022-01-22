import 'package:co/ui/main/cards/manage_limits_additional.dart';
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_result_modal.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';

class ManageLimits extends StatefulWidget {
  final data;
  const ManageLimits({Key? key, this.data}) : super(key: key);
  @override
  ManageLimitsState createState() => ManageLimitsState();
}

class ManageLimitsState extends State<ManageLimits> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final cardTypeCtl = TextEditingController();
  int cardType = 0; // 0 => Fixed Card, 1 => Recurring Card
  var cardTypeArr = ["Fixed Card", "Recurring Card"];
  final cardLimitCtl = TextEditingController();
  final limitRefreshCtl = TextEditingController();
  final expiryDateCtl = TextEditingController();
  final transactionLimitCtl = TextEditingController(text: 'SGD 0.00');
  final varianceLimitCtl = TextEditingController(text: '0%');

  bool isSwitchedMerchant = true;
  bool isSwitchedTransactionLimit = true;
  List<bool> isSwitchedArr = [
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true
  ];
  double transactionLimitValue = 0;
  double varianceLimitValue = 0;

  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String readFinanceAccountQuery = Queries.QUERY_READ_FINANCE_ACCOUNT;
  String mutationFinanceAccountLimit =
      FXRMutations.MUTATION_FINANCE_ACCOUNT_LIMIT;
  bool isLoading = false;

  handleCloneSetting() {}

  handleSwitch(index, v) {
    setState(() {
      isSwitchedArr[index] = v;
    });
  }

  setTransactionLimitValue(newValue) {
    setState(() {
      transactionLimitValue = newValue;
    });
  }

  setVarianceLimitValue(newValue) {
    setState(() {
      varianceLimitValue = newValue;
    });
  }

  handleSave(runMutation) {
    runMutation({
      "financeAccountId": widget.data['id'],
      "limitValue": int.parse(cardLimitCtl.text),
      "orgId": widget.data['orgId'],
      "controls": {
        "transactionLimit": transactionLimitValue,
        "variancePercentage": varianceLimitValue,
        "allowedCategories": [
          {"categoryName": "AIRLINES", "isAllowed": true},
          {"categoryName": "CAR_RENTAL", "isAllowed": true},
          {"categoryName": "TRANSPORTATION", "isAllowed": true},
          {"categoryName": "HOTELS", "isAllowed": true},
          {"categoryName": "PETROL", "isAllowed": true},
          {"categoryName": "DEPARTMENT_STORES", "isAllowed": true},
          {"categoryName": "PARKING", "isAllowed": true},
          {"categoryName": "FOOD_AND_BEVERAGES", "isAllowed": true},
          {"categoryName": "TAXIS", "isAllowed": true},
          {"categoryName": "OTHERS", "isAllowed": true}
        ]
      }
    });
    setState(() {
      isLoading = true;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Query(
            options: QueryOptions(
              document: gql(readFinanceAccountQuery),
              variables: {
                'orgId': widget.data['orgId'],
                "financeAccountId": widget.data['id']
              },
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

              var financeAccount = result.data!['readFinanceAccount'];

              return home(financeAccount);
            }));
  }

  Widget home(data) {
    print(data['spendControlLimits']['transactionLimit']);
    return Material(
        child: Scaffold(
            body: Stack(children: [
      Container(
        height: hScale(812),
        child:SingleChildScrollView(
          child:  Column(children: [
          const CustomSpacer(size: 44),
          const CustomMainHeader(title: 'Manage Limits'),
          const CustomSpacer(size: 38),
          isLoading
              ? Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: hScale(30)),
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF60C094))))
              : Column(
                  children: [
                    cardDetailField(widget.data),
                    const CustomSpacer(size: 20),
                    // additionalField(data['spendControlLimits']),
                    ManageLimitsAdditional(
                        data: data == null ? null : data['spendControlLimits'],
                        availableLimitValue: data == null? 0.0 : data['financeAccountLimits'][0]['availableLimit'].toDouble(),
                        transactionLimitValue: data['spendControlLimits']['transactionLimit'] == null ? 0.0 : data['spendControlLimits']['transactionLimit'].toDouble(),
                        varianceLimitValue: data['spendControlLimits']['variancePercentage'] == null ? 0.0 : data['spendControlLimits']['variancePercentage'].toDouble(),
                        isSwitchedArr: isSwitchedArr,
                        // handleSwitch: handleSwitch,
                        setTransactionLimitValue: setTransactionLimitValue,
                        isSwitchedTransactionLimit: isSwitchedTransactionLimit,
                        setVarianceLimitValue: setVarianceLimitValue),
                    const CustomSpacer(size: 20),
                    buttonField(),
                    const CustomSpacer(size: 24),
                  ],
                ),
          const CustomSpacer(size: 88),
        ]),
      )),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 1),
      )
    ])));
  }

  Widget cardDetailField(data) {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(
          left: wScale(16),
          right: wScale(16),
          top: hScale(16),
          bottom: hScale(16)),
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
            color: Colors.grey.withOpacity(0.25),
            spreadRadius: 4,
            blurRadius: 20,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cardTitle(),
          const CustomSpacer(size: 22),
          cardTypeField(data == null ? "" : data['cardType']),
          const CustomSpacer(size: 22),
          CustomTextField(
              ctl: cardLimitCtl
                ..text = data == null
                    ? ''
                    : data['financeAccountLimits'][0]['availableLimit']
                        .toString(),
              hint: 'Enter Card Limit',
              label: 'Card Limit',
              // onChanged: (text) {
              //   setState(() {
              //     isSwitchedTransactionLimit =
              //       isSwitchedMerchant && text.length > 0 ? true : false;
              //   });
              // },
              // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number),
          const CustomSpacer(size: 22),
          limitRefreshField(),
          const CustomSpacer(size: 15),
        ],
      ),
    );
  }

  Widget cardTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Spend Control Main',
            style: TextStyle(
                fontSize: fSize(16),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2831))),
      ],
    );
  }

  Widget cardTypeField(cardtype) {
    cardTypeCtl.text = cardtype == 'RECURRING'
        ? 'Recurring'
        : cardtype == 'ONE-TIME'
            ? 'Fixed'
            : '';
    return Stack(
      children: [
        Container(
          width: wScale(295),
          height: hScale(56),
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: hScale(8)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border:
                  Border.all(color: const Color(0xFF040415).withOpacity(0.1))),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: TextField(
                readOnly: true,
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF040415).withOpacity(0.5)),
                controller: cardTypeCtl,
                enabled: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
                  hintText: 'Select Card Types',
                  hintStyle: TextStyle(
                      color: const Color(0xffBFBFBF), fontSize: fSize(14)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
                ),
              )),
              Icon(Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFFBFBFBF))
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text('Card Type*',
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFBFBFBF))),
          ),
        )
      ],
    );
  }

  Widget limitRefreshField() {
    limitRefreshCtl.text = "Monthly";
    return Stack(
      children: [
        Container(
          width: wScale(295),
          height: hScale(56),
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: hScale(8)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border:
                  Border.all(color: const Color(0xFF040415).withOpacity(0.1))),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: TextField(
                readOnly: true,
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF040415).withOpacity(0.5)),
                controller: limitRefreshCtl,
                enabled: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
                  hintText: 'Enter Limit Refresh',
                  hintStyle: TextStyle(
                      color: const Color(0xffBFBFBF), fontSize: fSize(14)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
                ),
              )),
              Icon(Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFFBFBFBF))
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text('Limit Refresh',
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFBFBFBF))),
          ),
        )
      ],
    );
  }

  Widget mutationSaveButton() {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Mutation(
            options: MutationOptions(
              document: gql(mutationFinanceAccountLimit),
              update: (GraphQLDataProxy cache, QueryResult? result) {
                return cache;
              },
              onCompleted: (resultData) {
                setState(() {
                  isLoading = false;
                });
                resultData['updateFinanceAccountLimit']
                    ? showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: wScale(40)),
                              child: Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.0)),
                                  child: CustomResultModal(
                                      status: true,
                                      title: "Request sent successfully",
                                      message:
                                          "Your request has been sent. You will receive a confirmation e-mail shortly.")));
                        })
                    : showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: wScale(40)),
                              child: Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.0)),
                                  child: CustomResultModal(
                                      status: true,
                                      title: "Request sent faild",
                                      message: "")));
                        });
                print(resultData);
              },
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              return saveButton(runMutation);
            }));
  }

  Widget buttonField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [backButton(), mutationSaveButton()],
    );
  }

  Widget backButton() {
    return Container(
        width: wScale(156),
        height: hScale(56),
        margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xffc9c9c9).withOpacity(0.1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Back",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget saveButton(runMutation) {
    return Container(
        width: wScale(156),
        height: hScale(56),
        margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            handleSave(runMutation);
          },
          child: Text("Save",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }
}

import 'package:co/ui/main/home/receipt_screen.dart';
import 'package:co/ui/widgets/custom_result_modal.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:timezone/standalone.dart' as tz;

class ReceiptRemarks extends StatefulWidget {
  final data;
  final sourceTransactionId;
  final accountID;
  final transactionID;
  const ReceiptRemarks(
      {Key? key,
      this.data,
      this.sourceTransactionId,
      this.accountID,
      this.transactionID})
      : super(key: key);

  @override
  ReceiptRemarksState createState() => ReceiptRemarksState();
}

class ReceiptRemarksState extends State<ReceiptRemarks> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  bool showAddRemark = false;
  bool isRemarkable = false;

  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String addRemarksMutation = FXRMutations.MUTATION_ADD_REMARK;

  TextEditingController remarkCtl = TextEditingController();

  convertLocalToDetroit(_date) {
    final detroit = tz.getLocation(userStorage.getItem("org_timezone"));
    final localizedDt =
        tz.TZDateTime.from(DateTime.fromMillisecondsSinceEpoch(_date), detroit);
    var date = DateFormat.yMMMd().format(localizedDt).split(' ')[1].substring(
        0, DateFormat.yMMMd().format(localizedDt).split(' ')[1].length - 1);
    var month = DateFormat.yMMMd().format(localizedDt).split(' ')[0];
    var year = DateFormat.yMMMd().format(localizedDt).split(' ')[2];
    var time = DateFormat('hh:mm a').format(localizedDt);
    return '${date.length == 1 ? "0$date" : date} $month $year | $time';
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // widget.data.length == 0 ? showAddRemark ? addRemarkField() : emptyRemarkField() : remarkField()
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: widget.data.length == 0
            ? showAddRemark
                ? addRemarkField()
                : emptyRemarkField()
            : remarkField());
  }

  Widget emptyRemarkField() {
    return Column(children: [
      const CustomSpacer(size: 46),
      Text('No Remarks!',
          style: TextStyle(
              fontSize: fSize(12),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF70828D))),
      const CustomSpacer(size: 400),
      addRemarkButton()
    ]);
  }

  Widget remarkField() {
    return Column(
        children: widget.data.map<Widget>((item) {
      return remarkDetail(item['remarkUserName'],
          convertLocalToDetroit(item['remarkCreatedAt']), item['remark']);
    }).toList());
  }

  Widget remarkDetail(name, date, detail) {
    return Container(
        width: wScale(327),
        margin: EdgeInsets.only(top: hScale(15)),
        padding:
            EdgeInsets.symmetric(horizontal: wScale(18), vertical: hScale(26)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF106549).withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 10,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2831))),
            CustomSpacer(size: 6),
            Text(date,
                style: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF29C490))),
            CustomSpacer(size: 20),
            Text(detail,
                style: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF70828D))),
          ],
        ));
  }

  Widget addRemarkButton() {
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
            setState(() {
              showAddRemark = true;
            });
          },
          child: Text("Add Remarks",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget addRemarkField() {
    return Column(
      children: [
        CustomSpacer(size: 16),
        Column(
          children: <Widget>[
            Card(
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: remarkCtl,
                onChanged: (text) {
                  setState(() {
                    isRemarkable = text.length != 0;
                  });
                },
                maxLines: 8,
                decoration: InputDecoration.collapsed(
                    hintText: "Please enter your remarks"),
              ),
            ))
          ],
        ),
        isRemarkable
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    Row(children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          primary: const Color(0xffadd2c8),
                          textStyle: TextStyle(
                              fontSize: fSize(18),
                              color: const Color(0xffadd2c8),
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          setState(() {
                            remarkCtl.text = '';
                            isRemarkable = false;
                          });
                        },
                        child: Text("Cancel"),
                      ),
                      SizedBox(width: wScale(6)),
                      mutationSaveButton()
                    ]),
                    Text('${remarkCtl.text.length} / 200')
                  ])
            : SizedBox()
      ],
    );
  }

  Widget mutationSaveButton() {
    return Mutation(
        options: MutationOptions(
          document: gql(addRemarksMutation),
          update: (GraphQLDataProxy cache, QueryResult? result) {
            return cache;
          },
          onCompleted: (resultData) {
            resultData['addReceiptRemarks']['success'] == true
                ? _showResultModalDialog(context)
                : null;
          },
        ),
        builder: (RunMutation runMutation, QueryResult? result) {
          return TextButton(
            style: TextButton.styleFrom(
              primary: const Color(0xff30e7a9),
              textStyle: TextStyle(
                  fontSize: fSize(18),
                  color: const Color(0xff30e7a9),
                  fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              runMutation({
                "ReceiptRemark": remarkCtl.text,
                "orgId": userStorage.getItem("orgId"),
                "sourceTxnId": widget.sourceTransactionId
              });
            },
            child: Text("Save"),
          );
        });
  }

  _showResultModalDialog(context) {
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
                    title: 'Remark Added',
                    message: 'You have successfully added a remark',
                    handleOKClick: () {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      Navigator.of(context).pushReplacement(CupertinoPageRoute(
                          builder: (context) => ReceiptScreen(
                              accountID: widget.accountID,
                              transactionID: widget.transactionID,
                              initTransactionType: 3)));
                    },
                  )));
        });
  }
}

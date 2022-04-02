import 'dart:io';

import 'package:co/utils/queries.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:flowder/flowder.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class BillingItem extends StatefulWidget {
  final index;
  final String statementDate;
  final String totalAmount;
  final String dueDate;
  final String status; // 0: unpaid, 1: overdue, 2: paid
  final String download;
  const BillingItem(
      {Key? key,
      this.index,
      this.statementDate = '30 Jan 2021',
      this.totalAmount = '0.00',
      this.dueDate = '05 Mar 2021',
      this.status = '',
      this.download = ""})
      : super(key: key);
  @override
  BillingItemState createState() => BillingItemState();
}

class BillingItemState extends State<BillingItem> {
  get downloadPath => null;

  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  bool isLoading = false;
  late DownloaderUtils options;
  late DownloaderCore core;
  late final String path;
  double progress = 0.0;

  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String billDownloadQuery = Queries.QUERY_BILL_DOWNLOAD;
  String documentLink = '';

  handleDownload() async {
    final Directory? download = await getApplicationDocumentsDirectory();
    final String downloadPath = download!.path + "/FXCII_${widget.index}.pdf'";
    await _fetchData();
    isLoading ? null : downloadFile(documentLink, downloadPath);
  }

  Future<void> downloadFile(documentLink, downloadPath) async {
    try {
      Dio dio = Dio();
      await dio.download(documentLink, downloadPath,
          onReceiveProgress: (current, total) {
        setState(() {
          progress = (current / total) * 100;
          setState(() {
            progress = (current / total);
          });
        });
      });
      OpenFile.open(downloadPath).then((value) {});
    } catch (error) {
      print("===== Error : Dio File Download =====");
      print(error);
      await Sentry.captureException(error);
      return null;
    }
  }

  Future<void> _fetchData() async {
    isLoading = true;
    var accessToken = storage.getItem("jwt_token");
    final HttpLink httpLink =
        HttpLink("https://gql.staging.fxr.one/v1/graphql");

    final AuthLink authLink = AuthLink(getToken: () async => "$accessToken");
    final Link link = authLink.concat(httpLink);
    final client = GraphQLClient(cache: GraphQLCache(), link: link);

    final downloadVars = {"fileId": widget.download};

    final downloadOption =
        QueryOptions(document: gql(billDownloadQuery), variables: downloadVars);
    final downloadResult = await client.query(downloadOption);

    setState(() {
      documentLink = downloadResult.data?['downloadBillStatement'] ?? '';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var statement_month,
        statement_date,
        statement_year,
        due_month,
        due_date,
        due_year;
    if (widget.statementDate != "N/A") {
      statement_month = widget.statementDate.split(" ")[0];
      statement_date = widget.statementDate
          .split(" ")[1]
          .substring(0, widget.statementDate.split(" ")[1].length - 1);
      statement_year = widget.statementDate.split(" ")[2];
      statement_date =
          statement_date.length == 1 ? "0$statement_date" : statement_date;
    }

    if (widget.dueDate != "N/A") {
      due_month = widget.dueDate.split(" ")[0];
      due_date = widget.dueDate
          .split(" ")[1]
          .substring(0, widget.dueDate.split(" ")[1].length - 1);
      due_year = widget.dueDate.split(" ")[2];
      due_date = due_date.length == 1 ? "0$due_date" : due_date;
    }

    return Container(
      width: wScale(327),
      // padding: EdgeInsets.only(left: wScale(16), right: wScale(16), top: hScale(16), bottom: hScale(16)),
      margin: EdgeInsets.only(bottom: hScale(16)),
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
            color: Color(0xFF106549).withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(children: [
        detailField(
            'Statement Date',
            widget.statementDate == "N/A"
                ? "N/A"
                : "$statement_date $statement_month $statement_year",
            const Color(0xFF1A2831)),
        Container(height: 1, color: const Color(0xFFF1F1F1)),
        amountDetailField(
            'Total Amount',
            widget.totalAmount,
            widget.status == "PAID" || widget.status == "UNPAID"
                ? const Color(0xFF1A2831)
                : const Color(0xFFEB5757)),
        Container(height: 1, color: const Color(0xFFF1F1F1)),
        detailField(
            'Due Date',
            widget.dueDate == "N/A" ? "N/A" : "$due_date $due_month $due_year",
            widget.status == "PAID" || widget.status == "UNPAID"
                ? const Color(0xFF1A2831)
                : const Color(0xFFEB5757)),
        Container(height: 1, color: const Color(0xFFF1F1F1)),
        statusField(widget.status),
        Container(height: 1, color: const Color(0xFFF1F1F1)),
        downloadField()
      ]),
    );
  }

  Widget detailField(title, value, valueColor) {
    return Container(
      height: hScale(35),
      padding: EdgeInsets.symmetric(horizontal: wScale(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: fSize(12),
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF70828D),
                  height: 1.7)),
          Text(
            value,
            style: TextStyle(
                fontSize: fSize(12),
                fontWeight: FontWeight.w500,
                color: valueColor),
          )
        ],
      ),
    );
  }

  Widget amountDetailField(title, value, valueColor) {
    return Container(
      padding:
          EdgeInsets.symmetric(vertical: hScale(6), horizontal: wScale(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: fSize(12),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF70828D),
                  height: 1.7)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SGD ',
                  style: TextStyle(
                      fontSize: fSize(8),
                      fontWeight: FontWeight.w500,
                      color: valueColor,
                      height: 1)),
              Text(value,
                  style: TextStyle(
                      fontSize: fSize(12),
                      fontWeight: FontWeight.w500,
                      height: 1,
                      color: valueColor))
            ],
          )
        ],
      ),
    );
  }

  Widget statusField(status) {
    return Container(
      height: hScale(35),
      padding: EdgeInsets.symmetric(horizontal: wScale(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Status',
              style: TextStyle(
                  fontSize: fSize(12),
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF70828D))),
          Container(
            padding: EdgeInsets.symmetric(
                vertical: hScale(4), horizontal: wScale(11)),
            // color: status == 0 ? const Color(0xFFC9E8FB) : status == 1 ? const Color(0xFFFFDFD4): const Color(0xFFE1FFEF),
            decoration: BoxDecoration(
              color: status == "PAID"
                  ? const Color(0xFFE1FFEF)
                  : status == "UNPAID"
                      ? const Color(0xFFC9E8FB)
                      : const Color(0xFFFFDFD4),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(hScale(100)),
                topRight: Radius.circular(hScale(100)),
                bottomLeft: Radius.circular(hScale(100)),
                bottomRight: Radius.circular(hScale(100)),
              ),
            ),
            child: Text(
              status == "UNPAID"
                  ? 'Unpaid'
                  : status == "PAID"
                      ? 'Paid'
                      : 'Overdue',
              style: TextStyle(
                fontSize: fSize(12),
                fontWeight: FontWeight.w500,
                color: status == 'PAID'
                    ? const Color(0xFF2ED47A)
                    : status == "UNPAID"
                        ? const Color(0xFF0C649A)
                        : const Color(0xFFEB5757),
              ),
            ),
          )
          // Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,color: valueColor),)
        ],
      ),
    );
  }

  Widget downloadField() {
    return isLoading
        ? Container(
            padding: EdgeInsets.symmetric(vertical: hScale(10)),
            alignment: Alignment.center,
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF60C094))))
        : Container(
            height: hScale(35),
            child: TextButton(
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/paper_download.png',
                            fit: BoxFit.cover, width: wScale(10)),
                        SizedBox(width: wScale(8)),
                        Text('Statement Download',
                            style: TextStyle(
                                fontSize: fSize(12),
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1DA7FF))),
                      ],
                    ),
                    Positioned(
                      right: wScale(20),
                      child: Text(progress == 0
                          ? ""
                          : '${(progress * 100).toStringAsFixed(0)} %', style: TextStyle(
                                fontSize: fSize(12),
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1DA7FF))),
                    )
                  ],
                ),
                onPressed: () {
                  handleDownload();
                }));
  }
}

import 'dart:io';

import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:dio/dio.dart';
import 'package:flowder/flowder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CreditDirectDebitScreen extends StatefulWidget {
  final data;
  const CreditDirectDebitScreen({Key? key, this.data}) : super(key: key);

  @override
  CreditDirectDebitScreenState createState() => CreditDirectDebitScreenState();
}

class CreditDirectDebitScreenState extends State<CreditDirectDebitScreen> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  late DownloaderUtils options;
  late DownloaderCore core;
  late final String path;
  double progress = 0.0;

  handleDownload(type) async {
    final Directory? download = await getApplicationDocumentsDirectory();
    final String downloadPath1 = download!.path + "/DDA.docx'";
    final String downloadPath2 = download.path + "/DDA.pdf'";

    downloadFile(
        type == 0
            ? 'https://app.staging.fxr.one/flex/static/media/DDA.c359397a.docx'
            : 'https://app.staging.fxr.one/flex/static/media/DDA.00f8db8e.pdf',
        type == 0 ? downloadPath1 : downloadPath2);
  }

  Future<void> downloadFile(documentLink, docPath) async {
    try {
      Dio dio = Dio();
      await dio.download(documentLink, docPath,
          onReceiveProgress: (current, total) {
        setState(() {
          progress = (current / total) * 100;
          setState(() {
            progress = (current / total);
          });
        });
      });
      OpenFile.open(docPath).then((value) {});
    } catch (error) {
      print("===== Error : File Download  =====");
      print("===== Function : dio.download =====");
      print(error);
      await Sentry.captureException(error);
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Stack(children: [
      SizedBox(
          height: hScale(812),
          child: SingleChildScrollView(
              child: Column(children: [
            const CustomSpacer(size: 44),
            const CustomMainHeader(title: 'Flex PLUS Credit'),
            const CustomSpacer(size: 21),
            titleField(),
            const CustomSpacer(size: 29),
            depositFundsField(),
            const CustomSpacer(size: 88),
          ]))),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 3),
      )
    ])));
  }

  Widget titleField() {
    return Container(
      width: wScale(327),
      alignment: Alignment.centerLeft,
      child: Text('Flex PLUS Account ${widget.data['creditLine']['name']}',
          style: TextStyle(
              fontSize: fSize(16),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2831))),
    );
  }

  Widget depositFundsField() {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(
          left: wScale(16),
          right: wScale(16),
          top: hScale(16),
          bottom: hScale(16)),
      margin: EdgeInsets.only(bottom: hScale(10)),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('To help you make timely payments, download the DDA form',
              style: TextStyle(
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A2831))),
          const CustomSpacer(size: 42),
          Row(children: [
            Text('Download as:',
                style: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A2831))),
            SizedBox(width: wScale(24)),
            downloadType('assets/word.png', 0),
            SizedBox(width: wScale(15)),
            downloadType('assets/pdf.png', 1),
          ]),
          const CustomSpacer(size: 42),
          Text('Please mail the filled form to the following address:',
              style: TextStyle(
                  fontSize: fSize(14),
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A2831))),
          const CustomSpacer(size: 10),
          Text('FXR Business Services Pte. Ltd.',
              style: TextStyle(fontSize: fSize(14), color: Color(0xFF1A2831))),
          const CustomSpacer(size: 10),
          Text('230 Victoria Street, #15-01/08',
              style: TextStyle(fontSize: fSize(14), color: Color(0xFF1A2831))),
          const CustomSpacer(size: 10),
          Text('Bugis Junction Tower',
              style: TextStyle(fontSize: fSize(14), color: Color(0xFF1A2831))),
          const CustomSpacer(size: 10),
          Text('Singapore 188024',
              style: TextStyle(fontSize: fSize(14), color: Color(0xFF1A2831))),
          const CustomSpacer(size: 20),
          progress == 0.0
              ? SizedBox(height: 14)
              : Row(
                  children: [
                    Text('${(progress * 100).toStringAsFixed(0)} %'),
                    LinearPercentIndicator(
                      width: wScale(250),
                      lineHeight: 14.0,
                      percent: progress,
                      backgroundColor: Colors.white,
                      progressColor: Colors.blue,
                    ),
                  ],
                )
        ],
      ),
    );
  }

  Widget title(text) {
    return Text(text,
        style: TextStyle(color: const Color(0xff70828D), fontSize: fSize(12)));
  }

  Widget detail(text) {
    return Text(text,
        style: TextStyle(
            color: const Color(0xff040415),
            fontSize: fSize(14),
            fontWeight: FontWeight.w500));
  }

  Widget downloadType(imageURL, type) {
    return Container(
      width: hScale(34),
      height: hScale(34),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE7EFF0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(hScale(6)),
          topRight: Radius.circular(hScale(6)),
          bottomLeft: Radius.circular(hScale(6)),
          bottomRight: Radius.circular(hScale(6)),
        ),
      ),
      child: TextButton(
          style: TextButton.styleFrom(
            // primary: const Color(0xffF5F5F5).withOpacity(0.4),
            padding: const EdgeInsets.all(0),
          ),
          onPressed: () {
            handleDownload(type);
          },
          child: Image.asset(imageURL, fit: BoxFit.contain, width: hScale(18))),
    );
  }
}

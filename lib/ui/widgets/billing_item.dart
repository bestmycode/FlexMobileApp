import 'dart:io';

import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:flowder/flowder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class BillingItem extends StatefulWidget {
  final index;
  final String statementDate;
  final String totalAmount;
  final String dueDate;
  final String status; // 0: unpaid, 1: overdue, 2: paid
  final String documentLink;
  const BillingItem(
      {Key? key,
      this.index,
      this.statementDate = '30 Jan 2021',
      this.totalAmount = '0.00',
      this.dueDate = '05 Mar 2021',
      this.status = '',
      this.documentLink = ""})
      : super(key: key);
  @override
  BillingItemState createState() => BillingItemState();
}

class BillingItemState extends State<BillingItem> {
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

  handleDownload() async {
    /*
    final Directory? download = Platform.isAndroid
        ? Directory('/storage/emulated/0/Download')
        : await getApplicationDocumentsDirectory();
    */
    final Directory? download = await getApplicationDocumentsDirectory();
    final String downloadPath = download!.path;
    String path = "${downloadPath}/FXCII_${widget.index}.pdf";
    options = DownloaderUtils(
      progressCallback: (current, total) {
        progress = (current / total) * 100;

        setState(() {
          progress = (current / total);
        });
      },
      file: File(path),
      progress: ProgressImplementation(),
      onDone: () {
        setState(() {
          progress = 0.0;
        });
        OpenFile.open(path).then((value) {});
      },
      deleteOnCancel: true,
    );
    core = await Flowder.download(widget.documentLink, options);
  }

  @override
  Widget build(BuildContext context) {
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
            color: Colors.grey.withOpacity(0.25),
            spreadRadius: 4,
            blurRadius: 20,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(children: [
        detailField(
            'Statement Date', widget.statementDate, const Color(0xFF1A2831)),
        Container(height: 1, color: const Color(0xFFF1F1F1)),
        amountDetailField(
            'Total Amount',
            widget.totalAmount,
            widget.status != "PAID"
                ? const Color(0xFFEB5757)
                : const Color(0xFF1A2831)),
        Container(height: 1, color: const Color(0xFFF1F1F1)),
        detailField(
            'Due Date',
            widget.dueDate,
            widget.status != "PAID"
                ? const Color(0xFFEB5757)
                : const Color(0xFF1A2831)),
        Container(height: 1, color: const Color(0xFFF1F1F1)),
        statusField(widget.status),
        Container(height: 1, color: const Color(0xFFF1F1F1)),
        widget.documentLink != '' ? downloadField() : SizedBox()
      ]),
    );
  }

  Widget detailField(title, value, valueColor) {
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
                      fontSize: fSize(12),
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
      padding:
          EdgeInsets.symmetric(vertical: hScale(6), horizontal: wScale(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Status',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF70828D))),
          Container(
            padding: EdgeInsets.symmetric(
                vertical: hScale(4), horizontal: wScale(11)),
            // color: status == 0 ? const Color(0xFFC9E8FB) : status == 1 ? const Color(0xFFFFDFD4): const Color(0xFFE1FFEF),
            decoration: BoxDecoration(
              color: status == "PAID"
                  ? const Color(0xFFC9E8FB)
                  : status == "UNPAID"
                      ? const Color(0xFFFFDFD4)
                      : const Color(0xFFE1FFEF),
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
                    ? const Color(0xFF2F7BFA)
                    : status == "UNPAID"
                        ? const Color(0xFFEB5757)
                        : const Color(0xFF2ED47A),
              ),
            ),
          )
          // Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,color: valueColor),)
        ],
      ),
    );
  }

  Widget downloadField() {
    return TextButton(
        child: Stack(
          children: [
            Container(
                padding: EdgeInsets.symmetric(vertical: hScale(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/paper_download.png',
                        fit: BoxFit.cover, width: wScale(10)),
                    SizedBox(width: wScale(8)),
                    const Text('Statement Download',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1DA7FF))),
                  ],
                )),
            Positioned(
              top: hScale(5),
              right: wScale(20),
              child: Text(progress == 0
                  ? ""
                  : '${(progress * 100).toStringAsFixed(0)} %'),
            )
          ],
        ),
        onPressed: () {
          handleDownload();
        });
  }
}

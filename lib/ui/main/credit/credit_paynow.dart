import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class CreditPayNowScreen extends StatefulWidget {
  final data;
  const CreditPayNowScreen({Key? key, this.data}) : super(key: key);

  @override
  CreditPayNowScreenState createState() => CreditPayNowScreenState();
}

class CreditPayNowScreenState extends State<CreditPayNowScreen> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  bool flagCopied = false;
  bool isScan = false;
  Barcode? result;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  handleScanToPay() {
    setState(() {
      isScan = true;
    });
    // Navigator.of(context).push(
    //   CupertinoPageRoute(builder: (context) => QRViewScreen()),
    // );
  }

  handleBack() {
    Navigator.of(context).pop();
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
          top: hScale(24),
          bottom: hScale(19)),
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
            color: Colors.grey.withOpacity(0.25),
            spreadRadius: 4,
            blurRadius: 20,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset('assets/paynow.png',
              fit: BoxFit.contain, width: wScale(71)),
          CustomSpacer(size: 18),
          isScan
              ? Image.asset('assets/qr_code.png',
                  fit: BoxFit.contain, width: wScale(320))
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xff1A2831),
                    side: const BorderSide(width: 0, color: Color(0xff1A2831)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    handleScanToPay();
                  },
                  child: SizedBox(
                      width: wScale(295),
                      height: hScale(56),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/scan.png',
                              fit: BoxFit.contain, width: wScale(21)),
                          SizedBox(width: wScale(18)),
                          Text('Scan to Pay',
                              style: TextStyle(
                                  fontSize: fSize(16),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white))
                        ],
                      )))
        ],
      ),
    );
  }

  Widget paymentOptionField(title, event) {
    return TextButton(
        style: TextButton.styleFrom(
          primary: const Color(0xFFF8FAF9),
          padding: const EdgeInsets.all(0),
        ),
        onPressed: event,
        child: Container(
            padding: EdgeInsets.all(hScale(20)),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(hScale(10)),
                topRight: Radius.circular(hScale(10)),
                bottomLeft: Radius.circular(hScale(10)),
                bottomRight: Radius.circular(hScale(10)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(children: [
                  SizedBox(
                      width: hScale(22),
                      child: Image.asset('assets/green_card.png',
                          fit: BoxFit.contain, width: wScale(21))),
                  SizedBox(width: wScale(18)),
                  Text(title,
                      style: TextStyle(
                          fontSize: fSize(12), color: const Color(0xff465158))),
                ]),
                const Icon(Icons.arrow_forward_rounded,
                    color: Color(0xff70828D), size: 24.0),
              ],
            )));
  }
}

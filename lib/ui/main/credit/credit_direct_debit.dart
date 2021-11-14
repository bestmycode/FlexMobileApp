import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/ui/widgets/custom_header.dart';
import 'package:flexflutter/ui/widgets/signup_progress_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';
import 'package:flexflutter/ui/widgets/custom_textfield.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';

class CreditDirectDebitScreen extends StatefulWidget {
  const CreditDirectDebitScreen({Key? key}) : super(key: key);

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

  handleUpload() {

  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: SingleChildScrollView(
                child: Column(
                    children: [
                      const CustomSpacer(size: 44),
                      const CustomHeader(title: 'Flex PLUS Credit'),
                      const CustomSpacer(size: 21),
                      titleField(),
                      const CustomSpacer(size: 29),
                      depositFundsField(),
                      const CustomSpacer(size: 70),
                    ]
                )
            )
        )
    );
  }

  Widget titleField() {
    return Container(
      width: wScale(327),
      alignment: Alignment.centerLeft,
      child: Text('Flex PLUS Account 123456', style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w600, color: const Color(0xFF1A2831))),
    );
  }

  Widget depositFundsField() {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(left: wScale(16), right: wScale(16), top: hScale(16), bottom: hScale(16)),
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('To help you make timely payments, download the DDA form', style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w500, color: Color(0xFF1A2831))),
          const CustomSpacer(size: 42),
          Row(
            children: [
              Text('Download as:', style:TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w500, color: const Color(0xFF1A2831))),
              SizedBox(width: wScale(24)),
              downloadType('assets/excel.png'),
              SizedBox(width: wScale(15)),
              downloadType('assets/pdf.png'),
            ]
          ),
          const CustomSpacer(size: 36),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: const Color(0xff1A2831),
                side: const BorderSide(width: 0, color: Color(0xff1A2831)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)
                ),
              ),
              onPressed: () { handleUpload(); },
              child: SizedBox(
                  width: wScale(295),
                  height: hScale(56),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Upload DDA', style:TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w700, color: Colors.white))
                    ],
                  )
              )
          )
        ],
      ),
    );
  }

  Widget title(text) {
    return Text(text, style:TextStyle(color: const Color(0xff70828D), fontSize: fSize(12)));
  }

  Widget detail(text) {
    return Text(text, style:TextStyle(color: const Color(0xff040415), fontSize: fSize(14), fontWeight: FontWeight.w500));
  }

  Widget downloadType(imageURL) {
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
      child: Image.asset(imageURL, fit: BoxFit.contain, width: hScale(18)),
    );
  }

}
import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class ViewLimits extends StatefulWidget {
  // final CupertinoTabController controller;
  // final GlobalKey<NavigatorState> navigatorKey;

  // const PhysicalCards({Key? key, required this.controller, required this.navigatorKey}) : super(key: key);

  const ViewLimits({Key? key}) : super(key: key);
  @override
  ViewLimitsState createState() => ViewLimitsState();
}

class ViewLimitsState extends State<ViewLimits> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final monthlyLimitCtl = TextEditingController();
  final transactionLimitCtl = TextEditingController(text: 'SGD 1000.00');
  final varianceLimitCtl = TextEditingController(text: '30%');
  final remarksCtl = TextEditingController(
      text:
          'I think we need to lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do usmod tempor incididunt?');

  bool isSwitchedMerchant = true;
  bool isSwitchedTransactionLimit = true;
  var isSwitchedArr = [
    false,
    false,
    true,
    false,
    false,
    true,
    false,
    false,
    true,
    false
  ];
  double transactionLimitValue = 1.0;
  double varianceLimitValue = 0;

  handleCloneSetting() {}

  handleSwitch(index, v) {
    setState(() {
      isSwitchedArr[index] = v;
    });
  }

  handleSave() {}

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Stack(children: [
      SingleChildScrollView(
          child: Column(children: [
        const CustomSpacer(size: 44),
        const CustomMainHeader(title: 'View Limits'),
        const CustomSpacer(size: 38),
        monthlyLimitField(),
        const CustomSpacer(size: 20),
        additionalField(),
        const CustomSpacer(size: 26),
        const CustomSpacer(size: 88),
      ])),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 1),
      )
    ])));
  }

  Widget monthlyLimitField() {
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
          Text('Monthly Spend Limit',
              style: TextStyle(
                  fontSize: fSize(12),
                  color: const Color(0xFF040415).withOpacity(0.4))),
          const CustomSpacer(size: 8),
          Text('SGD 1,000',
              style: TextStyle(
                  fontSize: fSize(14),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF040415))),
        ],
      ),
    );
  }

  Widget additionalField() {
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
          Text('Additional Spend Control',
              style: TextStyle(
                  fontSize: fSize(16),
                  height: 1.8,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A2831))),
          Opacity(
              opacity: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomSpacer(size: 14),
                  Text('Merchant Category Blocking',
                      style: TextStyle(
                          fontSize: fSize(14),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A2831))),
                  const CustomSpacer(size: 20),
                  additionalSpendControl(
                      'assets/air_lines.png', 'Airlines', 1.0),
                  const CustomSpacer(size: 20),
                  additionalSpendControl(
                      'assets/car_rental.png', 'Car Rental', 1.0),
                  const CustomSpacer(size: 20),
                  additionalSpendControl(
                      'assets/transportation.png', 'Transportation', 1.0),
                  const CustomSpacer(size: 20),
                  additionalSpendControl('assets/hotels.png', 'Hotels', 1.0),
                  const CustomSpacer(size: 20),
                  additionalSpendControl('assets/petrol.png', 'Petrol', 1.0),
                  const CustomSpacer(size: 32),
                  Text('Merchant Categories Not Allowed',
                      style: TextStyle(
                          fontSize: fSize(14), color: const Color(0xFFEB5757))),
                  const CustomSpacer(size: 20),
                  additionalSpendControl(
                      'assets/department_stores.png', 'Department Stores', 0.4),
                  const CustomSpacer(size: 20),
                  additionalSpendControl('assets/parking.png', 'Parking', 0.4),
                  const CustomSpacer(size: 20),
                  additionalSpendControl(
                      'assets/fandb.png', 'F&B (Restaurants & Groceries)', 0.4),
                  const CustomSpacer(size: 20),
                  additionalSpendControl('assets/taxis.png', 'Taxis', 0.4),
                  const CustomSpacer(size: 20),
                  additionalSpendControl('assets/others.png', 'Others', 0.4),
                  const CustomSpacer(size: 34),
                  Text('Transaction Limit',
                      style: TextStyle(
                          fontSize: fSize(12),
                          color: const Color(0xFF040415).withOpacity(0.4))),
                  const CustomSpacer(size: 8),
                  Text('SGD 1,000.00',
                      style: TextStyle(
                          fontSize: fSize(14),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF040415))),
                  const CustomSpacer(size: 17),
                  Text('Variance Limit',
                      style: TextStyle(
                          fontSize: fSize(12),
                          color: const Color(0xFF040415).withOpacity(0.4))),
                  const CustomSpacer(size: 8),
                  Text('30%',
                      style: TextStyle(
                          fontSize: fSize(14),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF040415))),
                ],
              )),
        ],
      ),
    );
  }

  Widget additionalSpendControl(image, title, opacity) {
    return Opacity(
        opacity: opacity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(image, width: hScale(16), fit: BoxFit.contain),
            SizedBox(width: wScale(9)),
            Text(title,
                style: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A2831)))
          ],
        ));
  }
}

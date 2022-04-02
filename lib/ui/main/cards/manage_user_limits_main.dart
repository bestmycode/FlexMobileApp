import 'package:co/ui/widgets/custom_bottom_bar.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class ManageUserLimitsMain extends StatefulWidget {
  final data;
  final financeAccount;
  const ManageUserLimitsMain({Key? key, this.data, this.financeAccount})
      : super(key: key);
  @override
  ManageUserLimitsMainState createState() => ManageUserLimitsMainState();
}

class ManageUserLimitsMainState extends State<ManageUserLimitsMain> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  bool showTransactionHint = false;
  bool showVarianceHint = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Stack(children: [
      Container(
          height: hScale(812),
          child: SingleChildScrollView(
            child: Column(children: [
              const CustomSpacer(size: 44),
              const CustomMainHeader(title: 'View Limits'),
              const CustomSpacer(size: 38),
              Column(
                children: [
                  cardDetailField(widget.data),
                  const CustomSpacer(size: 20),
                  additionalSpendControl(widget.financeAccount),
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
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A2831))),
          const CustomSpacer(size: 22),
          Text(
              data == null
                  ? ''
                  : "${data['currencyCode']} ${data['financeAccountLimits'][0]['availableLimit']}",
              style: TextStyle(
                  fontSize: fSize(22),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A2831))),
          const CustomSpacer(size: 15),
        ],
      ),
    );
  }

  Widget additionalSpendControl(financeAccount) {
    List isSwitchedArr = [];
    financeAccount['spendControlLimits']['allowedCategories'].forEach((item) {
      isSwitchedArr.add(item['isAllowed']);
    });
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
          merchantCategoryField(isSwitchedArr),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Text('Transaction Limit',
                        style: TextStyle(
                            fontSize: fSize(14),
                            color: const Color(0xFF1A2831))),
                    SizedBox(width: wScale(6)),
                    !showTransactionHint
                        ? Container(
                            height: hScale(16),
                            width: hScale(16),
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Image.asset('assets/info.png',
                                  fit: BoxFit.contain, height: hScale(16)),
                              iconSize: hScale(16),
                              onPressed: () {
                                setState(() {
                                  showTransactionHint = !showTransactionHint;
                                });
                              },
                            ))
                        : SizedBox(),
                  ]),
                ],
              ),
              const CustomSpacer(size: 10),
              showTransactionHint
                  ? Container(
                      width: wScale(300),
                      child: Text(
                          'This amount is the maximum value you can charge for every transaction.',
                          style: TextStyle(
                              fontSize: fSize(12),
                              color: const Color(0xFF1A2831).withOpacity(0.8))))
                  : SizedBox(),
              const CustomSpacer(size: 18),
              Text(
                  financeAccount['spendControlLimits']['transactionLimit'] ==
                          null
                      ? "N/A"
                      : "${widget.data['currencyCode']} ${financeAccount['spendControlLimits']['transactionLimit']}",
                  style: TextStyle(
                      fontSize: fSize(22),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A2831))),
              const CustomSpacer(size: 30),
              Row(children: [
                Text('Variance Limit',
                    style: TextStyle(
                        fontSize: fSize(14), color: const Color(0xFF1A2831))),
                SizedBox(width: wScale(6)),
                !showVarianceHint
                    ? Container(
                        height: hScale(16),
                        width: hScale(16),
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          icon: Image.asset('assets/info.png',
                              fit: BoxFit.contain, height: hScale(16)),
                          iconSize: hScale(16),
                          onPressed: () {
                            setState(() {
                              showVarianceHint = !showVarianceHint;
                            });
                          },
                        ))
                    : SizedBox(),
              ]),
              const CustomSpacer(size: 10),
              showVarianceHint
                  ? Container(
                      width: wScale(300),
                      child: Text(
                          'This is the allowed percentage you can exceed beyond the set transaction value.',
                          style: TextStyle(
                              fontSize: fSize(12),
                              color: const Color(0xFF1A2831).withOpacity(0.8))))
                  : SizedBox(),
              const CustomSpacer(size: 18),
              Text(
                  financeAccount['spendControlLimits']['variancePercentage'] ==
                          null
                      ? "N/A"
                      : "${financeAccount['spendControlLimits']['variancePercentage']}%",
                  style: TextStyle(
                      fontSize: fSize(22),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A2831))),
              const CustomSpacer(size: 20),
            ],
          )
        ],
      ),
    );
  }

  Widget merchantCategoryField(arr) {
    var isSwitchedArr = arr.length == 0
        ? [
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
          ]
        : arr;
    return Column(
      children: [
        const CustomSpacer(size: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Merchant Category Allowed',
                style: TextStyle(
                    fontSize: fSize(14), color: const Color(0xFF1A2831))),
          ],
        ),
        CustomSpacer(size: 24),
        isSwitchedArr[0]
            ? customMerchant('assets/air_lines.png', 'Airlines')
            : SizedBox(),
        CustomSpacer(size: isSwitchedArr[0] ? 20 : 0),
        isSwitchedArr[1]
            ? customMerchant('assets/car_rental.png', 'Car Rental')
            : SizedBox(),
        CustomSpacer(size: isSwitchedArr[1] ? 20 : 0),
        isSwitchedArr[2]
            ? customMerchant('assets/transportation.png', 'Transportation')
            : SizedBox(),
        CustomSpacer(size: isSwitchedArr[2] ? 20 : 0),
        isSwitchedArr[3]
            ? customMerchant('assets/hotels.png', 'Hotels')
            : SizedBox(),
        CustomSpacer(size: isSwitchedArr[3] ? 20 : 0),
        isSwitchedArr[4]
            ? customMerchant('assets/petrol.png', 'Petrol')
            : SizedBox(),
        CustomSpacer(size: isSwitchedArr[4] ? 20 : 0),
        isSwitchedArr[5]
            ? customMerchant(
                'assets/department_stores.png', 'Department Stores')
            : SizedBox(),
        CustomSpacer(size: isSwitchedArr[5] ? 20 : 0),
        isSwitchedArr[6]
            ? customMerchant('assets/parking.png', 'Parking')
            : SizedBox(),
        CustomSpacer(size: isSwitchedArr[6] ? 20 : 0),
        isSwitchedArr[7]
            ? customMerchant(
                'assets/fandb.png', 'F&B (Restaurants & Groceries)')
            : SizedBox(),
        CustomSpacer(size: isSwitchedArr[7] ? 20 : 0),
        isSwitchedArr[8]
            ? customMerchant('assets/taxis.png', 'Taxis')
            : SizedBox(),
        CustomSpacer(size: isSwitchedArr[8] ? 20 : 0),
        isSwitchedArr[9]
            ? customMerchant('assets/others.png', 'Others')
            : SizedBox(),
        CustomSpacer(size: isSwitchedArr[9] ? 34 : 0),
      ],
    );
  }

  Widget customMerchant(image, title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(image, width: hScale(16), fit: BoxFit.contain),
        SizedBox(width: wScale(9)),
        Container(
            width: wScale(250),
            child: Text(title,
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A2831))))
      ],
    );
  }
}

import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class ManageLimitsAdditional extends StatefulWidget {
  final data;
  final transactionLimitValue;
  final varianceLimitValue;
  final isSwitchedArr;
  // final handleSwitch;
  final setTransactionLimitValue;
  final setVarianceLimitValue;
  final isSwitchedTransactionLimit;
  const ManageLimitsAdditional({
    Key? key, 
    this.data,
    this.transactionLimitValue,
    this.varianceLimitValue,
    this.isSwitchedArr,
    // this.handleSwitch,
    this.setTransactionLimitValue,
    this.isSwitchedTransactionLimit,
    this.setVarianceLimitValue
    }) : super(key: key);
  @override
  ManageLimitsAdditionalState createState() => ManageLimitsAdditionalState();
}

class ManageLimitsAdditionalState extends State<ManageLimitsAdditional> {
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
  bool isSwitchedTransactionLimit = false;
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

  handleCloneSetting() {}

  handleSwitch(index, v) {
    setState(() {
      isSwitchedArr[index] = v;
    });
    // widget.handleSwitch(index, v);
  }

  handleSave() {}

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      List<bool> istempSwitchedArr = [];
      widget.data['allowedCategories'].forEach((item) {
        istempSwitchedArr.add(item['isAllowed']);
      });
      setState(() {
        isSwitchedArr = istempSwitchedArr;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Text('Additional Spend Control',
              style: TextStyle(
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A2831))),
          Opacity(
              opacity: isSwitchedMerchant ? 1 : 0.4,
              child: Column(
                children: [
                  const CustomSpacer(size: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Merchant Category Blocking',
                          style: TextStyle(
                              fontSize: fSize(14),
                              color: const Color(0xFF1A2831))),
                      SizedBox(
                        width: wScale(32),
                        height: hScale(18),
                        child: Transform.scale(
                          scale: 0.5,
                          child: CupertinoSwitch(
                            trackColor: const Color(0xFFDFDFDF),
                            activeColor: const Color(0xFF3BD8A3),
                            value: isSwitchedMerchant,
                            onChanged: (v) =>
                                setState(() => isSwitchedMerchant = v),
                          ),
                        ),
                      )
                    ],
                  ),
                  const CustomSpacer(size: 10),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                          fontSize: fSize(12),
                          color: const Color(0xFF70828D),
                          fontWeight: FontWeight.w400),
                      children: const [
                        TextSpan(
                            text:
                                'Select the categories where spending will be \n'),
                        TextSpan(
                            text: 'Blocked',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEB5757))),
                        TextSpan(
                            text:
                                '.  When making a purchase on unauthorized\ncategories, the transaction will be rejected. All\nspending categories are'),
                        TextSpan(
                            text: ' allowed',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3BD8A3))),
                        TextSpan(text: ' by default.'),
                      ],
                    ),
                  ),
                  const CustomSpacer(size: 24),
                  customSwitchControl(0, 'assets/air_lines.png', 'Airlines'),
                  const CustomSpacer(size: 20),
                  customSwitchControl(1, 'assets/car_rental.png', 'Car Rental'),
                  const CustomSpacer(size: 20),
                  customSwitchControl(
                      2, 'assets/transportation.png', 'Transportation'),
                  const CustomSpacer(size: 20),
                  customSwitchControl(3, 'assets/hotels.png', 'Hotels'),
                  const CustomSpacer(size: 20),
                  customSwitchControl(4, 'assets/petrol.png', 'Petrol'),
                  const CustomSpacer(size: 20),
                  customSwitchControl(
                      5, 'assets/department_stores.png', 'Department Stores'),
                  const CustomSpacer(size: 20),
                  customSwitchControl(6, 'assets/parking.png', 'Parking'),
                  const CustomSpacer(size: 20),
                  customSwitchControl(
                      7, 'assets/fandb.png', 'F&B (Restaurants & Groceries)'),
                  const CustomSpacer(size: 20),
                  customSwitchControl(8, 'assets/taxis.png', 'Taxis'),
                  const CustomSpacer(size: 20),
                  customSwitchControl(9, 'assets/others.png', 'Others'),
                  const CustomSpacer(size: 34),
                ],
              )),
          Opacity(
              opacity: isSwitchedTransactionLimit ? 1 : 0.4,
              child: Column(
                
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Transaction Limit',
                          style: TextStyle(
                              fontSize: fSize(14),
                              color: const Color(0xFF1A2831))),
                      SizedBox(
                        width: wScale(32),
                        height: hScale(18),
                        child: Transform.scale(
                          scale: 0.5,
                          child: CupertinoSwitch(
                            trackColor: const Color(0xFFDFDFDF),
                            activeColor: const Color(0xFF3BD8A3),
                            value: isSwitchedTransactionLimit,
                            onChanged: (v) =>
                                setState(() => isSwitchedTransactionLimit = v),
                          ),
                        ),
                      )
                    ],
                  ),
                  const CustomSpacer(size: 28),
                  readonlyTextFiled(transactionLimitCtl,
                      'Enter Transaction Limit', 'Transaction Limit'),
                  const CustomSpacer(size: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: hScale(12)),
                      overlayShape:
                          RoundSliderOverlayShape(overlayRadius: hScale(12)),
                    ),
                    child: Slider(
                      value: widget.transactionLimitValue,
                      min: 0.0,
                      max: 100.0,
                      divisions: 100,
                      activeColor: const Color(0xFF3BD8A3),
                      inactiveColor: const Color(0xFF1A2831).withOpacity(0.1),
                      onChanged: (double newValue) {
                        setState(() {
                          transactionLimitCtl.text =
                              'SGD ' + (newValue * 100).toStringAsFixed(2);
                        });
                        widget.setTransactionLimitValue(newValue);
                      },
                    ),
                  ),
                  const CustomSpacer(size: 24),
                  Text('Variance Limit',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: fSize(14), color: const Color(0xFF1A2831))),
                  const CustomSpacer(size: 28),
                  readonlyTextFiled(varianceLimitCtl, 'Enter Variance Limit',
                      'Variance Limit'),
                  const CustomSpacer(size: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: hScale(12)),
                      overlayShape:
                          RoundSliderOverlayShape(overlayRadius: hScale(12)),
                    ),
                    child: Slider(
                      value: widget.varianceLimitValue,
                      min: 0.0,
                      max: 100.0,
                      divisions: 100,
                      activeColor: const Color(0xFF3BD8A3),
                      inactiveColor: const Color(0xFF1A2831).withOpacity(0.1),
                      onChanged:  (double newValue) {
                        setState(() {
                          varianceLimitCtl.text = newValue.toString() + '%';
                        });
                        widget.setVarianceLimitValue(newValue);
                      },
                    ),
                  ),
                  const CustomSpacer(size: 20),
                ],
              ))
        ],
      ),
    );
  }

  Widget customSwitchControl(type, image, title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        customSwitch(type),
        SizedBox(width: wScale(20)),
        Image.asset(image, width: hScale(16), fit: BoxFit.contain),
        SizedBox(width: wScale(9)),
        Text(title,
            style: TextStyle(
                fontSize: fSize(16),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2831)))
      ],
    );
  }

  Widget customSwitch(index) {
    return SizedBox(
      width: wScale(26),
      height: hScale(15),
      child: Transform.scale(
        scale: 0.4,
        child: CupertinoSwitch(
            trackColor: const Color(0xFFEB5757),
            activeColor: const Color(0xFF3BD8A3),
            value: isSwitchedArr[index],
            onChanged: (v) => handleSwitch(index, v)),
      ),
    );
  }

  Widget readonlyTextFiled(ctl, hint, label) {
    return Container(
        width: wScale(295),
        height: hScale(56),
        alignment: Alignment.center,
        child: TextField(
          controller: ctl,
          readOnly: true,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: const Color(0xff040415).withOpacity(0.1),
                    width: 1.0)),
            hintText: hint,
            hintStyle: TextStyle(
                color: const Color(0xff040415).withOpacity(0.1),
                fontSize: fSize(14),
                fontWeight: FontWeight.w500),
            labelText: label,
            labelStyle: TextStyle(
                color: const Color(0xff040415).withOpacity(0.4),
                fontSize: fSize(14),
                fontWeight: FontWeight.w500),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff040415), width: 1.0)),
          ),
        ));
  }
}

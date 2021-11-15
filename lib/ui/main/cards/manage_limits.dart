import 'package:flexflutter/ui/main/cards/physical_my_card.dart';
import 'package:flexflutter/ui/main/cards/physical_team_card.dart';
import 'package:flexflutter/ui/widgets/custom_bottom_bar.dart';
import 'package:flexflutter/ui/widgets/custom_header.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flexflutter/ui/widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

class ManageLimits extends StatefulWidget {

  // final CupertinoTabController controller;
  // final GlobalKey<NavigatorState> navigatorKey;

  // const PhysicalCards({Key? key, required this.controller, required this.navigatorKey}) : super(key: key);

  const ManageLimits({Key? key}) : super(key: key);
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

  final monthlyLimitCtl = TextEditingController();
  final transactionLimitCtl = TextEditingController(text:'SGD 1000.00');
  final varianceLimitCtl = TextEditingController(text: '30%');
  final remarksCtl = TextEditingController(text: 'I think we need to lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do usmod tempor incididunt?');

  bool isSwitchedMerchant = true;
  bool isSwitchedTransactionLimit = true;
  var isSwitchedArr = [false, false, true, false, false, true, false, false, true, false];
  double transactionLimitValue = 10;
  double varianceLimitValue = 30;

  handleCloneSetting() {

  }

  handleSwitch(index, v) {
    setState(() {
      isSwitchedArr[index] = v;
    });
  }

  handleSave() {

  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Stack(
                children:[
                  SingleChildScrollView(
                      child: Column(
                          children: [
                            const CustomSpacer(size: 44),
                            const CustomHeader(title: 'Manage Limits'),
                            const CustomSpacer(size: 38),
                            cardDetailField(),
                            const CustomSpacer(size: 20),
                            additionalField(),
                            Opacity(
                              opacity: isSwitchedMerchant ? 1 : 0.4,
                              child: Column(
                                children: [
                                  const CustomSpacer(size: 20),
                                  remarksField(),
                                  const CustomSpacer(size: 30),
                                ],
                              )
                            ),
                            buttonField(),
                            const CustomSpacer(size: 24),
                            const CustomSpacer(size: 88),
                          ]
                      )
                  ),
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    child: CustomBottomBar(active: 1),
                  )
                ]
            )
        )
    );
  }

  Widget cardDetailField() {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(left: wScale(16), right: wScale(16), top: hScale(16), bottom: hScale(16)),
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
          CustomTextField(ctl: monthlyLimitCtl, hint: 'Enter Monthly Spend Limit', label: 'Monthly Spend Limit'),
          const CustomSpacer(size: 15),
          monthlyCardsList(),
        ],
      ),
    );
  }

  Widget cardTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Monthly Spend Limit', style:TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w600, color: const Color(0xFF1A2831))),
        TextButton(
          style: TextButton.styleFrom(
            primary: const Color(0xff60C094),
            padding: EdgeInsets.zero,
            textStyle: TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w600, color: const Color(0xff60C094), decoration: TextDecoration.underline),
          ),
          onPressed: () { handleCloneSetting(); },
          child: const Text('Clone Settings', style:TextStyle(decoration: TextDecoration.underline)),
        ),
      ],
    );
  }

  Widget monthlyCardsList() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(
            children: [
              monthlyCard('500'),
              monthlyCard('1000'),
              monthlyCard('5000'),
              monthlyCard('10000'),
            ]
        )
    );
  }

  Widget monthlyCard(value) {
    return Container(
      width: wScale(90),
      height: hScale(40),
      // padding: EdgeInsets.all(wScale(9)),
      margin: EdgeInsets.only(right: wScale(7)),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFDEFEE9),
        borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('SGD', style:TextStyle(fontSize: fSize(10), fontWeight: FontWeight.w600, color: const Color(0xFF30E7A9))),
          SizedBox(width: wScale(3)),
          Text(value, style:TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w600, color: const Color(0xFF30E7A9))),
        ],
      )
    );
  }

  Widget additionalField() {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(left: wScale(16), right: wScale(16), top: hScale(16), bottom: hScale(16)),
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
          Text('Additional Spend Control', style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w600, color: const Color(0xFF1A2831))),
          Opacity(
            opacity: isSwitchedMerchant ? 1 : 0.4,
            child: Column(
              children: [
                const CustomSpacer(size: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Merchant Category Blocking', style: TextStyle(fontSize: fSize(14), color: const Color(0xFF1A2831))),
                    SizedBox(
                      width: wScale(32),
                      height: hScale(18),
                      child: Transform.scale(
                        scale: 0.5,
                        child:CupertinoSwitch(
                          trackColor: const Color(0xFFDFDFDF),
                          activeColor: const Color(0xFF3BD8A3),
                          value: isSwitchedMerchant,
                          onChanged: (v) => setState(() => isSwitchedMerchant = v),
                        ),
                      ) ,
                    )

                  ],
                ),
                const CustomSpacer(size: 10),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                        fontSize: fSize(12),
                        color: const Color(0xFF70828D),
                        fontWeight: FontWeight.w400
                    ),
                    children: const [
                      TextSpan(text: 'Select the categories where spending will be \n'),
                      TextSpan(text: 'Blocked', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFEB5757))),
                      TextSpan(text: '.  When making a purchase on unauthorized\ncategories, the transaction will be rejected. All\nspending categories are'),
                      TextSpan(text: ' allowed', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3BD8A3))),
                      TextSpan(text: ' by default.'),
                    ],
                  ),
                ),
                const CustomSpacer(size: 24),
                customSwitchControl(0, 'assets/air_lines.png', 'Airlines'),
                const CustomSpacer(size: 20),
                customSwitchControl(1, 'assets/car_rental.png', 'Car Rental'),
                const CustomSpacer(size: 20),
                customSwitchControl(2, 'assets/transportation.png', 'Transportation'),
                const CustomSpacer(size: 20),
                customSwitchControl(3, 'assets/hotels.png', 'Hotels'),
                const CustomSpacer(size: 20),
                customSwitchControl(4, 'assets/petrol.png', 'Petrol'),
                const CustomSpacer(size: 20),
                customSwitchControl(5, 'assets/department_stores.png', 'Department Stores'),
                const CustomSpacer(size: 20),
                customSwitchControl(6, 'assets/parking.png', 'Parking'),
                const CustomSpacer(size: 20),
                customSwitchControl(7, 'assets/fandb.png', 'F&B (Restaurants & Groceries)'),
                const CustomSpacer(size: 20),
                customSwitchControl(8, 'assets/taxis.png', 'Taxis'),
                const CustomSpacer(size: 20),
                customSwitchControl(9, 'assets/others.png', 'Others'),
                const CustomSpacer(size: 34),
              ],
            )
          ),
          Opacity(
            opacity: isSwitchedTransactionLimit ? 1 : 0.4,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Transaction Limit', style: TextStyle(fontSize: fSize(14), color: const Color(0xFF1A2831))),
                    SizedBox(
                      width: wScale(32),
                      height: hScale(18),
                      child: Transform.scale(
                        scale: 0.5,
                        child:CupertinoSwitch(
                          trackColor: const Color(0xFFDFDFDF),
                          activeColor: const Color(0xFF3BD8A3),
                          value: isSwitchedTransactionLimit,
                          onChanged: (v) => setState(() => isSwitchedTransactionLimit = v),
                        ),
                      ) ,
                    )

                  ],
                ),
                const CustomSpacer(size: 28),
                readonlyTextFiled(transactionLimitCtl, 'Enter Transaction Limit', 'Transaction Limit'),
                const CustomSpacer(size: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: hScale(12)),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: hScale(12)),
                  ),
                  child: Slider(
                    value: transactionLimitValue,
                    min: 0.0,
                    max: 100.0,
                    divisions: 100,
                    activeColor: const Color(0xFF3BD8A3),
                    inactiveColor: const Color(0xFF1A2831).withOpacity(0.1),
                    onChanged: (double newValue) {
                      setState(() {
                        transactionLimitValue = newValue;
                        transactionLimitCtl.text = 'SGD ' + (newValue*100).toString();
                      });
                    },
                  ),
                ),
                const CustomSpacer(size: 24),
                Text('Variance Limit', style: TextStyle(fontSize: fSize(14), color: const Color(0xFF1A2831))),
                const CustomSpacer(size: 28),
                readonlyTextFiled(varianceLimitCtl, 'Enter Variance Limit', 'Variance Limit'),
                const CustomSpacer(size: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: hScale(12)),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: hScale(12)),
                  ),
                  child: Slider(
                    value: varianceLimitValue,
                    min: 0.0,
                    max: 100.0,
                    divisions: 100,
                    activeColor: const Color(0xFF3BD8A3),
                    inactiveColor: const Color(0xFF1A2831).withOpacity(0.1),
                    onChanged: (double newValue) {
                      setState(() {
                        varianceLimitValue = newValue;
                        varianceLimitCtl.text = newValue.toString() + '%';
                      });
                    },
                  ),
                ),
                const CustomSpacer(size: 20),
              ],
            )
          )
        ],
      ),
    );
  }

  Widget customSwitchControl(isSwitched, image, title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        customSwitch(isSwitched),
        SizedBox(width: wScale(20)),
        Image.asset(image, width: hScale(16),fit: BoxFit.contain),
        SizedBox(width: wScale(9)),
        Text(title, style:TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w600, color: const Color(0xFF1A2831)))
      ],
    );
  }

  Widget customSwitch(index) {
    return SizedBox(
      width: wScale(26),
      height: hScale(15),
      child: Transform.scale(
        scale: 0.4,
        child:CupertinoSwitch(
          trackColor: const Color(0xFFEB5757),
          activeColor: const Color(0xFF3BD8A3),
          value: isSwitchedArr[index],
          onChanged: (v) => handleSwitch(index, v)
        ),
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
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(
                color: const Color(0xff040415).withOpacity(0.1),
                width: 1.0)
            ),
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
                borderSide: BorderSide(
                    color: Color(0xff040415),
                    width: 1.0)
            ),
          ),
        )
    );
  }

  Widget remarksField() {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(left: wScale(16), right: wScale(16), top: hScale(16), bottom: hScale(16)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Remarks', style:TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w600, color: const Color(0xFF1A2831))),
          const CustomSpacer(size: 22),
          remarkTextFiled(remarksCtl, 'Enter Remarks', 'Remarks (Optional)')
        ],
      ),
    );
  }

  Widget remarkTextFiled(ctl, hint, label) {
    return Container(
        width: wScale(295),
        // height: hScale(56),
        alignment: Alignment.center,
        child: TextField(
          controller: ctl,
          minLines: 3,
          maxLines: 7,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(
                color: const Color(0xff040415).withOpacity(0.1),
                width: 1.0)
            ),
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
                borderSide: BorderSide(
                    color: Color(0xff040415),
                    width: 1.0)
            ),
          ),
        )
    );
  }

  Widget buttonField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        backButton(),
        saveButton()
      ],
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
            ),
          ),
          onPressed: () { Navigator.of(context).pop(); },
          child: Text(
              "Back",
              style: TextStyle(color: Colors.black, fontSize: fSize(16), fontWeight: FontWeight.w700 )),
        )
    );
  }

  Widget saveButton() {
    return Container(
        width: wScale(156),
        height: hScale(56),
        margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
            ),
          ),
          onPressed: () { handleSave(); },
          child: Text(
              "Save",
              style: TextStyle(color: Colors.white, fontSize: fSize(16), fontWeight: FontWeight.w700 )),
        )
    );
  }

}
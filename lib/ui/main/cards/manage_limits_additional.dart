import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:flutter/services.dart';

class ManageLimitsAdditional extends StatefulWidget {
  final data;
  final availableLimitValue;
  final transactionLimitValue;
  final varianceLimitValue;
  final isSwitchedArr;
  final handleSwitch;
  final setTransactionLimitValue;
  final setVarianceLimitValue;
  final isSwitchedMerchant;
  final isSwitchedTransactionLimit;
  final setIsSwitchedMerchant;
  final setIsSwitchedTransactionLimit;
  const ManageLimitsAdditional(
      {Key? key,
      this.data,
      this.transactionLimitValue,
      this.availableLimitValue,
      this.varianceLimitValue,
      this.isSwitchedArr,
      this.handleSwitch,
      this.isSwitchedMerchant,
      this.setTransactionLimitValue,
      this.isSwitchedTransactionLimit,
      this.setIsSwitchedMerchant,
      this.setIsSwitchedTransactionLimit,
      this.setVarianceLimitValue})
      : super(key: key);
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
  final transactionLimitCtl = TextEditingController();
  final varianceLimitCtl = TextEditingController();

  bool isSwitchedMerchant = true;
  bool isSwitchedTransactionLimit = true;
  bool showTransactionHint = false;
  bool showVarianceHint = false;
  bool errorTransactionLimit = false;
  double transactionLimitValue = 1.0;
  double varianceLimitValue = 0.0;
  List isSwitchedArr = [
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
    widget.handleSwitch(isSwitchedArr);
  }

  handleSave() {}

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      List istempSwitchedArr = [];
      widget.data['allowedCategories'].length == 0
          ? istempSwitchedArr = isSwitchedArr
          : widget.data['allowedCategories'].forEach((item) {
              istempSwitchedArr.add(item['isAllowed']);
            });
      setState(() {
        isSwitchedArr = istempSwitchedArr;
        transactionLimitCtl.text =
            '${widget.transactionLimitValue.toStringAsFixed(0)}';
        varianceLimitCtl.text =
            '${widget.varianceLimitValue.toStringAsFixed(0)}%';
        transactionLimitValue = widget.transactionLimitValue;
        varianceLimitValue = widget.varianceLimitValue;
        isSwitchedTransactionLimit = widget.isSwitchedTransactionLimit;
        isSwitchedMerchant =
            widget.data['allowedCategories'].length == 0 ? false : true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double tlValue = transactionLimitCtl.text.toString() == ""
        ? 0
        : double.parse(transactionLimitCtl.text.toString()) /
            widget.availableLimitValue *
            100;
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
                              fontWeight: FontWeight.w500,
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
                              onChanged: (v) {
                                setState(() => isSwitchedMerchant = v);
                                widget.setIsSwitchedMerchant(v);
                              }),
                        ),
                      )
                    ],
                  ),
                  const CustomSpacer(size: 10),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                          fontSize: fSize(14),
                          color: const Color(0xFF70828D),
                          fontWeight: FontWeight.w400),
                      children: const [
                        TextSpan(
                            text:
                                'Select the categories where spending will be '),
                        TextSpan(
                            text: 'blocked',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEB5757))),
                        TextSpan(
                            text:
                                '.  When making a purchase on unauthorized categories, the transaction will be rejected. All spending categories are'),
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
                  // const CustomSpacer(size: 20),
                  customSwitchControl(1, 'assets/car_rental.png', 'Car Rental'),
                  // const CustomSpacer(size: 20),
                  customSwitchControl(
                      2, 'assets/transportation.png', 'Transportation'),
                  // const CustomSpacer(size: 20),
                  customSwitchControl(3, 'assets/hotels.png', 'Hotels'),
                  // const CustomSpacer(size: 20),
                  customSwitchControl(4, 'assets/petrol.png', 'Petrol'),
                  // const CustomSpacer(size: 20),
                  customSwitchControl(
                      5, 'assets/department_stores.png', 'Department Stores'),
                  // const CustomSpacer(size: 20),
                  customSwitchControl(6, 'assets/parking.png', 'Parking'),
                  // const CustomSpacer(size: 20),
                  customSwitchControl(
                      7, 'assets/fandb.png', 'F&B (Restaurants & Groceries)'),
                  // const CustomSpacer(size: 20),
                  customSwitchControl(8, 'assets/taxis.png', 'Taxis'),
                  // const CustomSpacer(size: 20),
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
                                      showTransactionHint =
                                          !showTransactionHint;
                                    });
                                  },
                                ))
                            : SizedBox(),
                      ]),
                      SizedBox(
                        width: wScale(32),
                        height: hScale(18),
                        child: Transform.scale(
                          scale: 0.5,
                          child: CupertinoSwitch(
                              trackColor: const Color(0xFFDFDFDF),
                              activeColor: const Color(0xFF3BD8A3),
                              value: isSwitchedTransactionLimit,
                              onChanged: (v) {
                                setState(() => isSwitchedTransactionLimit = v);
                                widget.setIsSwitchedTransactionLimit(v);
                              }),
                        ),
                      )
                    ],
                  ),
                  const CustomSpacer(size: 10),
                  showTransactionHint
                      ? Container(
                          width: wScale(300),
                          child: TextButton(
                              style: TextButton.styleFrom(
                                primary: const Color(0xffffffff),
                                textStyle: TextStyle(
                                    fontSize: fSize(14),
                                    color: const Color(0xffffffff)),
                              ),
                              onPressed: () {
                                setState(() {
                                  showTransactionHint = !showTransactionHint;
                                });
                              },
                              child: Text(
                                  'This amount is the maximum value a user can charge for every transaction. Transaction limit cannot exceed the monthly limit set above.',
                                  style: TextStyle(
                                      fontSize: fSize(12),
                                      color: const Color(0xFF1A2831)
                                          .withOpacity(0.8)))))
                      : SizedBox(),
                  const CustomSpacer(size: 18),
                  transactionField(transactionLimitCtl,
                      'Enter Transaction Limit', 'Transaction Limit'),
                  errorTransactionLimit
                      ? Container(
                          height: hScale(32),
                          width: wScale(295),
                          padding: EdgeInsets.only(top: hScale(5)),
                          child: Text(
                              "Minimum transaction limit is SGD 1. Switch off the toggle if transaction limit is not required.",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: fSize(12),
                                  color: Color(0xFFEB5757),
                                  fontWeight: FontWeight.w400)))
                      : const CustomSpacer(),
                  const CustomSpacer(size: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: hScale(12)),
                      overlayShape:
                          RoundSliderOverlayShape(overlayRadius: hScale(12)),
                    ),
                    child: Slider(
                      value: tlValue < 1
                          ? 1
                          : tlValue > 100
                              ? 100
                              : tlValue,
                      min: 1.0 / widget.availableLimitValue * 100,
                      max: 100.0,
                      divisions: 100,
                      activeColor: const Color(0xFF3BD8A3),
                      inactiveColor: const Color(0xFF1A2831).withOpacity(0.1),
                      onChanged: (double newValue) {
                        if (isSwitchedTransactionLimit) {
                          setState(() {
                            transactionLimitValue =
                                newValue * widget.availableLimitValue / 100;
                            if (varianceLimitValue >
                                (100 / newValue - 1) * 100) {
                              varianceLimitValue = (100 / newValue - 1) * 100;
                              varianceLimitCtl.text =
                                  "${varianceLimitValue.toStringAsFixed(0)}%";
                            }
                            transactionLimitCtl.text =
                                (newValue * widget.availableLimitValue / 100)
                                    .toStringAsFixed(0);
                            transactionLimitCtl.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: transactionLimitCtl.text.length));
                            varianceLimitCtl.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: varianceLimitCtl.text.length - 1));
                          });
                          widget
                              .setTransactionLimitValue(transactionLimitValue);
                        }
                      },
                    ),
                  ),
                  const CustomSpacer(size: 24),
                  Row(children: [
                    Text('Variance Limit',
                        style: TextStyle(
                            fontSize: fSize(14),
                            color: const Color(0xFF1A2831))),
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
                          child: TextButton(
                              style: TextButton.styleFrom(
                                primary: const Color(0xffffffff),
                                textStyle: TextStyle(
                                    fontSize: fSize(14),
                                    color: const Color(0xffffffff)),
                              ),
                              onPressed: () {
                                setState(() {
                                  showVarianceHint = !showVarianceHint;
                                });
                              },
                              child: Text(
                                  'Set a percentage that allows user to spend beyond the set transaction value.',
                                  style: TextStyle(
                                      fontSize: fSize(12),
                                      color: const Color(0xFF1A2831)
                                          .withOpacity(0.8)))))
                      : SizedBox(),
                  const CustomSpacer(size: 18),
                  varianceField(varianceLimitCtl, 'Enter Variance Limit',
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
                      value: varianceLimitValue,
                      min: 0.0,
                      max: 100.0,
                      divisions: 100,
                      activeColor: const Color(0xFF3BD8A3),
                      inactiveColor: const Color(0xFF1A2831).withOpacity(0.1),
                      onChanged: isSwitchedTransactionLimit &&
                              !errorTransactionLimit
                          ? (double newValue) {
                              setState(() {
                                varianceLimitValue = newValue;
                                if (transactionLimitValue /
                                        widget.availableLimitValue *
                                        100 >
                                    (100 / (100 + newValue) * 100)) {
                                  transactionLimitValue =
                                      (100 / (100 + newValue) * 100) /
                                          100 *
                                          widget.availableLimitValue;
                                  transactionLimitCtl.text =
                                      transactionLimitValue.toStringAsFixed(0);
                                }
                                varianceLimitCtl.text =
                                    "${newValue.toInt().toString()}%";
                                varianceLimitCtl.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset:
                                            varianceLimitCtl.text.length - 1));
                                transactionLimitCtl.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset:
                                            transactionLimitCtl.text.length));
                              });
                              widget.setVarianceLimitValue(varianceLimitValue);
                            }
                          : null,
                    ),
                  ),
                  const CustomSpacer(size: 20),
                ],
              ))
        ],
      ),
    );
  }

  Widget customSwitchControl(index, image, title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        customSwitch(index),
        SizedBox(width: wScale(10)),
        Image.asset(image, width: hScale(16), fit: BoxFit.contain),
        SizedBox(width: wScale(9)),
        Container(
            width: wScale(220),
            child: Text(title,
                style: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A2831))))
      ],
    );
  }

  Widget customSwitch(index) {
    return Container(
        height: wScale(30),
        width: wScale(38),
        child: TextButton(
          onPressed: () {
            setState(() {
              isSwitchedArr[index] = !isSwitchedArr[index];
            });
          },
          child: Transform.scale(
            scale: 0.4,
            child: CupertinoSwitch(
                trackColor: const Color(0xFFEB5757),
                activeColor: const Color(0xFF3BD8A3),
                value: isSwitchedArr[index],
                onChanged: (v) {}),
          ),
        ));
  }

  Widget transactionField(ctl, hint, label) {
    return Stack(
      children: [
        Container(
          width: wScale(295),
          // height: hScale(56),
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: hScale(8)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Color(0xffBFBFBF))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: wScale(10)),
              Text('SGD',
                  style: TextStyle(
                      fontSize: fSize(16),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF040415))),
              SizedBox(width: wScale(5)),
              Expanded(
                  child: Focus(
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          if (transactionLimitCtl.text.length == 0)
                            transactionLimitCtl.text = "1";
                        }
                      },
                      child: TextField(
                        style: TextStyle(
                            fontSize: fSize(16),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF040415)),
                        controller: ctl,
                        readOnly: isSwitchedTransactionLimit ? false : true,
                        onEditingComplete: () {
                          if (transactionLimitCtl.text.length == 0)
                            transactionLimitCtl.text = "1";
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        onChanged: (text) {
                          setState(() {
                            errorTransactionLimit = text == '' ? true : false;
                            double temp_transactionValue =
                                text == "0" || text.length == 0
                                    ? 1
                                    : double.parse(text);
                            if (text == "0") {
                              transactionLimitCtl.text = '1';
                              transactionLimitValue = 1 /
                                  double.parse(widget.availableLimitValue) *
                                  100;
                              transactionLimitCtl.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: transactionLimitCtl.text.length));
                            }

                            if (temp_transactionValue >
                                double.parse(
                                    widget.availableLimitValue.toString())) {
                              transactionLimitCtl.text =
                                  widget.availableLimitValue.toStringAsFixed(0);
                            }

                            transactionLimitValue = temp_transactionValue /
                                        widget.availableLimitValue <
                                    1
                                ? temp_transactionValue /
                                    widget.availableLimitValue *
                                    100
                                : 100;

                            if (varianceLimitValue >
                                (100 / transactionLimitValue - 1) * 100) {
                              varianceLimitValue =
                                  (100 / transactionLimitValue - 1) * 100;
                              varianceLimitCtl.text =
                                  "${varianceLimitValue.toStringAsFixed(0)}%";
                            }
                          });
                          widget
                              .setTransactionLimitValue(transactionLimitValue);
                          transactionLimitCtl.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: transactionLimitCtl.text.length));
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        decoration: InputDecoration(
                          filled: true,
                          contentPadding: EdgeInsets.zero,
                          fillColor: Colors.white,
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 1.0)),
                          hintText: 'Enter ${label}',
                          hintStyle: TextStyle(
                              color: Color(0xffBFBFBF), fontSize: fSize(14)),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 1.0)),
                        ),
                      ))),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text(label,
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: Color(0xffBFBFBF))),
          ),
        )
      ],
    );
  }

  Widget varianceField(ctl, hint, label) {
    return Stack(
      children: [
        Container(
          width: wScale(295),
          // height: hScale(56),
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: hScale(8)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Color(0xffBFBFBF))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: wScale(10)),
              Expanded(
                  child: TextField(
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF040415)),
                controller: ctl,
                readOnly: isSwitchedTransactionLimit ? false : true,
                onChanged: (text) {
                  setState(() {
                    ctl.text = "${text}%";
                    if (text.length == 0) {
                      varianceLimitCtl.text = "0%";
                    }
                    if (text.length == 2 && text[0] == "0") {
                      varianceLimitCtl.text =
                          "${text.substring(1, text.length)}%";
                    }
                    if (double.parse(text.split("%")[0] == ""
                            ? "0"
                            : text.split("%")[0]) >
                        100) {
                      varianceLimitValue = 100;
                      varianceLimitCtl.text = "100%";
                    } else {
                      varianceLimitValue = text.split("%")[0] == ""
                          ? 0
                          : double.parse(text.split("%")[0]);
                    }
                    if (transactionLimitValue /
                            widget.availableLimitValue *
                            100 >
                        (100 / (100 + varianceLimitValue) * 100)) {
                      transactionLimitValue =
                          (100 / (100 + varianceLimitValue) * 100) /
                              100 *
                              widget.availableLimitValue;
                      transactionLimitCtl.text =
                          transactionLimitValue.toStringAsFixed(0);
                    }
                    varianceLimitCtl.selection = TextSelection.fromPosition(
                        TextPosition(offset: varianceLimitCtl.text.length - 1));
                  });
                  widget.setTransactionLimitValue(transactionLimitValue);
                  widget.setVarianceLimitValue(varianceLimitValue);
                },
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: const TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                decoration: InputDecoration(
                  filled: true,
                  contentPadding: EdgeInsets.zero,
                  fillColor: Colors.white,
                  enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 1.0)),
                  hintText: 'Enter ${label}',
                  hintStyle:
                      TextStyle(color: Color(0xffBFBFBF), fontSize: fSize(14)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 1.0)),
                ),
              )),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text(label,
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: Color(0xffBFBFBF))),
          ),
        )
      ],
    );
  }
}

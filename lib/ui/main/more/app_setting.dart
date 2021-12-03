import 'dart:async';

import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class AppSetting extends StatefulWidget {
  const AppSetting({Key key}) : super(key: key);
  @override
  AppSettingState createState() => AppSettingState();
}

class AppSettingState extends State<AppSetting> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  int appType = 0;
  bool syncing = false;
  bool synced = false;
  startTime() async {
    var _duration = const Duration(seconds: 3);
    return Timer(_duration, handleSynced);
  }

  void handleSynced() {
    setState(() {
      synced = true;
      syncing = false;
    });
  }

  handleAppType(type) {
    setState(() {
      appType = type;
    });
  }

  handleSync() {
    if (!synced) {
      setState(() {
        syncing = true;
      });
      startTime();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const CustomSpacer(size: 15),
      Text('Connected Apps',
          style: TextStyle(
              fontSize: fSize(16),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2831))),
      const CustomSpacer(size: 15),
      connectedAppField(),
      const CustomSpacer(size: 30),
      Text('Connect a New App',
          style: TextStyle(
              fontSize: fSize(16),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2831))),
      appTypeField(),
      appsDetailField(),
      const CustomSpacer(size: 30),
    ]);
  }

  Widget connectedAppField() {
    return Container(
        width: wScale(327),
        padding:
            EdgeInsets.symmetric(vertical: hScale(20), horizontal: wScale(20)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 4,
              blurRadius: 20,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            connectedAppIcon(),
            const CustomSpacer(size: 6),
            Text('Xero Accounting',
                style: TextStyle(
                    fontSize: fSize(18),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A2831))),
            const CustomSpacer(size: 6),
            Text('Last Sync : 12 August 2019',
                style: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF70828D))),
            const CustomSpacer(size: 26),
            buttonField()
          ],
        ));
  }

  Widget connectedAppIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/xero.png', fit: BoxFit.contain, height: hScale(59)),
        Container(
          margin: EdgeInsets.only(top: hScale(10)),
          padding:
              EdgeInsets.symmetric(vertical: hScale(4), horizontal: wScale(8)),
          decoration: const BoxDecoration(
            color: Color(0xFFE1FFEF),
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
          child: Text('connected',
              style: TextStyle(
                  fontSize: fSize(12),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2ED47A))),
        )
      ],
    );
  }

  Widget buttonField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [syncActionButton(), deleteActionButton()],
    );
  }

  Widget syncActionButton() {
    return TextButton(
      style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
      child: Container(
          width: wScale(132),
          height: hScale(56),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: !syncing ? const Color(0xFF1A2831) : const Color(0xFF81919B),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(synced ? 'Connected' : 'Sync Now',
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            syncing ? SizedBox(width: wScale(8)) : const SizedBox(),
            syncing
                ? SizedBox(
                    child: CircularProgressIndicator(
                      color: const Color(0xFFFFFFFF),
                      backgroundColor: const Color(0xFFFFFFFF).withOpacity(0.5),
                      strokeWidth: 1,
                    ),
                    width: hScale(13),
                    height: hScale(13))
                : const SizedBox()
          ])),
      onPressed: () {
        handleSync();
      },
    );
  }

  Widget deleteActionButton() {
    return TextButton(
      style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
      child: Container(
          width: wScale(132),
          height: hScale(56),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFEB5757).withOpacity(0.1),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset('assets/red_delete.png',
                fit: BoxFit.contain, height: hScale(17)),
            SizedBox(width: wScale(8)),
            Text('Delete',
                style: TextStyle(
                    fontSize: fSize(16),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEB5757))),
          ])),
      onPressed: () {},
    );
  }

  Widget appTypeField() {
    return Container(
      width: wScale(327),
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(children: [
          statusButton('All Apps', 0),
          statusButton('Accounting', 1),
          statusButton('Trade', 2),
          statusButton('Payment', 3),
        ]),
      ),
    );
  }

  Widget statusButton(title, type) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff70828D),
        padding: const EdgeInsets.all(0),
        textStyle:
            TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
      ),
      onPressed: () {
        handleAppType(type);
      },
      child: Container(
        width: wScale(81),
        height: hScale(30),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: type == appType
                        ? const Color(0xFF29C490)
                        : const Color(0xFFEEEEEE),
                    width: type == appType ? hScale(2) : hScale(1)))),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(12),
              fontWeight: type == appType ? FontWeight.w600 : FontWeight.w500,
              color: type == appType
                  ? const Color(0xFF1A2831)
                  : const Color(0xff70828D)),
        ),
      ),
    );
  }

  Widget appsDetailField() {
    return Row(
      children: [
        appField('assets/xero.png', 'Xero Payment'),
        appField('assets/quickbooks.png', 'Quickbooks'),
      ],
    );
  }

  Widget appField(icon, name) {
    return Container(
      width: wScale(155),
      height: hScale(197),
      padding: EdgeInsets.symmetric(horizontal: wScale(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 4,
            blurRadius: 20,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
              height: hScale(59),
              margin: EdgeInsets.only(top: hScale(16)),
              child: Image.asset(
                icon,
                fit: BoxFit.contain,
                width: wScale(124),
                height: hScale(59),
              )),
          const CustomSpacer(size: 6),
          Text(name,
              style: TextStyle(
                  fontSize: fSize(18),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF70828D))),
          const CustomSpacer(size: 14),
          connectActionButton()
        ],
      ),
    );
  }

  Widget connectActionButton() {
    return TextButton(
      style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
      child: Container(
        width: wScale(123),
        height: hScale(56),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFF1A2831),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Text('Connect',
            style: TextStyle(
                fontSize: fSize(16),
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
      onPressed: () {},
    );
  }
}

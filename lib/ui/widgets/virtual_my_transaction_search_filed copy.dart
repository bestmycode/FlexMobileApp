import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class VirtualMyTransactionSearchField extends StatefulWidget {
  final searchCtl;
  final dateType;
  final handleExport;
  final handleSearch;
  final setDateType;
  const VirtualMyTransactionSearchField(
      {
        Key? key,
        this.searchCtl,
        this.dateType,
        this.handleExport,
        this.handleSearch,
        this.setDateType
      })
      : super(key: key);

  @override
  VirtualMyTransactionSearchFieldState createState() => VirtualMyTransactionSearchFieldState();
}

class VirtualMyTransactionSearchFieldState extends State<VirtualMyTransactionSearchField> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  bool showCalendarModal = false;

  handleCalendar() {
    setState(() {
      showCalendarModal = !showCalendarModal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(overflow: Overflow.visible, children: [
      searchRow(),
      showCalendarModal
          ? Positioned(top: hScale(50), right: 0, child: calendarModalField())
          : const SizedBox()
    ]);
  }

  Widget searchRow() {
    return Container(
        width: wScale(327),
        height: hScale(500),
        alignment: Alignment.topCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            searchField(),
            Container(
              width: wScale(43),
              height: wScale(36),
              decoration: BoxDecoration(
                color: const Color(0xFFA3A3A3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: wScale(12))),
                child: Image.asset('assets/calendar.png',
                    fit: BoxFit.contain, width: wScale(24)),
                onPressed: () {
                  handleCalendar();
                },
              ),
            ),
            // SizedBox(
            //   width: wScale(40),
            //   height: hScale(36),
            //   child: TextButton(
            //     style: TextButton.styleFrom(
            //       primary: const Color(0xff29C490),
            //       padding: const EdgeInsets.all(0),
            //       textStyle: TextStyle(
            //           fontSize: fSize(12),
            //           color: const Color(0xff29C490),
            //           decoration: TextDecoration.underline),
            //     ),
            //     onPressed: () {
            //       widget.handleExport();
            //     },
            //     child: const Text('Export'),
            //   ),
            // )
          ],
        ));
  }

  Widget searchField() {
    return Container(
        width: wScale(265),
        height: hScale(36),
        padding: EdgeInsets.only(left: wScale(15), right: wScale(15)),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border.all(
              color: const Color(0xff040415).withOpacity(0.1),
              width: hScale(1)),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: wScale(150),
                height: hScale(36),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: widget.searchCtl,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)),
                    hintText: 'Type your search here',
                    hintStyle: TextStyle(
                        color: const Color(0xff040415).withOpacity(0.5),
                        fontSize: fSize(12),
                        fontWeight: FontWeight.w500),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)),
                  ),
                  style: TextStyle(
                      fontSize: fSize(12), fontWeight: FontWeight.w500),
                )),
            SizedBox(
              width: wScale(20),
              child: TextButton(
                  style: TextButton.styleFrom(
                    primary: const Color(0xff70828D),
                    padding: const EdgeInsets.all(0),
                    textStyle: TextStyle(
                        fontSize: fSize(14), color: const Color(0xff70828D)),
                  ),
                  onPressed: () {
                    widget.handleSearch();
                  },
                  // child: const Icon( Icons.search_rounded, color: Color(0xFFBFBFBF), size: 20 ),
                  child: Image.asset(
                    'assets/search_icon.png',
                    fit: BoxFit.contain,
                    width: wScale(13),
                  )),
            ),
          ],
        ));
  }

  Widget calendarModalField() {
    return Container(
      width: wScale(177),
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
          modalButton('Last 7 Days', 1),
          modalButton('Last 30 Days', 2),
          modalButton('Last 90 Days', 3),
          modalButton('Date Range', 4),
        ],
      ),
    );
  }

  Widget modalButton(title, type) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: widget.dateType == type ? const Color(0xFF29C490) : Colors.black,
        padding: const EdgeInsets.only(left: 16),
        textStyle: TextStyle(fontSize: fSize(14), color: Colors.black),
      ),
      onPressed: () {
        widget.setDateType(type);
        showCalendarModal = false;
      },
      child: Container(
        width: wScale(177),
        // padding: EdgeInsets.only(top:hScale(6), bottom: hScale(6)),
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: fSize(12)),
        ),
      ),
    );
  }
}

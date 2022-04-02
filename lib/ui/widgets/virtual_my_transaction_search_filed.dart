import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class VirtualMyTransactionSearchField extends StatefulWidget {
  final transactions;
  final searchCtl;
  final dateType;
  final handleExport;
  final handleSearch;
  final handleShowExport;
  final setDateType;
  final transactionStatus;
  final showCalendarModal;
  final handleCalendar;
  final isShowCalendar;
  const VirtualMyTransactionSearchField(
      {Key? key,
      this.transactions,
      this.searchCtl,
      this.dateType,
      this.handleExport,
      this.handleShowExport,
      this.handleSearch,
      this.setDateType,
      this.transactionStatus,
      this.showCalendarModal = false,
      this.isShowCalendar = true,
      this.handleCalendar})
      : super(key: key);

  @override
  VirtualMyTransactionSearchFieldState createState() =>
      VirtualMyTransactionSearchFieldState();
}

class VirtualMyTransactionSearchFieldState
    extends State<VirtualMyTransactionSearchField> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final searchCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(overflow: Overflow.visible, children: [
      searchRow(),
      widget.showCalendarModal
          ? Positioned(top: hScale(50), right: 0, child: calendarModalField())
          : const SizedBox()
    ]);
  }

  Widget searchRow() {
    return GestureDetector(
        onTap: () {
          widget.showCalendarModal && widget.handleCalendar();
        },
        child: Container(          
            height: hScale(500),
            padding: EdgeInsets.symmetric(horizontal: wScale(24)),
            color: widget.showCalendarModal ? Colors.transparent : null,
            alignment: Alignment.topCenter,
            child: Container(
                height: hScale(50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    searchField(),
                    widget.transactionStatus == 1 &&
                            widget.transactions.length > 0
                        ? SizedBox(
                            width: wScale(40),
                            height: hScale(36),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                primary: const Color(0xff29C490),
                                padding: const EdgeInsets.all(0),
                                textStyle: TextStyle(
                                    fontSize: fSize(12),
                                    color: const Color(0xff29C490),
                                    decoration: TextDecoration.underline),
                              ),
                              onPressed: () {
                                widget.handleExport();
                              },
                              child: const Text('Export'),
                            ),
                          )
                        : SizedBox()
                  ],
                ))));
  }

  Widget searchField() {
    return Container(
        width: wScale(
            widget.transactionStatus == 1 && widget.transactions.length > 0
                ? 280
                : 325),
        height: hScale(36),
        padding: EdgeInsets.only(left: wScale(10), right: wScale(6)),
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
                width: wScale(160),
                height: hScale(36),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: searchCtl,
                  onChanged: (text) {
                    widget.handleSearch(text);
                  },
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
            searchCtl.text.length > 0
                ? Container(
                    width: wScale(20),
                    child: TextButton(
                        style: TextButton.styleFrom(
                          primary: const Color(0xff70828D),
                          padding: const EdgeInsets.all(0),
                          textStyle: TextStyle(
                              fontSize: fSize(14),
                              color: const Color(0xff70828D)),
                        ),
                        onPressed: () {
                          widget.handleSearch('');
                          searchCtl.text = "";
                        },
                        // child: const Icon( Icons.search_rounded, color: Color(0xFFBFBFBF), size: 20 ),
                        child: Icon(Icons.cancel_outlined,
                            color: const Color(0xFFBFBFBF), size: wScale(15))),
                  )
                : SizedBox(),
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
        primary:
            widget.dateType == type ? const Color(0xFF29C490) : Colors.black,
        padding: const EdgeInsets.only(left: 16),
        textStyle: TextStyle(fontSize: fSize(14), color: Colors.black),
      ),
      onPressed: () {
        widget.setDateType(type);
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

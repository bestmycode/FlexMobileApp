import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class TeamHeader extends StatefulWidget {
  final type;
  final activeType;
  final sortType;
  final subSortType;
  final sortArr;
  final handleCardType;
  final handleSortType;
  final handleSubSortType;
  final activeCounts;
  final inActiveCounts;
  const TeamHeader(
      {Key? key,
      this.type = 'physical',
      this.activeType,
      this.sortType,
      this.subSortType,
      this.sortArr,
      this.handleCardType,
      this.handleSortType,
      this.handleSubSortType,
      this.activeCounts,
      this.inActiveCounts})
      : super(key: key);

  @override
  TeamHeaderState createState() => TeamHeaderState();
}

class TeamHeaderState extends State<TeamHeader> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  bool showSortModal = false;
  int sortType = -1;

  setSortType(type) {
    setState(() {
      sortType = type;
    });
    widget.handleSortType(type);
  }

  setDefaultFilter() {
    setSortType(-1);
  }

  handleSortModal() {
    setState(() {
      showSortModal = !showSortModal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(overflow: Overflow.visible, children: [
      headerSortField(),
      showSortModal
          ? Positioned(top: hScale(50), right: 0, child: modalField())
          : const SizedBox()
    ]);
  }

  Widget headerSortField() {
    return GestureDetector(
        onTap: () {
          showSortModal && handleSortModal();
        },
        child: Container(
            height: hScale(500),
            color: showSortModal ? Colors.transparent : null,
            alignment: Alignment.topCenter,
            child: Container(
              height: hScale(40),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      activeButton(
                          'Active Cards${widget.activeType == 1 ? " (${widget.activeCounts})" : ''}',
                          1),
                      activeButton(
                          'Inactive Cards${widget.activeType == 2 ? " (${widget.inActiveCounts})" : ''}',
                          2),
                    ]),
                    TextButton(
                        style: TextButton.styleFrom(
                          primary: const Color(0xff70828D),
                          padding: const EdgeInsets.all(0),
                          textStyle: TextStyle(
                              fontSize: fSize(14),
                              color: const Color(0xff70828D)),
                        ),
                        onPressed: () {
                          // handleSortModal();
                          _openSortByDialog();
                        },
                        child: Row(
                          children: [
                            Icon(Icons.swap_vert_rounded,
                                color: const Color(0xff29C490),
                                size: hScale(18)),
                            Text('Sort by',
                                style: TextStyle(fontSize: fSize(12)))
                          ],
                        )),
                  ]),
            )));
  }

  Widget activeButton(title, type) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff70828D),
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: wScale(5)),
        // textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
      ),
      onPressed: () {
        widget.handleCardType(type);
      },
      child: Container(
        height: hScale(35),
        padding: EdgeInsets.only(left: wScale(6), right: wScale(6)),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: type == widget.activeType
                        ? const Color(0xFF29C490)
                        : const Color(0xFFEEEEEE),
                    width: type == widget.activeType ? hScale(2) : hScale(1)))),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(14),
              color: type == widget.activeType
                  ? const Color(0xff1A2831)
                  : const Color(0xff70828D)),
        ),
      ),
    );
  }

  Widget modalField() {
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
          modalButton('Sort by ${widget.sortArr[0]['sortType']}', 0, 0),
          modalButton('Sort by ${widget.sortArr[1]['sortType']}', 1, 0),
          modalButton('Sort by ${widget.sortArr[2]['sortType']}', 2, 0)
        ],
      ),
    );
  }

  Widget modalButton(title, type, style) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: style == 0
            ? widget.sortType == type
                ? const Color(0xFF29C490)
                : Colors.black
            : widget.subSortType == type
                ? const Color(0xFF29C490)
                : Colors.black,
        padding: EdgeInsets.only(
            top: hScale(10),
            bottom: hScale(10),
            left: wScale(16),
            right: wScale(16)),
        textStyle: TextStyle(fontSize: fSize(14), color: Colors.black),
      ),
      onPressed: () {
        widget.handleSortType(type);
        showSortModal = false;
      },
      child: Container(
        width: wScale(177),
        padding: EdgeInsets.only(top: hScale(6), bottom: hScale(6)),
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: fSize(12)),
        ),
      ),
    );
  }

  void _openSortByDialog() => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(hScale(24)),
          topRight: Radius.circular(hScale(24)),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
              color: Colors.white,
              child: SingleChildScrollView(
                  child: Container(
                      child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  filterOnModal(),
                  modalDevider(),
                  sortItem('Date Issued', 'New to Old', 0, setState),
                  sortItem('Date Issued', 'Old to New', 1, setState),
                  sortItem('Available Limit', 'High to Low', 2, setState),
                  sortItem('Available Limit', 'Low to High', 3, setState),
                  widget.type == 'physical'
                      ? sortItem('Card Holder', 'A – Z', 4, setState)
                      : sortItem('Card Type', 'Recurring', 4, setState),
                  widget.type == 'physical'
                      ? sortItem('Card Holder', 'Z – A', 5, setState)
                      : sortItem('Card Type', 'Fixed', 5, setState),
                  modalButtonField(setState)
                ],
              ))));
        });
      });

  Widget modalDevider() {
    return Container(
      height: hScale(1),
      color: Color(0xFF828282),
    );
  }

  Widget filterOnModal() {
    return Container(
      height: hScale(72),
      padding: EdgeInsets.symmetric(horizontal: wScale(24)),
      alignment: Alignment.center,
      child: Row(children: [
        Text('Sort by',
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: fSize(16),
                fontWeight: FontWeight.w600,
                color: Color(0xFF828282)))
      ]),
    );
  }

  Widget modalButtonField(setState) {
    return Container(
      height: hScale(120),
      padding: EdgeInsets.symmetric(horizontal: wScale(24)),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              width: wScale(156),
              height: hScale(56),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFFE8E9EA),
                  side: const BorderSide(width: 0, color: Color(0xFFE8E9EA)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  setState(() {
                    sortType = 0;
                  });
                  setDefaultFilter();
                },
                child: Text('Clear All',
                    style: TextStyle(
                        color: Color(0xff1A2831),
                        fontSize: fSize(16),
                        fontWeight: FontWeight.w700)),
              )),
          Container(
              width: wScale(156),
              height: hScale(56),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  primary: const Color(0xff1A2831),
                  side: const BorderSide(width: 0, color: Color(0xff1A2831)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  setState(() {});
                  Navigator.of(context).pop();
                },
                child: Text('Apply',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: fSize(16),
                        fontWeight: FontWeight.w700)),
              ))
        ],
      ),
    );
  }

  Widget sortItem(title, value, index, setState) {
    return Container(
      height: hScale(72),
      color: sortType == index ? Color(0xFFF5FEFB) : Color(0xFFFFFFFF),
      child: TextButton(
          onPressed: () {
            setState(() {
              sortType = index;
            });
            setSortType(index);
          },
          style: TextButton.styleFrom(
            primary: const Color(0xFFF5FEFB),
            padding: EdgeInsets.symmetric(horizontal: wScale(24)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text("${title}: ",
                      style: TextStyle(
                          fontSize: fSize(16),
                          fontWeight: FontWeight.w600,
                          color: sortType == index
                              ? Color(0xFF0F7855)
                              : Color(0xFF606060))),
                  Text(value,
                      style: TextStyle(
                          fontSize: fSize(16),
                          fontWeight: FontWeight.w400,
                          color: sortType == index
                              ? Color(0xFF0F7855)
                              : Color(0xFF606060)))
                ],
              ),
              sortType == index
                  ? Icon(Icons.check, color: Color(0xFF0F7855), size: 30.0)
                  : SizedBox()
            ],
          )),
    );
  }
}

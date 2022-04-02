import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class VirtualMyCardsSubSearchField extends StatefulWidget {
  final sortArr;
  final sortType;
  final subSortType;
  final handleSubSortType;
  const VirtualMyCardsSubSearchField(
      {Key? key,
      this.sortArr,
      this.sortType,
      this.subSortType,
      this.handleSubSortType})
      : super(key: key);

  @override
  VirtualMyCardsSubSearchFieldState createState() =>
      VirtualMyCardsSubSearchFieldState();
}

class VirtualMyCardsSubSearchFieldState
    extends State<VirtualMyCardsSubSearchField> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  bool showSubSortModal = false;

  handleSubSortModal() {
    setState(() {
      showSubSortModal = !showSubSortModal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(overflow: Overflow.visible, children: [
      sortField(),
      showSubSortModal
          ? Positioned(
              top: hScale(30), right: 0, child: subSortTypeModalField())
          : const SizedBox()
    ]);
  }

  Widget subSortTypeModalField() {
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
          widget.sortType != -1
              ? modalButton(widget.sortArr[widget.sortType]['subType1'], 0, 1)
              : const SizedBox(),
          widget.sortType != -1
              ? modalButton(widget.sortArr[widget.sortType]['subType2'], 1, 1)
              : const SizedBox()
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
        widget.handleSubSortType(type);
        showSubSortModal = false;
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

  Widget sortField() {
    return GestureDetector(
        onTap: () {
          showSubSortModal && handleSubSortModal();
        },
        child: Container(
          height: hScale(450),
          color: showSubSortModal ? Colors.transparent : null,
          alignment: Alignment.topCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Sorted by: ${widget.sortArr[widget.sortType]['sortType']}',
                  style: TextStyle(
                      fontSize: fSize(12),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1B2931))),
              sortValue()
            ],
          ),
        ));
  }

  Widget sortValue() {
    return Container(
      height: hScale(30),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF040415).withOpacity(0.1))),
      child: TextButton(
          style: TextButton.styleFrom(
            primary: const Color(0xffffffff),
            padding: EdgeInsets.symmetric(horizontal: wScale(16)),
          ),
          child: Row(children: [
            Text(
                widget.subSortType == 0
                    ? '${widget.sortArr[widget.sortType]['subType1']}'
                    : '${widget.sortArr[widget.sortType]['subType2']}',
                style: TextStyle(
                    fontSize: fSize(12), color: const Color(0xFF1B2931))),
            SizedBox(width: wScale(12)),
            SizedBox(
              width: wScale(12),
              child: Icon(Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFFBFBFBF), size: fSize(24)),
            )
          ]),
          onPressed: () {
            handleSubSortModal();
          }),
    );
  }
}

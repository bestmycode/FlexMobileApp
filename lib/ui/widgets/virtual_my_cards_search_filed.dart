import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class VirtualMyCardsSearchField extends StatefulWidget {
  final activeType;
  final sortArr;
  final sortType;
  final handleCardType;
  final handleSortType;
  const VirtualMyCardsSearchField(
      {
        Key? key,
        this.activeType,
        this.sortArr,
        this.sortType,
        this.handleCardType,
        this.handleSortType
      })
      : super(key: key);

  @override
  VirtualMyCardsSearchFieldState createState() => VirtualMyCardsSearchFieldState();
}

class VirtualMyCardsSearchFieldState extends State<VirtualMyCardsSearchField> {
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
          ? Positioned(top: hScale(50), right: 0, child: sortTypeModalField())
          : const SizedBox()
    ]);
  }

  Widget headerSortField() {
    return Container(
      height: hScale(500),
      alignment: Alignment.topCenter,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          activeButton('Active Cards', 1),
          activeButton('Inactive Cards', 2),
        ]),
        TextButton(
            style: TextButton.styleFrom(
              primary: const Color(0xff70828D),
              padding: const EdgeInsets.all(0),
              textStyle: TextStyle(
                  fontSize: fSize(14), color: const Color(0xff70828D)),
            ),
            onPressed: () {
              handleSortModal();
            },
            child: Row(
              children: [
                Icon(Icons.swap_vert_rounded,
                    color: const Color(0xff29C490), size: hScale(18)),
                Text('Sort by', style: TextStyle(fontSize: fSize(12)))
              ],
            )),
      ]),
    );
  }

  Widget activeButton(title, type) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff70828D),
        padding: const EdgeInsets.all(0),
        textStyle:
            TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
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
              fontWeight:
                  type == widget.activeType ? FontWeight.w600 : FontWeight.w500,
              color: type == widget.activeType
                  ? const Color(0xff1A2831)
                  : const Color(0xff70828D)),
        ),
      ),
    );
  }

  Widget sortTypeModalField() {
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
        primary: widget.sortType == type
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


}

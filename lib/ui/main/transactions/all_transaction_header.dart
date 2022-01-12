import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class AllTransactionHeader extends StatefulWidget {
  final dateType;
  final sortType;
  final transactionStatus;
  final handleTransactionStatus;
  final setDateType;
  final setSortType;
  const AllTransactionHeader(
      {
        Key? key,
        this.dateType,
        this.sortType,
        this.transactionStatus,
        this.handleTransactionStatus,
        this.setDateType,
        this.setSortType
      })
      : super(key: key);

  @override
  AllTransactionHeaderState createState() => AllTransactionHeaderState();
}

class AllTransactionHeaderState extends State<AllTransactionHeader> {
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
  
  handleSort() {
    setState(() {
      showSortModal = !showSortModal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(overflow: Overflow.visible, children: [
      SizedBox(
        width: wScale(327),
        height: hScale(300),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('All Transactions',
                    style: TextStyle(
                        fontSize: fSize(16), fontWeight: FontWeight.w500)),
                TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color(0xff70828D),
                      padding: const EdgeInsets.all(0),
                      textStyle: TextStyle(
                          fontSize: fSize(14), color: const Color(0xff70828D)),
                    ),
                    onPressed: () {
                      handleSort();
                    },
                    child: Row(
                      children: [
                        Icon(Icons.swap_vert_rounded,
                            color: const Color(0xff29C490), size: hScale(18)),
                        Text('Sort by', style: TextStyle(fontSize: fSize(12)))
                      ],
                    )),
              ],
            ),
            // const CustomSpacer(size: 10),
            transactionStatusField()
          ],
        ),
      ),
      showSortModal
          ? Positioned(top: hScale(50), right: 0, child: sortModalField())
          : const SizedBox()
    ]);
  }
Widget transactionStatusField() {
    return Container(
      width: wScale(327),
      height: hScale(34),
      padding: EdgeInsets.all(hScale(2)),
      decoration: BoxDecoration(
        color: const Color(0xff040415).withOpacity(0.04),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(hScale(17)),
          topRight: Radius.circular(hScale(17)),
          bottomLeft: Radius.circular(hScale(17)),
          bottomRight: Radius.circular(hScale(17)),
        ),
      ),
      child: Row(children: [
        transactionStatusButton('Completed', 1),
        transactionStatusButton('Pending', 2),
        transactionStatusButton('Declined', 3)
      ]),
    );
  }

  Widget transactionStatusButton(status, type) {
    return type == widget.transactionStatus
        ? Container(
            width: wScale(107),
            height: hScale(35),
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(260),
              boxShadow: [
                BoxShadow(
                  color: const Color(0XFF040415).withOpacity(0.1),
                  spreadRadius: 4,
                  blurRadius: 20,
                  offset: const Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: TextButton(
                style: TextButton.styleFrom(
                  primary: const Color(0xFFFFFFFF),
                  padding: const EdgeInsets.all(0),
                ),
                child: Text(
                  status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: fSize(14),
                      fontWeight: FontWeight.w600,
                      color: type != 3
                          ? const Color(0xFF70828D)
                          : const Color(0xFFEB5757)),
                ),
                onPressed: () {
                  widget.handleTransactionStatus(type);
                }),
          )
        : TextButton(
            style: TextButton.styleFrom(
              primary: const Color(0xff70828D),
              padding: const EdgeInsets.all(0),
              textStyle: TextStyle(
                  fontSize: fSize(14), color: const Color(0xff70828D)),
            ),
            onPressed: () {
              widget.handleTransactionStatus(type);
            },
            child: Container(
              width: wScale(107),
              height: hScale(30),
              alignment: Alignment.center,
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: fSize(14),
                    color: type != 3
                        ? const Color(0xFF1A2831)
                        : const Color(0xFFEB5757)),
              ),
            ),
          );
  }

  Widget sortModalField() {
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
          modalButton('Sort by Newest on top', 0, 0),
          modalButton('Sort by Oldest on top', 1, 0),
          modalButton('Sort by Card Type', 2, 0)
        ],
      ),
    );
  }

  Widget modalButton(title, type, style) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: style == 1
            ? widget.dateType == type
                ? const Color(0xFF29C490)
                : Colors.black
            : widget.sortType == type
                ? const Color(0xFF29C490)
                : Colors.black,
        padding:
            const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
        textStyle: TextStyle(fontSize: fSize(14), color: Colors.black),
      ),
      onPressed: () {
        widget.setSortType(type);
        setState(() {
          showSortModal = false;
        });
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

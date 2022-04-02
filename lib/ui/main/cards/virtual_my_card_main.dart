import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/virtual_my_cards_sub_search_filed.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:expandable/expandable.dart';
import 'package:indexed/indexed.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:timezone/standalone.dart' as tz;

class VirtualMyCardsMain extends StatefulWidget {
  final transactions;
  final sortArr;
  final sortType;
  final subSortType;
  final handleSubSortType;
  final handleCardDetail;
  const VirtualMyCardsMain(
      {Key? key,
      this.transactions,
      this.sortArr,
      this.sortType,
      this.subSortType,
      this.handleSubSortType,
      this.handleCardDetail})
      : super(key: key);

  @override
  VirtualMyCardsMainState createState() => VirtualMyCardsMainState();
}

class VirtualMyCardsMainState extends State<VirtualMyCardsMain> {
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
  String searchText = '';
  final LocalStorage userStorage = LocalStorage('user_info');

  convertLocalToDetroit(_date) {
    final detroit = tz.getLocation(userStorage.getItem("org_timezone"));
    final localizedDt =
        tz.TZDateTime.from(DateTime.fromMillisecondsSinceEpoch(_date), detroit);
    var date = DateFormat.yMMMd().format(localizedDt).split(' ')[1].substring(
        0, DateFormat.yMMMd().format(localizedDt).split(' ')[1].length - 1);
    var month = DateFormat.yMMMd().format(localizedDt).split(' ')[0];
    var year = DateFormat.yMMMd().format(localizedDt).split(' ')[2];
    return '${date.length == 1 ? "0$date" : date} $month $year';
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Indexed(
        index: 50,
        child: Column(
          children: [
            SizedBox(height: hScale(40)),
            Container(
                height: hScale(50), child: Row(children: [searchField()])),
            Indexer(children: [
              Indexed(
                  index: 200,
                  child: widget.sortType >= 0
                      ? VirtualMyCardsSubSearchField(
                          sortArr: widget.sortArr,
                          sortType: widget.sortType,
                          subSortType: widget.subSortType,
                          handleSubSortType: widget.handleSubSortType,
                        )
                      : const SizedBox()),
              Indexed(
                  index: 40,
                  child: Column(
                    children: [
                      widget.sortType >= 0
                          ? SizedBox(height: hScale(40))
                          : SizedBox(),
                      Container(
                          height: hScale(widget.sortType >= 0 ? 450 : 490),
                          child: SingleChildScrollView(
                              child: getTransactionArrWidgets(
                                  widget.transactions)))
                    ],
                  ))
            ])
          ],
        ));
  }

  Widget searchField() {
    return Container(
        width: wScale(327),
        height: hScale(36),
        padding: EdgeInsets.only(left: wScale(10), right: wScale(6)),
        decoration: BoxDecoration(
          color: const Color(0xffffffff),
          border: Border.all(
              color: const Color(0xff040415).withOpacity(0.1),
              width: hScale(1)),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: wScale(260),
                height: hScale(36),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: searchCtl,
                  onChanged: (text) {
                    setState(() {
                      searchText = text;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)),
                    hintText: 'Card Holders, Card Names',
                    hintStyle: TextStyle(
                        color: const Color(0xff040415).withOpacity(0.5),
                        fontSize: fSize(12),
                        fontWeight: FontWeight.w500),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)),
                  ),
                  style: TextStyle(
                      fontSize: fSize(14), fontWeight: FontWeight.w500),
                  scrollPadding: EdgeInsets.zero,
                )),
            searchText.length > 0
                ? SizedBox(
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
                          setState(() {
                            searchText = '';
                            searchCtl.text = "";
                          });
                        },
                        child: Icon(Icons.cancel_outlined,
                            color: const Color(0xFFBFBFBF), size: wScale(15))),
                  )
                : SizedBox(),
          ],
        ));
  }

  Widget collapseField(index, data) {
    return ExpandableNotifier(
      initialExpanded: index == 0 ? true : false,
      child: Container(
        margin: EdgeInsets.only(bottom: hScale(10)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
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
          children: [
            ScrollOnExpand(
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                    tapBodyToCollapse: true, tapBodyToExpand: true),
                expanded: Column(
                  children: [cardHeader(data), cardBody(data)],
                ),
                collapsed: cardHeader(data),
                builder: (_, collapsed, expanded) {
                  return SizedBox(
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget searchCountField(searchCount) {
    return Container(
        width: wScale(327),
        margin: EdgeInsets.only(bottom: hScale(6)),
        child: Text('Showing ${searchCount} results',
            style: TextStyle(fontSize: fSize(12), color: Color(0xFF606060))));
  }

  Widget getTransactionArrWidgets(arr) {
    if (widget.sortType == 0) {
      var fixedList =
          arr.where((item) => item['cardType'] == "ONE-TIME").toList();
      fixedList.sort((a, b) => a['cardName']
          .toString()
          .toLowerCase()
          .compareTo(b['cardName'].toString().toLowerCase()));
      var recurringList =
          arr.where((item) => item['cardType'] == "RECURRING").toList();
      recurringList.sort((a, b) => a['cardName']
          .toString()
          .toLowerCase()
          .compareTo(b['cardName'].toString().toLowerCase()));
      if (widget.subSortType == 0) {
        arr = new List.from(fixedList)..addAll(recurringList);
      } else {
        arr = new List.from(recurringList)..addAll(fixedList);
      }
    } else if (widget.sortType == 1) {
      widget.subSortType == 0
          ? arr.sort((a, b) => a['financeAccountLimits'][0]['availableLimit'] <
                  b['financeAccountLimits'][0]['availableLimit']
              ? 1
              : -1)
          : arr.sort((a, b) => a['financeAccountLimits'][0]['availableLimit'] >
                  b['financeAccountLimits'][0]['availableLimit']
              ? 1
              : -1);
    } else {
      widget.subSortType == 0 ? arr = arr : arr = arr.reversed.toList();
    }
    List tempArr = [];
    arr.forEach((item) {
      var cardName = item['cardName'] != null
          ? item['cardName'].toString().toLowerCase()
          : '';
      var searchTxt =
          searchText != '' ? searchText.toString().toLowerCase() : '';
      if (cardName.contains(searchTxt)) tempArr.add(item);
    });

    return tempArr.length == 0
        ? Column(children: [
            searchText.length != 0 ? searchCountField(tempArr.length) : SizedBox(),
            Image.asset('assets/empty_transaction.png',
                fit: BoxFit.contain, width: wScale(327))
          ])
        : Column(children: [
            searchText.length != 0 ? searchCountField(tempArr.length) : SizedBox(),
            Column(
                children: tempArr.map<Widget>((item) {
              return collapseField(tempArr.indexOf(item), item);
            }).toList())
          ]);
  }

  Widget cardHeader(data) {
    var cardNum = data["permanentAccountNumber"];
    var cardNumber = cardNum.substring(cardNum.length - 4, cardNum.length);
    return Container(
        width: wScale(327),
        height: hScale(80),
        padding: EdgeInsets.only(left: wScale(16), right: wScale(16)),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2931),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(hScale(10)),
            topRight: Radius.circular(hScale(10)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${data['cardName']}',
                style: TextStyle(
                    fontSize: fSize(16),
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
            CustomSpacer(size: 4),
            Text(
                '**** **** **** ${cardNumber} | ${data['cardType'] == "RECURRING" ? "Recurring" : "Fixed"}',
                style: TextStyle(
                    fontSize: fSize(14),
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
          ],
        ));
  }

  Widget cardBody(data) {
    return Container(
        width: wScale(327),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(hScale(10)),
            topRight: Radius.circular(hScale(10)),
          ),
        ),
        child: Column(
          children: [
            cardBodyAvailableDetail(
                'Available Limit',
                data['currencyCode'],
                data['financeAccountLimits'][0]['availableLimit']
                    .toStringAsFixed(2),
                data['financeAccountLimits'][0]['availableLimit'] /
                    data['financeAccountLimits'][0]['limitValue']),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            cardBodyMonthlyDetail(
                'Monthly Spend Limit',
                data['currencyCode'],
                data['financeAccountLimits'][0]['limitValue']
                    .toStringAsFixed(2)),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            cardBodyStatusDetail(
              'Status',
              '',
              data['status'],
            ),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            cardBodyMonthlyDetail(
                'Date of Issue', '', convertLocalToDetroit(data['creation'])),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            TextButton(
              style: TextButton.styleFrom(
                primary: const Color(0xff29C490),
                textStyle: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff29C490)),
              ),
              onPressed: () {
                widget.handleCardDetail(data);
              },
              child: const Text('View Card Details'),
            ),
          ],
        ));
  }

  Widget cardBodyAvailableDetail(title, symbol, value, percent) {
    return Container(
        padding: EdgeInsets.only(
            top: hScale(10),
            bottom: hScale(10),
            left: wScale(16),
            right: wScale(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: fSize(14),
                    color: const Color(0xFF70828D),
                    fontWeight: FontWeight.w500)),
            Container(
                padding: EdgeInsets.symmetric(
                    horizontal: wScale(8), vertical: hScale(8)),
                decoration: BoxDecoration(
                  color: percent == 0
                      ? Color(0xFFFBECED)
                      : percent <= 0.3
                          ? Color(0xFFFFF5C2)
                          : Color(0xFFDEFEE9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(hScale(16)),
                    topRight: Radius.circular(hScale(16)),
                    bottomLeft: Radius.circular(hScale(16)),
                    bottomRight: Radius.circular(hScale(16)),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$symbol ',
                        style: TextStyle(
                            fontSize: fSize(12),
                            height: 1,
                            color: percent == 0
                                ? Color(0xFF813D41)
                                : percent <= 0.3
                                    ? Color(0xFF58571D)
                                    : Color(0xFF0F7855))),
                    Container(
                        constraints:
                            BoxConstraints(minWidth: 1, maxWidth: wScale(110)),
                        child: Text(value,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: fSize(14),
                                fontWeight: FontWeight.w600,
                                height: 1,
                                color: percent == 0
                                    ? Color(0xFF813D41)
                                    : percent <= 0.3
                                        ? Color(0xFF58571D)
                                        : Color(0xFF0F7855))))
                  ],
                ))
          ],
        ));
  }

  Widget cardBodyMonthlyDetail(title, symbol, value) {
    return Container(
        padding: EdgeInsets.only(
            top: hScale(10),
            bottom: hScale(10),
            left: wScale(16),
            right: wScale(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: fSize(14),
                    color: const Color(0xFF70828D),
                    fontWeight: FontWeight.w500)),
            Container(
                padding: EdgeInsets.symmetric(
                    horizontal: wScale(8), vertical: hScale(8)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(hScale(16)),
                    topRight: Radius.circular(hScale(16)),
                    bottomLeft: Radius.circular(hScale(16)),
                    bottomRight: Radius.circular(hScale(16)),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$symbol ',
                        style: TextStyle(
                            fontSize: fSize(12),
                            height: 1,
                            color: const Color(0xFF1A2831))),
                    Container(
                        constraints:
                            BoxConstraints(minWidth: 1, maxWidth: wScale(110)),
                        child: Text(value,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: fSize(14),
                                fontWeight: FontWeight.w600,
                                height: 1,
                                color: const Color(0xFF1A2831))))
                  ],
                ))
          ],
        ));
  }

  Widget cardBodyStatusDetail(title, symbol, value) {
    return Container(
        padding: EdgeInsets.only(
            top: hScale(10),
            bottom: hScale(10),
            left: wScale(16),
            right: wScale(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: fSize(14),
                    color: const Color(0xFF70828D),
                    fontWeight: FontWeight.w500)),
            Container(
                padding: EdgeInsets.symmetric(
                    horizontal: wScale(8), vertical: hScale(8)),
                decoration: BoxDecoration(
                  color: value == "ACTIVE"
                      ? Color(0xFF0F7855)
                      : value == "SUSPENDED"
                          ? Color(0xFF0C649A)
                          : value == "EXPIRED"
                              ? Color(0xFF606060)
                              : Color(0xFFB81A27),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(hScale(16)),
                    topRight: Radius.circular(hScale(16)),
                    bottomLeft: Radius.circular(hScale(16)),
                    bottomRight: Radius.circular(hScale(16)),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        value == "ACTIVE"
                            ? "Active"
                            : value == "SUSPENDED"
                                ? "Frozen"
                                : value == "EXPIRED"
                                    ? "Expired"
                                    : "Cancelled",
                        style: TextStyle(
                            fontSize: fSize(14),
                            fontWeight: FontWeight.w600,
                            height: 1,
                            color: Color(0xFFFFFFFF)))
                  ],
                ))
          ],
        ));
  }
}

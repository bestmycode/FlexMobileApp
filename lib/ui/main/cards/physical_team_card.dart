import 'package:flexflutter/ui/main/cards/physical_personal_card.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';
import 'package:expandable/expandable.dart';
import 'package:indexed/indexed.dart';

class PhysicalTeamCards extends StatefulWidget {
  const PhysicalTeamCards({Key? key}) : super(key: key);

  @override
  PhysicalTeamCardsState createState() => PhysicalTeamCardsState();
}

class PhysicalTeamCardsState extends State<PhysicalTeamCards> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  int activeType = 1;
  int sortType = -1;
  int subSortType = 0;
  final searchCtl = TextEditingController();
  bool showSortModal = false;
  bool showSubSortModal = false;
  var transactionArr = [
    {
      'id': 0,
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'available': '1,200.00',
      'monthly': '600.00',
      'status': 'Active'
    },
    {
      'id': 1,
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'available': '1,200.00',
      'monthly': '600.00',
      'status': 'Active'
    },
    {
      'id': 2,
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'available': '1,200.00',
      'monthly': '600.00',
      'status': 'Active'
    },
    {
      'id': 3,
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'available': '1,200.00',
      'monthly': '600.00',
      'status': 'Active'
    },
    {
      'id': 4,
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'available': '1,200.00',
      'monthly': '600.00',
      'status': 'Active'
    },
    {
      'id': 5,
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'available': '1,200.00',
      'monthly': '600.00',
      'status': 'Active'
    },
    {
      'id': 6,
      'userName': 'Erin Rosser',
      'cardNum': '2314',
      'available': '1,200.00',
      'monthly': '600.00',
      'status': 'Active'
    },
  ];

  var sortArr = [
    {'sortType': 'card holder', 'subType1': 'A - Z', 'subType2': 'Z - A'},
    {
      'sortType': 'available limit',
      'subType1': 'Highest to lowest',
      'subType2': 'Lowest to highest'
    },
    {
      'sortType': 'date issued',
      'subType1': 'Newest to oldest',
      'subType2': 'Oldest to newest'
    },
  ];

  handleCardType(type) {
    setState(() {
      activeType = type;
    });
  }

  handleSort() {
    setState(() {
      showSortModal = !showSortModal;
    });
  }

  handleSearch() {}

  handleCardDetail(data) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => const PhysicalPersonalCard()),
    );
  }

  sortCardHolder() {
    setState(() {
      showSortModal = false;
      sortType = 1;
    });
  }

  handleSortModal() {
    setState(() {
      showSortModal = !showSortModal;
    });
  }

  handleSubSortModal() {
    setState(() {
      showSubSortModal = !showSubSortModal;
    });
  }

  handleSortType(type) {
    setState(() {
      showSortModal = false;
      sortType = type;
    });
  }

  handleSubSortType(type) {
    setState(() {
      showSubSortModal = false;
      subSortType = type;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: wScale(24), right: wScale(24)),
      child: Indexer(children: [
        Indexed(index: 100, child: headerField()),
        Indexed(
            index: 50,
            child: Column(
              children: [
                const CustomSpacer(size: 60),
                searchField(),
                Indexer(children: [
                  Indexed(
                      index: 200,
                      child: sortType >= 0 ? subSortField() : const SizedBox()),
                  Indexed(
                      index: 40,
                      child: Column(
                        children: [
                          sortType >= 0
                              ? const CustomSpacer(size: 60)
                              : const SizedBox(),
                          sortType < 0
                              ? const CustomSpacer(size: 10)
                              : const SizedBox(),
                          getTransactionArrWidgets(transactionArr)
                        ],
                      ))
                ])
                // const CustomSpacer(size: 15),
                // getTransactionArrWidgets(transactionArr),
              ],
            )),
      ]),
    );
  }

  Widget headerField() {
    return Stack(overflow: Overflow.visible, children: [
      headerSortField(),
      showSortModal
          ? Positioned(top: hScale(50), right: 0, child: modalField())
          : const SizedBox()
    ]);
  }

  Widget headerSortField() {
    return Container(
      height: hScale(200),
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
              handleSort();
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
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: wScale(5)),
        // textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
      ),
      onPressed: () {
        handleCardType(type);
      },
      child: Container(
        height: hScale(35),
        padding: EdgeInsets.only(left: wScale(6), right: wScale(6)),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: type == activeType
                        ? const Color(0xFF29C490)
                        : const Color(0xFFEEEEEE),
                    width: type == activeType ? hScale(2) : hScale(1)))),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(14),
              color: type == activeType
                  ? const Color(0xff1A2831)
                  : const Color(0xff70828D)),
        ),
      ),
    );
  }

  Widget searchField() {
    return Container(
        height: hScale(36),
        padding: EdgeInsets.only(left: wScale(15), right: wScale(15)),
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
                // height: hScale(24),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: searchCtl,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)),
                    hintText: 'Card Holders , Cards…',
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
                    handleSearch();
                  },
                  // child: _rounded, color: Color(0xFF7B7E80), size: 20 ),
                  child: Image.asset(
                    'assets/search_icon.png',
                    fit: BoxFit.contain,
                    width: wScale(13),
                  )),
            ),
          ],
        ));
  }

  Widget collapseField(data) {
    return ExpandableNotifier(
      initialExpanded: data['id'] == 0 ? true : false,
      child: Container(
        margin: EdgeInsets.only(bottom: hScale(5)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
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

  Widget getTransactionArrWidgets(arr) {
    return Column(
        children: arr.map<Widget>((item) {
      return collapseField(item);
    }).toList());
  }

  Widget cardHeader(data) {
    return Container(
        width: wScale(327),
        // height: hScale(50),
        padding: EdgeInsets.only(
            left: wScale(16),
            right: wScale(16),
            top: hScale(8),
            bottom: hScale(8)),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2931),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(hScale(10)),
            topRight: Radius.circular(hScale(10)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['userName'],
                style: TextStyle(fontSize: fSize(12), color: Colors.white)),
            Text('**** **** **** ${data["cardNum"]}',
                style: TextStyle(fontSize: fSize(12), color: Colors.white)),
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
            cardBodyDetail('Available Limit', data['available'], 0),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            cardBodyDetail('Monthly Spend Limit', data['monthly'], 1),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            cardBodyDetail('Status', data['status'], 2),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            TextButton(
              style: TextButton.styleFrom(
                primary: const Color(0xff1da7ff),
                textStyle: TextStyle(
                    fontSize: fSize(14),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff1da7ff)),
              ),
              onPressed: () {
                handleCardDetail(data);
              },
              child: const Text('View Card Details'),
            ),
          ],
        ));
  }

  Widget cardBodyDetail(title, value, type) {
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
                    fontSize: fSize(12), color: const Color(0xFF70828D))),
            Container(
                padding: EdgeInsets.only(
                    left: wScale(16),
                    right: wScale(16),
                    top: hScale(5),
                    bottom: hScale(5)),
                decoration: BoxDecoration(
                  color:
                      type != 1 ? const Color(0xFFDEFEE9) : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(hScale(16)),
                    topRight: Radius.circular(hScale(16)),
                    bottomLeft: Radius.circular(hScale(16)),
                    bottomRight: Radius.circular(hScale(16)),
                  ),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      type != 2
                          ? Text('SGD ',
                              style: TextStyle(
                                  fontSize: fSize(8),
                                  color: type != 1
                                      ? const Color(0xFF30E7A9)
                                      : const Color(0xFF1A2831)))
                          : SizedBox(),
                      Text(value,
                          style: TextStyle(
                              fontSize: fSize(14),
                              fontWeight: FontWeight.w600,
                              color: type != 1
                                  ? const Color(0xFF30E7A9)
                                  : const Color(0xFF1A2831)))
                    ]))
          ],
        ));
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
          modalButton('Sort by ${sortArr[0]['sortType']}', 0, 0),
          modalButton('Sort by ${sortArr[1]['sortType']}', 1, 0),
          modalButton('Sort by ${sortArr[2]['sortType']}', 2, 0)
        ],
      ),
    );
  }

  Widget modalButton(title, type, style) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: style == 0
            ? sortType == type
                ? const Color(0xFF29C490)
                : Colors.black
            : subSortType == type
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
        style == 0 ? handleSortType(type) : handleSubSortType(type);
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

  Widget subSortField() {
    return Stack(overflow: Overflow.visible, children: [
      sortField(),
      showSubSortModal
          ? Positioned(
              top: hScale(50), right: 0, child: subSortTypeModalField())
          : const SizedBox()
    ]);
  }

  Widget sortField() {
    return Container(
      height: hScale(500),
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Sorted by: ${sortArr[sortType]['sortType']}',
              style: TextStyle(
                  fontSize: fSize(12),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1B2931))),
          sortValue()
        ],
      ),
    );
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
          sortType != -1
              ? modalButton(sortArr[sortType]['subType1'], 0, 1)
              : const SizedBox(),
          sortType != -1
              ? modalButton(sortArr[sortType]['subType2'], 1, 1)
              : const SizedBox()
        ],
      ),
    );
  }

  Widget sortValue() {
    return TextButton(
        style: TextButton.styleFrom(
          primary: const Color(0xffffffff),
          padding: const EdgeInsets.all(0),
        ),
        child: Container(
          padding:
              EdgeInsets.symmetric(vertical: hScale(3), horizontal: wScale(16)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: const Color(0xFF040415).withOpacity(0.1))),
          child: Row(children: [
            Text(
                subSortType == 0
                    ? '${sortArr[sortType]['subType1']}'
                    : '${sortArr[sortType]['subType2']}',
                style: TextStyle(
                    fontSize: fSize(12), color: const Color(0xFF1B2931))),
            SizedBox(width: wScale(12)),
            SizedBox(
              width: wScale(12),
              child: Icon(Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFFBFBFBF), size: fSize(24)),
            )
          ]),
        ),
        onPressed: () {
          handleSubSortModal();
        });
  }
}

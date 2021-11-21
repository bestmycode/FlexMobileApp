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
  int sortType = 1;
  final searchCtl = TextEditingController();
  bool showModal = false;
  var transactionArr = [
    {'id': 0, 'userName':'Erin Rosser', 'cardNum':'2314', 'available':'1,200.00', 'monthly': '600.00', 'status': 'Active'},
    {'id': 1, 'userName':'Erin Rosser', 'cardNum':'2314', 'available':'1,200.00', 'monthly': '600.00', 'status': 'Active'},
    {'id': 2, 'userName':'Erin Rosser', 'cardNum':'2314', 'available':'1,200.00', 'monthly': '600.00', 'status': 'Active'},
    {'id': 3, 'userName':'Erin Rosser', 'cardNum':'2314', 'available':'1,200.00', 'monthly': '600.00', 'status': 'Active'},
    {'id': 4, 'userName':'Erin Rosser', 'cardNum':'2314', 'available':'1,200.00', 'monthly': '600.00', 'status': 'Active'},
    {'id': 5, 'userName':'Erin Rosser', 'cardNum':'2314', 'available':'1,200.00', 'monthly': '600.00', 'status': 'Active'},
    {'id': 6, 'userName':'Erin Rosser', 'cardNum':'2314', 'available':'1,200.00', 'monthly': '600.00', 'status': 'Active'},
  ];

  handleCardType(type) {
    setState(() {
      activeType = type;
    });
  }

  handleSort() {
    setState(() {
      showModal = !showModal;
    });
  }

  handleSearch() {

  }

  handleCardDetail(data) {
    Navigator.of(context).push(
      CupertinoPageRoute (
          builder: (context) => const PhysicalPersonalCard()
      ),
    );
  }

  sortCardHolder() {
    setState(() {
      showModal = false;
      sortType = 1;
    });
  }

  sortAvailableLimit() {
    setState(() {
      showModal = false;
      sortType = 2;
    });
  }

  sortDateIssued() {
    setState(() {
      showModal = false;
      sortType = 3;
    });
  }

    @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left:wScale(24), right: wScale(24)),
        child: Indexer(
            children: [
              Indexed(index: 100, child: headerField()),
              Indexed(index: 50, child: Column(
                children: [
                  const CustomSpacer(size: 60),
                  searchField(),
                  const CustomSpacer(size: 15),
                  getTransactionArrWidgets(transactionArr),
                ],
              )),
            ]
        ),
    );
  }

  Widget headerField() {
    return Stack(
        overflow: Overflow.visible,
        children: [
          headerSortField(),
          showModal ? Positioned(
              top: hScale(50),
              right:0,
              child: modalField()
          ): const SizedBox()
        ]
    );
  }

  Widget headerSortField() {
    return Container(
      margin: EdgeInsets.only(top: hScale(13)),
      height: hScale(200),
      alignment: Alignment.topCenter,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
                children: [
                  activeButton('Active Cards', 1),
                  activeButton('Inactive Cards', 2),
                ]
            ),
            TextButton(
                style: TextButton.styleFrom(
                  primary: const Color(0xff70828D),
                  padding: const EdgeInsets.all(0),
                  textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
                ),
                onPressed: () { handleSort(); },
                child:Row(
                  children: [
                    Icon(Icons.swap_vert_rounded, color: const Color(0xff29C490),size: hScale(18)),
                    Text('Sort by', style: TextStyle(fontSize: fSize(12)))
                  ],
                )
            ),
          ]
      ),
    );
  }

  Widget activeButton(title, type) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff70828D),
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: wScale(5)),
        // textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
      ),
      onPressed: () { handleCardType(type); },
      child: Container(
        height: hScale(35),
        padding: EdgeInsets.only(left: wScale(6),right: wScale(6)),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(
                color: type == activeType ? const Color(0xFF29C490): const Color(0xFFEEEEEE),
                width: type == activeType ? hScale(2): hScale(1)))
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(14),
              color: type == activeType ? const Color(0xff1A2831) : const Color(0xff70828D)),
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
          border: Border.all(color: const Color(0xff040415).withOpacity(0.1), width: hScale(1)),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(hScale(10)),
            topRight: Radius.circular(hScale(10)),
            bottomLeft: Radius.circular(hScale(10)),
            bottomRight: Radius.circular(hScale(10)),
          ),
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
                enabledBorder: const OutlineInputBorder( borderSide: BorderSide(color: Colors.transparent) ),
                hintText: 'Card Holders , Cards…',
                hintStyle: TextStyle( color: const Color(0xff040415).withOpacity(0.5), fontSize: fSize(12), fontWeight: FontWeight.w500),
                focusedBorder: const OutlineInputBorder( borderSide: BorderSide(color: Colors.transparent) ),
              ),
              style: TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w500),
              scrollPadding: EdgeInsets.zero,
            )
          ),
          SizedBox(
            width: wScale(20),
            child: TextButton(
              style: TextButton.styleFrom(
                primary: const Color(0xff70828D),
                padding: const EdgeInsets.all(0),
                textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
              ),
              onPressed: () { handleSearch(); },
              // child: _rounded, color: Color(0xFF7B7E80), size: 20 ),
              child: Image.asset('assets/search_icon.png', fit:BoxFit.contain, width: wScale(13),)
            ),
          ),
        ],
      )
    );
  }

  Widget collapseField(data) {
    return ExpandableNotifier(
      initialExpanded: data['id'] == 0 ? true : false,
      child: Container(
        margin: EdgeInsets.only(bottom: hScale(5)),
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
          children: [
            ScrollOnExpand(
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                    tapBodyToCollapse: true,
                    tapBodyToExpand: true
                ),
                expanded: Column(
                  children: [
                    cardHeader(data),
                    cardBody(data)
                  ],
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
    return Column(children: arr.map<Widget>((item) {
      return collapseField(item);
    }).toList());
  }

  Widget cardHeader(data) {
    return Container(
      width: wScale(327),
      // height: hScale(50),
      padding: EdgeInsets.only(left: wScale(16), right: wScale(16),top: hScale(8), bottom: hScale(8)),
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
          Text(data['userName'], style: TextStyle(fontSize: fSize(12), color: Colors.white)),
          Text('**** **** **** ${data["cardNum"]}', style: TextStyle(fontSize: fSize(12), color: Colors.white)),
        ],
      )
    );
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
                textStyle: TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w500,
                    color: const Color(0xff1da7ff)),
              ),
              onPressed: () { handleCardDetail(data); },
              child: const Text('View Card Details'),
            ),
          ],
        )
    );
  }

  Widget cardBodyDetail(title, value, type) {
    return Container(
      padding: EdgeInsets.only(top:hScale(10), bottom: hScale(10), left: wScale(16), right: wScale(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: fSize(12), color: const Color(0xFF70828D))),
          Container(
              padding: EdgeInsets.only(left: wScale(16), right: wScale(16), top:hScale(5), bottom: hScale(5)),
              decoration: BoxDecoration(
                color: type!=1 ? const Color(0xFFDEFEE9) : Colors.transparent,
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
                  type != 2 ? Text('SGD ', style: TextStyle(fontSize: fSize(8),
                      color: type != 1 ? const Color(0xFF30E7A9): const Color(0xFF1A2831))) : SizedBox(),
                  Text(value, style:TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w600,
                      color: type != 1 ? const Color(0xFF30E7A9): const Color(0xFF1A2831)))
                ]
              )
          )
        ],
      )
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
          modalButton('Sort by card holder', 1),
          modalButton('Sort by available limit', 2),
          modalButton('Sort by date issued', 3)
        ],
      ),
    );
  }

  Widget modalButton(title, type) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: sortType == type ? const Color(0xFF29C490) : Colors.black,
        padding: EdgeInsets.only(top: hScale(10), bottom: hScale(10), left: wScale(16), right: wScale(16)),
        textStyle: TextStyle(fontSize: fSize(14), color: Colors.black),
      ),
      onPressed: () {
        if(type == 1) {
          sortCardHolder();
        } else if(type==2) {
          sortAvailableLimit();
        } else {
          sortDateIssued();
        }
      },
      child: Container(
        width: wScale(177),
        padding: EdgeInsets.only(top:hScale(6), bottom: hScale(6)),
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

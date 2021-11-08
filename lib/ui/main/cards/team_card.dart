import 'package:flexflutter/ui/main/cards/personal_card.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';
import 'package:expandable/expandable.dart';

class TeamCards extends StatefulWidget {
  const TeamCards({Key? key}) : super(key: key);

  @override
  TeamCardsState createState() => TeamCardsState();
}

class TeamCardsState extends State<TeamCards> {

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
  final searchCtl = TextEditingController();
  bool showModal = false;
  var transactionArr = [
    {'userName':'Erin Rosser', 'cardNum':'2314', 'available':'1,200.00', 'monthly': '600.00', 'status': 'active'},
    {'userName':'Erin Rosser', 'cardNum':'2314', 'available':'1,200.00', 'monthly': '600.00', 'status': 'active'},
    {'userName':'Erin Rosser', 'cardNum':'2314', 'available':'1,200.00', 'monthly': '600.00', 'status': 'active'},
    {'userName':'Erin Rosser', 'cardNum':'2314', 'available':'1,200.00', 'monthly': '600.00', 'status': 'active'},
    {'userName':'Erin Rosser', 'cardNum':'2314', 'available':'1,200.00', 'monthly': '600.00', 'status': 'active'},
    {'userName':'Erin Rosser', 'cardNum':'2314', 'available':'1,200.00', 'monthly': '600.00', 'status': 'active'},
    {'userName':'Erin Rosser', 'cardNum':'2314', 'available':'1,200.00', 'monthly': '600.00', 'status': 'active'},
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
          builder: (context) => const PersonalCard()
      ),
    );
  }

  sortCardHolder() {
    setState(() {
      showModal = false;
    });
    print('------++++++++++++++');
  }

  sortAvailableLimit() {
    setState(() {
      showModal = false;
    });
  }

  sortDateIssued() {
    setState(() {
      showModal = false;
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
        child: Column(
            children: [
              headerField(),
              const CustomSpacer(size: 15),
              searchField(),
              const CustomSpacer(size: 15),
              getTransactionArrWidgets(transactionArr),
              const CustomSpacer(size: 70),
            ]
        ),
    );
  }

  Widget headerField() {
    return Container(
        // width: MediaQuery.of(context).size.width,
        child: Stack(
          // alignment: Alignment.center,
            overflow: Overflow.visible,
            children: [
              headerSortField(),
              showModal ? Positioned(
                  top: hScale(50),
                  right:0,
                  child: modalField()
              ): const SizedBox()
            ]
        )
    );
  }

  Widget headerSortField() {
    return Row(
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
    );
  }

  Widget activeButton(title, type) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff70828D),
        padding: const EdgeInsets.all(0),
        textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
      ),
      onPressed: () { handleCardType(type); },
      child: Container(
        height: hScale(35),
        padding: EdgeInsets.only(left: wScale(6),right: wScale(6)),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(
                color: type == activeType ? Color(0xFF29C490): Color(0xFFEEEEEE),
                width: type == activeType ? hScale(2): hScale(1)))
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(14),
              color: const Color(0xff70828D)),
        ),
      ),
    );
  }

  Widget searchField() {
    return Container(
      padding: EdgeInsets.only(left: wScale(15), right: wScale(15), top: hScale(6), bottom: hScale(6)),
        decoration: BoxDecoration(
          color: const Color(0xffffffff),
          border: Border.all(color: Color(0xff040415), width: hScale(1)),
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
            height: hScale(24),
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              controller: searchCtl,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(0),
                enabledBorder: const OutlineInputBorder( borderSide: BorderSide(color: Colors.transparent) ),
                hintText: 'Card Holders , Cards…',
                hintStyle: TextStyle(
                    color: const Color(0xff040415).withOpacity(0.5),
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w500),
                focusedBorder: const OutlineInputBorder( borderSide: BorderSide(color: Colors.transparent) ),
              ),
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
              child: const Icon( Icons.search_rounded, color: Colors.black, size: 20 ),
            ),
          ),
        ],
      )
    );
  }

  Widget collapseField(data) {
    return ExpandableNotifier(
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Card(
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
            cardBodyDetail('Available Limit', data['available']),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            cardBodyDetail('Monthly Spend Limit', data['monthly']),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            cardBodyDetail('Status', data['status']),
            Container(height: 1, color: const Color(0xFFF1F1F1)),
            TextButton(
              style: TextButton.styleFrom(
                primary: const Color(0xff1da7ff),
                textStyle: TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w500,
                    color: const Color(0xff1da7ff), decoration: TextDecoration.underline),
              ),
              onPressed: () { handleCardDetail(data); },
              child: const Text('View Card Details'),
            ),
          ],
        )
    );
  }

  Widget cardBodyDetail(title, value) {
    return Container(
      padding: EdgeInsets.only(top:hScale(10), bottom: hScale(10), left: wScale(16), right: wScale(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: fSize(12))),
          Container(
              padding: EdgeInsets.only(left: wScale(16), right: wScale(16), top:hScale(5), bottom: hScale(5)),
              decoration: BoxDecoration(
                color: const Color(0xFFDEFEE9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(hScale(16)),
                  topRight: Radius.circular(hScale(16)),
                  bottomLeft: Radius.circular(hScale(16)),
                  bottomRight: Radius.circular(hScale(16)),
                ),
              ),
              child: Text(value, style:TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w600, color: const Color(
                  0xFF30E7A9)))
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
      autofocus: true,
      style: TextButton.styleFrom(
        primary: Colors.black,
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
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

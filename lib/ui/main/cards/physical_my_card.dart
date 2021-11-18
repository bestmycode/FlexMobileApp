import 'package:flexflutter/ui/main/cards/manage_limits.dart';
import 'package:flexflutter/ui/widgets/custom_header.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flexflutter/ui/widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';
import 'package:indexed/indexed.dart';

class PhysicalMyCards extends StatefulWidget {
  const PhysicalMyCards({Key? key}) : super(key: key);

  @override
  PhysicalMyCardsState createState() => PhysicalMyCardsState();
}

class PhysicalMyCardsState extends State<PhysicalMyCards> {

  hScale(double scale) {
    return Scale().hScale(context, scale);
  }
  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  int cardType = 1;
  int transactionStatus = 1;
  var transactionArr = [
    {'date':'21 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage1', 'status':0, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'22 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage2', 'status':1, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'23 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage3', 'status':1, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'24 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage4', 'status':0, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'25 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage5', 'status':0, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'26 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage6', 'status':1, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'},
    {'date':'27 June 2021', 'time':'03:45 AM', 'transactionName':'Mobile Phone Rechage7', 'status':1, 'userName':'Erin Rosser', 'cardNum':'2314', 'value':'1,200.00'}
  ];
  bool showDateRange = false;
  bool showCalendarModal = false;
  bool showCardDetail = true;
  int dateType = 1;
  final searchCtl = TextEditingController();
  final startDateCtl = TextEditingController();
  final endDateCtl = TextEditingController();

  handleBack() {

  }

  handleCardType(type) {
    setState(() {
      cardType = type;
    });
  }

  handleTransactionStatus(status) {
    setState(() {
      transactionStatus = status;
    });
  }

  handleExport() {

  }

  handleCloneSetting() {

  }

  handleSearch() {

  }

  handleCalendar() {
    setState(() {
      showCalendarModal = !showCalendarModal;
    });
  }

  setDateType(type) {
    if(type == 4) {
      setState(() {
        showDateRange = !showDateRange;
        showCalendarModal = false;
        dateType = type;
      });
    } else {
      setState(() {
        showCalendarModal = false;
        showDateRange = false;
        dateType = type;
      });
    }
  }

  handleMonthlySpendLimit() {

  }

  handleAction(index) {
    if(index == 0 ) _showSimpleModalDialog(context);
    if(index == 1) {
      Navigator.of(context).push(
        CupertinoPageRoute (
            builder: (context) => const ManageLimits()
        ),
      );
    }
  }

  handleShowCardDetail() {
    setState(() {
      showCardDetail = !showCardDetail;
    });
  }

  handleStartDateCalendar() {

  }

  handleEndDateCalendar() {

  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomSpacer(size: 31),
        cardDetailField(),
        const CustomSpacer(size: 10),
        spendLimitField(),
        const CustomSpacer(size: 20),
        actionButtonField(),
        const CustomSpacer(size: 20),
        allTransactionField(),
        const CustomSpacer(size: 15),
        Indexer(
            children: [
              Indexed(index: 100, child: searchRowField()),
              Indexed(index: 50, child: Column(
                children: [
                  const CustomSpacer(size: 45),
                  showDateRange ? dateRangeField() : const SizedBox(),
                  getTransactionArrWidgets(transactionArr),
                ],
              )),
            ]
        ),
      ]
    );
  }

  Widget cardDetailField() {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(left: wScale(16), right: wScale(16), bottom: hScale(16)),
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
            color: const Color(0xFF106549).withOpacity(0.1),
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
          cardTitle(),
          const CustomSpacer(size: 10),
          cardField(),
          const CustomSpacer(size: 14),
          cardValueField()
        ],
      ),
    );
  }

  Widget cardTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('My Card', style:TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w600, color: const Color(0xFF1A2831))),
        TextButton(
          style: TextButton.styleFrom(
            primary: const Color(0xff60C094),
            padding: EdgeInsets.zero,
            textStyle: TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w600, color: const Color(0xff60C094), decoration: TextDecoration.underline),
          ),
          onPressed: () { handleCloneSetting(); },
          child: const Text('Clone Settings', style:TextStyle(decoration: TextDecoration.underline)),
        ),
      ],
    );
  }

  Widget cardField() {
    return Container(
        width: wScale(295),
        height: wScale(187),
        padding: EdgeInsets.all(hScale(16)),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/physical_card_detail.png"),
            fit: BoxFit.contain,
          ),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  eyeIconField()
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Angel Matthews', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w100, fontSize: fSize(14))),
                  const CustomSpacer(size: 6),
                  Row(
                      children:[
                        Text(showCardDetail ? '2145 4587 4875 1211': '* * * *  * * * *  * * * *  * * * *' , style: TextStyle(color: Colors.white, fontSize: fSize(16))),
                        SizedBox(width: wScale(7)),
                        const Icon( Icons.content_copy, color: Color(0xff30E7A9), size: 14.0 )
                      ]
                  ),
                ],
              ),
              Row(
                  children:[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Valid Thru', style: TextStyle(color: Colors.white, fontSize: fSize(10))),
                        Text(showCardDetail ? '12/20' : 'MM / DD', style: TextStyle(color: Colors.white, fontSize: fSize(11), fontWeight: FontWeight.bold))
                      ],
                    ),
                    SizedBox(width: wScale(10)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CVV', style: TextStyle(color: Colors.white, fontSize: fSize(10))),
                        Text(showCardDetail ? '214' : '* * *', style: TextStyle(color: Colors.white, fontSize: fSize(11), fontWeight: FontWeight.bold))
                      ],
                    ),
                    SizedBox(width: wScale(6)),
                    const Icon( Icons.content_copy, color: Color(0xff30E7A9), size: 14.0 )
                  ]
              )
            ]
        )
    );
  }

  Widget cardValueField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Available Limit', style:TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w600)),
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
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SGD', style:TextStyle(fontSize: fSize(10), fontWeight: FontWeight.w600, color: const Color(0xFF30E7A9))),
                SizedBox(width: wScale(3)),
                Text('3,000.00', style:TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w600, color: const Color(0xFF30E7A9)))
              ],
            )
        )
      ],
    );
  }

  Widget eyeIconField() {
    return Container(
        height: hScale(34),
        width: hScale(34),
        // padding: EdgeInsets.all(hScale(17)),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(hScale(17)),
              topRight: Radius.circular(hScale(17)),
              bottomLeft: Radius.circular(hScale(17)),
              bottomRight: Radius.circular(hScale(17)),
            )
        ),
        child: IconButton(
          padding: const EdgeInsets.all(0),
          // icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xff30E7A9),),
          icon: Image.asset(showCardDetail ? 'assets/hide_eye.png' : 'assets/show_eye.png', fit: BoxFit.contain, height: hScale(16)),
          iconSize: hScale(17),
          onPressed: () { handleShowCardDetail(); },
        )
    );
  }

  Widget spendLimitField() {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(left: wScale(16), right: wScale(16), top: hScale(16), bottom: hScale(16)),
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
            color: const Color(0xFF106549).withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 20,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          primary: const Color(0xFFFFFFFF),
          padding: EdgeInsets.zero,
        ),
        onPressed: () { handleMonthlySpendLimit(); },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Monthly Spend Limit', style:TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w600, color: const Color(0xFF1A2831))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SGD', style:TextStyle(fontSize: fSize(10), fontWeight: FontWeight.w600, color: const Color(0xFF1A2831))),
                    SizedBox(width: wScale(3)),
                    Text('5000.00', style:TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w600, color: const Color(0xFF1A2831))),
                  ]
                )

              ],
            ),
            const CustomSpacer(size: 12),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: LinearProgressIndicator( value: 0.8, backgroundColor: const Color(0xFFF4F4F4), color: const Color(0xFF30E7A9), minHeight: hScale(10),),
            ),
            const CustomSpacer(size: 12),
            Row(
              children: [
                Image.asset('assets/happy_emoji.png', fit: BoxFit.contain, width: wScale(18)),
                SizedBox(width: wScale(10)),
                Text('Great job, you are within your allocated limit!', style:TextStyle(fontSize: fSize(12), color: const Color(0xFF70828D))),
              ],
            )

          ],
        )
      ),
    );
  }

  Widget actionButton(imageUrl, text, index) {
    return Container(
        width: wScale(102),
        // height: hScale(82),
        padding: EdgeInsets.only(left: wScale(16), right: wScale(16), top: hScale(16), bottom: hScale(16)),
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
              color: const Color(0xFF106549).withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 40,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),

        child: TextButton(
            style: TextButton.styleFrom(
                primary: const Color(0xFFFFFFFF),
                padding: EdgeInsets.zero
            ),
            onPressed: () { handleAction(index); },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(imageUrl, fit: BoxFit.contain, height: hScale(24), width: wScale(28),),
                const CustomSpacer(size: 10,),
                Text(text, style:TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w500, color: const Color(0xFF70828D)), textAlign: TextAlign.center,),
              ],
            )
        )
    );
  }

  Widget actionButtonField() {
    return SizedBox(
      width: wScale(327),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            actionButton('assets/free.png', 'Freeze Card', 0),
            actionButton('assets/limit.png', 'Edit Limit', 1),
            actionButton('assets/cancel.png', 'Cancel Card', 2),
          ]
      ),
    );
  }

  Widget allTransactionField() {
    return SizedBox(
      width: wScale(327),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('All Transactions', style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w500)),
              // TextButton(
              //   style: TextButton.styleFrom(
              //     primary: const Color(0xff30E7A9),
              //     textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff30E7A9)),
              //   ),
              //   onPressed: () { handleExport(); },
              //   child: const Text('Export', style:TextStyle(decoration: TextDecoration.underline)),
              // ),
            ],
          ),
          const CustomSpacer(size: 10),
          transactionStatusField()
        ],
      ),
    );
  }

  Widget transactionStatusField() {
    return Container(
      width: wScale(327),
      height: hScale(34),
      padding: EdgeInsets.all(hScale(2)),
      decoration: BoxDecoration(
        color: const Color(0xfff5f5f6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(hScale(17)),
          topRight: Radius.circular(hScale(17)),
          bottomLeft: Radius.circular(hScale(17)),
          bottomRight: Radius.circular(hScale(17)),
        ),
      ),
      child: Row(
          children: [
            transactionStatusButton('Completed', 1, const Color(0xFF70828D)),
            transactionStatusButton('Pending', 2, const Color(0xFF1A2831)),
            transactionStatusButton('Declined', 3, const Color(0xFFEB5757))
          ]
      ),
    );
  }

  Widget transactionStatusButton(status, type, textColor) {
    return type == transactionStatus ?
    ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          primary: const Color(0xffffffff),
          side: const BorderSide(width: 0,color: Color(0xffffffff)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
        ),
        onPressed: () { handleTransactionStatus(type); },
        child: Container(
          width: wScale(107),
          height: hScale(30),
          alignment: Alignment.center,
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: fSize(14),
                color: textColor),
          ),
        )
    ) : TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff70828D),
        padding: const EdgeInsets.all(0),
        textStyle: TextStyle(fontSize: fSize(14), color: const Color(0xff70828D)),
      ),
      onPressed: () { handleTransactionStatus(type); },
      child: Container(
        width: wScale(107),
        height: hScale(30),
        alignment: Alignment.center,
        child: Text(
          status,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fSize(14),
              color: textColor),
        ),
      ),
    );
  }

  Widget transactionField(date, transactionName, value, status) {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(left: wScale(16), right: wScale(16), top: hScale(16), bottom: hScale(16)),
      margin: EdgeInsets.only(bottom: hScale(16)),
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
            color: const Color(0xFF106549).withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 20,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              transactionTimeField(date),
              const CustomSpacer(size: 6),
              transactionNameField(transactionName),
              const CustomSpacer(size: 6),
              moneyValue('', value, 14.0, FontWeight.w700, status==0 ? const Color(0xFF1A2831) : const Color(0xff60C094)),
            ],
          ),
          SizedBox(
            width: wScale(16),
            height: hScale(18),
            child: status == 0
                ? Image.asset( 'assets/add_transaction.png', fit: BoxFit.contain, width: wScale(16))
                : Image.asset( 'assets/check_transaction.png', fit: BoxFit.contain, width: wScale(16))
          )
        ],
      )
    );
  }

  Widget transactionTimeField(date) {
    return Text('$date',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xff70828D)));
  }

  Widget transactionNameField(name) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fSize(16),
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        children: [
          TextSpan(text: name),
        ],
      ),
    );
  }

  Widget moneyValue(title, value, size, weight, color) {
    return SizedBox(
      width: wScale(263),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
              title,
              style: TextStyle(fontSize: fSize(12), color: Colors.white)),
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Text("SGD  ",
                    style: TextStyle(fontSize: fSize(12), fontWeight: weight, color: color)),
                Text(value,
                    style: TextStyle(fontSize: fSize(size), fontWeight: weight, color: color)),
              ]
          )
        ],
      ),
    );
  }

  Widget getTransactionArrWidgets(arr) {
    return Column(children: arr.map<Widget>((item) {
      return transactionField(item['date'], item['transactionName'], item['value'], item['status']);
    }).toList());
  }

  _showSimpleModalDialog(context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(12.0)),
          child: modalField()
        );
    });
  }

  Widget modalField() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container (
              padding: EdgeInsets.symmetric(vertical: hScale(25)),
              child: Column(
                  children: [
                    Image.asset('assets/snow_icon.png', fit: BoxFit.contain, height: wScale(30)),
                    const CustomSpacer(size: 15),
                    Text('Editing spend limit?', style:TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w700)),
                    const CustomSpacer(size: 10),
                    Text('To make changes to the spend limit\nassigned to this card, please reach out to\nyour company administrator.',
                      style:TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
                  ]
              )
          ),
          Container(height: 1,color: const Color(0xFFD5DBDE)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: hScale(30), horizontal: wScale(25)),
                  primary: const Color(0xff30E7A9),
                  textStyle: TextStyle(fontSize: fSize(16), color: const Color(0xff30E7A9)),
                ),
                onPressed: () => Navigator.of(context, rootNavigator: true).pop('dialog'),
                child: const Text('Cancel'),
              ),
              Container(width: 1, color: const Color(0xFFD5DBDE)),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: hScale(30)),
                  primary: const Color(0xff30E7A9),
                  textStyle: TextStyle(fontSize: fSize(16), color: const Color(0xff30E7A9)),
                ),
                onPressed: () { Navigator.of(context, rootNavigator: true).pop('dialog'); },
                child: const Text('Ok'),
              )
            ],
          )
        ]
    );
  }

  Widget searchField() {
    return Container(
        width: wScale(212),
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
                width: wScale(150),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: searchCtl,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0),
                    enabledBorder: const OutlineInputBorder( borderSide: BorderSide(color: Colors.transparent) ),
                    hintText: 'Type your search here',
                    hintStyle: TextStyle(
                        color: const Color(0xff040415).withOpacity(0.5),
                        fontSize: fSize(12),
                        fontWeight: FontWeight.w500),
                    focusedBorder: const OutlineInputBorder( borderSide: BorderSide(color: Colors.transparent) ),
                  ),
                  style: TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w500),
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
                // child: const Icon( Icons.search_rounded, color: Color(0xFFBFBFBF), size: 20 ),
                  child: Image.asset('assets/search_icon.png', fit:BoxFit.contain, width: wScale(13),)
              ),
            ),
          ],
        )
    );
  }

  Widget searchRowField() {
    return Stack(
        overflow: Overflow.visible,
        children: [
          searchRow(),
          showCalendarModal ? Positioned(
              top: hScale(50),
              right:0,
              child: calendarModalField()
          ): const SizedBox()
        ]
    );
  }

  Widget searchRow() {
    return Container(
        width: wScale(327),
        height: hScale(200),
        alignment: Alignment.topCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            searchField(),
            SizedBox(
              width: wScale(24),
              height: wScale(24),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                ),
                child: Image.asset('assets/calendar.png', fit: BoxFit.contain, width: wScale(24)),
                onPressed: () { handleCalendar();},
              ),
            ),
            SizedBox(
              width: wScale(40),
              child: TextButton(
                style: TextButton.styleFrom(
                  primary: const Color(0xff30E7A9),
                  padding: const EdgeInsets.all(0),
                  textStyle: TextStyle(fontSize: fSize(12), color: const Color(0xff30E7A9),decoration: TextDecoration.underline),
                ),
                onPressed: () { handleExport(); },
                child: const Text('Export'),
              ),
            )
          ],
        )
    );
  }

  Widget exportButton() {
    return SizedBox(
        width: wScale(295),
        height: hScale(56),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
            ),
          ),
          onPressed: () { handleSearch(); },
          child: Text(
              "Export",
              style: TextStyle(color: Colors.white, fontSize: fSize(16), fontWeight: FontWeight.w700 )),
        )
    );
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
        primary: dateType == type ? const Color(0xFF29C490) : Colors.black,
        // padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
        textStyle: TextStyle(fontSize: fSize(14), color: Colors.black),
      ),
      onPressed: () { setDateType(type); },
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

  Widget dateRangeField() {
    return  Container(
        width: wScale(327),
        padding: EdgeInsets.only(left: wScale(16), right: wScale(16), top: hScale(16), bottom: hScale(16)),
        margin: EdgeInsets.only(bottom: hScale(16)),
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
              Text('Date Range', style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w500)),
              const CustomSpacer(size: 23),
              Stack(
                alignment: Alignment.center,
                children: [
                  CustomTextField(ctl: startDateCtl, hint: 'DD/MM/YYYY', label: 'Start Date'),
                  Positioned(
                    // bottom: 0,
                      right: 0,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                        ),
                        child: Image.asset('assets/calendar.png', fit: BoxFit.contain, width: wScale(24)),
                        onPressed: () { handleStartDateCalendar();},
                      )
                  ),
                ],
              ),
              const CustomSpacer(size: 23),
              Stack(
                alignment: Alignment.center,
                children: [
                  CustomTextField(ctl: endDateCtl, hint: 'DD/MM/YYYY', label: 'End Date'),
                  Positioned(
                    // bottom: 0,
                      right: 0,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                        ),
                        child: Image.asset('assets/calendar.png', fit: BoxFit.contain, width: wScale(24)),
                        onPressed: () { handleEndDateCalendar();},
                      )
                  ),
                ],
              ),
              const CustomSpacer(size: 17),
              searchButton()
            ]
        )
    );
  }

  Widget searchButton() {
    return SizedBox(
        width: wScale(295),
        height: hScale(56),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
            ),
          ),
          onPressed: () { handleSearch(); },
          child: Text(
              "Search",
              style: TextStyle(color: Colors.white, fontSize: fSize(16), fontWeight: FontWeight.w700 )),
        )
    );
  }
}
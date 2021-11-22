import 'package:flexflutter/ui/widgets/custom_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  var notificationArr = [
    {
      'title': 'Physical Card Issued.',
      'detail': 'Your physical card approved by Justin Curtis.',
      'date': 'Today',
      'time': '05:05PM'
    },
    {
      'title': 'Physical Card Issued.',
      'detail': 'Your physical card approved by Justin Curtis.',
      'date': 'Today',
      'time': '05:05PM'
    },
    {
      'title': 'Physical Card Issued.',
      'detail': 'Your physical card approved by Justin Curtis.',
      'date': 'Today',
      'time': '05:05PM'
    },
    {
      'title': 'Physical Card Issued.',
      'detail': 'Your physical card approved by Justin Curtis.',
      'date': 'Today',
      'time': '05:05PM'
    },
    {
      'title': 'Physical Card Issued.',
      'detail': 'Your physical card approved by Justin Curtis.',
      'date': 'Today',
      'time': '05:05PM'
    },
    {
      'title': 'Physical Card Issued.',
      'detail': 'Your physical card approved by Justin Curtis.',
      'date': 'Today',
      'time': '05:05PM'
    },
    {
      'title': 'Physical Card Issued.',
      'detail': 'Your physical card approved by Justin Curtis.',
      'date': 'Today',
      'time': '05:05PM'
    },
    {
      'title': 'Physical Card Issued.',
      'detail': 'Your physical card approved by Justin Curtis.',
      'date': 'Today',
      'time': '05:05PM'
    },
    {
      'title': 'Physical Card Issued.',
      'detail': 'Your physical card approved by Justin Curtis.',
      'date': 'Today',
      'time': '05:05PM'
    },
    {
      'title': 'Physical Card Issued.',
      'detail': 'Your physical card approved by Justin Curtis.',
      'date': 'Today',
      'time': '05:05PM'
    },
  ];

  handleBack() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Stack(children: [
      SizedBox(
        height: hScale(812),
        child: SingleChildScrollView(
            child: Column(children: [
          const CustomSpacer(size: 44),
          headerNotification(),
          const CustomSpacer(size: 39),
          showNotificationWidgets(notificationArr),
          const CustomSpacer(size: 88),
        ])),
      ),
      const Positioned(
        bottom: 0,
        left: 0,
        child: CustomBottomBar(active: 0),
      )
    ])));
  }

  Widget headerNotification() {
    return Row(children: [
      SizedBox(width: wScale(20)),
      IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: Colors.black, size: 20.0),
        onPressed: () {
          handleBack();
        },
      ),
      SizedBox(width: wScale(30)),
      Text('Notifications',
          style: TextStyle(fontSize: fSize(20), fontWeight: FontWeight.w600))
    ]);
  }

  Widget notificationField(title, detail, date, time) {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(
          left: wScale(16),
          right: wScale(16),
          top: hScale(16),
          bottom: hScale(16)),
      margin: EdgeInsets.only(bottom: hScale(10)),
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
          Text(title,
              style:
                  TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w500)),
          const CustomSpacer(size: 4),
          Text(detail,
              style:
                  TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w500)),
          const CustomSpacer(size: 8),
          Row(children: [
            Text('${date},',
                style: TextStyle(
                    fontSize: fSize(10), fontWeight: FontWeight.w500)),
            Text(time,
                style: TextStyle(
                    fontSize: fSize(10), fontWeight: FontWeight.w500)),
          ])
        ],
      ),
    );
  }

  Widget showNotificationWidgets(arr) {
    return Column(
        children: arr.map<Widget>((item) {
      return notificationField(
          item['title'], item['detail'], item['date'], item['time']);
    }).toList());
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class More extends StatefulWidget {
  const More({Key? key}) : super(key: key);

  @override
  MoreState createState() => MoreState();
}

class MoreState extends State<More> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(body: Align(child: Column(children: [Text("More")]))));
  }
}

import 'dart:async';

import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/utils/scale.dart';
import 'package:flexflutter/ui/widgets/custom_textfield.dart';

class Credit extends StatefulWidget {
  const Credit({Key? key}) : super(key: key);

  @override
  CreditState createState() => CreditState();
}

class CreditState extends State<Credit> {

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
        child: Scaffold(
            body: Align(
                child: Column(
                    children: [
                      Text("home")
                    ]
                )
            )
        )
    );
  }

}
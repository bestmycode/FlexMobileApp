import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

class Cards extends StatefulWidget {
  const Cards({Key? key}) : super(key: key);

  @override
  CardsState createState() => CardsState();
}

class CardsState extends State<Cards> {

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
                      Text("Cards")
                    ]
                )
            )
        )
    );
  }

}
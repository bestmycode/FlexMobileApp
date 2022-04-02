import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class CustomPopUpList extends StatelessWidget {
  final arrData;
  final onPress;
  const CustomPopUpList({Key? key, this.arrData, this.onPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    hScale(double scale) {
      return Scale().hScale(context, scale);
    }

    wScale(double scale) {
      return Scale().wScale(context, scale);
    }

    fSize(double size) {
      return Scale().fSize(context, size);
    }

    return SingleChildScrollView(
        child: Column(
            children: arrData.map<Widget>((item) {
      return Container(
          height: hScale(50),
          child: TextButton(
              style: TextButton.styleFrom(
                primary: const Color(0xff515151),
                padding: const EdgeInsets.all(0),
              ),
              onPressed: () {
                onPress(item['id']);
                Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
              },
              child: Container(
                  width: wScale(375),
                  alignment: Alignment.center,
                  child: Text("${item['firstName']} ${item['lastName']}"))));
    }).toList()));
  }
}

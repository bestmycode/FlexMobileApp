import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

class CustomHeader extends StatelessWidget {
  final String title;

  const CustomHeader({Key? key, this.title = ""}) : super(key: key);

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

    return Row(children: [
      SizedBox(width: wScale(20)),
      Container(
        width: hScale(40),
        height: hScale(40),
        padding: EdgeInsets.zero,
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
        child: TextButton(
            style: TextButton.styleFrom(
              primary: const Color(0xff70828D),
              padding: const EdgeInsets.all(0),
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
              size: 12,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
            }),
      ),
      SizedBox(width: wScale(30)),
      Text(title,
          style: TextStyle(fontSize: fSize(20), fontWeight: FontWeight.w600))
    ]);
  }
}

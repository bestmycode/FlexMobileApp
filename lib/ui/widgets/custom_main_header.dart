import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class CustomMainHeader extends StatelessWidget {
  final String title;

  const CustomMainHeader({Key? key, this.title = ""}) : super(key: key);

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
          color: const Color(0xFFF5F5F5).withOpacity(0.4),
          borderRadius: BorderRadius.all(Radius.circular(10)),
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
      SizedBox(width: wScale(15)),
      Text(title,
          style: TextStyle(
              fontSize: fSize(20),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2831)))
    ]);
  }
}

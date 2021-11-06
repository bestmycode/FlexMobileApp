import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

class CustomHeader extends StatelessWidget {
  final String title;

  const CustomHeader({Key? key, this.title = "" }) : super(key: key);

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
    return Row(
        children: [
          SizedBox(width: wScale(20)),
          IconButton(
            icon: const Icon( Icons.arrow_back_ios_rounded, color: Colors.black, size: 20.0 ),
            onPressed: () { Navigator.of(context).pop(); },),
          SizedBox(width: wScale(30)),
          Text(title, style: TextStyle(fontSize: fSize(20), fontWeight: FontWeight.w600))
        ]
    );
  }
}

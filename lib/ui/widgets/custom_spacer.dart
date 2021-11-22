import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

class CustomSpacer extends StatelessWidget {
  final double size;

  const CustomSpacer({Key? key, this.size = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    hScale(double scale) {
      return Scale().hScale(context, scale);
    }

    return SizedBox(width: 10.0, height: hScale(size));
  }
}

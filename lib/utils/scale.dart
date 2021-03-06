import 'package:flutter/cupertino.dart';
// ignore: implementation_imports
import 'package:flutter/src/widgets/media_query.dart';
// ignore: implementation_imports
import 'package:flutter/src/widgets/framework.dart';

class Scale {
  double wScale(BuildContext context, double scale) {
    return scale * MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width / 375;
  }

  double hScale(BuildContext context, double scale) {
    return scale * MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height / 812;
  }

  double fSize(BuildContext context, double size) {
    return hScale(context, size);
  }
}

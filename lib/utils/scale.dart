import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/media_query.dart';
import 'package:flutter/src/widgets/framework.dart';

class Scale {
  double wScale(BuildContext context, double scale) {
    return scale * MediaQuery.of(context).size.width/375;
  }

  double hScale(BuildContext context, double scale) {
    return scale * MediaQuery.of(context).size.height/812;
  }

  double fSize(BuildContext context, double size) {
    return hScale(context, size);
  }
}

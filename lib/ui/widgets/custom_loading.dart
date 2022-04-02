import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class CustomLoading extends StatelessWidget {
  final bool isLogin;
  const CustomLoading({Key? key, this.isLogin = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    hScale(double scale) {
      return Scale().hScale(context, scale);
    }

    return Container(
        alignment: Alignment.center,
        color: Color(0xFF5f696f),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                alignment: Alignment.center,
                width: hScale(80),
                height: hScale(80),
                decoration: BoxDecoration(
                  color: Color(0xFF717f88),
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF303030).withOpacity(0.25),
                      spreadRadius: 4,
                      blurRadius: 10,
                      offset: const Offset(0, 1), // changes position of shadow
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF60C094)))),
            CustomSpacer(size: 30),
            isLogin ? Text('Authenticating',
                style: TextStyle(
                    fontSize: hScale(16),
                    fontWeight: FontWeight.w600,
                    color: Colors.white)):  SizedBox()
          ],
        ));
  }
}

import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class CustomNoInternet extends StatelessWidget {
  final handleTryAgain;
  const CustomNoInternet({Key? key, this.handleTryAgain}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    hScale(double scale) {
      return Scale().hScale(context, scale);
    }

    wScale(double scale) {
      return Scale().wScale(context, scale);
    }

    return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/empty_transaction.png',
                fit: BoxFit.contain, width: wScale(200)),
            CustomSpacer(size: 22),
            Text('No Internet Connection',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            CustomSpacer(size: 16),
            Text(
                'Please make sure Wifi or cellular data \nis turned on and then try again',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            CustomSpacer(size: 61),
            Container(
                width: wScale(295),
                height: hScale(54),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all()),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF1A2831),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    handleTryAgain();
                  },
                  child: Text('Try Again',
                      style: TextStyle(
                          color: Color(0xffffffff),
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ))
          ],
        ));
  }
}

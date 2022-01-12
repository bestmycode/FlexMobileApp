import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:flutter/rendering.dart';

class CustomFCAUser extends StatefulWidget {
  
  const CustomFCAUser(
      {Key? key}) : super(key: key);

  @override
  CustomFCAUserState createState() => CustomFCAUserState();
}

class CustomFCAUserState extends State<CustomFCAUser> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  bool isFCAUserFlag = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isFCAUserFlag ? Container(
        width: wScale(328),
        padding:
            EdgeInsets.symmetric(horizontal: wScale(16), vertical: hScale(16)),
        decoration: BoxDecoration(
            color: Color(0xFFF6C6C0),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: const Color(0xFF040415).withOpacity(0.1))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/error.png',
                fit: BoxFit.contain, width: wScale(20)),
            Text(
                'The Flex mobile app does not support \nfinancing and invoicing features. Please \nlog in with your browser to access.',
                style: TextStyle(
                    fontSize: fSize(16), fontWeight: FontWeight.w500)),
            Container(
              width: wScale(20),
              height: wScale(20),
              alignment: Alignment.center,
              child: TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
                  onPressed: () {
                    setState(() {
                      isFCAUserFlag = false;
                    });
                  },
                  child: Icon(Icons.close_rounded, color: Color(0xFF81919B), size: 20, )),
            )
          ],
        )): SizedBox();
  }

  
}

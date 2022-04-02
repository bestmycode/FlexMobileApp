import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class CustomResultModal extends StatelessWidget {
  final bool status;
  final String title;
  final titleColor;
  final String message;
  final handleOKClick;
  const CustomResultModal({
    Key? key,
    required this.status,
    required this.title,
    required this.message,
    this.titleColor = Colors.black,
    this.handleOKClick = null
  }) : super(key: key);

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
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            padding: EdgeInsets.symmetric(
                vertical: hScale(25), horizontal: wScale(10)),
            child: Column(children: [
              Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: fSize(14), fontWeight: FontWeight.w700, color: titleColor)),
              const CustomSpacer(size: 10),
              Text(
                message,
                style:
                    TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              )
            ])),
        Container(height: 1, color: const Color(0xFFD5DBDE)),
        Container(
            height: hScale(50),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        primary: const Color(0xff30E7A9),
                        textStyle: TextStyle(
                            fontSize: fSize(16),
                            color: const Color(0xff30E7A9)),
                      ),
                      onPressed: () {
                        handleOKClick != null ? handleOKClick(): Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
                      },
                      child: const Text('Ok'),
                    ))
              ],
            ))
      ],
    );
  }
}

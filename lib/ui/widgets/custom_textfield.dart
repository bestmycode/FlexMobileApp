import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final String label;
  final TextEditingController ctl;
  final bool pwd;
  final Color fillColor;
  const CustomTextField(
      {Key? key,
      required this.ctl,
      required this.hint,
      required this.label,
      this.pwd = false,
      this.fillColor = const Color(0xFFFFFFFF)})
      : super(key: key);

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

    return Stack(
      children: [
        Container(
            width: wScale(295),
            height: hScale(64),
            padding: EdgeInsets.only(top: hScale(8)),
            alignment: Alignment.center,
            child: TextField(
              style: TextStyle(
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF040415)),
              controller: ctl,
              obscureText: pwd,
              decoration: InputDecoration(
                filled: true,
                fillColor: fillColor,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: const Color(0xff040415).withOpacity(0.1),
                        width: 1.0)),
                hintText: hint,
                hintStyle: TextStyle(
                    color: const Color(0xffBFBFBF), fontSize: fSize(14)),
                focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xff040415), width: 1.0)),
              ),
            )),
        Positioned(
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text(label,
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFBFBFBF))),
          ),
        )
      ],
    );
  }
}

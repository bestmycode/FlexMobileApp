import 'dart:js';

import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final String label;
  final TextEditingController ctl;
  final bool pwd;

  const CustomTextField({Key? key, required this.ctl, required this.hint, required this.label, this.pwd= false }) : super(key: key);

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

    return Container(
        width: wScale(295),
        height: hScale(56),
        alignment: Alignment.center,
        child: TextField(
          controller: ctl,
          obscureText: pwd,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hint,
            hintStyle: TextStyle(
                color: const Color(0xff040415),
                fontSize: fSize(14),
                fontWeight: FontWeight.w500),
            labelText: label,
            labelStyle: TextStyle(
                color: const Color(0xff040415),
                fontSize: fSize(14),
                fontWeight: FontWeight.w500),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                    color: Color(0xff040415),
                    width: 1.0)
            ),
          ),
        )
    );
  }
}

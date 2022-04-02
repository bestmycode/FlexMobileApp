import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final String label;
  final TextEditingController ctl;
  final bool pwd;
  final Color fillColor;
  final bool isError;
  final bool readOnly;
  final keyboardType;
  final inputFormatters;
  final onChanged;
  const CustomTextField(
      {Key? key,
      required this.ctl,
      required this.hint,
      required this.label,
      this.readOnly = false,
      this.pwd = false,
      this.isError = false,
      this.keyboardType,
      this.inputFormatters,
      this.onChanged,
      this.fillColor = const Color(0xFFFFFFFF)})
      : super(key: key);
  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  FocusNode _focus = FocusNode();
  bool isEmptyFocus = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
  }

  void _onFocusChange() {
    setState(() {
      isEmptyFocus = _focus.hasFocus && widget.ctl.text.length == 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
                width: wScale(295),
                height: hScale(64),
                padding: EdgeInsets.all(0),
                alignment: Alignment.center,
                child: TextField(
                  focusNode: _focus,
                  style: TextStyle(
                      fontSize: fSize(16),
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF040415)),
                  controller: widget.ctl,
                  onChanged: (text) {
                    widget.onChanged(text);
                    _onFocusChange();
                  },
                  obscureText: widget.pwd,
                  readOnly: widget.readOnly,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: widget.fillColor,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: isEmptyFocus
                                ? const Color(0xFF29C490)
                                : widget.isError
                                    ? const Color(0xFFEB5757)
                                    : const Color(0xFF828282),
                            width: 1.0)),
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                        color: widget.isError
                            ? const Color(0xFFEB5757)
                            : const Color(0xffBFBFBF),
                        fontSize: fSize(14)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: isEmptyFocus
                                ? const Color(0xFF29C490)
                                : widget.isError
                                    ? const Color(0xFFEB5757)
                                    : Color(0xff040415),
                            width: 1.0)),
                  ),
                )),
            Positioned(
              top: fSize(-6),
              left: wScale(10),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: wScale(8)),
                color: Colors.white,
                child: Text(widget.label,
                    style: TextStyle(
                        fontSize: fSize(12),
                        fontWeight: FontWeight.w400,
                        color: isEmptyFocus
                            ? const Color(0xFF29C490)
                            : widget.isError
                                ? const Color(0xFFEB5757)
                                : const Color(0xFF828282))),
              ),
            )
          ],
        ),
      ],
    );
  }
}

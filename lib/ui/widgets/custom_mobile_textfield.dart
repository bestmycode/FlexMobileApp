import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:flutter/rendering.dart';

import 'custom_spacer.dart';

class CustomMobileTextField extends StatefulWidget {
  final String hint;
  final String label;
  final TextEditingController ctl;
  final bool pwd;
  final Color fillColor;
  const CustomMobileTextField(
      {Key? key,
      required this.ctl,
      required this.hint,
      required this.label,
      this.pwd = false,
      this.fillColor = const Color(0xFFFFFFFF)})
      : super(key: key);

  @override
  CustomMobileTextFieldState createState() => CustomMobileTextFieldState();
}

class CustomMobileTextFieldState extends State<CustomMobileTextField> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  Country _selectedDialogCountry =
      CountryPickerUtils.getCountryByPhoneCode('65');
  final _focus = FocusNode();

  bool flagFocused = false;

  _onFocusChange() {
    setState(() {
      flagFocused = _focus.hasFocus;
    });
  }

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: wScale(295),
          height: hScale(56),
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: hScale(8)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: flagFocused
                      ? const Color(0xFF040415)
                      : const Color(0xFF040415).withOpacity(0.1))),
          child: Row(children: [
            SizedBox(
              width: wScale(105),
              height: hScale(56),
              child: ListTile(
                  onTap: _openCountryPickerDialog,
                  title: _buildDialogItem(_selectedDialogCountry)),
            ),
            SizedBox(
              width: wScale(180),
              child: TextField(
                focusNode: _focus,
                controller: widget.ctl,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                      color: const Color(0xffBFBFBF), fontSize: fSize(14)),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                ),
              ),
            )
          ]),
        ),
        Positioned(
          top: 0,
          left: wScale(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: wScale(8)),
            color: Colors.white,
            child: Text(widget.label,
                style: TextStyle(
                    fontSize: fSize(12),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFBFBFBF))),
          ),
        )
      ],
    );
  }

  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(primaryColor: Colors.black),
          child: CountryPickerDialog(
            contentPadding: const EdgeInsetsDirectional.all(0.0),
            titlePadding: const EdgeInsetsDirectional.all(0.0),
            searchCursorColor: Colors.black,
            searchInputDecoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: const Color(0xff040415).withOpacity(0.1),
                      width: 1.0)),
              hintText: 'Search Country',
              hintStyle: TextStyle(
                  color: const Color(0xff040415).withOpacity(0.1),
                  fontSize: fSize(14),
                  fontWeight: FontWeight.w500),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff040415), width: 1.0),
              ),
            ),
            isSearchable: true,
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select a country',
                        style: TextStyle(
                            fontSize: fSize(20), fontWeight: FontWeight.w600)),
                    SizedBox(
                        width: wScale(20),
                        height: wScale(20),
                        child: TextButton(
                            style: TextButton.styleFrom(
                              primary: const Color(0xff000000),
                              padding: const EdgeInsets.all(0),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFFC8C4D9),
                              size: 20,
                            ),
                            onPressed: () {}))
                  ],
                ),
                const CustomSpacer(
                  size: 20,
                )
              ],
            ),
            onValuePicked: (Country country) =>
                setState(() => _selectedDialogCountry = country),
            itemBuilder: _showCountryDialogItem,
          ),
        ),
      );

  Widget _showCountryDialogItem(Country country) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: wScale(20),
                height: hScale(10),
                child: CountryPickerUtils.getDefaultFlagImage(country),
              ),
              SizedBox(width: wScale(16)),
              SizedBox(
                  width: wScale(140),
                  child:
                      Text(country.name, style: TextStyle(fontSize: fSize(14))))
            ],
          ),
          Text("+${country.phoneCode}", style: TextStyle(fontSize: fSize(14)))
        ],
      );

  Widget _buildDialogItem(Country country) => Container(
      margin: EdgeInsets.only(bottom: hScale(16)),
      child: Row(
        children: [
          SizedBox(
            width: wScale(20),
            height: hScale(10),
            child: CountryPickerUtils.getDefaultFlagImage(country),
          ),
          SizedBox(width: wScale(5)),
          Text("+${country.phoneCode}", style: TextStyle(fontSize: fSize(14)))
        ],
      ));
}

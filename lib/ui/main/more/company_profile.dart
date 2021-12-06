import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class CompanyProfile extends StatefulWidget {
  const CompanyProfile({Key? key}) : super(key: key);
  @override
  CompanyProfileState createState() => CompanyProfileState();
}

class CompanyProfileState extends State<CompanyProfile> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  bool flagEditable = false;
  final companyNameCtl = TextEditingController();

  handleEditProfile() {
    setState(() {
      flagEditable = true;
    });
  }

  handleConfirmChange() {
    setState(() {
      flagEditable = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const CustomSpacer(size: 15),
      userProfileField(),
      flagEditable ? const CustomSpacer(size: 30) : const SizedBox(),
      flagEditable ? confirmChangeButton() : const SizedBox(),
      const CustomSpacer(size: 46)
    ]);
  }

  Widget userProfileField() {
    return Container(
        width: wScale(327),
        // height: hScale(40),
        padding:
            EdgeInsets.symmetric(vertical: hScale(16), horizontal: wScale(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 4,
              blurRadius: 20,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleField(),
            const CustomSpacer(size: 6),
            flagEditable ? editableField() : nonEditableField()
          ],
        ));
  }

  Widget titleField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Company Profile',
            style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w600)),
        flagEditable
            ? const SizedBox()
            : SizedBox(
                width: wScale(16),
                height: wScale(16),
                child: TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color(0xffF5F5F5).withOpacity(0.4),
                      padding: const EdgeInsets.all(0),
                    ),
                    child: Image.asset('assets/green_edit.png',
                        fit: BoxFit.contain, width: wScale(16)),
                    onPressed: () {
                      handleEditProfile();
                    }),
              )
      ],
    );
  }

  Widget customDataField(label, value) {
    return SizedBox(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: fSize(12),
                fontWeight: FontWeight.w400,
                color: const Color(0xFF040415).withOpacity(0.4))),
        const CustomSpacer(size: 8),
        Text(value,
            style: TextStyle(
                fontSize: fSize(14),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF040415)))
      ],
    ));
  }

  Widget customEditField(hint, label, editable) {
    return Container(
        width: wScale(295),
        height: hScale(56),
        alignment: Alignment.center,
        child: TextField(
          readOnly: !editable,
          style: TextStyle(
              fontSize: fSize(14),
              fontWeight: FontWeight.w500,
              color:
                  editable ? const Color(0xFF040415) : const Color(0xFF7D7E80)),
          controller: TextEditingController()..text = label,
          decoration: InputDecoration(
            filled: true,
            fillColor: editable
                ? Colors.white
                : const Color(0xFFBDBDBD).withOpacity(0.1),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: const Color(0xff040415).withOpacity(0.1),
                    width: 1.0)),
            hintText: hint,
            hintStyle: TextStyle(
                color: const Color(0xff040415).withOpacity(0.1),
                fontSize: fSize(14),
                fontWeight: FontWeight.w500),
            labelText: hint,
            labelStyle: TextStyle(
                color: const Color(0xff040415).withOpacity(0.4),
                fontSize: fSize(14),
                fontWeight: FontWeight.w500),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Color(0xff040415).withOpacity(0.1), width: 1.0)),
          ),
        ));
  }

  Widget customMultiEditField(label) {
    return Container(
        width: wScale(295),
        // height: hScale(56),
        alignment: Alignment.center,
        child: TextField(
          readOnly: true,
          style: TextStyle(
              fontSize: fSize(14),
              fontWeight: FontWeight.w500,
              color: Color(0xFF7D7E80)),
          controller: TextEditingController()..text = label,
          minLines: 3,
          maxLines: 7,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFBDBDBD).withOpacity(0.1),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: const Color(0xff040415).withOpacity(0.1),
                    width: 1.0)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Color(0xff040415).withOpacity(0.1), width: 1.0)),
          ),
        ));
  }

  Widget confirmChangeButton() {
    return SizedBox(
        width: wScale(295),
        height: hScale(56),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            handleConfirmChange();
          },
          child: Text("Confirm Changes",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.bold)),
        ));
  }

  Widget nonEditableField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomSpacer(size: 14),
        customDataField('Company Name', 'Global Ptv.Ltd'),
        const CustomSpacer(size: 16),
        customDataField('Company Registration Number', '234878'),
        const CustomSpacer(size: 16),
        customDataField('Country', 'Singapore'),
        const CustomSpacer(size: 16),
        customDataField('Base Currency', 'SGD'),
        const CustomSpacer(size: 16),
        customDataField('Company Phone Number', '+65 9112 3950'),
        const CustomSpacer(size: 16),
        customDataField('Company Type', 'Retail'),
        const CustomSpacer(size: 16),
        customDataField('Contact Person', 'Terry Herwit'),
        const CustomSpacer(size: 16),
        customDataField('Company Email Address', 'terry@abc.co'),
        const CustomSpacer(size: 16),

        customDataField('Industry', '122-abchd'),
        const CustomSpacer(size: 16),

        customDataField('',
            '340 - Manufacture of derivatives and intermediates produced from basic building blocks (eg acetyls, acrylics, oxochemicals.'),

        const CustomSpacer(size: 16),
        customDataField('Company Address', '123 Tagore Lane'),
        const CustomSpacer(size: 16),
        customDataField('Postal Code', '121145'),
        const CustomSpacer(size: 16),
        customDataField('City', 'Singapore'),
        const CustomSpacer(size: 16),
        customDataField('Operating Address', '192 Sengkang Ave 3'),
        const CustomSpacer(size: 16),
        customDataField('Postal Code', '959122'),
        const CustomSpacer(size: 16),
        customDataField('City', 'Singapore'),
        // customEditField(companyNameCtl, const Color(0xFFBDBDBD).withOpacity(0.1), 'Global Ptv.Ltd', 'Company Name')
      ],
    );
  }

  Widget editableField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomSpacer(size: 14),
        customEditField('Company Name', 'Global Ptv.Ltd', false),
        const CustomSpacer(size: 16),
        customEditField('Company Registration Number', '234878', false),
        const CustomSpacer(size: 16),
        customEditField('Country', 'Singapore', false),
        const CustomSpacer(size: 16),
        customEditField('Base Currency', 'SGD', false),
        const CustomSpacer(size: 16),
        customEditField('Company Phone Number', '+65 9112 3950', true),
        const CustomSpacer(size: 16),
        customEditField('Company Type', 'Retail', false),
        const CustomSpacer(size: 16),
        customEditField('Contact Person', 'Terry Herwit', true),
        const CustomSpacer(size: 16),
        customEditField('Company Email Address', 'terry@abc.co', true),
        const CustomSpacer(size: 16),

        customEditField('Industry', '122-abchd', false),
        const CustomSpacer(size: 16),

        customMultiEditField(
            '340 - Manufacture of derivatives and \nintermediates produced from basic \nbuilding blocks (eg acetyls, acrylics, \noxochemicals.'),

        const CustomSpacer(size: 16),
        customEditField('Company Address', '123 Tagore Lane', false),
        const CustomSpacer(size: 16),
        customEditField('Postal Code', '121145', false),
        const CustomSpacer(size: 16),
        customEditField('City', 'Singapore', false),
        const CustomSpacer(size: 16),
        customEditField('Operating Address', '192 Sengkang Ave 3', true),
        const CustomSpacer(size: 16),
        customEditField('Postal Code', '959122', true),
        const CustomSpacer(size: 16),
        customEditField('City', 'Singapore', true),
        // customEditField(companyNameCtl, const Color(0xFFBDBDBD).withOpacity(0.1), 'Global Ptv.Ltd', 'Company Name')
      ],
    );
  }
}

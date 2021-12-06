import 'dart:io';

import 'package:co/ui/main/home/receipt_screen.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/scale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptCapture extends StatefulWidget {
  const ReceiptCapture({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ReceiptCapture();
  }
}

class _ReceiptCapture extends State<ReceiptCapture> {
  File? imageFile;
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  bool takeFlag = false;
  handleUpload() {
    Navigator.of(context).push(CupertinoPageRoute(
        builder: (context) => ReceiptScreen(imageFile: imageFile)));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Column(
      children: [
        const CustomSpacer(size: 51),
        const CustomMainHeader(title: 'Capture your receipt'),
        const CustomSpacer(size: 28),
        Container(
            width: wScale(375),
            height: hScale(580),
            padding: EdgeInsets.symmetric(
                horizontal: wScale(50), vertical: hScale(50)),
            decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                image: imageFile == null
                    ? const DecorationImage(
                        image: AssetImage('assets/empty_transaction.png'),
                        fit: BoxFit.contain)
                    : DecorationImage(
                        image: FileImage(imageFile!), fit: BoxFit.contain))),
        const CustomSpacer(size: 31),
        takeFlag == false ? takeButton() : buttonField()
      ],
    )));
  }

  Widget buttonField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [retakeButton(), uploadButton()],
    );
  }

  Widget retakeButton() {
    return Container(
        width: wScale(156),
        height: hScale(56),
        margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xffe8e9ea),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            _settingModalBottomSheet(context);
          },
          child: Text("Retake",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget takeButton() {
    return Container(
        width: wScale(256),
        height: hScale(56),
        margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            _settingModalBottomSheet(context);
          },
          child: Text("Upload",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget uploadButton() {
    return Container(
        width: wScale(156),
        height: hScale(56),
        margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff1A2831),
            side: const BorderSide(width: 0, color: Color(0xff1A2831)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            handleUpload();
          },
          child: Text("Upload",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  //********************** IMAGE PICKER
  Future imageSelector(BuildContext context, String pickerType) async {
    switch (pickerType) {
      case "gallery":

        /// GALLERY IMAGE PICKER
        imageFile = await ImagePicker.pickImage(
            source: ImageSource.gallery, imageQuality: 90);
        break;

      case "camera": // CAMERA CAPTURE CODE
        imageFile = await ImagePicker.pickImage(
            source: ImageSource.camera, imageQuality: 90);
        break;
    }

    if (imageFile != null) {
      print("You selected  image : " + imageFile!.path);
      setState(() {
        debugPrint("SELECTED IMAGE PICK   $imageFile");
      });
    } else {
      print("You have not taken image");
    }
  }

  // Image picker
  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          // ignore: avoid_unnecessary_containers
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    title: const Text('Gallery'),
                    onTap: () => {
                          imageSelector(context, "gallery"),
                          Navigator.pop(context),
                        }),
                ListTile(
                  title: const Text('Camera'),
                  onTap: () => {
                    imageSelector(context, "camera"),
                    Navigator.pop(context),
                    setState(() {
                      takeFlag = true;
                    }),
                  },
                ),
              ],
            ),
          );
        });
  }
}

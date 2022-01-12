import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:co/ui/main/home/receipt_screen.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/scale.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;

class ReceiptCapture extends StatefulWidget {
  final String? accountID;
  final String? transactionID;
  const ReceiptCapture({Key? key, this.accountID, this.transactionID})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ReceiptCapture();
  }
}

class _ReceiptCapture extends State<ReceiptCapture> {
  XFile? imageFile;
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
  final LocalStorage storage = LocalStorage('token');
  String docUploadMutation = FXRMutations.MUTATION_DOC_UPLOAD;

  handleUpload(runMutation) async {    
    // Uri upload_base_url = Uri.parse("https://gql.staging.fxr.one/v1/file/document_files?v4=true");
    // var upload_result = await http.post(upload_base_url,
    //       headers: {"Content-Type": "application/json"},
    //       body: json.encode(data));

    // Uri upload_amazon_url = Uri.parse("https://fxrassetsstaging.s3-accelerate.amazonaws.com");
    // var upload_amazon_result = await http.post(upload_amazon_url,
    //       headers: {"Content-Type": "application/json"},
    //       body: json.encode(data));
    // var uploadResult = json.decode(upload_amazon_result.body);

    // runMutation({
    //   'financeAccountId': widget.accountID,
    //   'id': 109293,
    //   'isDelivered': 1,
    //   'isInvoice': false,
    //   'orgId': uploadResult['fields']['x-amz-meta-orgid'],
    //   'orgIntegrationId': 1,
    //   'secondaryDocumentId': uploadResult['fields']['key'],
    // });
    print(widget.accountID);
    print(widget.transactionID);
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (context) => ReceiptScreen(
          imageFile: new XFile(imageFile!.path),
          accountID: widget.accountID,
          transactionID: widget.transactionID)));
  }

  void _onImageButtonPressed(ImageSource source,
      {BuildContext? context}) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
      );
      setState(() {
        imageFile = pickedFile;
        takeFlag = true;
      });
      Navigator.pop(context!);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    return Mutation(
        options: MutationOptions(
          document: gql(docUploadMutation),
          update: (GraphQLDataProxy cache, QueryResult? result) {
            return cache;
          },
          onCompleted: (resultData) {
            if (resultData.data['uploadReceipt']['isDuplicate'] == false) {
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => ReceiptScreen(
                      imageFile: new XFile(imageFile!.path),
                      accountID: widget.accountID,
                      transactionID: widget.transactionID)));
            } else {
              print("Upload Error");
            }
          },
        ),
        builder: (RunMutation runMutation, QueryResult? result) {
          return mainHome(runMutation);
        });
  }

  Widget mainHome(runMutation) {
    return Material(
        child: Scaffold(
            body: Container(
                height: hScale(812),
                child: SingleChildScrollView(
                    child: Column(
                  children: [
                    const CustomSpacer(size: 51),
                    const CustomMainHeader(title: 'Capture your receipt'),
                    const CustomSpacer(size: 28),
                    defaultTargetPlatform == TargetPlatform.android
                        ? FutureBuilder<void>(
                            future: retrieveLostData(),
                            builder: (BuildContext context,
                                AsyncSnapshot<void> snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                  return Container(
                                      width: wScale(375),
                                      height: hScale(580),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: wScale(50),
                                          vertical: hScale(50)),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFF9F9F9),
                                          image: const DecorationImage(
                                              image: AssetImage(
                                                  'assets/empty_transaction.png'),
                                              fit: BoxFit.contain)));
                                case ConnectionState.done:
                                  return _previewImages();
                                default:
                                  if (snapshot.hasError) {
                                    return Text(
                                      'Pick image/video error: ${snapshot.error}}',
                                      textAlign: TextAlign.center,
                                    );
                                  } else {
                                    return Container(
                                        width: wScale(375),
                                        height: hScale(580),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: wScale(50),
                                            vertical: hScale(50)),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFF9F9F9),
                                            image: const DecorationImage(
                                                image: AssetImage(
                                                    'assets/empty_transaction.png'),
                                                fit: BoxFit.contain)));
                                  }
                              }
                            },
                          )
                        : _previewImages(),
                    const CustomSpacer(size: 31),
                    takeFlag == false ? takeButton() : buttonField(runMutation),
                    const CustomSpacer(size: 30),
                  ],
                )))));
  }

  Widget buttonField(runMutation) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [retakeButton(), uploadButton(runMutation)],
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

  Widget uploadButton(runMutation) {
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
            handleUpload(runMutation);
          },
          child: Text("Upload",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
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
                          _onImageButtonPressed(ImageSource.gallery,
                              context: context),
                        }),
                ListTile(
                  title: const Text('Camera'),
                  onTap: () => {
                    _onImageButtonPressed(ImageSource.camera, context: context),
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await ImagePicker().retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        imageFile = response.file;
      });
    } else {
      // _retrieveDataError = response.exception!.code;

    }
  }

  Widget _previewImages() {
    if (imageFile != null) {
      return Semantics(
        label: 'image_picker',
        child: Image.file(File(imageFile!.path)),
      );
    } else {
      return Container(
          width: wScale(375),
          height: hScale(580),
          padding: EdgeInsets.symmetric(
              horizontal: wScale(50), vertical: hScale(50)),
          decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              image: const DecorationImage(
                  image: AssetImage('assets/empty_transaction.png'),
                  fit: BoxFit.contain)));
    }
  }
}

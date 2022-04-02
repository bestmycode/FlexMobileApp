import 'dart:io' as io;
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:co/ui/main/home/receipt_screen.dart';
import 'package:co/ui/widgets/custom_main_header.dart';
import 'package:co/ui/widgets/custom_result_modal.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/basedata.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/scale.dart';
import 'package:co/utils/token.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:uuid/uuid.dart';
import 'package:ua_client_hints/ua_client_hints.dart';
import 'package:path/path.dart' as p;

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
  get axios => null;

  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  XFile? uploadFile;
  bool takeFlag = false;
  bool cropFlag = false;
  bool uploading = false;
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String docUploadMutation = FXRMutations.MUTATION_DOC_UPLOAD;

  void printLongString(String text) {
    final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern
        .allMatches(text)
        .forEach((RegExpMatch match) => print(match.group(0)));
  }

  handleUpload(runMutation) async {
    setState(() {
      uploading = true;
    });
    Uri upload_base_url =
        Uri.parse("https://gql.staging.fxr.one/v1/file/document_files?v4=true");

    var today = new DateTime.now().toUtc();

    String formattedDate = DateFormat('yyyyMMdd').format(today);
    String formattedTime = DateFormat('HHmmss').format(today);

    var x_amz_date = "${formattedDate}T${formattedTime}Z";

    var exp_datetime = "${DateFormat('yyyy-MM-ddTHH:mm:ss').format(today)}Z";

    var uuid = Uuid();
    var key = uuid.v4();

    String fileName =
        'receipt_${widget.transactionID}_${DateTime.now().millisecondsSinceEpoch}.png';

    var extension = p.extension(uploadFile!.path);
    extension = extension.split('.')[1];

    String fileType =
        extension == "pdf" ? "application/jpg" : "image/${extension}";

    var bodyData = {
      "conditions": [
        {"acl": "private"},
        {"Content-Type": fileType},
        {"success_action_status": "200"},
        {"x-amz-algorithm": "AWS4-HMAC-SHA256"},
        {"key": key.toString()},
        {
          "x-amz-credential":
              "${BaseData.AWS_FXR_ASSETS_ACCESS_KEY}/${formattedDate}/${BaseData.FILE_API_REGION}/s3/aws4_request"
        },
        {"x-amz-date": x_amz_date},
        {"Content-Disposition": "attachment; filename=${fileName}"},
        {"x-amz-meta-entity": "document_files"},
        {"x-amz-meta-orgid": userStorage.getItem('orgId').toString()},
        {"x-amz-meta-qqfilename": "${fileName}"}
      ],
      "expiration": exp_datetime
    };

    print("================== V4 API Request ==================");
    print(bodyData);
    var fileApiData;
    try {
      var fileApiResponse = await http.post(upload_base_url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": storage.getItem("jwt_token"),
          },
          body: json.encode(bodyData));

      fileApiData = json.decode(fileApiResponse.body);
    } catch (error) {
      print("===== Error : Get File Api Data =====");
      print("===== Function : getBusinessAccountSummary =====");
      print(error);
      await Sentry.captureException(error);
      return null;
    }

    print("================== V4 API Response : Policy ==================");
    printLongString(fileApiData['fields']["policy"]);

    if (fileApiData.length > 0) {
      final header = await userAgentClientHintsHeader();

      try {
        ///[1] CREATING INSTANCE
        var dioRequest = dio.Dio();
        dioRequest.options.baseUrl = fileApiData['url'];
        dioRequest.options.receiveDataWhenStatusError = true;
        dioRequest.options.connectTimeout = 60 * 1000;
        dioRequest.options.receiveTimeout = 60 * 1000;

        //[2] ADDING TOKEN
        dioRequest.options.headers = {
          "Content-Type": "multipart/form-data",
          "Accept": "*/*",
          "Cache-Control": "no-cache",
          "Sec-Fetch-Site": "cross-site",
          "Sec-Fetch-Mode": "cors",
          "Sec-Fetch-Dest": "empty",
          "Host": "fxrassetsstaging.s3-accelerate.amazonaws.com",
          // "Origin": "https://app.staging.fxr.one",
          // "Regerer": "https://app.staging.fxr.one/",
          "Accept-Encoding": "gzip, deflate, br",
          // "Accept-Language": "pl-PL,pl;q=0.9,en-US;q=0.8,en;q=0.7,es;q=0.6",
          "Connection": "Keep-Alive",
          // "Content-Length": request.contentLength.toString(),
          "sec-ch-ua": header['Sec-CH-UA'].toString(),
          "sec-ch-ua-mobile": header['Sec-CH-UA-Mobile'].toString(),
          "User-Agent": header['User-Agent'].toString(),
          "sec-ch-ua-platform": header['Sec-CH-UA-Platform'].toString(),
        };

        //[3] ADDING EXTRA INFO
        var form_data = {
          "acl": fileApiData['fields']["acl"].toString(),
          "Content-Type": fileApiData['fields']["Content-Type"].toString(),
          "success_action_status":
              fileApiData['fields']["success_action_status"].toString(),
          "x-amz-algorithm":
              fileApiData['fields']["x-amz-algorithm"].toString(),
          "key": fileApiData['fields']["key"].toString(),
          "x-amz-credential": fileApiData['fields']["x-amz-credential"],
          "x-amz-date": fileApiData['fields']["x-amz-date"].toString(),
          "Content-Disposition":
              fileApiData['fields']["Content-Disposition"].toString(),
          "x-amz-meta-entity":
              fileApiData['fields']["x-amz-meta-entity"].toString(),
          "x-amz-meta-orgid":
              fileApiData['fields']["x-amz-meta-orgid"].toString(),
          "x-amz-meta-qqfilename":
              fileApiData['fields']["x-amz-meta-qqfilename"].toString(),
          "bucket": fileApiData['fields']["bucket"].toString(),
          "x-amz-signature":
              fileApiData['fields']["x-amz-signature"].toString(),
          "policy": fileApiData['fields']["policy"].toString(),
        };
        var formData = new dio.FormData.fromMap(form_data);

        //[4] ADD IMAGE TO UPLOAD
        try {
          var file = await dio.MultipartFile.fromFile(uploadFile!.path,
              filename: uploadFile!.name,
              contentType: MediaType("image", "jpg"));

          formData.files.add(MapEntry('file', file));

          print("===========   Form Data   ============");
          print(form_data);

          print("===========   Header   ============");
          print(dioRequest.options.headers);
        } catch (error) {
          print("===== Error : Get File from MultipartFile =====");
          print(error);
          await Sentry.captureException(error);
          return null;
        }
        //[5] SEND TO SERVER
        var response = await dioRequest.post(
          fileApiData['url'],
          data: formData,
          onSendProgress: (int sent, int total) {
            print('$sent $total');
          },
        );
        print("============================");
        print(response.toString());
        print("============================");

        print('Dio Success : ');
      } on DioError catch (e) {
        print("===== Error : Dio Error =====");
        print(e);
        await Sentry.captureException(e);
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx and is also not 304.
        if (e.response != null) {
          print(e.response!.data);
          print(e.response!.headers);
          print(e.response!.requestOptions);
        } else {
          // Something happened in setting up or sending the request that triggered an Error
          print("Dio Error Type : ${e.type}");
          print(e.requestOptions);
          print(e.message);
        }
      }
    }

    await runMutation({
      "currencyCode": "SGD",
      "filesList": [
        {
          "batchId": key,
          "batchSize": 1,
          "documentId": widget.transactionID,
          "documentType": "INVOICE",
          "fileDocumentType": "RECEIPT",
          "fileId": key,
          "id": key,
          "orgId": userStorage.getItem('orgId'),
          "requestId": key,
          "sourceFileName": fileName,
          "sourceFileType": fileType,
        }
      ],
      "financeAccountId": widget.accountID,
      "isDelivered": 1,
      "isInvoice": false,
      "orgId": userStorage.getItem('orgId'),
      "orgIntegrationId": 1,
      "secondaryDocumentId": key,
      "sourceDocumentId": widget.transactionID,
      "sourceTransactionId": widget.transactionID,
      "status": "PAID",
    });
  }

  void _onImageButtonPressed(ImageSource source,
      {BuildContext? context}) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
      );
      setState(() {
        uploadFile = pickedFile;
        takeFlag = true;
      });
      Navigator.pop(context!);
    } catch (e) {
      print("===== Error : Get Image from ImagePicker =====");
      print(e);
      await Sentry.captureException(e);
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
            setState(() {
              uploading = false;
            });
            if (resultData['uploadReceipt']['isDuplicate'] == false) {
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => ReceiptScreen(
                      uploadFile: new XFile(uploadFile!.path),
                      accountID: widget.accountID,
                      transactionID: widget.transactionID)));
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Padding(
                        padding: EdgeInsets.symmetric(horizontal: wScale(40)),
                        child: Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            child: CustomResultModal(
                              status: true,
                              title: "Something went wrong",
                              message:
                                  "Your receipt was not uploaded. Please try again later",
                            )));
                  });
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
                    uploading
                        ? Column(children: [
                            Container(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF60C094)))),
                            const CustomSpacer(size: 20),
                            Text('Your receipt is being uploaded.')
                          ])
                        : Column(
                            children: [
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
                                                    color:
                                                        const Color(0xFFF9F9F9),
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
                                                      color: const Color(
                                                          0xFFF9F9F9),
                                                      image: const DecorationImage(
                                                          image: AssetImage(
                                                              'assets/empty_transaction.png'),
                                                          fit:
                                                              BoxFit.contain)));
                                            }
                                        }
                                      },
                                    )
                                  : _previewImages(),
                              const CustomSpacer(size: 31),
                              takeFlag == false
                                  ? takeButton()
                                  : cropFlag == false
                                      ? cropButton()
                                      : buttonField(runMutation),
                            ],
                          ),
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

  Widget cropButton() {
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
            _cropImage();
          },
          child: Text("Crop",
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
        uploadFile = response.file;
      });
    } else {
      // _retrieveDataError = response.exception!.code;

    }
  }

  Widget _previewImages() {
    if (uploadFile != null) {
      return Semantics(
        label: 'image_picker',
        child: Image.file(io.File(uploadFile!.path)),
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

  Future<Null> _cropImage() async {
    io.File? croppedFile = await ImageCropper().cropImage(
        sourcePath: uploadFile!.path,
        aspectRatioPresets: io.Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      setState(() {
        uploadFile = new XFile(croppedFile.path);
        cropFlag = true;
      });
    }
  }
}

import 'dart:io';

import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flowder/flowder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ReceiptFile extends StatefulWidget {
  final data;
  final isRemoved;
  final handleRemoved;
  const ReceiptFile({Key? key, this.data, this.isRemoved, this.handleRemoved})
      : super(key: key);

  @override
  ReceiptFileState createState() => ReceiptFileState();
}

class ReceiptFileState extends State<ReceiptFile> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String docDownloadQuery = Queries.QUERY_DOC_DOWNLOAD;
  String removeReceiptMutation = FXRMutations.MUTATION_REMOVE_RECEIPT;

  late DownloaderUtils options;
  late DownloaderCore core;
  late final String path;
  double progress = 0.0;
  
  @override
  void initState() {
    super.initState();
  }

  handleRemoveReceipt(runMutation) {
    runMutation({
      "ReceiptId": widget.data['receiptData']['receiptId'],
      "fileId": widget.data['receiptData']['fileId'],
      "orgId": userStorage.getItem('orgId'),
      "sourceTxnId": widget.data['sourceTransactionId'],
    });
  }

  handleDownload(url) async {
    final Directory? download = await getApplicationDocumentsDirectory();
    final String downloadPath = download!.path;
    final String fileExt = widget.data['receiptData']['fileType'].split('/')[1];
    String path = "${downloadPath}/receipt_${widget.data['sourceTransactionId']}_${widget.data['receiptData']['uploadedAt']}.${fileExt}";
    options = DownloaderUtils(
      progressCallback: (current, total) {
        progress = (current / total) * 100;

        setState(() {
          progress = (current / total);
        });
      },
      file: File(path),
      progress: ProgressImplementation(),
      onDone: () {
        setState(() {
          progress = 0.0;
        });
        OpenFile.open(path).then((value) {});
      },
      deleteOnCancel: true,
    );
    core = await Flowder.download(url, options);
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    return widget.data['receiptData']['fileId'] == null || widget.isRemoved
        ? Image.asset('assets/empty_transaction.png',
            fit: BoxFit.contain, width: wScale(327))
        : Query(
            options: QueryOptions(
              document: gql(docDownloadQuery),
              variables: {"fileId": widget.data['receiptData']['fileId']},
            ),
            builder: (QueryResult result,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.hasException) {
                return Text(result.exception.toString());
              }

              if (result.isLoading) {
                return Container(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF60C094))));
              }
              return mainHome(result.data!['downloadDocument']);
            });
  }

  Widget mainHome(url) {
    return Column(children: [const CustomSpacer(size: 30), imageField(url)]);
  }

  Widget imageField(url) {
    return Stack(
      overflow: Overflow.visible,
      children: [
        Container(
            width: wScale(301),
            height: hScale(519),
            margin: EdgeInsets.only(right: wScale(27)),
            child: widget.data['receiptData']['fileType'].split('/')[0] == "image"
                ? Image.network(url)
                : SfPdfViewer.network(
                    url,
                    scrollDirection: PdfScrollDirection.vertical,
                  )),
        Positioned(
            top: wScale(-17),
            right: wScale(8),
            child: Column(
              children: [
                removeMutationButton(),
                const CustomSpacer(size: 12),
                handleButton(1, url),
              ],
            ))
      ],
    );
  }

  Widget removeMutationButton() {
    return Mutation(
        options: MutationOptions(
          document: gql(removeReceiptMutation),
          update: (GraphQLDataProxy cache, QueryResult? result) {
            return cache;
          },
          onCompleted: (resultData) {
            if (resultData['removeReceipt']['id'] > 0) {
              widget.handleRemoved();
            }
          },
        ),
        builder: (RunMutation runMutation, QueryResult? result) {
          return handleButton(0, runMutation);
        });
  }

  Widget handleButton(type, data) {
    return Container(
        width: wScale(35),
        height: wScale(35),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(hScale(8)),
          color: type == 0 ? const Color(0xffFFF2F2) : Colors.white,
        ),
        child: TextButton(
            style: TextButton.styleFrom(
              primary: const Color(0xff29c490),
              padding: const EdgeInsets.all(0),
            ),
            onPressed: () {
              if (type == 0) {
                handleRemoveReceipt(data);
              } else {
                handleDownload(data);
              }
            },
            child: Image.asset(
              type == 0 ? 'assets/red_delete.png' : 'assets/green_download.png',
              fit: BoxFit.contain,
              width: wScale(20),
            )));
  }
}

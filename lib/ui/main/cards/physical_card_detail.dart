import 'package:co/models/mcd_card_data.model.dart';
import 'package:co/services/mcd.dart';
import 'package:co/ui/main/home/request_card.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';

class PhysicalCardDetail extends StatefulWidget {
  final data;
  const PhysicalCardDetail({
    Key? key,
    this.data,
  }) : super(key: key);
  @override
  PhysicalCardDetailState createState() => PhysicalCardDetailState();
}

class PhysicalCardDetailState extends State<PhysicalCardDetail> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  bool showCardDetail = false;
  bool flagCopiedAccount = false;
  bool flagCopiedCVV = false;

  handleShowCardDetail() {
    setState(() {
      showCardDetail = !showCardDetail;
    });
  }

  handleCopied(index, num) {
    Clipboard.setData(ClipboardData(text: num));
    setState(() {
      index == 0 ? flagCopiedAccount = true : flagCopiedCVV = true;
    });
  }

  handleCloneSetting() {
    Navigator.of(context).push(
      CupertinoPageRoute(
          builder: (context) =>
              RequestCard(initData: widget.data['data']['physicalCard'])),
    );
  }

  final LocalStorage userStorage = LocalStorage('user_info');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.data['data']['physicalCard'] == null
        ? physicalNullWidget()
        : cardDetailField(widget.data);
  }

  Widget physicalNullWidget() {
    return (Opacity(
        opacity: 0.5,
        child: Container(
          width: wScale(327),
          padding: EdgeInsets.only(
              left: wScale(16), right: wScale(16), bottom: hScale(16)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(hScale(10)),
              topRight: Radius.circular(hScale(10)),
              bottomLeft: Radius.circular(hScale(10)),
              bottomRight: Radius.circular(hScale(10)),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF106549).withOpacity(0.1),
                spreadRadius: 4,
                blurRadius: 10,
                offset: const Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomSpacer(size: 14),
              Text('My Card',
                  style: TextStyle(
                      fontSize: fSize(14),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A2831))),
              const CustomSpacer(size: 14),
              Container(
                  width: wScale(295),
                  height: wScale(187),
                  padding: EdgeInsets.all(hScale(16)),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/physical_card_detail.png"),
                      colorFilter: new ColorFilter.mode(
                          Colors.black.withOpacity(0.5), BlendMode.dstATop),
                      fit: BoxFit.contain,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: SizedBox()),
              const CustomSpacer(size: 14),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Available Limit',
                    style: TextStyle(
                        fontSize: fSize(14),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A2831))),
                Text('0',
                    style: TextStyle(
                        fontSize: fSize(14),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A2831))),
              ])
            ],
          ),
        )));
  }

  Widget cardDetailField(userAccountSummary) {
    return Opacity(
        opacity: userAccountSummary['data']['physicalCard'] == null ||
                userAccountSummary['data']['physicalCard']['status'] == 'ACTIVE'
            ? 1
            : 0.5,
        child: Container(
          width: wScale(327),
          padding: EdgeInsets.only(
              left: wScale(16), right: wScale(16), bottom: hScale(16)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(hScale(10)),
              topRight: Radius.circular(hScale(10)),
              bottomLeft: Radius.circular(hScale(10)),
              bottomRight: Radius.circular(hScale(10)),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF106549).withOpacity(0.1),
                spreadRadius: 4,
                blurRadius: 10,
                offset: const Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userAccountSummary['data']['physicalCard'] == null
                  ? const CustomSpacer(size: 14)
                  : SizedBox(),
              cardTitle(userAccountSummary),
              userAccountSummary['data']['physicalCard'] == null
                  ? const CustomSpacer(size: 14)
                  : SizedBox(),
              showCardDetail
                  ? FutureBuilder<McdCardData?>(
                      future: const McdCardService().getCardData(
                          cardId: userAccountSummary['data']['physicalCard']
                              ['id'],
                          publicToken: userAccountSummary['data']
                              ['physicalCard']['publicToken']),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return cardField(
                            userAccountSummary,
                            cvv: snapshot.data!.cvv,
                            pan: snapshot.data!.pan,
                          );
                        }
                        return cardField(userAccountSummary, isLoading: true);
                      },
                    )
                  : cardField(userAccountSummary),
              const CustomSpacer(size: 14),
              userAccountSummary['data']['physicalCard']['status'] == "ACTIVE"
                  ? cardValueField(userAccountSummary)
                  : cardNoActiveValueField(
                      userAccountSummary['data']['physicalCard']['status'])
            ],
          ),
        ));
  }

  Widget cardNoActiveValueField(status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Card Status',
            style: TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w600)),
        Container(
            padding: EdgeInsets.only(
                left: wScale(16),
                right: wScale(16),
                top: hScale(5),
                bottom: hScale(5)),
            decoration: BoxDecoration(
              color: status == "INACTIVE"
                  ? Color(0xFF1A2831)
                  : status == "SUSPENDED"
                      ? Color(0xFFc9e8fb)
                      : Color(0xFFffdfd5),
              borderRadius: BorderRadius.all(
                Radius.circular(hScale(16)),
              ),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      status == "INACTIVE"
                          ? "Unactivated"
                          : status == "SUSPENDED"
                              ? "Frozen"
                              : "Cancelled",
                      style: TextStyle(
                          fontSize: fSize(12),
                          fontWeight: FontWeight.w500,
                          height: 1,
                          color: status == "INACTIVE"
                              ? Color(0XFFFFFFFF)
                              : status == "SUSPENDED"
                                  ? Color(0xFF0C649A)
                                  : Color(0xFFEB5757))),
                ]))
      ],
    );
  }

  Widget cardTitle(userAccountSummary) {
    var isAdmin = userStorage.getItem('isAdmin');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('My Card',
            style: TextStyle(
                fontSize: fSize(14),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2831))),
        userAccountSummary['data']['physicalCard'] == null
            ? SizedBox()
            : TextButton(
                style: TextButton.styleFrom(
                  primary: const Color(0xff60C094),
                  padding: EdgeInsets.zero,
                  textStyle: TextStyle(
                      fontSize: fSize(12),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff60C094),
                      decoration: TextDecoration.underline),
                ),
                onPressed: () {
                  isAdmin ? handleCloneSetting() : null;
                },
                child: Text(isAdmin ? 'Clone Settings' : '',
                    style: TextStyle(decoration: TextDecoration.underline)),
              ),
      ],
    );
  }

  Widget cardField(userAccountSummary,
      {bool isLoading = false, String cvv = '', String pan = ''}) {
    return Stack(children: [
      Container(
          width: wScale(295),
          height: wScale(187),
          padding: EdgeInsets.all(hScale(16)),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/physical_card_detail.png"),
              colorFilter: new ColorFilter.mode(
                  Colors.black.withOpacity(
                      userAccountSummary['data']['physicalCard'] == null
                          ? 0.5
                          : 1),
                  BlendMode.dstATop),
              fit: BoxFit.contain,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: userAccountSummary['data'] == null
              ? SizedBox()
              : userAccountSummary['data']['physicalCard'] == null
                  ? SizedBox()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [const SizedBox(), eyeIconField()],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  userAccountSummary['data']['physicalCard']
                                      ['accountName'],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300,
                                      fontSize: fSize(14))),
                              const CustomSpacer(size: 6),
                              Row(children: [
                                Text(
                                    showCardDetail && pan.isNotEmpty
                                        ? "${pan.substring(0, 4)} ${pan.substring(4, 8)} ${pan.substring(8, 12)} ${pan.substring(12, 16)}"
                                        : '* * * *  * * * *  * * * *  ${userAccountSummary['data']['physicalCard']['permanentAccountNumber'].split("******")[1]}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: fSize(16))),
                                SizedBox(width: wScale(7)),
                                widget.data['data']['physicalCard']['status'] ==
                                            'ACTIVE' &&
                                        showCardDetail
                                    ? Container(
                                        width: wScale(14),
                                        height: hScale(14),
                                        alignment: Alignment.center,
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            primary: const Color(0xff515151),
                                            padding: EdgeInsets.all(0),
                                            textStyle: TextStyle(
                                                fontSize: fSize(14),
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xff040415)),
                                          ),
                                          onPressed: () {
                                            handleCopied(0, pan);
                                          },
                                          child: const Icon(Icons.content_copy,
                                              color: Color(0xff30E7A9),
                                              size: 14.0),
                                        ))
                                    : SizedBox(),
                                SizedBox(width: wScale(4)),
                                flagCopiedAccount
                                    ? TextButton(
                                        style: TextButton.styleFrom(
                                          primary: const Color(0xff515151),
                                          padding: EdgeInsets.all(0),
                                        ),
                                        onPressed: () {
                                          handleCopied(0, pan);
                                        },
                                        child: Text('Copied',
                                            style: TextStyle(
                                                fontSize: fSize(14),
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    const Color(0xff30E7A9))))
                                    : const SizedBox(),
                              ]),
                            ],
                          ),
                          Row(children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Valid Thru',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: fSize(10))),
                                Text(
                                    showCardDetail
                                        ? "${userAccountSummary['data']['physicalCard']['expiryDate'].substring(0, 2)}/${userAccountSummary['data']['physicalCard']['expiryDate'].substring(2, 4)}"
                                        : 'MM / DD',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: fSize(11),
                                        fontWeight: FontWeight.bold))
                              ],
                            ),
                            SizedBox(width: wScale(10)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CVV',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: fSize(10))),
                                Text(
                                    showCardDetail && cvv.isNotEmpty
                                        ? cvv
                                        : '* * *',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: fSize(11),
                                        fontWeight: FontWeight.bold))
                              ],
                            ),
                            SizedBox(width: wScale(6)),
                            widget.data['data']['physicalCard']['status'] ==
                                        'ACTIVE' &&
                                    showCardDetail
                                ? Container(
                                    width: wScale(14),
                                    height: hScale(14),
                                    alignment: Alignment.center,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        primary: const Color(0xff515151),
                                        padding: EdgeInsets.all(0),
                                        textStyle: TextStyle(
                                            fontSize: fSize(14),
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xff040415)),
                                      ),
                                      onPressed: () {
                                        handleCopied(
                                            1,
                                            userAccountSummary['data']
                                                ['physicalCard']['cvv']);
                                      },
                                      child: const Icon(Icons.content_copy,
                                          color: Color(0xff30E7A9), size: 14.0),
                                    ))
                                : SizedBox(),
                            SizedBox(width: wScale(4)),
                            flagCopiedCVV
                                ? TextButton(
                                    style: TextButton.styleFrom(
                                      primary: const Color(0xff515151),
                                      padding: EdgeInsets.all(0),
                                    ),
                                    onPressed: () {
                                      handleCopied(
                                          1,
                                          userAccountSummary['data']
                                              ['physicalCard']['cvv']);
                                    },
                                    child: Text('Copied',
                                        style: TextStyle(
                                            fontSize: fSize(14),
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xff30E7A9))))
                                : const SizedBox(),
                          ])
                        ])),
      if (isLoading)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            color: Colors.white.withOpacity(0.7),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
    ]);
  }

  Widget cardValueField(userAccountSummary) {
    var availableLimit = userAccountSummary['data']['physicalCard'] == null
        ? {}
        : userAccountSummary['data']['physicalCard']['financeAccountLimits'][0]
            ['availableLimit'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Available Limit',
            style: TextStyle(
                fontSize: fSize(14),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2831))),
        Container(
            padding: EdgeInsets.only(
                left: wScale(16),
                right: wScale(16),
                top: hScale(5),
                bottom: hScale(5)),
            decoration: BoxDecoration(
              color: const Color(0xFFDEFEE9),
              borderRadius: BorderRadius.all(
                Radius.circular(hScale(16)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    userAccountSummary['data']['physicalCard'] == null
                        ? ""
                        : "${userAccountSummary['data']['physicalCard']['currencyCode']}  ",
                    style: TextStyle(
                        fontSize: fSize(12),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF30E7A9),
                        height: 1)),
                Text(
                    userAccountSummary['data'] == null
                        ? '0'
                        : userAccountSummary['data']['physicalCard'] == null
                            ? '0'
                            : "${availableLimit.toString()}",
                    style: TextStyle(
                        fontSize: fSize(16),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF30E7A9)))
              ],
            ))
      ],
    );
  }

  Widget eyeIconField() {
    return widget.data['data']['physicalCard']['status'] == 'INACTIVE'
        ? SizedBox()
        : Container(
            height: hScale(34),
            width: hScale(34),
            // padding: EdgeInsets.all(hScale(17)),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(hScale(17)),
                  topRight: Radius.circular(hScale(17)),
                  bottomLeft: Radius.circular(hScale(17)),
                  bottomRight: Radius.circular(hScale(17)),
                )),
            child: IconButton(
              padding: const EdgeInsets.all(0),
              // icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xff30E7A9),),
              icon: Image.asset(
                  showCardDetail
                      ? 'assets/hide_eye.png'
                      : 'assets/show_eye.png',
                  fit: BoxFit.contain,
                  height: hScale(16)),
              iconSize: hScale(17),
              onPressed: () {
                handleShowCardDetail();
              },
            ));
  }
}

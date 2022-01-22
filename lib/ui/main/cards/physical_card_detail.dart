import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:flutter/services.dart';

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

  bool showCardDetail = true;
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return cardDetailField(widget.data);
  }

  Widget cardDetailField(userAccountSummary) {
    return Opacity(
        opacity:
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
                blurRadius: 20,
                offset: const Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomSpacer(size: 10),
              cardTitle(userAccountSummary),
              const CustomSpacer(size: 10),
              cardField(userAccountSummary),
              const CustomSpacer(size: 14),
              cardValueField(userAccountSummary)
            ],
          ),
        ));
  }

  Widget cardTitle(userAccountSummary) {
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
                onPressed: () {},
                child: const Text('Clone Settings',
                    style: TextStyle(decoration: TextDecoration.underline)),
              ),
      ],
    );
  }

  Widget cardField(userAccountSummary) {
    return Container(
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
                                  showCardDetail
                                      ? userAccountSummary['data']
                                              ['physicalCard']
                                          ['permanentAccountNumber']
                                      : '* * * *  * * * *  * * * *  * * * *',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: fSize(16))),
                              SizedBox(width: wScale(7)),
                              widget.data['data']['physicalCard']['status'] ==
                                      'ACTIVE'
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
                                              0,
                                              userAccountSummary['data']
                                                      ['physicalCard']
                                                  ['permanentAccountNumber']);
                                        },
                                        child: const Icon(Icons.content_copy,
                                            color: Color(0xff30E7A9),
                                            size: 14.0),
                                      ))
                                  : SizedBox(),
                              SizedBox(width: wScale(4)),
                              flagCopiedAccount
                                  ? Text('Copied',
                                      style: TextStyle(
                                          fontSize: fSize(14),
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xff30E7A9)))
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
                                      ? userAccountSummary['data']
                                          ['physicalCard']['expiryDate']
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
                                  showCardDetail
                                      ? userAccountSummary['data']
                                          ['physicalCard']['cvv']
                                      : '* * *',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: fSize(11),
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                          SizedBox(width: wScale(6)),
                          widget.data['data']['physicalCard']['status'] ==
                                  'ACTIVE'
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
                              ? Text('Copied',
                                  style: TextStyle(
                                      fontSize: fSize(14),
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xff30E7A9)))
                              : const SizedBox(),
                        ])
                      ]));
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
    return widget.data['data']['physicalCard']['status'] == 'ACTIVE'
        ? Container(
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
            ))
        : SizedBox();
  }
}

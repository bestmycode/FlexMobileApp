import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/custom_textfield.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/scale.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';

class RequestPhysicalNewNameModalField extends StatefulWidget {
  RequestPhysicalNewNameModalField({
    required this.companyNameCtl,
    required this.setCompanyNameText,
  });
  final setCompanyNameText;
  final TextEditingController companyNameCtl;

  @override
  State<StatefulWidget> createState() {
    return ModalFieldState();
  }
}

class ModalFieldState extends State<RequestPhysicalNewNameModalField> {
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
  String updateCompanyNameMutation = FXRMutations.MUTATION_UPDATE_COMPANY_NAME;
  var iisCompanyNameCtlEmpty = false;

  @override
  void initState() {
    super.initState();
    if (widget.companyNameCtl.text == "") {
      setState(() {
        iisCompanyNameCtlEmpty = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    return Container(
        width: wScale(327),
        padding:
            EdgeInsets.symmetric(horizontal: wScale(16), vertical: hScale(16)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.asset('assets/company.png',
              fit: BoxFit.contain, height: hScale(150)),
          CustomSpacer(size: 10),
          Text('Company Name one-time setup',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: fSize(20),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF000000))),
          CustomSpacer(size: 10),
          Text(
              'Congratulations, you are about to issue your first Flex Physical Card. Please do a one-time setup of your company name that will appear on all the physical cards.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: fSize(14),
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF70828D))),
          CustomSpacer(size: 20),
          Container(
              width: wScale(295),
              alignment: Alignment.centerLeft,
              child: Text('Company Name to be shown on the card',
                  style: TextStyle(
                      fontSize: fSize(14),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF70828D)))),
          CustomSpacer(size: 10),
          CustomTextField(
            ctl: widget.companyNameCtl,
            hint: 'Type Company Name',
            label: 'Company Name',
            inputFormatters: [LengthLimitingTextInputFormatter(16)],
            onChanged: (text) {
              setState(() {
                iisCompanyNameCtlEmpty = text.isEmpty;
              });
            },
          ),
          CustomSpacer(size: 10),
          Container(
              width: wScale(295),
              alignment: Alignment.centerLeft,
              child: Text(
                  '*Company name will appear in uppercase on your card.',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: fSize(14),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF70828D)))),
          CustomSpacer(size: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              modalBackButton('Back'),
              mutationButton('Confirm', iisCompanyNameCtlEmpty)
            ],
          )
        ]));
  }

  Widget modalBackButton(title) {
    return SizedBox(
        width: wScale(141),
        height: hScale(56),
        // margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            primary: const Color(0xff1A2831).withOpacity(0.1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          child: Text(title,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget mutationButton(title, isCompanyNameCtlEmpty) {
    return Mutation(
        options: MutationOptions(
          document: gql(updateCompanyNameMutation),
          update: (GraphQLDataProxy cache, QueryResult? result) {
            return cache;
          },
          onCompleted: (resultData) {
            if (resultData['updateOrganizationAlias']['id'] > 0) {
              setState(() {
                widget.setCompanyNameText(widget.companyNameCtl.text.toUpperCase());
              });
              Navigator.of(context).pop();
            }
          },
        ),
        builder: (RunMutation runMutation, QueryResult? result) {
          return modalSaveButton(runMutation, title, isCompanyNameCtlEmpty);
        });
  }

  Widget modalSaveButton(runMutation, title, isCompanyNameCtlEmpty) {
    return Opacity(
        opacity: isCompanyNameCtlEmpty ? 0.5 : 1,
        child: SizedBox(
            width: wScale(141),
            height: hScale(56),
            // margin: EdgeInsets.only(left: wScale(8), right: wScale(8)),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                primary: const Color(0xff1A2831),
                side: const BorderSide(width: 0, color: Color(0xff1A2831)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                isCompanyNameCtlEmpty
                    ? null
                    : runMutation({
                        'orgId': userStorage.getItem('orgId'),
                        'organizationAlias': widget.companyNameCtl.text.toUpperCase()
                      });
              },
              child: Text(title,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fSize(16),
                      fontWeight: FontWeight.w700)),
            )));
  }
}

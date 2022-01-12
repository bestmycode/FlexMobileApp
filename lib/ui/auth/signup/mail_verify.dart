import 'package:co/constants/constants.dart';
import 'package:co/ui/auth/signup/company_detail.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/ui/widgets/signup_progress_header.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';

class MailVerifyScreen extends StatefulWidget {
  final verifyCode;
  const MailVerifyScreen({Key? key, this.verifyCode}) : super(key: key);

  @override
  MailVerifyScreenState createState() => MailVerifyScreenState();
}

class MailVerifyScreenState extends State<MailVerifyScreen> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }
  final LocalStorage infoStorage = LocalStorage('sign_up_info1');
  final LocalStorage storage = LocalStorage('token');
  
  final numCtl1 = TextEditingController(text: '');
  final numCtl2 = TextEditingController(text: '');
  final numCtl3 = TextEditingController(text: '');
  final numCtl4 = TextEditingController(text: '');
  final numCtl5 = TextEditingController(text: '');
  final numCtl6 = TextEditingController(text: '');
  bool flagValid = true;
  String verifyMutation = FXRMutations.MUTATION_VERIFY_CODE;

  handleVerify(runMutation) {
    int verify_num = int.parse('${numCtl1.text}${numCtl2.text}${numCtl3.text}${numCtl4.text}${numCtl5.text}${numCtl6.text}');
    runMutation({'verificationCode': verify_num});
    bool flag = verify_num == widget.verifyCode;
    setState(() {
      flagValid = flag;
      // if (flag) Navigator.of(context).pushReplacementNamed(COMPANY_DETAIL);
      if(flag)
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (context) => CompanyDetailScreen()),
        );
    });
  }

  resendEmail() {}

  @override
  void initState() {
    setState(() {
      // email = storage.getItem('companyEmail');  
    });
    super.initState();
  }

  
  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    return Material(
      child: Scaffold(
          body: Mutation(
      options: MutationOptions(
        document: gql(verifyMutation),
        update: ( GraphQLDataProxy cache, QueryResult? result) {
          return cache;
        },
        onCompleted: (resultData) {
          print(resultData);
        },
      ),
      builder: (RunMutation runMutation, QueryResult? result ) {
        return mainHome(runMutation);
      })));
  }

  Widget mainHome(runMutation) {
    return SingleChildScrollView(
      child: Column(children: [
        const SignupProgressHeader(),
        const CustomSpacer(size: 40),
        mailIcon(),
        const CustomSpacer(size: 28),
        mailTitle(),
        const CustomSpacer(size: 26),
        mailSection(),
        const CustomSpacer(size: 36),
        verifyNumberSection(),
        flagValid ? const CustomSpacer(size: 14) : CustomSpacer(size: 0),
        subSection(),
        verifyButton(runMutation),
      ]));
  }

  Widget mailIcon() {
    return Image.asset('assets/mail_check.png',
        fit: BoxFit.contain, width: wScale(74));
  }

  Widget mailTitle() {
    return Text(
        "Please verify your email address to start\nyour account creation process",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w600));
  }

  Widget mailSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('We have sent an OTP to ', style: TextStyle(fontSize: fSize(14), color: Color(0xFF515151))),
        Text(infoStorage.getItem('companyEmail'), style: TextStyle(fontSize: fSize(14), color: Color(0xFF000000), fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget verifyButton(runMutation) {
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
            handleVerify(runMutation);
          },
          child: Text("Verify",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fSize(16),
                  fontWeight: FontWeight.w700)),
        ));
  }

  Widget verifyNumber(num) {
    return Container(
      width: hScale(50),
      height: hScale(50),
      margin: EdgeInsets.only(right: wScale(4), left: wScale(4)),
      child: TextField(
        textInputAction: num != 6 ? TextInputAction.next : TextInputAction.done,
        onChanged: (_) => num != 6 ? FocusScope.of(context).nextFocus() : FocusScope.of(context).unfocus(),
        textAlign: TextAlign.center,
        controller: num == 1
            ? numCtl1
            : num == 2
                ? numCtl2
                : num == 3
                    ? numCtl3
                    : num == 4
                        ? numCtl4
                        : num == 5
                            ? numCtl5
                            : numCtl6,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: fSize(24),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly
        ], // Only numbers can be entered
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(0),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: flagValid == false
                      ? Color(0xffEB5757)
                      : Color(0xffE2E2E2),
                  width: 1.0)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: flagValid == false
                      ? Color(0xffEB5757)
                      : Color(0xffE2E2E2),
                  width: 1.0)),
        ),
      ),
    );
  }

  Widget verifyNumberSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        verifyNumber(1),
        verifyNumber(2),
        verifyNumber(3),
        verifyNumber(4),
        verifyNumber(5),
        verifyNumber(6),
      ],
    );
  }

  Widget validError(errorFlag) {
    return SizedBox(
      height: errorFlag ? 0 : hScale(18),
      child: Text("Verification code is invalid",
          style:
              TextStyle(fontSize: fSize(14), color: const Color(0xffEB5757))),
    );
  }

  Widget expireTitle() {
    return Text("This OTP expires in 30 minutes",
        style: TextStyle(fontSize: fSize(14), fontWeight: FontWeight.bold));
  }

  Widget subSection() {
    return SizedBox(
      height: hScale(137),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [validError(flagValid), expireTitle(), resendButton()],
      ),
    );
  }

  Widget resendButton() {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xff21C990),
        textStyle: TextStyle(
            fontSize: fSize(14),
            color: const Color(0xff21C990),
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline),
      ),
      onPressed: () {
        resendEmail();
      },
      child: Text('Resend OTP to ${infoStorage.getItem("companyEmail")}'),
    );
  }
}

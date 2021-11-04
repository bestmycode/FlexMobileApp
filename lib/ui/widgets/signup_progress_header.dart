import 'package:flutter/cupertino.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

class SignupProgressHeader extends StatefulWidget {
  final String title;
  final int progress;

  const SignupProgressHeader({Key? key, this.title="Create an account", this.progress = 1}) : super(key: key);

  @override
  _SignupProgressHeader createState() => _SignupProgressHeader();
}

class _SignupProgressHeader extends State<SignupProgressHeader> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  @override
  Widget build(BuildContext context) {
      return logo();
  }

  Widget logo() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: hScale(174),
        padding: EdgeInsets.only(top: hScale(44)),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/signup_top_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: hScale(40),
                  child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                            widget.title,
                            style: TextStyle(color: const Color(0xffffffff), fontSize: fSize(24), fontWeight: FontWeight.w700 )),
                        backButton()
                      ]
                  )
              ),
              const CustomSpacer(size: 25),
              signUpProgressField()
            ]
        )
    );
  }

  Widget signUpProgressField() {
    return (
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: hScale(32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              roundNumber(1,  widget.progress>= 1),
              hypen(widget.progress >= 1),
              roundNumber(2, widget.progress >= 2),
              hypen(widget.progress >= 2),
              roundNumber(3, widget.progress >= 3),
              hypen(widget.progress >= 3),
              roundNumber(4, widget.progress >= 4)
            ],
          ),
        )
    );
  }

  Widget backButton() {
    return Positioned(
        left: 24.0,
        top: 0.0,
        child: SizedBox(
            width: hScale(40),
            height: hScale(40),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: const Color(0xff727a80),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  padding: const EdgeInsets.all(0)
              ),
              onPressed: () {  },
              child: Icon(Icons.arrow_back_ios, color: Colors.white, size:wScale(13)),
            )
        )
    );
  }

  Widget roundNumber(num, active) {
    return Container(
      width: hScale(32),
      height: hScale(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: active ? const Color(0xff30E7A9) : Colors.white,
        ),
        borderRadius: BorderRadius.circular(hScale(16)),
      ),
      child: num != 4
          ? Text(num.toString(), style: TextStyle(color: active ? const Color(0xff30E7A9) : Colors.white))
          : Icon(Icons.check , color: active ? const Color(0xff30E7A9) : Colors.white, size: wScale(16)),
    );
  }

  Widget hypen(active) {
    return Container(
      width: wScale(30),
      height: 1,
      color: active ? const Color(0xff30E7A9) : Colors.white,
    );
  }
}

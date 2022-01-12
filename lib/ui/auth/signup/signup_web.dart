import 'package:co/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class SignUpWebScreen extends StatefulWidget {
  const SignUpWebScreen({Key? key}) : super(key: key);

  @override
  SignUpWebScreenState createState() => SignUpWebScreenState();
}

class SignUpWebScreenState extends State<SignUpWebScreen> {
  
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  final signupUrl = 'https://app.staging.fxr.one/signup';
  
  @override
  void initState() {
    super.initState();
    flutterWebViewPlugin.onUrlChanged.listen((String url) {
      if(url == "https://app.staging.fxr.one/flex/dashboard") {
        Navigator.of(context).pushReplacementNamed(SIGN_IN);
      }
    });
  }

  @override
  void dispose() {
    flutterWebViewPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: WebviewScaffold(
        url: signupUrl,
        withZoom: true,
        withLocalStorage: true,
        hidden: true,
      ),
    );
  }
}

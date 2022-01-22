import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height;
    double width = MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width;
    return Material(
      child: Container(
        height: height / 10,
        width: width,
        // ignore: prefer_const_constructors
        padding: EdgeInsets.only(left: 15, top: 25),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.orange, Colors.pinkAccent]),
        ),
        child: Row(
          children: <Widget>[
            IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        ),
      ),
    );
  }
}

import 'package:flexflutter/ui/main/cards/card.dart';
import 'package:flexflutter/ui/main/credit/credit.dart';
import 'package:flexflutter/ui/main/home/home.dart';
import 'package:flexflutter/ui/main/more/more.dart';
import 'package:flexflutter/ui/main/transactions/transaction.dart';
import 'package:flexflutter/utils/scale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
      activeColor: const Color(0xff29C490),
      items: [
        BottomNavigationBarItem(
            icon: Image.asset('assets/grey_home.png', height: hScale(18), fit: BoxFit.contain,),
            activeIcon: Image.asset('assets/green_home.png', height: hScale(18), fit: BoxFit.contain,),
            label:'Home'
        ),
        BottomNavigationBarItem(
            icon: Image.asset('assets/grey_card.png', height: hScale(18), fit: BoxFit.contain,),
            activeIcon: Image.asset('assets/green_card.png', height: hScale(18), fit: BoxFit.contain,),
            label:'Cards'
        ),
        BottomNavigationBarItem(
            icon: Image.asset('assets/grey_transaction.png', height: hScale(18), fit: BoxFit.contain,),
            activeIcon: Image.asset('assets/green_transaction.png', height: hScale(18), fit: BoxFit.contain,),
            label:'Transactions'
        ),
        BottomNavigationBarItem(
            icon: Image.asset('assets/grey_credit.png', height: hScale(18), fit: BoxFit.contain,),
            activeIcon: Image.asset('assets/green_credit.png', height: hScale(18), fit: BoxFit.contain,),
            label:'Credit'
        ),
        BottomNavigationBarItem(
            icon: Image.asset('assets/grey_more.png', height: hScale(18), fit: BoxFit.contain,),
            activeIcon: Image.asset('assets/green_more.png', height: hScale(18), fit: BoxFit.contain,),
            label:'More'
        ),
      ],
    ),
      tabBuilder: (BuildContext context, int index) {
      return CupertinoTabView(
        builder: (BuildContext context) {
        return CupertinoPageScaffold(
            child:
              index == 0
                ? const Home()
                : index == 1
                  ? const Cards()
                  : index == 2
                    ? const Transactions()
                    : index == 3
                      ? const Credit()
                      : const More()
            );
          },
        );
      },
    );
  }
}
import 'package:co/utils/scale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key key}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  var navigatorKeyList = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>()
  ];
  int currentIndex = 0;
  var controller = CupertinoTabController(initialIndex: 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
    // return Material(
    //   child: CupertinoTabScaffold(
    //     controller: controller,
    //     tabBar: CupertinoTabBar(
    //       activeColor: const Color(0xff29C490),
    //       onTap: (index) {
    //         if (currentIndex == index) {
    //           navigatorKeyList[index].currentState!.popUntil((route) {
    //             return route.isFirst;
    //           });
    //         }
    //         currentIndex = index;
    //       },
    //       items: [
    //         BottomNavigationBarItem(
    //             icon: Image.asset('assets/grey_home.png', height: hScale(18), fit: BoxFit.contain,),
    //             activeIcon: Image.asset('assets/green_home.png', height: hScale(18), fit: BoxFit.contain,),
    //             label:'Home'
    //         ),
    //         BottomNavigationBarItem(
    //             icon: Image.asset('assets/grey_card.png', height: hScale(18), fit: BoxFit.contain,),
    //             activeIcon: Image.asset('assets/green_card.png', height: hScale(18), fit: BoxFit.contain,),
    //             label:'Cards'
    //         ),
    //         BottomNavigationBarItem(
    //             icon: Image.asset('assets/grey_transaction.png', height: hScale(18), fit: BoxFit.contain,),
    //             activeIcon: Image.asset('assets/green_transaction.png', height: hScale(18), fit: BoxFit.contain,),
    //             label:'Transactions'
    //         ),
    //         BottomNavigationBarItem(
    //             icon: Image.asset('assets/grey_credit.png', height: hScale(18), fit: BoxFit.contain,),
    //             activeIcon: Image.asset('assets/green_credit.png', height: hScale(18), fit: BoxFit.contain,),
    //             label:'Credit'
    //         ),
    //         BottomNavigationBarItem(
    //             icon: Image.asset('assets/grey_more.png', height: hScale(18), fit: BoxFit.contain,),
    //             activeIcon: Image.asset('assets/green_more.png', height: hScale(18), fit: BoxFit.contain,),
    //             label:'More'
    //         ),
    //       ],
    //     ),
    //     tabBuilder: (BuildContext context, int index) {
    //       switch (index) {
    //         case 0:
    //           return CupertinoTabView(
    //             navigatorKey: navigatorKeyList[index],
    //             routes: {
    //               '/': (context) => WillPopScope(
    //                 child: Home(controller: controller, navigatorKey: navigatorKeyList[1]),
    //                 onWillPop: () => Future<bool>.value(true),
    //               ),
    //             },
    //           );
    //         case 1:
    //           return CupertinoTabView(
    //             navigatorKey: navigatorKeyList[index],
    //             routes: {
    //               '/': (context) => WillPopScope(
    //                 child: PhysicalCards(controller: controller, navigatorKey: navigatorKeyList[0]),
    //                 onWillPop: () => Future<bool>.value(true),
    //               ),
    //               'physical': (context) => PhysicalCards(controller: controller, navigatorKey: navigatorKeyList[0]),
    //               'virtual': (context) => VirtualCards(controller: controller, navigatorKey: navigatorKeyList[0]),
    //             },
    //           );
    //         case 2:
    //           return CupertinoTabView(
    //             navigatorKey: navigatorKeyList[index],
    //             routes: {
    //               '/': (context) => WillPopScope(
    //                 child: TransactionAdmin(controller: controller, navigatorKey: navigatorKeyList[0]),
    //                 onWillPop: () => Future<bool>.value(true),
    //               )
    //             },
    //           );
    //         case 3:
    //           return CupertinoTabView(
    //             navigatorKey: navigatorKeyList[index],
    //             routes: {
    //               '/': (context) => WillPopScope(
    //                 child: Credit(controller: controller, navigatorKey: navigatorKeyList[0]),
    //                 onWillPop: () => Future<bool>.value(true),
    //               )
    //             },
    //           );
    //         case 4:
    //           return CupertinoTabView(
    //             navigatorKey: navigatorKeyList[index],
    //             routes: {
    //               '/': (context) => WillPopScope(
    //                 child: PhysicalCards(controller: controller, navigatorKey: navigatorKeyList[0]),
    //                 onWillPop: () => Future<bool>.value(true),
    //               )
    //             },
    //           );
    //         default:
    //           return Text('Index must be less than 2');
    //       }
    //     },
    //   )
    // );
  }

  // Widget _getPageForTabIndex(int index) {
  //   return CupertinoPageScaffold(
  //       child:
  //       index == 0
  //           ? const Home()
  //           : index == 1
  //           ? const PhysicalCards()
  //           : index == 2
  //           ? const Transactions()
  //           : index == 3
  //           ? const Credit()
  //           : const More()
  //   );
  // }

  // void _onWantsToNavigateToHomePage() {
  //   // Works only once
  //   _setCurrentIndex(0);
  // }
  //
  // void _setCurrentIndex(int index) {
  //   setState(() {
  //     _currentIndex = index;
  //   });
  // }
}

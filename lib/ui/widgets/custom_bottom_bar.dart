// ignore: file_names
// ignore: file_names

import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/ui/main/cards/physical_card.dart';
import 'package:flexflutter/ui/main/cards/view_limits.dart';
import 'package:flexflutter/ui/main/cards/virtual_card.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';

class CustomBottomBar extends StatefulWidget {
  final int active;

  const CustomBottomBar({Key? key, this.active = 0 }) : super(key: key);

  @override
  CustomBottomBarState createState() => CustomBottomBarState();

}

class CustomBottomBarState extends State<CustomBottomBar> {

  hScale(double scale) {
    return Scale().hScale(context, scale);
  }
  wScale(double scale) {
    return Scale().wScale(context, scale);
  }
  fSize(double size) {
    return Scale().fSize(context, size);
  }

  handleTabItem(active) {
    if(widget.active == active && active != 1) {
      return;
    } else if(active == 0){
      Navigator.of(context).pushReplacementNamed(HOME_SCREEN);
    } else if(active == 1) {
      _openCardTypeDialog();
    } else if(active == 2) {
      Navigator.of(context).pushReplacementNamed(TRANSACTION_ADMIN);
    } else if(active == 3) {
      Navigator.of(context).pushReplacementNamed(CREDIT_SCREEN);
    } else if(active == 4) {
      Navigator.of(context).pushReplacementNamed(PHYSICAL_CARD);
    }
  }

  handleCard(type) {
    if(type == 1) {
      Navigator.of(context).push(
        CupertinoPageRoute (
            builder: (context) => const PhysicalCards()
        ),
      );
    } else {
      Navigator.of(context).push(
        CupertinoPageRoute (
            builder: (context) => const VirtualCards()
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: hScale(88),
      color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                navItem(widget.active == 0 ? 'assets/green_home.png' : 'assets/grey_home.png', 'Home', 0),
                navItem(widget.active == 1 ? 'assets/green_card.png' : 'assets/grey_card.png', 'Cards', 1),
                navItem(widget.active == 2 ? 'assets/green_transaction.png' : 'assets/grey_transaction.png', 'Transactions', 2),
                navItem(widget.active == 3 ? 'assets/green_credit.png' : 'assets/grey_credit.png', 'Credit', 3),
                navItem(widget.active == 4 ? 'assets/green_more.png' : 'assets/grey_more.png', 'More', 4),
              ],
            )
          ],
        )
    );
  }

  Widget navItem(icon, title, active) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: const Color(0xFFFFFFFF),
        padding: EdgeInsets.symmetric(horizontal: wScale(0)),
      ),
      onPressed: () { handleTabItem(active); },
      child: Column(
        children: [
          Image.asset(icon, height: hScale(18), fit: BoxFit.contain),
          const CustomSpacer(size: 8),
          Text(title,
              style:TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w400, color: active == widget.active ? const Color(0xFF29C490) : const Color(0xFFBFBFBF))
          )
        ],
      )
    );
  }

  void _openCardTypeDialog() => showModalBottomSheet<void>(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(hScale(24)),
        topRight: Radius.circular(hScale(24)),
      ),
    ),
    builder: (BuildContext context) {
      return Container(
        height: hScale(209),
        padding: EdgeInsets.symmetric(horizontal: hScale(24)),
        child: Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CustomSpacer(size: 35),
              modalItem('Physical Cards', () => handleCard(1)),
              const CustomSpacer(size: 18),
              modalItem('Virtual Cards', () => handleCard(2)),
            ],
          ),
        ),
      );
    },
  );

  Widget modalItem(title, event) {
    return TextButton(
        style: TextButton.styleFrom(
          primary: const Color(0xFFFFFFFF),
          padding: EdgeInsets.zero
        ),
        onPressed: event,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: hScale(46),
                  height: hScale(46),
                  padding: EdgeInsets.all(hScale(12)),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(hScale(46)),
                      border: Border.all(width: 1, color: const Color(0xFFE5E5E5))
                  ),
                  child: Image.asset('assets/green_card.png', height: hScale(18), fit: BoxFit.contain),
                ),
                const SizedBox(width: 20),
                Text(title, style:TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w600, color: const Color(0xFF515151).withOpacity(0.7)))
              ]
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFB4DEDD),size: 16,)
          ],
        )
    );
  }


}

import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/ui/main/cards/physical_card.dart';
import 'package:flexflutter/ui/main/cards/virtual_card.dart';
import 'package:flexflutter/ui/main/credit/credit.dart';
import 'package:flexflutter/ui/main/home/home.dart';
import 'package:flexflutter/ui/main/more/account_setting.dart';
import 'package:flexflutter/ui/main/more/company_setting.dart';
import 'package:flexflutter/ui/main/transactions/transaction_admin.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';
import 'dart:io' show Platform;

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
    if(widget.active%10 == active%10 && active%10 != 1 && active%10 != 4) {
      return;
    } else if(active == 0){
      Navigator.of(context).pushReplacementNamed(HOME_SCREEN);
    } else if(active%10 == 1) {
      _openCardTypeDialog();
    } else if(active == 2) {
      Navigator.of(context).pushReplacementNamed(TRANSACTION_ADMIN);
    } else if(active == 3) {
      Navigator.of(context).pushReplacementNamed(CREDIT_SCREEN);
    } else if(active == 4) {
      _openMenuDialog();
      // Navigator.of(context).pushReplacementNamed(PHYSICAL_CARD);
    }
  }

  handleCard(type) {
    Navigator.pop(context);
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

  handleMenu(type, active) {
    Navigator.pop(context);
    if(widget.active == active) {
      return;
    }
    if(type == 'home') {
      Navigator.of(context).push(
        CupertinoPageRoute (
            builder: (context) => const HomeScreen()
        ),
      );
    }
    if(type == 'physical_card') {
      Navigator.of(context).push(
        CupertinoPageRoute (
            builder: (context) => const PhysicalCards()
        ),
      );
    }
    if(type == 'virtual_card') {
      Navigator.of(context).push(
        CupertinoPageRoute (
            builder: (context) => const VirtualCards()
        ),
      );
    }
    if(type == 'transaction') {
      Navigator.of(context).push(
        CupertinoPageRoute (
            builder: (context) => const TransactionAdmin()
        ),
      );
    }
    if(type == 'credit') {
      Navigator.of(context).push(
        CupertinoPageRoute (
            builder: (context) => const CreditScreen()
        ),
      );
    }
    if(type == 'company_setting') {
      Navigator.of(context).push(
        CupertinoPageRoute (
            builder: (context) => const CompanySetting()
        ),
      );
    }
    if(type == 'account_setting') {
      Navigator.of(context).push(
        CupertinoPageRoute (
            builder: (context) => const AccountSetting()
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
                navItem(widget.active%10 == 1 ? 'assets/green_card.png' : 'assets/grey_card.png', 'Cards', 1),
                navItem(widget.active == 2 ? 'assets/green_transaction.png' : 'assets/grey_transaction.png', 'Transactions', 2),
                navItem(widget.active == 3 ? 'assets/green_credit.png' : 'assets/grey_credit.png', 'Credit', 3),
                navItem(widget.active%10 == 4 ? 'assets/green_more.png' : 'assets/grey_more.png', 'More', 4),
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
              style:TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w400,
                  color: active == widget.active%10 ? const Color(0xFF29C490) : const Color(0xFFBFBFBF))
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
        // color: Colors.white,
        child: Container(
          color: Colors.white,
          child:  Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Platform.isAndroid ? const CustomSpacer(size: 35) : const CustomSpacer(size: 67),
              modalItem('Physical Cards', 'assets/green_card.png', 'assets/green_card.png', () => handleCard(1), 100),
              const CustomSpacer(size: 18),
              modalItem('Virtual Cards', 'assets/issue_virtual_card.png', 'assets/green_card.png', () => handleCard(2), 100),
            ],
          )
        )
      );
    },
  );

  void _openMenuDialog() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(hScale(24)),
        topRight: Radius.circular(hScale(24)),
      ),
    ),
    builder: (BuildContext context) {
      return Container(
        height: hScale(621),
        padding: EdgeInsets.symmetric(horizontal: hScale(24)),
        child:  Container(
          color: Colors.white,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomSpacer(size: 52),
              modalItem('Home', 'assets/green_home.png', 'assets/white_home.png', () => handleMenu('home', 0), 0),
              Platform.isAndroid ? const CustomSpacer(size: 0) : const CustomSpacer(size: 18),
              modalItem('Physical Cards', 'assets/green_card.png', 'assets/white_card.png', () => handleMenu('physical_card', 1), 1),
              Platform.isAndroid ? const CustomSpacer(size: 0) : const CustomSpacer(size: 18),
              modalItem('Virtual Cards', 'assets/issue_virtual_card.png', 'assets/white_virtual_card.png', () => handleMenu('virtual_card', 11), 11),
              Platform.isAndroid ? const CustomSpacer(size: 0) : const CustomSpacer(size: 18),
              modalItem('Transactions', 'assets/green_transaction.png', 'assets/white_transaction.png', () => handleMenu('transaction', 2), 2),
              Platform.isAndroid ? const CustomSpacer(size: 0) : const CustomSpacer(size: 18),
              modalItem('Flex PLUS Credit','assets/green_credit.png', 'assets/white_credit.png', () => handleMenu('credit', 3), 3),
              const CustomSpacer(size: 31),
              Container(
                width: wScale(327),
                height: 1,
                color: const Color(0xFFDAE3E9)
              ),
              const CustomSpacer(size: 30),
              modalItem('Company Settings', 'assets/green_company_setting.png', 'assets/white_company_setting.png', () => handleMenu('company_setting', 4), 4),
              Platform.isAndroid ? const CustomSpacer(size: 0) : const CustomSpacer(size: 18),
              modalItem('Account Settings', 'assets/green_user_setting.png', 'assets/white_user_setting.png',() => handleMenu('account_setting', 14), 14),
              Platform.isAndroid ? const CustomSpacer(size: 0) : const CustomSpacer(size: 18),
              modalItem('Log Out', 'assets/green_logout.png', 'assets/white_logout.png',() => handleMenu('logout', 5), 5),
            ],
          ),
        )
      );
    },
  );

  Widget modalItem(title, inactiveIcon, activeIcon, event, activeNum) {
    return Container(
      margin: EdgeInsets.zero,
      child: TextButton(
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
                          color: widget.active == activeNum ? const Color(0xFF29C490) : const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(hScale(46)),
                          border: Border.all(width: 1, color: widget.active == activeNum ? const Color(0xFF29C490) :const Color(0xFFE5E5E5))
                      ),
                      child: Image.asset(widget.active == activeNum ? activeIcon : inactiveIcon, height: hScale(18), fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 20),
                    Text(title, style:TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w600,
                        color: widget.active == activeNum ? const Color(0xFF29C490) : const Color(0xFF515151).withOpacity(0.7)))
                  ]
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: widget.active == activeNum ? const Color(0xFF30E7A9) : const Color(0xFFB4DEDD),size: 16,)
            ],
          )
      )
    );
  }
}

import 'package:co/constants/constants.dart';
import 'package:co/ui/main/cards/physical_card.dart';
import 'package:co/ui/main/cards/physical_user_card.dart';
import 'package:co/ui/main/cards/virtual_card.dart';
import 'package:co/ui/main/credit/credit.dart';
import 'package:co/ui/main/home/home.dart';
import 'package:co/ui/main/more/account_setting.dart';
import 'package:co/ui/main/more/company_setting.dart';
import 'package:co/ui/main/transactions/transaction_admin.dart';
import 'package:co/ui/main/transactions/transaction_user.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'dart:io' show Platform;
import 'package:localstorage/localstorage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomBottomBar extends StatefulWidget {
  final int active;
  final bool mobileVerified;
  const CustomBottomBar(
      {Key? key, this.active = 0, this.mobileVerified = true})
      : super(key: key);

  @override
  CustomBottomBarState createState() => CustomBottomBarState();
}

class CustomBottomBarState extends State<CustomBottomBar> {
  final LocalStorage userStorage = LocalStorage('user_info');
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
    bool isAdmin = userStorage.getItem("isAdmin");
    if (widget.active % 10 == active % 10 &&
        active % 10 != 1 &&
        active % 10 != 4) {
      return;
    } else if (active == 0) {
      Navigator.of(context).pushReplacementNamed(HOME_SCREEN);
    } else if (active % 10 == 1) {
      widget.mobileVerified ? _openCardTypeDialog() : null;
    } else if (active == 2) {
      widget.mobileVerified ? Navigator.of(context)
          .pushReplacementNamed(isAdmin ? TRANSACTION_ADMIN : TRANSACTION_USER): null;
    } else if (active == 3) {
      widget.mobileVerified ? Navigator.of(context).pushReplacementNamed(CREDIT_SCREEN): null;
    } else if (active == 4) {
      _openMenuDialog();
    }
  }

  handleCard(type) {
    Navigator.pop(context);
    bool isAdmin = userStorage.getItem("isAdmin");
    if (isAdmin) {
      if (type == 1) {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (context) => const PhysicalCards()),
        );
      } else {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (context) => const VirtualCards()),
        );
      }
    } else {
      if (type == 1) {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (context) => const PhysicalUserCard()),
        );
      } else {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (context) => const VirtualCards()),
        );
      }
    }
  }

  handleMenu(type, active) {
    Navigator.pop(context);
    bool isAdmin = userStorage.getItem("isAdmin");
    if (widget.active == active) {
      return;
    }
    if (type == 'home') {
      Navigator.of(context).push(
        CupertinoPageRoute(builder: (context) => const HomeScreen()),
      );
    }
    if (type == 'physical_card') {
      Navigator.of(context).push(
        CupertinoPageRoute(builder: (context) => const PhysicalCards()),
      );
    }
    if (type == 'virtual_card') {
      Navigator.of(context).push(
        CupertinoPageRoute(builder: (context) => const VirtualCards()),
      );
    }
    if (type == 'transaction') {
      Navigator.of(context).push(
        CupertinoPageRoute(
            builder: (context) =>
                isAdmin ? const TransactionAdmin() : const TransactionUser()),
      );
    }
    if (type == 'credit') {
      Navigator.of(context).push(
        CupertinoPageRoute(builder: (context) => const CreditScreen()),
      );
    }
    if (type == 'company_setting') {
      Navigator.of(context).push(
        CupertinoPageRoute(builder: (context) => CompanySetting(tabIndex: 0)),
      );
    }
    if (type == 'account_setting') {
      Navigator.of(context).push(
        CupertinoPageRoute(builder: (context) => const AccountSetting()),
      );
    }
    if (type == "logout") {
      Navigator.of(context).pushReplacementNamed(SPLASH_SCREEN);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = userStorage.getItem("isAdmin");
    bool isCredit = userStorage.getItem("isCredit");
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
                navItem(
                    widget.active == 0
                        ? 'assets/green_home.png'
                        : 'assets/grey_home.png',
                    AppLocalizations.of(context)!.home,
                    0),
                navItem(
                    widget.active % 10 == 1
                        ? 'assets/green_card.png'
                        : 'assets/grey_card.png',
                    AppLocalizations.of(context)!.cards,
                    1),
                navItem(
                    widget.active == 2
                        ? 'assets/green_transaction.png'
                        : 'assets/grey_transaction.png',
                    AppLocalizations.of(context)!.transactions,
                    2),
                isAdmin && isCredit
                    ? navItem(
                        widget.active == 3
                            ? 'assets/green_credit.png'
                            : 'assets/grey_credit.png',
                        AppLocalizations.of(context)!.credit,
                        3)
                    : SizedBox(),
                navItem(
                    widget.active % 10 == 4
                        ? 'assets/green_more.png'
                        : 'assets/grey_more.png',
                    AppLocalizations.of(context)!.more,
                    4),
              ],
            )
          ],
        ));
  }

  Widget navItem(icon, title, active) {
    bool isAdmin = userStorage.getItem("isAdmin");
    return Container(
        width: isAdmin
            ? MediaQuery.of(context).size.width / 5
            : MediaQuery.of(context).size.width / 4,
        alignment: Alignment.center,
        child: TextButton(
            style: TextButton.styleFrom(
              primary: const Color(0xFFFFFFFF),
              padding: EdgeInsets.symmetric(horizontal: wScale(0)),
            ),
            onPressed: () {
              handleTabItem(active);
            },
            child: Column(
              children: [
                Image.asset(icon, height: hScale(18), fit: BoxFit.contain),
                const CustomSpacer(size: 8),
                Text(title,
                    style: TextStyle(
                        fontSize: fSize(12),
                        fontWeight: FontWeight.w400,
                        color: active == widget.active % 10
                            ? const Color(0xFF29C490)
                            : const Color(0xFFBFBFBF)))
              ],
            )));
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(hScale(24)),
                  topRight: Radius.circular(hScale(24)),
                ),
              ),
              child: Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Platform.isAndroid
                          ? const CustomSpacer(size: 35)
                          : const CustomSpacer(size: 67),
                      modalItem(
                          AppLocalizations.of(context)!.physicalcards,
                          'assets/green_card.png',
                          'assets/green_card.png',
                          () => handleCard(1),
                          100),
                      const CustomSpacer(size: 18),
                      modalItem(
                          AppLocalizations.of(context)!.virtualcards,
                          'assets/issue_virtual_card.png',
                          'assets/green_card.png',
                          () => handleCard(2),
                          100),
                    ],
                  )));
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
          bool isAdmin = userStorage.getItem("isAdmin");
          bool isCredit = userStorage.getItem("isCredit");
          return Container(
              height: !widget.mobileVerified ? hScale(366) : isAdmin ? hScale(621) : hScale(474),
              padding: EdgeInsets.symmetric(horizontal: hScale(24)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(hScale(24)),
                  topRight: Radius.circular(hScale(24)),
                ),
              ),
              child: Container(
                color: Colors.white,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomSpacer(size: 52),
                    modalItem(
                        AppLocalizations.of(context)!.home,
                        'assets/green_home.png',
                        'assets/white_home.png',
                        () => handleMenu('home', 0),
                        0),
                    Platform.isAndroid
                        ? const CustomSpacer(size: 0)
                        : const CustomSpacer(size: 18),
                    widget.mobileVerified ? Column(
                      children: [
                        modalItem(
                            AppLocalizations.of(context)!.physicalcards,
                            'assets/green_card.png',
                            'assets/white_card.png',
                            () => handleMenu('physical_card', 1),
                            1),
                        Platform.isAndroid
                            ? const CustomSpacer(size: 0)
                            : const CustomSpacer(size: 18),
                        modalItem(
                            AppLocalizations.of(context)!.virtualcards,
                            'assets/issue_virtual_card.png',
                            'assets/white_virtual_card.png',
                            () => handleMenu('virtual_card', 11),
                            11),
                        Platform.isAndroid
                            ? const CustomSpacer(size: 0)
                            : const CustomSpacer(size: 18),
                        modalItem(
                            AppLocalizations.of(context)!.transactions,
                            'assets/green_transaction.png',
                            'assets/white_transaction.png',
                            () => handleMenu('transaction', 2),
                            2),
                        isAdmin
                            ? Platform.isAndroid
                                ? const CustomSpacer(size: 0)
                                : const CustomSpacer(size: 18)
                            : SizedBox(),
                        isAdmin && isCredit
                            ? modalItem(
                                AppLocalizations.of(context)!.flexpluscredit,
                                'assets/green_credit.png',
                                'assets/white_credit.png',
                                () => handleMenu('credit', 3),
                                3)
                            : SizedBox(),
                      ],
                    ) : SizedBox(),
                    const CustomSpacer(size: 31),
                    Container(
                        width: wScale(327),
                        height: 1,
                        color: const Color(0xFFDAE3E9)),
                    const CustomSpacer(size: 30),
                    isAdmin
                        ? modalItem(
                            AppLocalizations.of(context)!.companysettings,
                            'assets/green_company_setting.png',
                            'assets/white_company_setting.png',
                            () => handleMenu('company_setting', 4),
                            4)
                        : SizedBox(),
                    isAdmin
                        ? Platform.isAndroid
                            ? const CustomSpacer(size: 0)
                            : const CustomSpacer(size: 18)
                        : SizedBox(),
                    modalItem(
                        AppLocalizations.of(context)!.accountsettings,
                        'assets/green_user_setting.png',
                        'assets/white_user_setting.png',
                        () => handleMenu('account_setting', 14),
                        14),
                    Platform.isAndroid
                        ? const CustomSpacer(size: 0)
                        : const CustomSpacer(size: 18),
                    modalItem(
                        AppLocalizations.of(context)!.logout,
                        'assets/green_logout.png',
                        'assets/white_logout.png',
                        () => handleMenu('logout', 5),
                        5),
                  ],
                ),
              ));
        },
      );

  Widget modalItem(title, inactiveIcon, activeIcon, event, activeNum) {
    return Container(
        margin: EdgeInsets.zero,
        child: TextButton(
            style: TextButton.styleFrom(
                primary: const Color(0xFFFFFFFF), padding: EdgeInsets.zero),
            onPressed: event,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(children: [
                  Container(
                    width: hScale(46),
                    height: hScale(46),
                    padding: EdgeInsets.all(hScale(12)),
                    decoration: BoxDecoration(
                        color: widget.active == activeNum
                            ? const Color(0xFF29C490)
                            : const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(hScale(46)),
                        border: Border.all(
                            width: 1,
                            color: widget.active == activeNum
                                ? const Color(0xFF29C490)
                                : const Color(0xFFE5E5E5))),
                    child: Image.asset(
                        widget.active == activeNum ? activeIcon : inactiveIcon,
                        height: hScale(18),
                        fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 20),
                  Text(title,
                      style: TextStyle(
                          fontSize: fSize(14),
                          fontWeight: FontWeight.w600,
                          color: widget.active == activeNum
                              ? const Color(0xFF29C490)
                              : const Color(0xFF515151).withOpacity(0.7)))
                ]),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: widget.active == activeNum
                      ? const Color(0xFF30E7A9)
                      : const Color(0xFFB4DEDD),
                  size: 16,
                )
              ],
            )));
  }
}

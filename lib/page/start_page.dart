import 'dart:async';

import 'package:dwpn_3dcnc_rooster/controller/app_controler.dart';
import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/event/app_events.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:dwpn_3dcnc_rooster/page/admin_page.dart';
import 'package:dwpn_3dcnc_rooster/page/ask_accesscode_page.dart';
import 'package:dwpn_3dcnc_rooster/page/error_page.dart';
import 'package:dwpn_3dcnc_rooster/page/help_page.dart';
import 'package:dwpn_3dcnc_rooster/page/splash_page.dart';
import 'package:dwpn_3dcnc_rooster/page/spreadsheet_page.dart';
import 'package:dwpn_3dcnc_rooster/util/app_constants.dart';
import 'package:dwpn_3dcnc_rooster/util/spreadsheet_status_help.dart'
    as status_help;
import 'package:dwpn_3dcnc_rooster/widget/busy_indicator.dart';
import 'package:dwpn_3dcnc_rooster/widget/user_info_widget.dart';
import 'package:dwpn_3dcnc_rooster/widget/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  // varbs
  Widget _barTitle = Container();
  String _accessCode = '';

  // This corresponds with action button next right arrow action (these are handled seperately)
  List<bool> _actionEnabled = [false, true, true, true];
  bool _nextMonthEnabled = true;
  bool _prevMonthEnabled = true;

  _StartPageState();

  @override
  void initState() {
    _setStackIndex(PageEnum.splashPage.code);
    _getMetaData();
    _getAllUsers();
    _getSpreadsheets();
    _accessCode = _checkCookie(); // this may be empty
    AppEvents.onErrorEvent(_onErrorEvent);
    AppEvents.onUserReadyEvent(_onUserReady);
    AppEvents.onSpreadsheetReadyEvent(_onSpreadsheetReady);
    AppEvents.onShowPage(_onShowPage);
    AppEvents.onLogoutEvent(_onLogOut);

    Timer(const Duration(milliseconds: 3900), () {
      WidgetHelper.instance.playWhooshSound();
      if (_accessCode.length == 4) {
        _findTrainer(_accessCode);
      } else {
        setState(() {
          // _setStackIndex(PageEnum.adminPage.code);
          _setStackIndex(PageEnum.askAccessCode.code);
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showTabBar() ? _appBar() : null,
      body: IndexedStack(
        index: _getStackIndex(),
        children: [
          SplashPage(), //0
          const AskAccessCodePage(), //1
          const SpreadsheetPage(), //2
          HelpPage(), //4
          const AdminPage(), //5
          const AppErrorPage(), //6
        ],
      ),
    );
  }

  Color _runModeColor() {
    if (AppData.instance.runMode == RunMode.prod) {
      return Colors.amber[100]!;
    } else {
      return AppData.instance.runMode == RunMode.dev
          ? Colors.lightGreen
          : Colors.yellow;
    }
  }

  bool _showTabBar() {
    return _getStackIndex() > 1;
  }

  PreferredSizeWidget? _appBar() {
    return AppBar(
      backgroundColor: _runModeColor(),
      title: _barTitle,
      actions: [
        _actionPrevMonth(),
        _actionNextMonth(),
        _buildPopMenu(),
      ],
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.grey,
            height: 2.0,
          )),
    );
  }

  Widget _buildBarTitle() {
    String title = _getBarTitle();
    Widget titleWidget;

    if (_getStackIndex() == PageEnum.spreadsheetPage.code) {
      titleWidget = _buildSpreadsheetStatusBarTitle(title);
    } else {
      titleWidget = SizedBox(
          width: AppConstants().w1 * 5,
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
          ));
    }

    return Row(
      children: [_buildUserNameWidget(), titleWidget],
    );
  }

  Widget _buildUserNameWidget() {
    return ElevatedButton(
      onPressed: _showUserInfoDialog,
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[200]!,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          )),
      child: Text(AppData.instance.getUser().pk),
    );
  }

  String _getBarTitle() {
    String result = '';

    if (_getStackIndex() == PageEnum.spreadsheetPage.code) {
      result = _getBarTitleForSpreadsheetPage();
    } else if (_getStackIndex() == PageEnum.helpPage.code) {
      result = 'Help pagina';
    } else if (_getStackIndex() == PageEnum.adminPage.code) {
      result = 'Admin pagina';
    }
    return result;
  }

  String _getBarTitleForSpreadsheetPage() {
    String result = '';
    result =
        '${AppData.instance.getActiveMonthAsString()}  (${AppData.instance.getSpreadsheet().status.display})';
    return result;
  }

  Widget _buildSpreadsheetStatusBarTitle(String title) {
    return TextButton(
      onPressed: () => _showStatusHelpDialog(),
      child: SizedBox(
          width: AppConstants().w1 * 5,
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black, fontSize: 24),
          )),
    );
  }

  void _findTrainer(String accessCode) async {
    await AppController.instance.findUser(accessCode);
    // if (!okay) {
    //   setState(() {
    //     // _setStackIndex(1);
    //   });
    // }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getMetaData() async {
    AppController.instance.getAllMetaData();
  }

  void _getAllUsers() async {
    AppController.instance.getAllUsers();
  }

  void _getSpreadsheets() async {
    await AppController.instance.getActiveSpreadsheets();
  }

  void _onUserReady(ActiveUserReadyEvent event) async {
    if (mounted) {
      setState(() {
        _setStackIndex(PageEnum.spreadsheetPage.code);
        _barTitle = _buildBarTitle();

        AppEvents.fireSpreadsheetReady();
      });
    }
  }

  void _onSpreadsheetReady(SpreadsheetReadyEvent event) {
    LoadingIndicatorDialog().dismiss();
    if (mounted) {
      setState(() {
        _barTitle = _buildBarTitle();

        // if (_getStackIndex() != PageEnum.spreadsheetPage.code) {
        //   _setStackIndex(PageEnum.spreadsheetPage.code);
        // }

        _barTitle = _buildBarTitle();

        _prevMonthEnabled = AppData.instance.getActiveSpreadSheetIndex() > 0;
        _nextMonthEnabled = AppData.instance.getActiveSpreadSheetIndex() == 0;
      });
    }
  }

  void _onShowPage(ShowPageEvent event) {
    if (mounted) {
      setState(() {
        _setStackIndex(event.page.code);
      });
    }
  }

  void _onLogOut(LogoutEvent event) {
    html.document.cookie = "ac=";
    setState(() {
      _setStackIndex(PageEnum.askAccessCode.code);
    });
  }

  void _onErrorEvent(ErrorEvent event) {
    setState(() {
      AppData.instance.setStackIndex(PageEnum.errorPage.code);
    });
  }

  Widget _buildPopMenu() {
    return PopupMenuButton(
      onSelected: (value) {
        if (value == PageEnum.spreadsheetPage.code.toString()) {
          _gotoSpreadsheetPage();
        } else if (value == PageEnum.helpPage.code.toString()) {
          _gotoHelpPage();
        } else if (value == PageEnum.adminPage.code.toString()) {
          _gotoAdminPage();
        }
      },
      itemBuilder: (BuildContext bc) {
        return [
          PopupMenuItem(
            value: PageEnum.spreadsheetPage.code.toString(),
            child: const Text("User reserveringen"),
          ),
          PopupMenuItem(
            value: PageEnum.helpPage.code.toString(),
            child: const Text("Help"),
          ),
          _adminPopup(),
        ];
      },
    );
  }

  PopupMenuItem _adminPopup() {
    if (AppData.instance.getUser().isAdmin()) {
      return PopupMenuItem(
        value: PageEnum.adminPage.code.toString(),
        child: const Text("Admin pagina"),
      );
    } else {
      return const PopupMenuItem(
        height: 1,
        value: '0',
        child: Text(""),
      );
    }
  }

  Widget _actionPrevMonth() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Ga naar de vorige maand',
      onPressed: _prevMonthEnabled ? _gotoPrevMonth : null,
    );
  }

  Widget _actionNextMonth() {
    return IconButton(
      icon: const Icon(Icons.arrow_forward),
      tooltip: 'Ga naar de volgende maand',
      onPressed: _nextMonthEnabled ? _gotoNextMonth : null,
    );
  }

  // onPressed actions --
  void _gotoPrevMonth() {
    AppController.instance.setActiveSpreadsheetIndex(0);

    if (_getStackIndex() == PageEnum.spreadsheetPage.code) {
      AppEvents.fireSpreadsheetReady();
    }
  }

  void _gotoNextMonth() {
    AppController.instance.setActiveSpreadsheetIndex(1);

    if (_getStackIndex() == PageEnum.spreadsheetPage.code) {
      AppEvents.fireSpreadsheetReady();
    }
  }

  void _gotoSpreadsheetPage() async {
    await AppController.instance.getActiveSpreadsheets();
    setState(() {
      _setStackIndex(PageEnum.spreadsheetPage.code);
      _barTitle = _buildBarTitle();
      _toggleActionEnabled(PageEnum.spreadsheetPage.code);
    });
  }

  void _gotoHelpPage() {
    setState(() {
      _setStackIndex(PageEnum.helpPage.code);
      _barTitle = _buildBarTitle();
      _toggleActionEnabled(PageEnum.helpPage.code);
    });
  }

  void _gotoAdminPage() {
    setState(() {
      _setStackIndex(PageEnum.adminPage.code);
      _barTitle = _buildBarTitle();
      _toggleActionEnabled(PageEnum.adminPage.code);
    });
  }

  void _toggleActionEnabled(int index) {
    _actionEnabled = [true, true, true, true, true, true, true, true, true];
    _actionEnabled[index] = false;
  }

  String _checkCookie() {
    final cookie = html.document.cookie!;
    if (cookie.isNotEmpty) {
      List<String> tokens = cookie.split('=');
      if (tokens.isNotEmpty) {
        return tokens[1];
      }
    }
    return '';
  }

  int _getStackIndex() => AppData.instance.getStackIndex();
  void _setStackIndex(int value) {
    AppData.instance.setStackIndex(value);
  }

  void _showStatusHelpDialog() {
    String title = _getBarTitleForSpreadsheetPage();
    Widget closeButton = TextButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop(); // dismisses only the dialog and returns nothing
      },
      child: const Text("Close"),
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(status_help.helpText()),
      actions: [
        closeButton,
      ],
    ); // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _showUserInfoDialog() {
    String title = "Gebruiker";
    Widget closeButton = TextButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop(); // dismisses only the dialog and returns nothing
      },
      child: const Text("Close"),
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: UserInfo(),
      actions: [
        closeButton,
      ],
    ); // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

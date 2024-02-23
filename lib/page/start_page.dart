import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dwpn_3dcnc_rooster/controller/app_controler.dart';
import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/event/app_events.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:dwpn_3dcnc_rooster/page/admin_page.dart';
import 'package:dwpn_3dcnc_rooster/page/ask_accesscode_page.dart';
import 'package:dwpn_3dcnc_rooster/page/error_page.dart';
import 'package:dwpn_3dcnc_rooster/page/help_page.dart';
import 'package:dwpn_3dcnc_rooster/page/spreadsheet_page.dart';
import 'package:dwpn_3dcnc_rooster/page/splash_page.dart';
import 'package:dwpn_3dcnc_rooster/util/app_constants.dart';
import 'package:dwpn_3dcnc_rooster/util/app_helper.dart';
import 'package:dwpn_3dcnc_rooster/util/spreadsheet_status_help.dart'
    as status_help;
import 'package:dwpn_3dcnc_rooster/widget/busy_indicator.dart';
import 'package:dwpn_3dcnc_rooster/widget/widget_helper.dart';
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
    _getMetaData();
    _getAllUsers();
    _getSpreadsheets();
    _accessCode = _checkCookie(); // this may be empty
    AppEvents.onErrorEvent(_onErrorEvent);
    AppEvents.onTrainerReadyEvent(_onTrainerReady);
    AppEvents.onSpreadsheetReadyEvent(_onSpreadsheetReady);
    AppEvents.onShowPage(_onShowPage);

    Timer(const Duration(milliseconds: 2900), () {
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
      return Colors.white;
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
    );
  }

  Widget _buildBarTitle() {
    String title = _getBarTitle();
    if (_getStackIndex() == PageEnum.spreadsheetPage.code) {
      return _buildSpreadsheetStatusBarTitle(title);
    } else {
      return SizedBox(
          width: AppConstants().w1 * 5,
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
          ));
    }
  }

  String _getBarTitle() {
    String result = '';

    if (_getStackIndex() == PageEnum.spreadsheetPage.code) {
      result = _getBarTitleForSchemaEditPage();
    } else if (_getStackIndex() == PageEnum.helpPage.code) {
      result = 'Help pagina';
    } else if (_getStackIndex() == PageEnum.adminPage.code) {
      result = 'Admin pagina';
    }
    return result;
  }

  String _getBarTitleForSpreadhsheetPage() {
    String result = '';
    if (_isLargeScreen()) {
      result = 'Schema ${AppData.instance.getActiveMonthAsString()}';
    } else {
      result = AppData.instance.getActiveMonthAsString().substring(0, 3);
    }
    result += ' (${_getSpreadstatus()})';
    return result;
  }

  String _getBarTitleForSchemaEditPage() {
    String firstName = '${AppData.instance.getUser().firstName()} ';
    String result = '';
    if (_isLargeScreen()) {
      result =
          'Reserveringen $firstName${AppData.instance.getActiveMonthAsString()}';
      result += ' ${AppData.instance.getActiveYear()}';
    } else {
      result =
          '$firstName ${AppData.instance.getActiveMonthAsString()} Reserveringen';
    }

    if (_isLargeScreen()) {}
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

  String _getSpreadstatus() {
    String result = '';
    DateTime useDate = AppData.instance.getSpreadsheetDate().copyWith(day: 2);
    if (useDate.isBefore(DateTime.now().copyWith(day: 1))) {
      result = 'verlopen';
    } else if (AppData.instance.getSpreadsheet().status ==
        SpreadsheetStatus.active) {
      result = 'actief';
    } else if (AppData.instance.getSpreadsheet().status ==
        SpreadsheetStatus.underConstruction) {
      result = 'onderhanden';
    } else if (AppData.instance.getSpreadsheet().status ==
        SpreadsheetStatus.opened) {
      result = 'geopend';
    } else if (AppData.instance.getSpreadsheet().status ==
        SpreadsheetStatus.dirty) {
      result = 'aangepast';
    }

    return result;
  }

  void _findTrainer(String accessCode) async {
    bool okay = await AppController.instance.findUser(accessCode);
    if (!okay) {
      setState(() {
        _setStackIndex(1);
      });
    }
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
    AppController.instance.getActiveSpreadsheets();
  }

  void _onTrainerReady(TrainerReadyEvent event) async {
    if (mounted) {
      await AppController.instance.getActiveSpreadsheets();
      setState(() {
        _setStackIndex(2);
      });
    }
  }

  void _onSpreadsheetReady(SpreadsheetReadyEvent event) {
    LoadingIndicatorDialog().dismiss();
    if (mounted) {
      setState(() {
        _barTitle = _buildBarTitle();

        if (_getStackIndex() != PageEnum.spreadsheetPage.code) {
          _setStackIndex(2);
        }

        _barTitle = _buildBarTitle();

        // we go back 1 month and check if date is after the first spreadsheet date
        _prevMonthEnabled = AppData.instance
            .getActiveDate()
            .add(const Duration(days: -30))
            .isAfter(AppData.instance.firstSpreadDate);

        _nextMonthEnabled = AppData.instance
            .getActiveDate()
            .isBefore(AppData.instance.lastMonth);
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

  void _onErrorEvent(ErrorEvent event) {
    setState(() {
      AppData.instance.stackIndex = PageEnum.errorPage.code;
    });
  }

  Widget _buildPopMenu() {
    return PopupMenuButton(
      onSelected: (value) {
        if (value == PageEnum.spreadsheetPage.code.toString()) {
          _gotoEditSchemas();
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
    if (AppData.instance.getActiveMonth() == 1) {
      int year = AppData.instance.getActiveYear() - 1;
      int month = 12;
      AppController.instance.setActiveDate(DateTime(year, month, 1));
    } else {
      int year = AppData.instance.getActiveYear();
      int month = AppData.instance.getActiveMonth() - 1;
      AppController.instance.setActiveDate(DateTime(year, month, 1));
    }

    if (_getStackIndex() == PageEnum.spreadsheetPage.code) {
      _gotoSpreadsheet();
    }
  }

  void _gotoNextMonth() {
    if (AppData.instance.getActiveMonth() == 12) {
      int year = AppData.instance.getActiveYear() + 1;
      int month = 1;
      AppController.instance.setActiveDate(DateTime(year, month, 1));
    } else {
      int year = AppData.instance.getActiveYear();
      int month = AppData.instance.getActiveMonth() + 1;
      AppController.instance.setActiveDate(DateTime(year, month, 1));
    }

    if (_getStackIndex() == PageEnum.spreadsheetPage.code) {
      _gotoSpreadsheet();
    }
  }

  void _gotoEditSchemas() async {
    await AppController.instance.getActiveSpreadsheets();
    setState(() {
      _setStackIndex(PageEnum.spreadsheetPage.code);
      _barTitle = _buildBarTitle();
      _toggleActionEnabled(PageEnum.spreadsheetPage.code);
    });
  }

  void _gotoSpreadsheet() async {
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

  int _getStackIndex() => AppData.instance.stackIndex;
  void _setStackIndex(int value) {
    AppData.instance.stackIndex = value;
  }

  void _showStatusHelpDialog() {
    String title = _getBarTitleForSpreadhsheetPage();
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

  //--------------------
  bool _isLargeScreen() {
    return (AppHelper.instance.isWindows() || AppHelper.instance.isTablet());
  }
}

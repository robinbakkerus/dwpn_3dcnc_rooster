import 'dart:developer';

import 'package:dwpn_3dcnc_rooster/data/app_version.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';

class AppData {
  AppData._() {
    _initialize();
  }

  static final instance = AppData._();

  void _initialize() {}

  /// these contains the current active values
  RunMode runMode = appRunModus;

  double screenWidth = 600.0; //assume
  double screenHeight = 600.0; //assume
  double shortestSide = 600; //assume
  String trainerId = "";

  DateTime _activeDate = DateTime(2024, 1, 1);
  DateTime lastActiveDate = DateTime(2024, 1, 1);
  DateTime lastMonth = DateTime(2024, 1, 1);
  DateTime firstSpreadDate = DateTime(2024, 1, 1);

  int stackIndex = 0;

  User _user = User.empty();
  User getUser() {
    return _user;
  }

  void setUser(User user) {
    _user = user;
  }

  List<User> _allUsers = [];
  List<User> getAllUsers() {
    return _allUsers;
  }

  void setAllUsers(List<User> users) {
    _allUsers = users;
  }

  List<WeekdaySlot> weekdaySlotList = [];
  List<Device> deviceList = [];

  String lastSnackbarMsg = '';

  // this is set in the start_page when you click on the showSpreadsheet, or next/prev month
  final List<SpreadSheet> _spreadSheetList = [];
  int activeSpreadSheetIndex = 1; //TODO

  SpreadSheet getSpreadsheet() {
    if (_spreadSheetList.isEmpty) {
      return SpreadSheet(
          year: DateTime.now().year, month: DateTime.now().month);
    } else {
      if (activeSpreadSheetIndex < _spreadSheetList.length) {
        return _spreadSheetList[activeSpreadSheetIndex];
      } else {
        return _spreadSheetList[0];
      }
    }
  }

  DateTime getSpreadsheetDate() {
    return DateTime(getSpreadsheet().year, getSpreadsheet().month, 1);
  }

  void addSpreadsheets(SpreadSheet spreadSheet) {
    //todo if al bestaat
    _spreadSheetList.add(spreadSheet);
  }

  // ---
  void setActiveDate(DateTime date) {
    log("todo set active data $date");
    DateTime useDate = DateTime(date.year, date.month, 1);
    _activeDate = useDate;
  }

  DateTime getActiveDate() {
    return _activeDate;
  }

  int getActiveMonth() {
    return _activeDate.month;
  }

  int getActiveYear() {
    return _activeDate.year;
  }

  ///
  String getActiveMonthAsString() {
    return maanden[getActiveMonth() - 1];
  }

  ///-----------------------------------
  bool isSchemaDirty() {
    return false;
  }

  List<String> maanden = [
    'Januari',
    'Februari',
    'Maart',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Augustus',
    'September',
    'Oktober',
    'November',
    'December'
  ];

  //---------- private --------------
}

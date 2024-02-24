import 'dart:developer';

// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/event/app_events.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:dwpn_3dcnc_rooster/repo/firestore_helper.dart';
import 'package:dwpn_3dcnc_rooster/service/dbs.dart';
import 'package:dwpn_3dcnc_rooster/util/spreadsheet_generator.dart';
// import 'package:dwpn_3dcnc_rooster/widget/busy_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:universal_html/html.dart' as html;

class AppController {
  AppController._();

  static AppController instance = AppController._();

  /// get screen sizes and save this
  Future<void> initializeAppData(BuildContext context) async {
    _setScreenSizes(context);
    await initializeDateFormatting('nl_NL', null);
  }

  Future<void> getAllUsers() async {
    List<User> users = await Dbs.instance.getAllUsers();
    AppData.instance.setAllUsers(users);
  }

  /// find the trainer gived the access code
  Future<bool> findUser(String accessCode) async {
    User? user = AppData.instance
        .getAllUsers()
        .firstWhereOrNull((e) => e.originalAccessCode == accessCode);
    if (user == null) {
      return false;
    }

    // bool signInOkay = await AuthHelper.instance.signIn(
    //     email: trainer.originalEmail,
    //     password: AppHelper.instance.getAuthPassword(trainer));
    bool signInOkay = true;

    if (signInOkay) {
      _setCookieIfNeeded(user, accessCode);
      AppData.instance.setUser(user);
      AppEvents.fireTrainerReady();
      return true;
    }
    // } else {
    //   return false;
    // }
  }

  bool _setCookieIfNeeded(User trainer, String accessCode) {
    if (!trainer.isEmpty()) {
      html.document.cookie = "ac=${trainer.accessCode}";
      return true;
    } else {
      return false;
    }
  }

  ///----- updateTrainer
  Future<bool> updateTrainer(User trainer) async {
    User updatedTrainer = await Dbs.instance.createOrUpdateUser(trainer);
    // AppData.instance.setTrainer(updatedTrainer);
    AppEvents.fireTrainerUpdated(updatedTrainer);
    return true;
  }

  ///------------------------------------------------
  Future<void> getActiveSpreadsheets() async {
    // LoadingIndicatorDialog().show();

    List<SpreadSheet> spreadSheets = await _getTheActiveSpreadsheets();
    if (spreadSheets.isEmpty) {
      // we kunnen 1 maand vooruit plannen
      SpreadSheet spreadSheet = await _saveThisSpreadsheet(nextMonth: true);
      // the current month will be the effective month
      spreadSheet = await _saveThisSpreadsheet(nextMonth: false);
      AppData.instance.addSpreadsheets(spreadSheet);
    } else if (spreadSheets.length == 1) {
      SpreadSheet spreadSheet = await _saveThisSpreadsheet(nextMonth: true);
      AppData.instance.addSpreadsheets(spreadSheet);
    } else {
      AppData.instance.addSpreadsheets(spreadSheets[0]);
      AppData.instance.addSpreadsheets(spreadSheets[1]);
    }

    AppData.instance.setActiveSpreadSheetIndex(0);
    AppEvents.fireSpreadsheetReady();
  }

  Future<SpreadSheet> _saveThisSpreadsheet({required bool nextMonth}) async {
    SpreadSheet spreadSheet = SpreadSheet(
        year: _getYearAndMonth(nextMonth)[0],
        month: _getYearAndMonth(nextMonth)[1]);
    await FirestoreHelper.instance.saveSpreadsheet(spreadSheet);
    return spreadSheet;
  }

  List<int> _getYearAndMonth(bool nextMonth) {
    DateTime now = DateTime.now();
    if (nextMonth) {
      if (now.month == 12) {
        return [now.year + 1, 1];
      } else {
        return [now.year, now.month + 1];
      }
    } else {
      return [now.year, now.month];
    }
  }

  ///------------------------------------------------
  Future<List<SpreadSheet>> _getTheActiveSpreadsheets() async {
    DateTime now = DateTime.now();
    return await Dbs.instance
        .getActiveSpreadsheets(year: now.year, month: now.month);
  }

  ///--------------------
  void finalizeSpreadsheet() async {
    SpreadSheet spreadSheet = SpreadsheetGenerator.instance
        .finalizeSpreadsheetReservation(AppData.instance
            .getSpreadsheet()); //SpreadsheetGenerator.instance.finalizeSpreadsheetReservation(spreadSheet, reservations);

    spreadSheet.status = SpreadsheetStatus.active;

    await Dbs.instance.saveSpreadsheet(spreadSheet);
    // await _mailSpreadsheetIsFinal(spreadSheet);
  }

  ///--------------------
  Future<void> updateSpreadsheet(SpreadSheet spreadSheet) async {
    // if (fsSpreadsheet.isFinal) {
    //   await _mailSpreadsheetDiffs(fsSpreadsheet, spreadSheet);
    // }

    await Dbs.instance.saveSpreadsheet(spreadSheet);
    await getActiveSpreadsheets();
    AppEvents.fireSpreadsheetReady();
  }

  void getAllMetaData() async {
    try {
      List<WeekdaySlot> allWeekDaySlots =
          await Dbs.instance.getAllWeekdaySlots();
      AppData.instance.weekdaySlotList = allWeekDaySlots;

      List<Device> allDevices = await Dbs.instance.getAllDevices();
      AppData.instance.deviceList = allDevices;
    } catch (ex, stackTrace) {
      handleError(ex, stackTrace);
    }
  }

  ///--------------------------
  Future<void> saveReservation(Reservation reservation, bool add) async {
    try {
      await Dbs.instance.saveReservation(reservation, add);
      if (add) {
        AppData.instance.getSpreadsheet().reservations.add(reservation);
      } else {
        AppData.instance.getSpreadsheet().reservations.remove(reservation);
      }

      // AppEvents.fireSpreadsheetReady();
    } catch (ex, stackTrace) {
      handleError(ex, stackTrace);
    }
  }

  /// ============ private methods -----------------
  void handleError(Object ex, StackTrace stackTrace) {
    if (AppData.instance.runMode == RunMode.prod) {
      FirestoreHelper.instance.handleError(ex, stackTrace);
    } else {
      log(ex.toString());
    }
  }

  ///----------------
  void setActiveSpreadsheetIndex(int index) {
    AppData.instance.setActiveSpreadSheetIndex(index);
  }

  //-------------------------------------------
  void _setScreenSizes(BuildContext context) {
    double width = (MediaQuery.of(context).size.width);
    AppData.instance.screenWidth = width;
    double height = (MediaQuery.of(context).size.height);
    AppData.instance.screenHeight = height;

    AppData.instance.shortestSide = MediaQuery.of(context).size.shortestSide;
  }
}

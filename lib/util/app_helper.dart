import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:week_number/iso.dart';

class AppHelper with AppMixin {
  AppHelper._();
  static final AppHelper instance = AppHelper._();

  ///----------------------------------------
  DateTime? parseDateTime(Object? value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is DateTime) {
      return value;
    } else if (value is Timestamp) {
      return (value).toDate();
    } else if (value == null) {
      return null;
    } else {
      return DateTime.now();
    }
  }

  ///----------------------------------------
  ///
  String buildTrainerSchemaId(User trainer) {
    String result = trainer.pk;
    result += '_${AppData.instance.getActiveYear()}';
    result += '_${AppData.instance.getActiveMonth()}';
    return result;
  }

  ///------------- get all dates in the given month
  List<DateTime> getAllDatesInMonth(DateTime startDate) {
    DateTime endDate = DateTime(startDate.year, startDate.month + 1, 0);
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  ///------------- get all dates in the given month
  List<DateTime> getAllDatesInWeek(int weeknr) {
    DateTime startDate =
        dateTimeFromWeekNumber(AppData.instance.getActiveYear(), weeknr);
    DateTime endDate = startDate.add(const Duration(days: 6));
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  ///-----------------
  bool isSameDate(DateTime dt1, DateTime dt2) {
    return dt1.year == dt2.year && dt1.month == dt2.month && dt1.day == dt2.day;
  }

  ///-----------------
  String getFirstName(User trainer) {
    List<String> tokens = trainer.fullname.split(' ');
    if (tokens.isNotEmpty) {
      return tokens[0];
    } else {
      return trainer.fullname;
    }
  }

  ///-----------------
  String monthAsString(DateTime date) {
    String dayMonth = DateFormat.MMMM('nl_NL').format(date);
    return dayMonth;
  }

  ///-----------------
  DateTime addMonths(DateTime date, int nMonths) {
    DateTime result = date;
    for (int i = 0; i < nMonths; i++) {
      result = add1Month(result);
    }
    return result;
  }

  DateTime add1Month(DateTime date) {
    if (date.month == 12) {
      return DateTime(date.year + 1, 1, 1);
    } else {
      return DateTime(date.year, date.month + 1, 1);
    }
  }

  // return something like "Din 9" , which can be used to set label
  String getSimpleDayString(DateTime dateTime) {
    return weekDayStringFromDate(date: dateTime, locale: c.localNL);
  }

  /// return something like: 'din 1' or 'vrijdag 1'
  String weekDayStringFromDate(
      {required DateTime date, required String locale, int length = -1}) {
    String weekdayStr = DateFormat.EEEE(locale).format(date);
    if (length > 0) {
      weekdayStr = weekdayStr.substring(0, length);
    }
    weekdayStr += ' ${date.day}';
    return weekdayStr.substring(0, 1).toUpperCase() + weekdayStr.substring(1);
  }

  /// ------------------------
  /// return something like: 'vrijdag' if locale is nl
  String weekDayStringFromWeekday(
      {required int weekday, required String locale}) {
    DateTime dateTime = DateTime.now();
    for (int i = 0; i < 7; i++) {
      DateTime dt = DateTime(AppData.instance.getActiveYear(),
          AppData.instance.getActiveMonth(), i);
      if (dt.weekday == weekday) {
        dateTime = dt;
        break;
      }
    }

    return DateFormat.EEEE(locale).format(dateTime);
  }

  //------------------------------------------
  String formatDate(DateTime date) {
    return date.toIso8601String().substring(0, 10);
  }

  /// ------------------------
  /// weekdayFromString('dinsdag', 'nl') -> 2
  int weekdayFromString({required String weekday, required String locale}) {
    for (int i = 0; i < 7; i++) {
      DateTime dt = DateTime(AppData.instance.getActiveYear(),
          AppData.instance.getActiveMonth(), i);

      String weekdayStr = DateFormat.EEEE(locale).format(dt);
      if (weekdayStr == weekday) {
        return dt.weekday;
      }
    }
    return -1; //not possible
  }

  ///-----------------
  void getDeviceType(BuildContext context) async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    final allInfo = deviceInfo.data;
    lp(allInfo.toString());
  }

  //--------------------
  List<WeekdaySlot> getWeekDaySlotsAtDate(DateTime date) {
    List<WeekdaySlot> result = [];
    result = AppData.instance.weekdaySlotList
        .where((e) => e.weekday == date.weekday)
        .toList();
    return result;
  }

  ///--------------------
  TargetPlatform getPlatform() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return TargetPlatform.android;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return TargetPlatform.iOS;
    } else {
      return TargetPlatform.windows;
    }
  }

  ///--------------------
  bool isWindows() {
    TargetPlatform platform = getPlatform();
    return platform == TargetPlatform.windows;
  }

  bool isTablet() {
    if (isWindows()) {
      return false;
    } else {
      return AppData.instance.shortestSide > 600;
    }
  }

  ///---------------------------------------------
  User findUserByFirstName(String name) {
    User? trainer = AppData.instance.getAllUsers().firstWhereOrNull(
        (e) => e.firstName().toLowerCase() == name.toLowerCase());

    if (trainer != null) {
      return trainer;
    } else {
      return User.empty();
    }
  }

  ///---------------------------------------------
  User findUserByFulltName(String fullname) {
    User? user = AppData.instance.getAllUsers().firstWhereOrNull(
        (e) => e.fullname.toLowerCase() == fullname.toLowerCase());

    if (user != null) {
      return user;
    } else {
      return User.empty();
    }
  }

  ///---------------------------------------------
  User findUserByPk(String pk) {
    User? trainer = AppData.instance
        .getAllUsers()
        .firstWhereOrNull((e) => e.pk.toUpperCase() == pk.toUpperCase());

    if (trainer != null) {
      return trainer;
    } else {
      return User.empty();
    }
  }

//------------------------
  Device findDeviceByName(String name) {
    Device? device =
        AppData.instance.deviceList.firstWhereOrNull((e) => e.name == name);
    return device ?? Device.empty();
  }

  ///---------------------------------------------
  String getAuthPassword(User trainer) {
    return 'pwd${trainer.originalAccessCode}!678123';
  }

  ///---------------------------------------------
  List<User> getAllAdmins() {
    return AppData.instance.getAllUsers().where((t) => t.isAdmin()).toList();
  }

  ///---------------------------------------------
  List<User> getAllSupervisors() {
    return AppData.instance
        .getAllUsers()
        .where((t) => t.isSupervisor())
        .toList();
  }

  ///---------------------------------------------
  bool addSchemaEditRow(DateTime date, User trainer) {
    int dayPref = trainer.getDayPrefValue(weekday: date.weekday);
    return dayPref == 1 || dayPref == 2;
  }

  ///---------------------------------------------
  Device? getTrainingGroupByName(String groupName) {
    return AppData.instance.deviceList.firstWhereOrNull(
        (e) => e.name.toLowerCase() == groupName.toLowerCase());
  }

  List<int> getWeekNumbersForMonth(DateTime dateTime) {
    List<int> result = [];

    DateTime date = dateTime.copyWith(day: 1);
    while (date.month == AppData.instance.getActiveMonth()) {
      int weeknr = date.weekNumber;
      result.add(weeknr);
      date = date.add(const Duration(days: 7));
    }

    return result;
  }
}

  /// -------- private methods --------------------------------


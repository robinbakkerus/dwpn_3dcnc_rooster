// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:dwpn_3dcnc_rooster/util/app_constants.dart';
import 'package:dwpn_3dcnc_rooster/util/app_helper.dart';

//------------------ enum ----------------------

enum LogAction {
  saveSchema,
  modifySchema,
  modifySettings,
  saveSpreadsheet,
  finalizeSpreadsheet,
  modifyTrainerField;
}

enum PageEnum {
  splashPage(0),
  askAccessCode(1),
  spreadsheetPage(2),
  logbookPage(3),
  helpPage(4),
  adminPage(5),
  errorPage(6);

  const PageEnum(this.code);
  final int code;
}

enum RunMode {
  prod,
  acc,
  dev;
}

enum SpreadsheetStatus {
  old("Verlopen"),
  underConstruction("Onderhanden"),
  active("Actief");

  String toMap() {
    return name;
  }

  factory SpreadsheetStatus.fromMap(String type) {
    switch (type) {
      case 'old':
        return SpreadsheetStatus.old;
      case 'underConstruction':
        return SpreadsheetStatus.underConstruction;
      default:
        return SpreadsheetStatus.active;
    }
  }

  final String display;
  const SpreadsheetStatus(this.display);
}

enum DeviceType {
  printer,
  laser,
  engrave;

  String toMap() {
    return name;
  }

  factory DeviceType.fromMap(String type) {
    switch (type) {
      case 'engrave':
        return DeviceType.engrave;
      case 'laser':
        return DeviceType.laser;
      default:
        return DeviceType.printer;
    }
  }
}

enum DaySlotEnum {
  morning,
  afternoon,
  evening;

  String shortName() {
    switch (this) {
      case DaySlotEnum.morning:
        return 'O';
      case DaySlotEnum.afternoon:
        return 'M';
      case DaySlotEnum.evening:
        return 'A';
    }
  }

  String toMap() {
    return name;
  }

  factory DaySlotEnum.fromType(String type) {
    switch (type) {
      case 'morning':
        return DaySlotEnum.morning;
      case 'afternoon':
        return DaySlotEnum.afternoon;
      default:
        return DaySlotEnum.evening;
    }
  }

  factory DaySlotEnum.fromShortname(String shortName) {
    switch (shortName.toUpperCase()) {
      case 'O':
        return DaySlotEnum.morning;
      case 'M':
        return DaySlotEnum.afternoon;
      default:
        return DaySlotEnum.evening;
    }
  }
}

///-----------------------------------------
class UserPref {
  final String paramName;
  int value;

  UserPref({
    required this.paramName,
    required this.value,
  });

  UserPref copyWith({
    String? paramName,
    int? value,
  }) {
    return UserPref(
      paramName: paramName ?? this.paramName,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paramName': paramName,
      'value': value,
    };
  }

  factory UserPref.fromMap(Map<String, dynamic> map) {
    return UserPref(
      paramName: map['paramName'],
      value: map['value'],
    );
  }

  @override
  String toString() => 'TrainerPref(paramName: $paramName, value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserPref &&
        other.paramName == paramName &&
        other.value == value;
  }

  @override
  int get hashCode => paramName.hashCode ^ value.hashCode;
}

///------------------------------------------

class User {
  String accessCode;
  final String originalAccessCode;
  final String pk; // this is also the firestore dbs ID
  final String fullname;
  String email;
  String originalEmail;
  List<UserPref> prefValues = [];
  final String roles;

  User({
    required this.accessCode,
    required this.originalAccessCode,
    required this.pk,
    required this.fullname,
    required this.email,
    required this.originalEmail,
    required this.prefValues,
    required this.roles,
  });

  User copyWith({
    String? accessCode,
    String? originalAccessCode,
    String? pk,
    String? fullname,
    String? email,
    String? originalEmail,
    List<UserPref>? prefValues,
    String? roles,
  }) {
    return User(
      accessCode: accessCode ?? this.accessCode,
      originalAccessCode: originalAccessCode ?? this.originalAccessCode,
      pk: pk ?? this.pk,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      originalEmail: originalEmail ?? this.originalEmail,
      prefValues:
          prefValues ?? this.prefValues.map((e) => e.copyWith()).toList(),
      roles: roles ?? this.roles,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accessCode': accessCode,
      'originalAccessCode': originalAccessCode,
      'pk': pk,
      'fullname': fullname,
      'email': email,
      'originalEmail': originalEmail,
      'prefValues': prefValues.map((x) => x.toMap()).toList(),
      'roles': roles,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      accessCode: map['accessCode'],
      originalAccessCode: map['originalAccessCode'],
      pk: map['pk'],
      fullname: map['fullname'],
      email: map['email'],
      originalEmail: map['originalEmail'],
      prefValues: List<UserPref>.from(
          map['prefValues']?.map((x) => UserPref.fromMap(x))),
      roles: map['roles'],
    );
  }

  @override
  String toString() {
    return 'Trainer(pk: $pk, fullname: $fullname, accessCode: $accessCode, orgCode: $originalAccessCode email: $email, originalEmail: $originalEmail,prefs: $prefValues, roles: $roles)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.accessCode == accessCode &&
        other.originalAccessCode == originalAccessCode &&
        other.pk == pk &&
        other.fullname == fullname &&
        other.email == email &&
        other.originalEmail == originalEmail &&
        listEquals(other.prefValues, prefValues) &&
        other.roles == roles;
  }

  @override
  int get hashCode {
    return accessCode.hashCode ^
        originalAccessCode.hashCode ^
        pk.hashCode ^
        fullname.hashCode ^
        email.hashCode ^
        originalEmail.hashCode ^
        prefValues.hashCode ^
        roles.hashCode;
  }

  /// ---- extra methods -------------
  factory User.empty() {
    return User(
        accessCode: '',
        originalAccessCode: '',
        pk: '',
        fullname: '',
        email: '',
        originalEmail: '',
        prefValues: [],
        roles: '');
  }

  //--- not generated
  bool isEmpty() {
    return pk.isEmpty;
  }

  String firstName() {
    List<String> tokens = fullname.split(' ');
    if (tokens.isNotEmpty) {
      return tokens[0];
    } else {
      return fullname;
    }
  }

  bool isSupervisor() {
    return roles.contains(RegExp('S'));
  }

  bool isAdmin() {
    return roles.contains(RegExp('A'));
  }

  int getPrefValue({required String paramName}) {
    for (UserPref pref in prefValues) {
      if (pref.paramName.toLowerCase() == paramName.toLowerCase()) {
        return pref.value;
      }
    }
    return -1;
  }

  int getDayPrefValue({required int weekday}) {
    int result = -1;

    for (UserPref pref in prefValues) {
      String weekDayStr = AppHelper.instance
          .weekDayStringFromWeekday(
              weekday: weekday, locale: AppConstants().localNL)
          .toLowerCase();
      if (pref.paramName == weekDayStr) {
        return pref.value;
      }
    }
    return result;
  }

  void setPrefValue(String paramName, int value) {
    for (UserPref pref in prefValues) {
      if (pref.paramName == paramName) {
        pref.value = value;
        return;
      }
    }
  }
}

///------- Spreadsheet

class SpreadSheet {
  int year = 2024;
  int month = 1;
  SpreadsheetStatus status = SpreadsheetStatus.underConstruction;
  List<Reservation> reservations = [];

  void addRow(Reservation row) {
    reservations.add(row);
  }

  SpreadSheet({
    required this.year,
    required this.month,
    this.status = SpreadsheetStatus.underConstruction,
  });

  SpreadSheet clone() {
    SpreadSheet result = SpreadSheet(year: year, month: month);
    result.status = status;
    for (Reservation row in reservations) {
      result.reservations.add(row.clone());
    }
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SpreadSheet &&
        other.year == year &&
        other.month == month &&
        other.status == status &&
        listEquals(other.reservations, reservations);
  }

  @override
  int get hashCode {
    return year.hashCode ^
        month.hashCode ^
        status.hashCode ^
        reservations.hashCode;
  }

  @override
  String toString() {
    return 'SpreadSheet(year: $year, month: $month, status: $status, timeSlots: $reservations)';
  }

  SpreadSheet copyWith({
    int? year,
    int? month,
    SpreadsheetStatus? status,
    List<Reservation>? reservation,
  }) {
    return SpreadSheet(
      year: year ?? this.year,
      month: month ?? this.month,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'status': status.toMap(),
      'reservations': reservations.map((x) => x.toDbsId()).toList(),
    };
  }

  factory SpreadSheet.fromMap(Map<String, dynamic> map) {
    SpreadSheet result = SpreadSheet(
      year: map['year'],
      month: map['month'],
      status: SpreadsheetStatus.fromMap(map['status']),
    );
    var reservationsMap = map['reservations'];
    List<dynamic> reservations =
        reservationsMap.map((e) => Reservation.fromDbsId(e)).toList();
    result.reservations = reservations.map((e) => e as Reservation).toList();
    return result;
  }

  String toJson() => json.encode(toMap());
  factory SpreadSheet.fromJson(String source) =>
      SpreadSheet.fromMap(json.decode(source));
}

//----------------------
class Reservation {
  final int day;
  final DaySlotEnum daySlotEnum;
  final String devicePk;
  final String userPk;
  bool selected = false;

  //-- build something like; BG-14-M-PRI"
  String toDbsId() {
    return "$userPk-${day.toString()}-${daySlotEnum.shortName()}-$devicePk${selected ? '-S' : ''}";
  }

  Reservation clone() {
    return Reservation(
      day: day,
      daySlotEnum: daySlotEnum,
      devicePk: devicePk,
      userPk: userPk,
      selected: selected,
    );
  }

  factory Reservation.fromDbsId(String dbsId) {
    List<String> tokens = dbsId.split('-');
    String userPk = tokens[0];
    bool selected = tokens.length > 4 && tokens[4] == 'S';

    Reservation result = Reservation(
        day: int.parse(tokens[1]),
        userPk: userPk,
        devicePk: tokens[3],
        daySlotEnum: DaySlotEnum.fromShortname(tokens[2]),
        selected: selected);

    return result;
  }

  Reservation({
    required this.day,
    required this.daySlotEnum,
    required this.devicePk,
    required this.userPk,
    this.selected = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'daySlotEnum': daySlotEnum.toMap(),
      'devicePk': devicePk,
      'user': userPk,
      'selected': selected
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Reservation &&
        other.day == day &&
        other.daySlotEnum == daySlotEnum &&
        other.devicePk == devicePk &&
        other.userPk == userPk;
  }

  @override
  int get hashCode {
    return day.hashCode ^
        daySlotEnum.hashCode ^
        devicePk.hashCode ^
        userPk.hashCode;
  }
}

///-----------------------------

class SpreedsheetDiff {
  DateTime date;
  String column;
  String oldValue;
  String newValue;

  SpreedsheetDiff({
    required this.date,
    required this.column,
    required this.oldValue,
    required this.newValue,
  });
}

///-------------------------------

class Device {
  final String name;
  final String description;
  final DeviceType type;

  Device({
    required this.name,
    required this.description,
    required this.type,
  });

  factory Device.empty() {
    return Device(name: '', description: '', type: DeviceType.printer);
  }

  Device copyWith({
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    DeviceType? type,
  }) {
    return Device(
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'type': type.toMap(),
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      name: map['name'],
      description: map['description'],
      type: DeviceType.fromMap(map['type']),
    );
  }
  String toJson() => json.encode(toMap());
  factory Device.fromJson(String source) => Device.fromMap(json.decode(source));
  @override
  String toString() {
    return 'TrainingGroup(name: $name, description: $description, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Device &&
        other.name == name &&
        other.description == description &&
        other.type == type;
  }

  @override
  int get hashCode {
    return name.hashCode ^ description.hashCode ^ type.hashCode;
  }
}

///--------------------------------
class WeekdaySlot {
  final int weekday;
  final DaySlotEnum daySlot;

  WeekdaySlot({
    required this.weekday,
    required this.daySlot,
  });
  WeekdaySlot copyWith({
    int? weekday,
    DaySlotEnum? daySlot,
  }) {
    return WeekdaySlot(
      weekday: weekday ?? this.weekday,
      daySlot: daySlot ?? this.daySlot,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weekday': weekday,
      'daySlot': daySlot.toMap(),
    };
  }

  factory WeekdaySlot.fromMap(Map<String, dynamic> map) {
    return WeekdaySlot(
      weekday: map['weekday'],
      daySlot: DaySlotEnum.fromType(map['daySlot']),
    );
  }

  factory WeekdaySlot.fromValues(
      {required int weekday, required DaySlotEnum daySlot}) {
    return WeekdaySlot(
      weekday: weekday,
      daySlot: daySlot,
    );
  }

  String toJson() => json.encode(toMap());
  factory WeekdaySlot.fromJson(String source) =>
      WeekdaySlot.fromMap(json.decode(source));
  @override
  String toString() => 'Weekslot(weekday: $weekday, daySlot: $daySlot)';
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WeekdaySlot &&
        other.weekday == weekday &&
        other.daySlot == daySlot;
  }

  @override
  int get hashCode => weekday.hashCode ^ daySlot.hashCode;
}

//-------------------------------------------
class LogbookItem {
  final int id;
  final String devicePk;
  final DateTime date;
  final String userPk;
  final int weight;
  final String description;
  final String image;

  LogbookItem({
    required this.id,
    required this.devicePk,
    required this.date,
    required this.userPk,
    required this.weight,
    required this.description,
    required this.image,
  });

  LogbookItem copyWith({
    int? id,
    String? devicePk,
    DateTime? date,
    String? userPk,
    int? weight,
    String? description,
    String? image,
  }) {
    return LogbookItem(
      id: id ?? this.id,
      devicePk: devicePk ?? this.devicePk,
      date: date ?? this.date,
      userPk: userPk ?? this.userPk,
      weight: weight ?? this.weight,
      description: description ?? this.description,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'devicePk': devicePk,
      'date': date.millisecondsSinceEpoch,
      'userPk': userPk,
      'weight': weight,
      'description': description,
      'image': image,
    };
  }

  factory LogbookItem.fromMap(Map<String, dynamic> map) {
    return LogbookItem(
      id: map['id'] as int,
      devicePk: map['devicePk'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      userPk: map['userPk'] as String,
      weight: map['weight'] as int,
      description: map['description'] as String,
      image: map['image'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory LogbookItem.fromJson(String source) =>
      LogbookItem.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LogbookItem(id: $id, devicePk: $devicePk, date: $date, userPk: $userPk, weight: $weight, description: $description, image: $image)';
  }

  @override
  bool operator ==(covariant LogbookItem other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.devicePk == devicePk &&
        other.date == date &&
        other.userPk == userPk;
  }

  @override
  int get hashCode {
    return id.hashCode ^ devicePk.hashCode ^ date.hashCode ^ userPk.hashCode;
  }
}

//-------------------------
class Logbook {
  List<LogbookItem> items;
  Logbook({
    required this.items,
  });

  Logbook copyWith({
    List<LogbookItem>? items,
  }) {
    return Logbook(
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'items': items.map((x) => x.toMap()).toList(),
    };
  }

  factory Logbook.fromMap(Map<String, dynamic> map) {
    return Logbook(
      items: List<LogbookItem>.from(
        (map['items'] as List<int>).map<LogbookItem>(
          (x) => LogbookItem.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Logbook.fromJson(String source) =>
      Logbook.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Logbook(items: $items)';

  @override
  bool operator ==(covariant Logbook other) {
    if (identical(this, other)) return true;

    return listEquals(other.items, items);
  }

  @override
  int get hashCode => items.hashCode;
}

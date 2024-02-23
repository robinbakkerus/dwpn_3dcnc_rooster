// ignore_for_file: constant_identifier_names

import 'package:dwpn_3dcnc_rooster/model/app_models.dart';

List<User> allUsers = [
  userJeff,
  userBill,
  userMarc,
  userElon,
];
User userBill = _buildUser(
    'BG', 'Bill Gates', 'BILL', 'robin.bakkerus@gmail.com',
    roles: 'T,A,S');
User userJeff =
    _buildUser('JB', 'Jeff Bezos', 'JEFF', 'robin.bakkerus@gmail.com');
User userElon =
    _buildUser('EM', 'Elon Musk', 'ELON', 'robin.bakkerus@gmail.com');
User userMarc =
    _buildUser('MZ', 'Mark Zuckerberg', 'MARC', 'robin.bakkerus@gmail.com');

// _builduser
User _buildUser(String pk, String fullname, String accesscode, String email,
    {String roles = 'T'}) {
  return User(
      accessCode: accesscode,
      originalAccessCode: accesscode,
      pk: pk,
      fullname: fullname,
      email: email,
      originalEmail: email,
      prefValues: [],
      roles: roles);
}

//---------------- spreadsheets
List<SpreadSheet> allSpreadsheets = [
  _spreadSheetJanuari(),
  _spreadSheetFebruari(),
  _spreadSheetMarch()
];

SpreadSheet _spreadSheetJanuari() {
  return SpreadSheet(year: 2024, month: 1);
}

SpreadSheet _spreadSheetFebruari() {
  return SpreadSheet(year: 2024, month: 2);
}

SpreadSheet _spreadSheetMarch() {
  return SpreadSheet(year: 2024, month: 3);
}

List<Device> allDevices() {
  List<Device> result = [];

  result.add(_buildDevice('PR1', 'Bamboo Lujia ', DeviceType.printer));
  result.add(_buildDevice('PR2', 'Bamboo Romeo ', DeviceType.printer));
  result.add(_buildDevice('PR3', '3d printer ', DeviceType.printer));
  result.add(_buildDevice('LAS1', 'Laser links ', DeviceType.laser));
  result.add(_buildDevice('LAS2', 'Laser rechts ', DeviceType.laser));
  result.add(_buildDevice('GRA1', 'Graveer machine ', DeviceType.engrave));

  return result;
}

Device _buildDevice(String name, String descr, DeviceType type) {
  return Device(name: name, description: descr, type: type);
}

List<WeekdaySlot> allWeekDaySlots() {
  List<WeekdaySlot> result = [];
  result
      .add(WeekdaySlot(weekday: DateTime.monday, daySlot: DaySlotEnum.morning));
  result.add(
      WeekdaySlot(weekday: DateTime.monday, daySlot: DaySlotEnum.afternoon));
  result
      .add(WeekdaySlot(weekday: DateTime.monday, daySlot: DaySlotEnum.evening));

  result.add(
      WeekdaySlot(weekday: DateTime.tuesday, daySlot: DaySlotEnum.morning));
  result.add(
      WeekdaySlot(weekday: DateTime.tuesday, daySlot: DaySlotEnum.afternoon));

  result.add(
      WeekdaySlot(weekday: DateTime.wednesday, daySlot: DaySlotEnum.morning));
  result.add(
      WeekdaySlot(weekday: DateTime.wednesday, daySlot: DaySlotEnum.afternoon));
  result.add(
      WeekdaySlot(weekday: DateTime.wednesday, daySlot: DaySlotEnum.evening));

  result.add(
      WeekdaySlot(weekday: DateTime.thursday, daySlot: DaySlotEnum.morning));
  result.add(
      WeekdaySlot(weekday: DateTime.thursday, daySlot: DaySlotEnum.afternoon));

  result
      .add(WeekdaySlot(weekday: DateTime.friday, daySlot: DaySlotEnum.morning));
  result.add(
      WeekdaySlot(weekday: DateTime.friday, daySlot: DaySlotEnum.afternoon));

  return result;
}

List<Reservation> allReservationsMaart() {
  List<Reservation> result = [];

  result.add(Reservation(
      day: 4,
      daySlotEnum: DaySlotEnum.morning,
      devicePk: 'PR1',
      userPk: userJeff.pk));
  result.add(Reservation(
      day: 4,
      daySlotEnum: DaySlotEnum.morning,
      devicePk: 'PR2',
      userPk: userBill.pk));
  result.add(Reservation(
      day: 4,
      daySlotEnum: DaySlotEnum.afternoon,
      devicePk: 'PR3',
      userPk: userJeff.pk));
  result.add(Reservation(
      day: 4,
      daySlotEnum: DaySlotEnum.morning,
      devicePk: 'PR1',
      userPk: userMarc.pk));

  return result;
}

// ignore_for_file: constant_identifier_names

import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:dwpn_3dcnc_rooster/util/app_constants.dart';

List<User> allUsers = [
  userJeff,
  userBill,
  userMarc,
  userElon,
];
User userRobin = _buildUser(
    'RB', 'Robin Bakkerus', 'REAL', 'robin.bakkerus@gmail.com',
    roles: 'T,A,S');
User userBill =
    _buildUser('BG', 'Bill Gates', 'BILL', 'robin.bakkerus@gmail.com');
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

  result.add(_buildDevice(
      DevicePK.lulliet.name, 'BambooLab lulliet ', DeviceType.printer));
  result.add(_buildDevice(
      DevicePK.romeo.name, 'BambooLab Romeo ', DeviceType.printer));
  result
      .add(_buildDevice(DevicePK.joe.name, '3d printer ', DeviceType.printer));
  result.add(
      _buildDevice(DevicePK.brownBean.name, 'Laser links ', DeviceType.laser));
  result.add(
      _buildDevice(DevicePK.grayBeam.name, 'Laser rechts ', DeviceType.laser));
  result.add(_buildDevice(
      DevicePK.cutThing.name, 'Graveer machine ', DeviceType.engrave));

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
      devicePk: DevicePK.lulliet.name,
      userPk: userJeff.pk));
  result.add(Reservation(
      day: 4,
      daySlotEnum: DaySlotEnum.morning,
      devicePk: DevicePK.romeo.name,
      userPk: userBill.pk));
  result.add(Reservation(
      day: 4,
      daySlotEnum: DaySlotEnum.afternoon,
      devicePk: DevicePK.joe.name,
      userPk: userJeff.pk));
  result.add(Reservation(
      day: 4,
      daySlotEnum: DaySlotEnum.morning,
      devicePk: DevicePK.lulliet.name,
      userPk: userMarc.pk));

  return result;
}

Logbook getLogbook() {
  Logbook logbook = Logbook(items: []);
  logbook.items.add(_buildLogbookItem());
  return logbook;
}

LogbookItem _buildLogbookItem() {
  LogbookItem item = LogbookItem(
      id: 1000,
      devicePk: DevicePK.romeo.name,
      date: DateTime.now(),
      userPk: 'BG',
      weight: 70,
      description: 'Demo model',
      image: '');
  return item;
}

// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:dwpn_3dcnc_rooster/data/populate_data.dart' as p;
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:dwpn_3dcnc_rooster/service/dbs.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';

class Simulator with AppMixin implements Dbs {
  Simulator._();
  static final Simulator instance = Simulator._();

  @override
  Future<User> createOrUpdateUser(trainer) async {
    return trainer;
  }

  @override
  Future<List<User>> getAllUsers() async {
    return p.allUsers;
  }

  @override
  Future<List<SpreadSheet>> getActiveSpreadsheets(
      {required int year, required int month}) async {
    SpreadSheet? spreadsheet = p.allSpreadsheets
        .firstWhereOrNull((e) => e.month == month && e.year == year);
    return [spreadsheet!];
  }

  @override
  Future<void> saveSpreadsheet(SpreadSheet fsSpreadsheet) async {
    return;
  }

  @override
  Future<bool> sendEmail(
      {required List<User> toList,
      required List<User> ccList,
      required String subject,
      required String html}) async {
    return true;
  }

  @override
  Future<void> saveDevices(List<Device> trainingGroups) async {}

  @override
  Future<List<Device>> getAllDevices() async {
    return p.allDevices();
  }

  @override
  Future<List<WeekdaySlot>> getAllWeekdaySlots() async {
    return p.allWeekDaySlots();
  }

  @override
  Future<void> saveReservation(Reservation reservation, bool add) async {}

  @override
  Future<void> saveWeekdaySlots(List<WeekdaySlot> weekdaySlots) async {}

  @override
  Future<Logbook> getLogbook() async {
    return getLogbook();
  }
}

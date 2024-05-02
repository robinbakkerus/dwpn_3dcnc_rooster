import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:dwpn_3dcnc_rooster/repo/dbs_simulator.dart';
import 'package:dwpn_3dcnc_rooster/repo/firestore_helper.dart';

abstract class Dbs {
  static Dbs instance = (AppData.instance.runMode == RunMode.dev)
      ? Simulator.instance as Dbs
      : FirestoreHelper.instance;

  Future<List<User>> getAllUsers();
  Future<User> createOrUpdateUser(user);
  Future<void> saveSpreadsheet(SpreadSheet spreadsheet);
  Future<List<SpreadSheet>> getActiveSpreadsheets(
      {required int year, required int month});
  Future<bool> sendEmail(
      {required List<User> toList,
      required List<User> ccList,
      required String subject,
      required String html});
  Future<void> saveDevices(List<Device> trainingGroups);
  Future<List<Device>> getAllDevices();
  Future<List<WeekdaySlot>> getAllWeekdaySlots();
  Future<void> saveWeekdaySlots(List<WeekdaySlot> weekdaySlots);
  Future<void> saveReservation(Reservation reservation, bool add);
  Future<Logbook> getLogbook();
  Future<void> addLogbookItem(LogbookItem logbookItem);
}

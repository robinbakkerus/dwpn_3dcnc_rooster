// ignore_for_file: depend_on_referenced_packages

import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:dwpn_3dcnc_rooster/util/app_helper.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';

class SpreadsheetGenerator with AppMixin {
  SpreadsheetGenerator._();
  static SpreadsheetGenerator instance = SpreadsheetGenerator._();

  //-----------------------------
  String buildSpreadsheetCellText(
      {required int day,
      required DaySlotEnum daySlotEnum,
      required String devicePk,
      required User user}) {
    String result = '';

    List<Reservation> reservations =
        _getReservationForThisCell(day, daySlotEnum, devicePk);

    if (reservations.isNotEmpty) {
      result =
          reservations.map((e) => _getFirstNameByReservation(e)).join(', ');
    } else {
      result = '';
    }
    return result;
  }

  String _getFirstNameByReservation(Reservation reservation) {
    User user = AppHelper.instance.findUserByPk(reservation.userPk);
    if (!user.isEmpty()) {
      return user.firstName();
    } else {
      return reservation.userPk;
    }
  }

  List<Reservation> _getReservationForThisCell(
      int day, DaySlotEnum daySlotEnum, String devicePk) {
    List<Reservation> reservations = AppData.instance
        .getSpreadsheet()
        .reservations
        .where((e) =>
            e.day == day &&
            e.daySlotEnum == daySlotEnum &&
            e.devicePk == devicePk)
        .toList();
    return reservations;
  }

  //---- private --
}

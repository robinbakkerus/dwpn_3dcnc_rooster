// ignore_for_file: depend_on_referenced_packages

import 'dart:math';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
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
    if (AppData.instance.getSpreadsheet().status == SpreadsheetStatus.active) {
      return _buildActiveSpreadsheetCellText(day, daySlotEnum, devicePk);
    } else {
      return _buildInProgressSpreadsheetCellText(day, daySlotEnum, devicePk);
    }
  }

  String _buildInProgressSpreadsheetCellText(
      int day, DaySlotEnum daySlotEnum, String devicePk) {
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

  String _buildActiveSpreadsheetCellText(
      int day, DaySlotEnum daySlotEnum, String devicePk) {
    String result = '';

    List<Reservation> reservations =
        _getReservationForThisCell(day, daySlotEnum, devicePk);

    if (reservations.isNotEmpty) {
      if (reservations.length == 1) {
        result = _getFirstNameByReservation(reservations[0]);
      } else {
        Reservation? rsv = reservations.firstWhereOrNull((e) => e.selected);
        if (rsv != null) {
          result = _getFirstNameByReservation(rsv);
          result += ' + ${reservations.length - 1}';
        }
      }
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

  SpreadSheet finalizeSpreadsheetReservation(SpreadSheet spreadSheet) {
    // first make reserveations : selected
    for (var r in spreadSheet.reservations) {
      r.selected = true;
    }

    // find all reservation with more than one user
    List<List<Reservation>> overBookedList =
        _findOverbooked(spreadSheet.reservations);

    for (List<Reservation> overBooked in overBookedList) {
      int idx = Random().nextInt(overBooked.length);
      for (Reservation r in overBooked) {
        r.selected = false;
      }
      overBooked[idx].selected = true;
    }

    return spreadSheet;
  }
  //---- private --

  List<List<Reservation>> _findOverbooked(List<Reservation> reservations) {
    List<List<Reservation>> result = [];

    for (Reservation r in reservations) {
      List<Reservation> overBooked = reservations
          .where((e) =>
              e.day == r.day &&
              e.daySlotEnum == r.daySlotEnum &&
              e.devicePk == r.devicePk &&
              e.userPk != r.userPk &&
              !_alreadySelected(r, result))
          .toList();
      if (overBooked.isNotEmpty) {
        overBooked.add(r);
        result.add(overBooked);
      }
    }

    return result;
  }

  //-----------------------------
  bool _alreadySelected(Reservation r, List<List<Reservation>> overbookedList) {
    for (List<Reservation> overBooked in overbookedList) {
      if (overBooked.contains(r)) {
        return true;
      }
    }

    return false;
  }
}

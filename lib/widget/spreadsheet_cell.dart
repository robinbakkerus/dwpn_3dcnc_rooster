import 'package:dwpn_3dcnc_rooster/controller/app_controler.dart';
import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/event/app_events.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';
import 'package:dwpn_3dcnc_rooster/util/spreadsheet_generator.dart';
import 'package:dwpn_3dcnc_rooster/widget/spreadsheet_daycell_dialog.dart';
import 'package:flutter/material.dart';

class SpreadsheetCell extends StatefulWidget {
  final DateTime dateTime;
  final WeekdaySlot weekDaySlot;
  final String devicePk;
  final bool isEditable;
  final Color color;
  const SpreadsheetCell(
      {required super.key,
      required this.dateTime,
      required this.weekDaySlot,
      required this.devicePk,
      required this.isEditable,
      required this.color});

  @override
  State<SpreadsheetCell> createState() => _SpreadsheetCellState();
}

//--------------------------------
class _SpreadsheetCellState extends State<SpreadsheetCell> with AppMixin {
  final _textTextCtrl = TextEditingController();
  String _cellText = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textTextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _cellText = _getCellText();
    Color borderCol =
        _cellText.contains(_userName()) ? Colors.orangeAccent : Colors.grey;
    Color backColor = _getCellBackgroundColor();
    double borderWidth = _cellText.contains(_userName()) ? 2 : 0.1;

    return InkWell(
      onTap: _showDialog() ? () => _dialogBuilder(context) : null,
      child: Container(
          width: c.w1,
          decoration: _showDialog()
              ? BoxDecoration(
                  color: backColor,
                  border: Border.all(width: borderWidth, color: borderCol))
              : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
            child: _buildCellWidget(),
          )),
    );
  }

  Widget _buildCellWidget() {
    return Text(
      _cellText,
      overflow: TextOverflow.ellipsis,
    );
  }

  Color _getCellBackgroundColor() {
    List<String> userNames = _getCellText().replaceAll(' ', '').split(', ');
    if (userNames.length > 1) {
      return Colors.grey[300]!;
    } else {
      return widget.color;
    }
  }

  // bool _isSupervisor() => AppData.instance.getUser().isSupervisor();
  String _userName() => AppData.instance.getUser().firstName();
  String _userPk() => AppData.instance.getUser().pk;

  bool _showDialog() {
    return widget.dateTime
        .isAfter(DateTime.now().add(const Duration(days: -1)));
  }

  Future<void> _dialogBuilder(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: DayCellDialogWidget(
            key: UniqueKey(),
            userName: _userName(),
            cellText: _cellText,
            devicePk: widget.devicePk,
            spreadsheetIsActive: _spreadsheetIsActive(),
          ),
        );
      },
    ).then((value) => _updateCell(value));
  }

  String _getCellText() {
    return SpreadsheetGenerator.instance.buildSpreadsheetCellText(
        day: widget.dateTime.day,
        daySlotEnum: widget.weekDaySlot.daySlot,
        devicePk: widget.devicePk,
        user: AppData.instance.getUser());
  }

  bool _spreadsheetIsActive() =>
      AppData.instance.getSpreadsheet().status == SpreadsheetStatus.active;

  //------------------------------
  void _updateCell(ReservationAction action) async {
    if (action == ReservationAction.none) {
      return;
    }

    List<Reservation> addReservations = [];
    List<Reservation> cancelReservations = [];
    _fillReservationLists(action, addReservations, cancelReservations);

    for (Reservation reservation in addReservations) {
      await AppController.instance.saveReservation(reservation, true);
    }
    for (Reservation reservation in cancelReservations) {
      await AppController.instance.saveReservation(reservation, false);
    }

    setState(() {
      _cellText = '${_userName()}, ${_getCellText()}';
    });

    if (addReservations.length > 1 || cancelReservations.length > 1) {
      AppEvents.fireSpreadsheetReady();
    }
  }

  void _fillReservationLists(ReservationAction action,
      List<Reservation> addReservations, List<Reservation> cancelReservations) {
    if (action == ReservationAction.addDay) {
      addReservations.add(_buildReservation(widget.dateTime));
    } else if (action == ReservationAction.cancelDay) {
      cancelReservations.add(_buildReservation(widget.dateTime));
    } else if (action == ReservationAction.addRange) {
      DateTime startDate = widget.dateTime;
      while (startDate.month == widget.dateTime.month) {
        addReservations.add(_buildReservation(startDate));
        startDate = startDate.add(const Duration(days: 7));
      }
    } else if (action == ReservationAction.cancelRange) {
      DateTime startDate = widget.dateTime;
      while (startDate.month == widget.dateTime.month) {
        cancelReservations.add(_buildReservation(startDate));
        startDate = startDate.add(const Duration(days: 7));
      }
    }
  }

  Reservation _buildReservation(DateTime date) {
    return Reservation(
        day: date.day,
        daySlotEnum: widget.weekDaySlot.daySlot,
        devicePk: widget.devicePk,
        userPk: _userPk());
  }
}

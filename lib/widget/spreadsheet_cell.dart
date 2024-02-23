import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/event/app_events.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';
import 'package:dwpn_3dcnc_rooster/util/spreadsheet_generator.dart';
import 'package:flutter/material.dart';

class SpreadsheetCell extends StatefulWidget {
  final DateTime dateTime;
  final WeekdaySlot weekDaySlot;
  final String devicePk;
  final bool isEditable;
  const SpreadsheetCell(
      {required super.key,
      required this.dateTime,
      required this.weekDaySlot,
      required this.devicePk,
      required this.isEditable});

  @override
  State<SpreadsheetCell> createState() => _SpreadsheetCellState();
}

//--------------------------------
class _SpreadsheetCellState extends State<SpreadsheetCell> with AppMixin {
  final _textTextCtrl = TextEditingController();

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
    String cellText = _getCellText();
    Color borderCol =
        cellText.contains(_userName()) ? Colors.orangeAccent : Colors.grey;
    double borderWidth = cellText.contains(_userName()) ? 2 : 0.1;

    return InkWell(
      onTap: _showDialog() ? () => _dialogBuilder(context) : null,
      child: Container(
          width: c.w1,
          decoration: _showDialog()
              ? BoxDecoration(
                  border: Border.all(width: borderWidth, color: borderCol))
              : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
            child: Text(
              cellText,
              overflow: TextOverflow.ellipsis,
            ),
          )),
    );
  }

  // bool _isSupervisor() => AppData.instance.getUser().isSupervisor();
  String _userName() => AppData.instance.getUser().firstName();

  bool _showDialog() {
    // // String txt = widget.sheetRow.rowCells[_groupIndex].text;
    // return txt.isNotEmpty && _isEditable();
    return true;
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            height: AppData.instance.screenHeight * 0.2,
            width: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                wh.verSpace(15),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                  child: _askReservation(),
                ),
                wh.verSpace(15),
                _buildYesAndCancelButtons(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _askReservation() {
    String text =
        'Hallo ${_userName()} wil je de ${widget.devicePk} reserveren?';
    return Text(text);
  }

  String _getCellText() {
    return SpreadsheetGenerator.instance.buildSpreadsheetCellText(
        day: widget.dateTime.day,
        daySlotEnum: widget.weekDaySlot.daySlot,
        devicePk: widget.devicePk,
        user: AppData.instance.getUser());
  }

  // bool _isSameTrainer() {
  //   String name = _getCellText();
  //   User trainer = AppHelper.instance.findUserByFirstName(name);
  //   if (!trainer.isEmpty()) {
  //     return trainer.pk == AppData.instance.getUser().pk;
  //   } else {
  //     return false;
  //   }
  // }

  Widget _buildYesAndCancelButtons(BuildContext context) {
    return Row(
      children: [
        TextButton(
            onPressed: () {
              AppEvents.fireReservationEvent(
                  day: widget.dateTime.day,
                  daySlotEnum: widget.weekDaySlot.daySlot,
                  devicePk: widget.devicePk,
                  user: AppData.instance.getUser(),
                  addReservation: _addReservation());

              Navigator.of(context, rootNavigator: true)
                  .pop(); // dismisses only the dialog and returns nothing
            },
            child: const Text("Ja", style: TextStyle(color: Colors.green))),
        wh.horSpace(10),
        TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true)
                  .pop(); // dismisses only the dialog and returns nothing
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.red))),
      ],
    );
  }

  bool _addReservation() {
    return true;
  }
}

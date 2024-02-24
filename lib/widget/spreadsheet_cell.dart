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
            child: Text(
              _cellText,
              overflow: TextOverflow.ellipsis,
            ),
          )),
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
            height: AppData.instance.screenHeight * 0.3,
            width: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                wh.verSpace(15),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                  child: __showOtherReservation(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                  child: _askReservation(),
                ),
                wh.verSpace(10),
                _buildYesAndCancelButtons(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _askReservation() {
    if (_reservedByMe()) {
      String text =
          'Hallo ${_userName()}; wil je de  reservering voor de ${widget.devicePk} annuleren?';
      return Text(text);
    } else {
      String text =
          'Hallo ${_userName()}; wil je de ${widget.devicePk} reserveren?';
      return Text(text);
    }
  }

  Widget __showOtherReservation() {
    if (_otherReservations().isNotEmpty) {
      String txt = '''Deze is al gereserveerd door: ${_otherReservations()}
      ''';
      return Text(txt);
    } else {
      return Container();
    }
  }

  String _otherReservations() {
    String txt = _getCellText();
    if (txt.isNotEmpty) {
      List<String> list = txt.replaceAll(' ', '').split(',');
      List<String> result = [];
      for (String name in list) {
        if (name != _userName()) {
          result.add(name);
        }
      }
      return result.join(', ');
    } else {
      return '';
    }
  }

  bool _reservedByMe() {
    String txt = _getCellText();
    if (txt.isNotEmpty) {
      List<String> list = txt.replaceAll(' ', '').split(',');
      for (String name in list) {
        if (name == _userName()) {
          return true;
        }
      }
    }
    return false;
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
              _updateCell();

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

  void _updateCell() {
    setState(() {
      _cellText = '${_userName()}, ${_getCellText()}';
    });
  }

  bool _addReservation() {
    return _reservedByMe() ? false : true;
  }
}

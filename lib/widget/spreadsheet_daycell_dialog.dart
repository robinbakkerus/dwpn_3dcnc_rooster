import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';
import 'package:flutter/material.dart';

class DayCellDialogWidget extends StatefulWidget {
  final String userName;
  final String cellText;
  final bool spreadsheetIsActive;
  final String devicePk;
  const DayCellDialogWidget(
      {super.key,
      required this.userName,
      required this.cellText,
      required this.spreadsheetIsActive,
      required this.devicePk});

  @override
  State<DayCellDialogWidget> createState() => _DayCellDialogWidgetState();
}

///--------------------------------
class _DayCellDialogWidgetState extends State<DayCellDialogWidget>
    with AppMixin {
  bool _addYesButton = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        height: AppData.instance.screenHeight * 0.4,
        width: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            wh.verSpace(5),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 4, 4),
              child: __showOtherReservation(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 4, 4),
              child: _askReservation(),
            ),
            wh.verSpace(1),
            _buildSelectRangeRadios(),
            wh.verSpace(5),
            _buildYesAndCancelButtons(context),
            wh.verSpace(5),
          ],
        ),
      ),
    );
  }

  Widget _buildYesAndCancelButtons(BuildContext context) {
    return Row(
      children: [
        _addYesButton ? _buildYesButton(context) : Container(),
        wh.horSpace(10),
        _buildCancelButton(context),
      ],
    );
  }

  TextButton _buildCancelButton(BuildContext context) {
    return TextButton(
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop(ReservationAction
              .none); // dismisses only the dialog and returns nothing
        },
        child: const Text("Cancel", style: TextStyle(color: Colors.red)));
  }

  TextButton _buildYesButton(BuildContext context) {
    ReservationAction action = ReservationAction.none;
    if (_reservedByMe()) {
      action = _selectedRange == _rangeOptions[0]
          ? ReservationAction.cancelDay
          : ReservationAction.cancelRange;
    } else {
      action = _selectedRange == _rangeOptions[0]
          ? ReservationAction.addDay
          : ReservationAction.addRange;
    }

    return TextButton(
        onPressed: () {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pop(action); // dismisses only the dialog and returns nothing
        },
        child: const Text("Ja", style: TextStyle(color: Colors.green)));
  }

  Widget _askReservation() {
    _addYesButton = true;
    String prefix = 'Hallo ${widget.userName} :\n';
    String text = '';
    if (_reservedByMe()) {
      text = '$prefix Wil je de ${widget.devicePk} annuleren?';
    } else if (widget.cellText.isEmpty) {
      text = '$prefix Wil je de ${widget.devicePk} reserveren?';
    } else if (_otherReservations().isNotEmpty && widget.spreadsheetIsActive) {
      _addYesButton = false;
      text = '$prefix Dit timeslot is al gereserveerd en schema is definitief!';
    } else if (_otherReservations().isNotEmpty && !widget.spreadsheetIsActive) {
      text = '$prefix Wil je de ${widget.devicePk} reserveren?';
    } else {
      return Container();
    }

    return Text(text, style: const TextStyle(fontSize: 16));
  }

  Widget __showOtherReservation() {
    if (_otherReservations().isNotEmpty) {
      String txt = '''Deze is al gereserveerd door: ${_otherReservations()}
      ''';

      Color col = widget.spreadsheetIsActive ? Colors.red[300]! : Colors.black;
      return Text(txt, style: TextStyle(fontSize: 16, color: col));
    } else {
      return Container();
    }
  }

  String _otherReservations() {
    String txt = widget.cellText;
    if (txt.isNotEmpty) {
      List<String> list = txt.replaceAll(' ', '').split(',');
      List<String> result = [];
      for (String name in list) {
        if (name != widget.userName) {
          result.add(name);
        }
      }
      return result.join(', ');
    } else {
      return '';
    }
  }

  bool _reservedByMe() {
    String txt = widget.cellText;
    if (txt.isNotEmpty) {
      List<String> list = txt.replaceAll(' ', '').split(',');
      for (String name in list) {
        if (name == widget.userName) {
          return true;
        }
      }
    }
    return false;
  }

  final List<String> _rangeOptions = ['Alleen dit slot', 'Alle in deze maand'];
  String _selectedRange = 'Alleen dit slot';
  //--------------------------------
  Widget _buildSelectRangeRadios() {
    if (_otherReservations().isNotEmpty && widget.spreadsheetIsActive) {
      return Container();
    }

    return Expanded(
      child: SizedBox(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioListTile(
              title: Text(_rangeOptions[0]),
              value: _rangeOptions[0],
              groupValue: _selectedRange,
              onChanged: (value) => setState(() {
                _selectedRange = value.toString();
              }),
            ),
            RadioListTile(
              title: Text(_rangeOptions[1]),
              value: _rangeOptions[1],
              groupValue: _selectedRange,
              onChanged: (value) => setState(() {
                _selectedRange = value.toString();
              }),
            )
          ],
        ),
      ),
    );
  }
}

enum ReservationAction {
  addDay,
  addRange,
  cancelDay,
  cancelRange,
  none;
}

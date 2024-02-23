import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:dwpn_3dcnc_rooster/util/app_helper.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';
import 'package:flutter/material.dart';

class SpreadsheetDayColumn extends StatefulWidget {
  final DateTime dateTime;
  final WeekdaySlot weekdaySlot;
  const SpreadsheetDayColumn(
      {required super.key, required this.dateTime, required this.weekdaySlot});

  @override
  State<SpreadsheetDayColumn> createState() => _SpreadsheetDayColumnState();
}

//--------------------------------
class _SpreadsheetDayColumnState extends State<SpreadsheetDayColumn>
    with AppMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets insets = AppHelper.instance.isWindows()
        ? const EdgeInsets.fromLTRB(5, 2, 5, 2)
        : const EdgeInsets.fromLTRB(2, 2, 2, 2);

    Decoration? decoration = _isEditable()
        ? BoxDecoration(border: Border.all(width: 0.1, color: Colors.grey))
        : null;
    return InkWell(
      onTap: _isEditable() ? () {} : null,
      child: Container(
          decoration: decoration,
          child: Padding(
            padding: insets,
            child: Text(
              _getText(),
              // AppHelper.instance.getSimpleDayString(widget.timeSlot.date),
              overflow: TextOverflow.ellipsis,
            ),
          )),
    );
  }

  String _getText() {
    String result = widget.weekdaySlot.daySlot.shortName();
    result += ' - ${AppHelper.instance.getSimpleDayString(widget.dateTime)}';
    return result;
  }

  bool _isEditable() {
    return AppData.instance.getUser().isSupervisor() &&
        AppData.instance.getSpreadsheet().status != SpreadsheetStatus.active;
  }
}
